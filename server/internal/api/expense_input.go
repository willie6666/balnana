package api

import (
	"context"
	"strings"
	"time"

	"balnana/internal/domain"
)

const (
	kindExpense = "expense"
	kindPayment = "payment"
)

// expenseData is a validated expense, ready to store.
type expenseData struct {
	kind            string
	transactionType string
	title           string
	category        *string
	amount          int64
	occurredAt      time.Time
	note            *string
	location        *Location
	method          domain.SplitMethod
	payers          map[string]int64
	splits          map[string]int64
	shares          map[string]string // entered weight, 4 decimals
	foreign         *foreignData
	clientKey       *IdempotencyKey
}

// foreignData is what an expense paid in another currency came to in it.
// The expenseData's amounts are the same spread over the group's currency.
type foreignData struct {
	currency string
	digits   int
	amount   int64
	payers   map[string]int64
	splits   map[string]int64
}

// foreignCurrency checks the currency of an expense's foreign amount.
func foreignCurrency(g *group, in ForeignInput) (string, error) {
	currency := strings.ToUpper(strings.TrimSpace(in.Currency))
	if !currencyCode.MatchString(currency) || currency == g.currency {
		return "", badRequest("invalid_currency")
	}
	return currency, nil
}

// Dates an expense may have: wide enough for any real one, and well inside
// what JSON and the database can carry.
const (
	minExpenseYear = 1900
	maxExpenseYear = 2999
)

// checkExpenseDate refuses a date outside the years an expense may have.
func checkExpenseDate(t time.Time) error {
	if y := t.Year(); t.IsZero() || y < minExpenseYear || y > maxExpenseYear {
		return badRequest("invalid_date")
	}
	return nil
}

// validateExpense checks an expense against the group: every member must
// belong to it, payers must add up to the amount and the split must work.
// Members who left still belong: their balance has to stay possible to settle.
// members is the group's, or nil to load them.
func validateExpense(ctx context.Context, q querier, g *group, kind string, in ExpenseInput,
	members []member) (*expenseData, error) {
	d := &expenseData{kind: kind, transactionType: "expense", occurredAt: in.OccurredAt, method: domain.SplitMethod(in.SplitMethod)}

	minTitle := 1
	if kind == kindPayment {
		minTitle = 0
	}
	title, ok := cleanText(in.Title, minTitle, maxTitleLen)
	if !ok || strings.Contains(title, "\n") {
		return nil, badRequest("invalid_title")
	}
	d.title = title

	if in.Note != nil {
		note, ok := cleanText(*in.Note, 0, maxNoteLen)
		if !ok {
			return nil, badRequest("invalid_note")
		}
		if note != "" {
			d.note = &note
		}
	}
	if in.Location != nil {
		loc, err := cleanLocation(*in.Location)
		if err != nil {
			return nil, err
		}
		d.location = loc
	}
	if err := checkExpenseDate(in.OccurredAt); err != nil {
		return nil, err
	}

	if in.CategoryId != nil && *in.CategoryId != "" {
		var exists bool
		if err := q.QueryRow(ctx, `
			select exists (select 1 from categories where id = $1 and (group_id is null or group_id = $2))`,
			*in.CategoryId, g.id).Scan(&exists); err != nil {
			return nil, err
		}
		if !exists {
			return nil, badRequest("invalid_category")
		}
		d.category = in.CategoryId
	}

	amount, err := domain.ParseAmount(in.Amount, g.digits)
	if err != nil {
		return nil, err
	}
	if amount <= 0 {
		return nil, domain.ErrInvalidAmount
	}
	d.amount = amount

	// Payers and the split are entered in the currency the expense was paid
	// in: the group's, or the foreign one.
	total, digits := amount, g.digits
	if in.Foreign != nil {
		if kind == kindPayment {
			return nil, badRequest("invalid_payment")
		}
		currency, err := foreignCurrency(g, *in.Foreign)
		if err != nil {
			return nil, err
		}
		digits = domain.CurrencyDigits(currency)
		if total, err = domain.ParseAmount(in.Foreign.Amount, digits); err != nil {
			return nil, err
		}
		if total <= 0 {
			return nil, domain.ErrInvalidAmount
		}
		d.foreign = &foreignData{currency: currency, digits: digits, amount: total}
	}

	if members == nil {
		if members, err = groupMembers(ctx, q, g.id); err != nil {
			return nil, err
		}
	}
	known := func(id string) error {
		if findMember(members, id) == nil {
			return badRequest("unknown_member")
		}
		return nil
	}

	if len(in.Payers) == 0 {
		return nil, badRequest("no_payers")
	}
	if len(in.Payers) > maxMembers || len(in.Splits) > maxMembers {
		return nil, badRequest("too_many_members")
	}
	d.payers = make(map[string]int64, len(in.Payers))
	var paid int64
	for _, p := range in.Payers {
		if err := known(p.MemberId); err != nil {
			return nil, err
		}
		if _, dup := d.payers[p.MemberId]; dup {
			return nil, domain.ErrDuplicateMember
		}
		v, err := domain.ParseAmount(p.Amount, digits)
		if err != nil {
			return nil, err
		}
		if v <= 0 {
			return nil, domain.ErrInvalidAmount
		}
		d.payers[p.MemberId] = v
		paid += v // each v <= MaxMinor and there are few: no overflow
	}
	if paid != total {
		return nil, badRequest("payer_total")
	}

	parts := make([]domain.Part, 0, len(in.Splits))
	d.shares = map[string]string{}
	for _, sp := range in.Splits {
		if err := known(sp.MemberId); err != nil {
			return nil, err
		}
		value := ""
		if sp.Value != nil {
			value = strings.TrimSpace(*sp.Value)
		}
		if d.method == domain.SplitShares {
			w, err := domain.ParseAmount(value, 4)
			if err != nil || w < 0 || w > maxShareValue {
				return nil, domain.ErrInvalidShare
			}
			d.shares[sp.MemberId] = domain.FormatAmount(w, 4)
		}
		parts = append(parts, domain.Part{Member: sp.MemberId, Value: value})
	}
	d.splits, err = domain.Split(total, digits, d.method, parts)
	if err != nil {
		return nil, err
	}

	if f := d.foreign; f != nil {
		f.payers, f.splits = d.payers, d.splits
		if d.payers, err = domain.Spread(amount, f.payers); err != nil {
			return nil, err
		}
		for _, v := range d.payers {
			if v == 0 {
				return nil, badRequest("payer_too_small")
			}
		}
		if d.splits, err = domain.Spread(amount, f.splits); err != nil {
			return nil, err
		}
	}

	if kind == kindPayment {
		if len(d.payers) != 1 || len(d.splits) != 1 || d.method != domain.SplitExact {
			return nil, badRequest("invalid_payment")
		}
		for from := range d.payers {
			if _, self := d.splits[from]; self {
				return nil, badRequest("invalid_payment")
			}
		}
	}
	return d, nil
}

func (d *expenseData) payload(digits int) map[string]any {
	p := map[string]any{"title": d.title, "amount": domain.FormatAmount(d.amount, digits), "kind": d.kind}
	if f := d.foreign; f != nil {
		p["foreignAmount"] = domain.FormatAmount(f.amount, f.digits)
		p["foreignCurrency"] = f.currency
	}
	return p
}
