package api

import (
	"context"
	"errors"
	"math/big"
	"net/http"
	"regexp"
	"slices"
	"strings"
	"unicode"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"balnana/internal/config"
	"balnana/internal/domain"
	"balnana/internal/importer"
)

// errDryRun rolls back a preview import.
var errDryRun = errors.New("dry run")

func importFileError(problem string) error {
	return &apiError{status: http.StatusBadRequest, code: "import_file", params: map[string]any{"problem": problem}}
}

func importRowError(line int, problem string) error {
	return &apiError{status: http.StatusBadRequest, code: "import_row", params: map[string]any{"line": line, "problem": problem}}
}

// ImportGroup creates a group from another app's export. With dryRun it
// does the same work, reports what the group would hold and keeps nothing.
func (s *Server) ImportGroup(ctx context.Context, req ImportGroupRequestObject) (ImportGroupResponseObject, error) {
	var creator *user
	if s.conf().AuthMode == config.AuthModeAccounts {
		u, err := s.requireUser(ctx)
		if err != nil {
			return nil, err
		}
		creator = u
	}
	in := req.Body
	dryRun := in.DryRun != nil && *in.DryRun
	if in.Format != SettleUp {
		return nil, badRequest("invalid_format")
	}
	file, err := importer.SettleUp(in.File)
	var ie *importer.Error
	if errors.As(err, &ie) {
		if ie.Line == 0 {
			return nil, importFileError(ie.Problem)
		}
		return nil, importRowError(ie.Line, ie.Problem)
	}
	if err != nil {
		return nil, err
	}

	if len(file.People) > maxMembers {
		return nil, badRequest("too_many_members")
	}
	names := make([]string, len(file.People))
	for i, p := range file.People {
		n, err := cleanName(importName(p))
		if err != nil {
			return nil, importFileError("names")
		}
		for _, other := range names[:i] {
			if strings.EqualFold(other, n) {
				return nil, importFileError("names")
			}
		}
		names[i] = n
	}
	me := -1
	if in.Me != nil && strings.TrimSpace(*in.Me) != "" {
		want := importName(*in.Me)
		for i, n := range names {
			if strings.EqualFold(n, want) || strings.EqualFold(file.People[i], strings.TrimSpace(*in.Me)) {
				me = i
			}
		}
		if me < 0 {
			return nil, badRequest("import_me")
		}
	} else if creator != nil && !dryRun {
		return nil, badRequest("import_me")
	}
	owner := max(me, 0)

	// A preview may come before the name is chosen.
	name := "Import"
	raw := ""
	if in.Name != nil {
		raw = *in.Name
	}
	if n, err := cleanName(raw); err == nil {
		name = n
	} else if !dryRun {
		return nil, err
	}
	untitled := "Untitled"
	if in.Untitled != nil {
		t, ok := cleanText(*in.Untitled, 1, maxTitleLen)
		if !ok || strings.Contains(t, "\n") {
			return nil, badRequest("invalid_title")
		}
		untitled = t
	}

	currency, digits, err := importCurrency(file.Entries)
	if err != nil {
		return nil, err
	}

	var preview ImportPreview
	var out Group
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := scanGroup(tx.QueryRow(ctx, `
			insert into groups (token, name, currency, minor_digits, link_access)
			values ($1, $2, $3, $4, $5)
			returning `+groupColumns, newToken(), name, currency, digits, creator == nil))
		if err != nil {
			return err
		}
		// Splits give a leftover cent by member id when it is a tie, so ids
		// that sort in file order make the preview and the import agree.
		ordered := make([]string, len(names))
		for i := range ordered {
			ordered[i] = uuid.NewString()
		}
		slices.Sort(ordered)
		ids := make(map[string]string, len(names))
		for i, n := range names {
			id := ordered[i]
			var userID *string
			if i == me && creator != nil {
				userID = &creator.id
			}
			// clock_timestamp keeps the file's order; now() is fixed per transaction.
			err := tx.QueryRow(ctx, `
				insert into members (id, group_id, display_name, is_owner, user_id, created_at)
				values ($1, $2, $3, $4, $5, clock_timestamp()) returning id::text`, id, g.id, n, i == owner, userID).Scan(&id)
			if err != nil {
				return err
			}
			ids[file.People[i]] = id
		}
		actor := ids[file.People[owner]]
		if err := logActivity(ctx, tx, g.id, &actor, "group.created", nil, map[string]any{"name": name}); err != nil {
			return err
		}

		categories := map[string]string{}
		rows, err := tx.Query(ctx, `select id, emoji from categories`)
		if err != nil {
			return err
		}
		for rows.Next() {
			var id, emoji string
			if err := rows.Scan(&id, &emoji); err != nil {
				return err
			}
			categories[plainEmoji(emoji)] = id
		}
		if err := rows.Err(); err != nil {
			return err
		}

		count := 0
		for _, e := range file.Entries {
			kind, input, problem := importInput(e, currency, digits, untitled, ids, categories)
			if problem == "skip" {
				preview.Skipped++
				continue
			}
			if problem != "" {
				return importRowError(e.Line, problem)
			}
			d, err := validateExpense(ctx, tx, g, kind, input)
			if err != nil {
				var ae *apiError
				var dc domain.Code
				switch {
				case errors.As(err, &ae):
					return importRowError(e.Line, ae.code)
				case errors.As(err, &dc):
					return importRowError(e.Line, string(dc))
				}
				return err
			}
			if kind == kindExpense {
				if e.Type == "income" {
					d.transactionType = "income"
				} else if importReceived(e, currency, digits) {
					d.transactionType = "refund"
				}
			}
			if _, err := storeExpense(ctx, tx, g, &actor, d); err != nil {
				return err
			}
			count++
			if kind == kindPayment {
				preview.Payments++
			} else {
				preview.Expenses++
			}
			if preview.From == nil || e.Time.Before(*preview.From) {
				preview.From = &e.Time
			}
			if preview.To == nil || e.Time.After(*preview.To) {
				preview.To = &e.Time
			}
		}
		if err := logActivity(ctx, tx, g.id, &actor, "group.imported", nil, map[string]any{"count": count, "from": "Settle Up"}); err != nil {
			return err
		}
		if err := s.resolveAccess(ctx, tx, g); err != nil {
			return err
		}
		out, err = loadGroup(ctx, tx, g)
		if err != nil || !dryRun {
			return err
		}
		preview.Currency = currency
		preview.MinorDigits = digits
		preview.Members = make([]ImportMember, len(out.Members))
		for i, m := range out.Members {
			preview.Members[i] = ImportMember{Name: m.Name, Balance: m.Balance}
		}
		return errDryRun
	})
	if dryRun && errors.Is(err, errDryRun) {
		return ImportGroup200JSONResponse(preview), nil
	}
	if err != nil {
		return nil, err
	}
	return ImportGroup201JSONResponse(out), nil
}

// importName makes a name from another app fit ours: one line, not too long.
func importName(s string) string {
	s = strings.Join(strings.FieldsFunc(s, func(r rune) bool { return unicode.IsSpace(r) || unicode.IsControl(r) }), " ")
	if r := []rune(s); len(r) > maxNameLen {
		s = strings.TrimSpace(string(r[:maxNameLen]))
	}
	return s
}

func plainEmoji(s string) string { return strings.ReplaceAll(strings.TrimSpace(s), "️", "") }

// importCurrency picks the group's currency: the one most rows are written
// in without an exchange rate. Its minor digits are the usual ones, or more
// when the amounts need them.
func importCurrency(entries []importer.Entry) (string, int, error) {
	counts := map[string]int{}
	currency := ""
	for _, e := range entries {
		if e.Rate != "" || !currencyCode.MatchString(e.Currency) {
			continue
		}
		counts[e.Currency]++
		if counts[e.Currency] > counts[currency] {
			currency = e.Currency
		}
	}
	if currency == "" {
		return "", 0, importFileError("currency")
	}
	digits := defaultDigits(currency)
	for _, e := range entries {
		if e.Currency != currency {
			continue
		}
		for _, p := range e.Payers {
			if _, frac, ok := strings.Cut(p.Amount, "."); ok {
				digits = max(digits, min(len(strings.TrimRight(frac, "0")), domain.MaxDigits))
			}
		}
	}
	return currency, digits, nil
}

// defaultDigits mirrors the app's table of currencies without two decimals.
func defaultDigits(currency string) int {
	switch currency {
	case "BIF", "CLP", "DJF", "GNF", "ISK", "JPY", "KMF", "KRW", "PYG", "RWF", "UGX", "UYI", "VND", "VUV", "XAF", "XOF", "XPF":
		return 0
	case "BHD", "IQD", "JOD", "KWD", "LYD", "OMR", "TND":
		return 3
	}
	return 2
}

var decimalNumber = regexp.MustCompile(`^[-+]?(\d{1,18}(\.\d{0,18})?|\.\d{1,18})$`)

// toMinor reads a decimal from an export, rounding it half away from zero
// to digits places.
func toMinor(s string, digits int) (int64, bool) {
	if !decimalNumber.MatchString(s) {
		return 0, false
	}
	r, ok := new(big.Rat).SetString(s)
	if !ok {
		return 0, false
	}
	r.Mul(r, new(big.Rat).SetInt(new(big.Int).Exp(big.NewInt(10), big.NewInt(int64(digits)), nil)))
	neg := r.Sign() < 0
	r.Abs(r)
	q, m := new(big.Int).QuoRem(r.Num(), r.Denom(), new(big.Int))
	if m.Lsh(m, 1).Cmp(r.Denom()) >= 0 {
		q.Add(q, big.NewInt(1))
	}
	if !q.IsInt64() || q.Int64() > domain.MaxMinor {
		return 0, false
	}
	if neg {
		return -q.Int64(), true
	}
	return q.Int64(), true
}

// importReceived reads the sign of the amounts importInput uses for payers.
// That function has already validated their signs and conversion counts.
func importReceived(e importer.Entry, currency string, digits int) bool {
	if e.Type == "income" {
		return true
	}
	if e.Currency != currency {
		for _, amount := range e.Converted {
			if v, _ := toMinor(amount, digits); v < 0 {
				return true
			}
		}
	} else {
		for _, p := range e.Payers {
			if v, _ := toMinor(p.Amount, digits); v < 0 {
				return true
			}
		}
	}
	return false
}

// share is one person's amount on a row, summed when a name repeats.
type share struct {
	id    string
	value int64
}

func addTo(list []share, id string, v int64) []share {
	for i := range list {
		if list[i].id == id {
			list[i].value += v
			return list
		}
	}
	return append(list, share{id, v})
}

// importInput turns one row into an expense or payment. The problem is
// "skip" for rows that move no money.
func importInput(e importer.Entry, currency string, digits int, untitled string, ids, categories map[string]string) (string, ExpenseInput, string) {
	// What each payer paid, in the group's currency.
	var paid []share
	switch {
	case e.Currency == currency:
		for _, p := range e.Payers {
			v, ok := toMinor(p.Amount, digits)
			if !ok {
				return "", ExpenseInput{}, "amount"
			}
			paid = addTo(paid, ids[p.Name], v)
		}
	case e.Rate == "":
		return "", ExpenseInput{}, "currency"
	case len(e.Converted) == len(e.Payers):
		for i, p := range e.Payers {
			v, ok := toMinor(e.Converted[i], digits)
			if !ok {
				return "", ExpenseInput{}, "amount"
			}
			paid = addTo(paid, ids[p.Name], v)
		}
	case len(e.Converted) == 1:
		total, ok := toMinor(e.Converted[0], digits)
		if !ok {
			return "", ExpenseInput{}, "amount"
		}
		var weights []share
		for _, p := range e.Payers {
			w, ok := toMinor(p.Amount, 4)
			if !ok {
				return "", ExpenseInput{}, "amount"
			}
			weights = addTo(weights, ids[p.Name], w)
		}
		if total == 0 {
			return "", ExpenseInput{}, "skip"
		}
		for _, w := range weights {
			if (w.value < 0) != (total < 0) && w.value != 0 {
				return "", ExpenseInput{}, "amount"
			}
		}
		amounts, ok := spread(abs(total), digits, weights)
		if !ok {
			return "", ExpenseInput{}, "amount"
		}
		for _, w := range weights {
			paid = addTo(paid, w.id, sign(total)*amounts[w.id])
		}
	default:
		return "", ExpenseInput{}, "counts"
	}
	var total int64
	for _, p := range paid {
		total += p.value
	}
	if total == 0 {
		return "", ExpenseInput{}, "skip"
	}
	for _, p := range paid {
		if p.value != 0 && (p.value < 0) != (total < 0) {
			return "", ExpenseInput{}, "amount"
		}
	}
	// A refund or income: money came in. Whoever it is for "paid" it, and
	// those who received it are owed nothing more and nothing less.
	received := e.Type == "income" || total < 0
	total = abs(total)

	// Who it is for, by weight, and the exact amounts when they add up.
	var weights, exact []share
	exactOK := e.Currency == currency
	for _, p := range e.ForWhom {
		w, ok := toMinor(p.Amount, 4)
		if !ok {
			return "", ExpenseInput{}, "amount"
		}
		weights = addTo(weights, ids[p.Name], abs(w))
		v, ok := toMinor(p.Amount, digits)
		exactOK = exactOK && ok
		exact = addTo(exact, ids[p.Name], abs(v))
	}
	var sum int64
	for _, x := range exact {
		sum += x.value
	}
	exactOK = exactOK && sum == total

	title := strings.Join(strings.FieldsFunc(e.Purpose, func(r rune) bool { return unicode.IsSpace(r) || unicode.IsControl(r) }), " ")
	if r := []rune(title); len(r) > maxTitleLen {
		title = strings.TrimSpace(string(r[:maxTitleLen]))
	}
	in := ExpenseInput{Title: title, OccurredAt: e.Time}
	if id, ok := categories[plainEmoji(e.Category)]; ok && plainEmoji(e.Category) != "" {
		in.CategoryId = &id
	}
	in.Amount = domain.FormatAmount(total, digits)

	if e.Type == "transfer" {
		var from, to []share
		for _, p := range paid {
			if p.value != 0 {
				from = append(from, p)
			}
		}
		for _, w := range weights {
			if w.value != 0 {
				to = append(to, w)
			}
		}
		if len(from) != 1 || len(to) != 1 || from[0].id == to[0].id {
			return "", ExpenseInput{}, "transfer"
		}
		if received {
			from, to = to, from
		}
		v := in.Amount
		in.Payers = []PayerInput{{MemberId: from[0].id, Amount: in.Amount}}
		in.SplitMethod = SplitMethod(domain.SplitExact)
		in.Splits = []Share{{MemberId: to[0].id, Value: &v}}
		return kindPayment, in, ""
	}

	if title == "" {
		in.Title = untitled
	}
	var people []share
	for _, w := range weights {
		if w.value != 0 {
			people = append(people, w)
		}
	}
	if len(people) == 0 {
		// No amounts at all: count everyone once.
		for _, w := range weights {
			people = append(people, share{w.id, 1})
		}
	}
	equal := true
	for _, p := range people {
		equal = equal && p.value == people[0].value
	}

	if received {
		var owed map[string]int64
		if exactOK {
			owed = make(map[string]int64, len(exact))
			for _, x := range exact {
				owed[x.id] = x.value
			}
		} else {
			var ok bool
			if owed, ok = spread(total, digits, people); !ok {
				return "", ExpenseInput{}, "amount"
			}
		}
		for _, p := range people {
			if owed[p.id] > 0 {
				in.Payers = append(in.Payers, PayerInput{MemberId: p.id, Amount: domain.FormatAmount(owed[p.id], digits)})
			}
		}
		in.SplitMethod = SplitMethod(domain.SplitExact)
		for _, p := range paid {
			if p.value != 0 {
				v := domain.FormatAmount(abs(p.value), digits)
				in.Splits = append(in.Splits, Share{MemberId: p.id, Value: &v})
			}
		}
		return kindExpense, in, ""
	}

	for _, p := range paid {
		if p.value != 0 {
			in.Payers = append(in.Payers, PayerInput{MemberId: p.id, Amount: domain.FormatAmount(p.value, digits)})
		}
	}
	switch {
	case equal:
		in.SplitMethod = SplitMethod(domain.SplitEqual)
		for _, p := range people {
			in.Splits = append(in.Splits, Share{MemberId: p.id})
		}
	case exactOK:
		in.SplitMethod = SplitMethod(domain.SplitExact)
		for _, x := range exact {
			v := domain.FormatAmount(x.value, digits)
			in.Splits = append(in.Splits, Share{MemberId: x.id, Value: &v})
		}
	default:
		in.SplitMethod = SplitMethod(domain.SplitShares)
		for _, p := range people {
			v := domain.FormatAmount(p.value, 4)
			in.Splits = append(in.Splits, Share{MemberId: p.id, Value: &v})
		}
	}
	return kindExpense, in, ""
}

// spread divides total by weight (4 decimals); zero weights get nothing.
func spread(total int64, digits int, weights []share) (map[string]int64, bool) {
	parts := make([]domain.Part, 0, len(weights))
	for _, w := range weights {
		if w.value != 0 {
			parts = append(parts, domain.Part{Member: w.id, Value: domain.FormatAmount(abs(w.value), 4)})
		}
	}
	if len(parts) == 0 {
		return nil, false
	}
	out, err := domain.Split(total, digits, domain.SplitShares, parts)
	return out, err == nil
}

func abs(v int64) int64 {
	if v < 0 {
		return -v
	}
	return v
}

func sign(v int64) int64 {
	if v < 0 {
		return -1
	}
	return 1
}
