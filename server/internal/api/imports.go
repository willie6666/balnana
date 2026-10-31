package api

import (
	"context"
	"errors"
	"math/big"
	"net/http"
	"regexp"
	"slices"
	"strings"
	"time"
	"unicode"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"balnana/internal/config"
	"balnana/internal/domain"
	"balnana/internal/importer"
)

// importSlots bounds the imports running at once: each holds its file's rows
// in memory, and one being stored a database connection for all of them.
var importSlots = make(chan struct{}, 2)

// importWait is how long an import may wait for its turn before it is turned
// away as busy.
var importWait = 30 * time.Second

func importFileError(problem string) error {
	return &apiError{status: http.StatusBadRequest, code: "import_file", params: map[string]any{"problem": problem}}
}

func importRowError(line int, problem string) error {
	return &apiError{status: http.StatusBadRequest, code: "import_row", params: map[string]any{"line": line, "problem": problem}}
}

// ImportGroup creates a group from another app's export. With dryRun it
// checks every row the same way and reports what the group would hold,
// without touching the database.
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
	// Before the file is read, as that is the work: one that fails counts too.
	if err := s.limitCreates(ctx); err != nil {
		return nil, err
	}
	wait := time.NewTimer(importWait)
	defer wait.Stop()
	select {
	case importSlots <- struct{}{}:
		defer func() { <-importSlots }()
	case <-wait.C:
		return nil, &apiError{status: http.StatusServiceUnavailable, code: "busy"}
	case <-ctx.Done():
		return nil, ctx.Err()
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
	categories, err := builtInCategories(ctx, s.db)
	if err != nil {
		return nil, err
	}
	// Splits give a leftover cent by member id when it is a tie, so ids
	// that sort in file order make the preview and the import agree.
	ordered := make([]string, len(names))
	for i := range ordered {
		ordered[i] = uuid.NewString()
	}
	slices.Sort(ordered)
	ids := make(map[string]string, len(names))
	for i, id := range ordered {
		ids[file.People[i]] = id
	}
	rows := importRows{file: file, currency: currency, digits: digits, untitled: untitled, ids: ids, categories: categories}

	if dryRun {
		err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
			_, err := s.checkNewGroup(ctx, tx, creator, len(names))
			return err
		})
		if err != nil {
			return nil, err
		}
		members := make([]member, len(names))
		for i, n := range names {
			members[i] = member{id: ordered[i], name: n}
		}
		nets := map[string]int64{}
		g := &group{currency: currency, digits: digits}
		_, preview, err := rows.check(ctx, g, members, func(d *expenseData) error {
			for id, v := range d.payers {
				nets[id] += v
			}
			for id, v := range d.splits {
				nets[id] -= v
			}
			return nil
		})
		if err != nil {
			return nil, err
		}
		preview.Currency = currency
		preview.MinorDigits = digits
		preview.Members = make([]ImportMember, len(names))
		for i, m := range members {
			preview.Members[i] = ImportMember{Name: m.name, Balance: domain.FormatAmount(nets[m.id], digits)}
		}
		return ImportGroup200JSONResponse(preview), nil
	}

	var out Group
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		sponsor, err := s.checkNewGroup(ctx, tx, creator, len(names))
		if err != nil {
			return err
		}
		g, err := scanGroup(tx.QueryRow(ctx, `
			insert into groups (token, name, currency, minor_digits, link_access, sponsor_user_id)
			values ($1, $2, $3, $4, $5, $6)
			returning `+groupColumns, newToken(), name, currency, digits, creator == nil, sponsor))
		if err != nil {
			return err
		}
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
		}
		actor := ids[file.People[owner]]
		if err := logActivity(ctx, tx, g.id, &actor, "group.created", nil, map[string]any{"name": name}); err != nil {
			return err
		}

		members, err := groupMembers(ctx, tx, g.id)
		if err != nil {
			return err
		}
		count, _, err := rows.check(ctx, g, members, func(d *expenseData) error {
			_, err := storeExpense(ctx, tx, g, &actor, d)
			return err
		})
		if err != nil {
			return err
		}
		if err := logActivity(ctx, tx, g.id, &actor, "group.imported", nil, map[string]any{"count": count, "from": "Settle Up"}); err != nil {
			return err
		}
		if err := s.resolveAccess(ctx, tx, g); err != nil {
			return err
		}
		out, err = loadGroup(ctx, tx, g)
		return err
	})
	if err != nil {
		return nil, err
	}
	return ImportGroup201JSONResponse(out), nil
}

// builtInCategories maps the emoji of the categories every group has to their ids.
func builtInCategories(ctx context.Context, q querier) (map[string]string, error) {
	rows, err := q.Query(ctx, `select id, emoji from categories where group_id is null`)
	if err != nil {
		return nil, err
	}
	out := map[string]string{}
	var id, emoji string
	_, err = pgx.ForEachRow(rows, []any{&id, &emoji}, func() error {
		out[plainEmoji(emoji)] = id
		return nil
	})
	return out, err
}

// importRows is what turning a file's rows into expenses takes.
type importRows struct {
	file       *importer.File
	currency   string
	digits     int
	untitled   string
	ids        map[string]string // people in the file to member ids
	categories map[string]string
}

// check validates the rows in order and hands each that moves money to keep,
// returning how many there were and what they come to. It asks nothing of the
// database: the members are given, and the categories are those it was given.
func (r importRows) check(ctx context.Context, g *group, members []member, keep func(*expenseData) error) (int, ImportPreview, error) {
	var preview ImportPreview
	count := 0
	var total int64 // what the new group's entries add up to, see maxGroupTotal
	for _, e := range r.file.Entries {
		kind, input, problem := importInput(e, r.currency, r.digits, r.untitled, r.ids, r.categories)
		if problem == "skip" {
			preview.Skipped++
			continue
		}
		if problem != "" {
			return 0, preview, importRowError(e.Line, problem)
		}
		category := input.CategoryId
		input.CategoryId = nil
		d, err := validateExpense(ctx, nil, g, kind, input, members)
		if err != nil {
			var ae *apiError
			var dc domain.Code
			switch {
			case errors.As(err, &ae):
				return 0, preview, importRowError(e.Line, ae.code)
			case errors.As(err, &dc):
				return 0, preview, importRowError(e.Line, string(dc))
			}
			return 0, preview, err
		}
		d.category = category
		if total > maxGroupTotal-d.amount {
			return 0, preview, importRowError(e.Line, string(domain.ErrAmountTooLarge))
		}
		total += d.amount
		if kind == kindExpense {
			if e.Type == "income" {
				d.transactionType = "income"
			} else if importReceived(e, r.currency, r.digits) {
				d.transactionType = "refund"
			}
		}
		if err := keep(d); err != nil {
			return 0, preview, err
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
	return count, preview, nil
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
	digits := domain.CurrencyDigits(currency)
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

// addTo adds v to id's value, failing when that would pass what any amount
// may be, so a name repeated on many rows cannot overflow it.
func addTo(list []share, id string, v int64) ([]share, bool) {
	for i := range list {
		if list[i].id == id {
			sum := list[i].value + v
			if abs(sum) > domain.MaxMinor {
				return list, false
			}
			list[i].value = sum
			return list, true
		}
	}
	return append(list, share{id, v}), true
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
			if paid, ok = addTo(paid, ids[p.Name], v); !ok {
				return "", ExpenseInput{}, "amount"
			}
		}
	case e.Rate == "":
		return "", ExpenseInput{}, "currency"
	case len(e.Converted) == len(e.Payers):
		for i, p := range e.Payers {
			v, ok := toMinor(e.Converted[i], digits)
			if !ok {
				return "", ExpenseInput{}, "amount"
			}
			if paid, ok = addTo(paid, ids[p.Name], v); !ok {
				return "", ExpenseInput{}, "amount"
			}
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
			if weights, ok = addTo(weights, ids[p.Name], w); !ok {
				return "", ExpenseInput{}, "amount"
			}
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
			paid, _ = addTo(paid, w.id, sign(total)*amounts[w.id])
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
		if weights, ok = addTo(weights, ids[p.Name], abs(w)); !ok {
			return "", ExpenseInput{}, "amount"
		}
		v, ok := toMinor(p.Amount, digits)
		exactOK = exactOK && ok
		exact, ok = addTo(exact, ids[p.Name], abs(v))
		exactOK = exactOK && ok
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
	case slices.ContainsFunc(people, func(p share) bool { return p.value > maxShareValue }):
		// Weights larger than a share may be are kept as the amounts they
		// come to.
		owed, ok := spread(total, digits, people)
		if !ok {
			return "", ExpenseInput{}, "amount"
		}
		in.SplitMethod = SplitMethod(domain.SplitExact)
		for _, p := range people {
			v := domain.FormatAmount(owed[p.id], digits)
			in.Splits = append(in.Splits, Share{MemberId: p.id, Value: &v})
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
