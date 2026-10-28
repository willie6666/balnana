package api

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"

	"balnana/internal/domain"
)

// A recurring expense is an expense the server adds again and again: at its
// start and then every so many days, weeks, months or years. Each addition
// is an ordinary expense, made by whoever set it up, that remembers which
// occurrence it is, so an occurrence is never added twice.

// recurringEvery is how often the server looks for occurrences that are due.
const recurringEvery = time.Minute

// maxDue caps how many occurrences a change may add at once, so a mistyped
// start date cannot fill a group with copies.
const maxDue = 100

const dateLayout = "2006-01-02"

// schedule is when a recurring expense's occurrences fall: occurrence n is
// start plus n times the interval on loc's calendar, so it keeps its time of
// day across daylight saving and its day of the month where it can.
type schedule struct {
	start time.Time // the first occurrence, in loc
	loc   *time.Location
	unit  RepeatUnit
	every int
	end   string // the last day one may fall on, YYYY-MM-DD in loc; empty for none
}

// at is occurrence n. Months and years count from the start, so one from
// the 31st falls on the last day of shorter months and on the 31st again
// after them.
func (s schedule) at(n int) time.Time {
	t := s.start
	switch s.unit {
	case Day:
		return t.AddDate(0, 0, n*s.every)
	case Week:
		return t.AddDate(0, 0, 7*n*s.every)
	}
	months := n * s.every
	if s.unit == Year {
		months *= 12
	}
	y, m, d := t.Date()
	first := time.Date(y, m+time.Month(months), 1, 0, 0, 0, 0, s.loc)
	if last := first.AddDate(0, 1, -1).Day(); d > last {
		d = last
	}
	return time.Date(first.Year(), first.Month(), d, t.Hour(), t.Minute(), t.Second(), t.Nanosecond(), s.loc)
}

// ended tells whether t falls after the last day.
func (s schedule) ended(t time.Time) bool {
	return s.end != "" && t.In(s.loc).Format(dateLayout) > s.end
}

// after is the first occurrence later than t, or nil when there is none.
func (s schedule) after(t time.Time) *time.Time {
	n := 0
	if !s.start.After(t) {
		// Guess low from the time between, then step to it: calendar days
		// and months vary in length.
		switch s.unit {
		case Day, Week:
			days := int(t.Sub(s.start) / (24 * time.Hour))
			if s.unit == Week {
				days /= 7
			}
			n = days/s.every - 1
		default:
			months := (t.Year()-s.start.Year())*12 + int(t.Month()) - int(s.start.Month())
			if s.unit == Year {
				months /= 12
			}
			n = months/s.every - 1
		}
		n = max(n, 0)
		for !s.at(n).After(t) {
			n++
		}
	}
	next := s.at(n)
	if s.ended(next) {
		return nil
	}
	return &next
}

// first is the first occurrence, or nil when the schedule ended before it.
func (s schedule) first() *time.Time {
	return s.after(s.start.Add(-time.Nanosecond))
}

// due counts the occurrences from next up to now, stopping past maxDue.
func (s schedule) due(next *time.Time, now time.Time) int {
	n := 0
	for t := next; t != nil && !t.After(now) && n <= maxDue; t = s.after(*t) {
		n++
	}
	return n
}

// checkDue refuses a schedule that would add more than maxDue at once.
func (s schedule) checkDue(next *time.Time, now time.Time) error {
	if s.due(next, now) > maxDue {
		return badRequest("too_many_due")
	}
	return nil
}

func scheduleOf(r *RecurringExpense) (schedule, error) {
	loc, err := time.LoadLocation(r.TimeZone)
	if err != nil {
		return schedule{}, err
	}
	s := schedule{start: r.StartsAt.In(loc), loc: loc, unit: r.Repeat.Unit, every: r.Repeat.Every}
	if r.EndsOn != nil {
		s.end = *r.EndsOn
	}
	return s, nil
}

// validateRecurring checks a recurring expense as validateExpense checks an
// expense dated at its start, and checks its schedule.
func validateRecurring(ctx context.Context, q querier, g *group, in RecurringExpenseInput) (*expenseData, schedule, error) {
	d, err := validateExpense(ctx, q, g, kindExpense, ExpenseInput{
		Title:       in.Title,
		CategoryId:  in.CategoryId,
		Amount:      in.Amount,
		OccurredAt:  in.StartsAt,
		Note:        in.Note,
		Location:    in.Location,
		Payers:      in.Payers,
		SplitMethod: in.SplitMethod,
		Splits:      in.Splits,
	}, nil, nil)
	if err != nil {
		return nil, schedule{}, err
	}
	switch in.Repeat.Unit {
	case Day, Week, Month, Year:
	default:
		return nil, schedule{}, badRequest("invalid_repeat")
	}
	if in.Repeat.Every < 1 || in.Repeat.Every > 999 {
		return nil, schedule{}, badRequest("invalid_repeat")
	}
	zone := "UTC"
	if in.TimeZone != nil && *in.TimeZone != "" {
		zone = *in.TimeZone
	}
	loc, err := readerZone(nil, &zone)
	if err != nil {
		return nil, schedule{}, err
	}
	s := schedule{start: in.StartsAt.In(loc), loc: loc, unit: in.Repeat.Unit, every: in.Repeat.Every}
	if in.EndsOn != nil && *in.EndsOn != "" {
		end, err := time.Parse(dateLayout, *in.EndsOn)
		if err != nil || end.Format(dateLayout) != *in.EndsOn || end.Year() > maxExpenseYear ||
			*in.EndsOn < s.start.Format(dateLayout) {
			return nil, schedule{}, badRequest("invalid_end")
		}
		s.end = *in.EndsOn
	}
	return d, s, nil
}

// input is the expense r adds at occurrence at.
func (r *RecurringExpense) input(at time.Time) ExpenseInput {
	in := ExpenseInput{
		Title:       r.Title,
		CategoryId:  r.CategoryId,
		Amount:      r.Amount,
		OccurredAt:  at,
		Note:        r.Note,
		Location:    r.Location,
		SplitMethod: r.SplitMethod,
	}
	for _, p := range r.Payers {
		in.Payers = append(in.Payers, PayerInput{MemberId: p.MemberId, Amount: p.Amount})
	}
	for _, p := range r.Splits {
		share := Share{MemberId: p.MemberId}
		switch domain.SplitMethod(r.SplitMethod) {
		case domain.SplitExact:
			share.Value = &p.Amount
		case domain.SplitShares:
			share.Value = p.Share
		}
		in.Splits = append(in.Splits, share)
	}
	return in
}

func (r *RecurringExpense) payload() map[string]any {
	return map[string]any{"title": r.Title, "amount": r.Amount}
}

func insertRecurringParts(ctx context.Context, tx pgx.Tx, id string, d *expenseData) error {
	for m, v := range d.payers {
		if _, err := tx.Exec(ctx, `
			insert into recurring_expense_payers (recurring_id, member_id, amount) values ($1, $2, $3)`, id, m, v); err != nil {
			return err
		}
	}
	for m, v := range d.splits {
		var share *string
		if s, ok := d.shares[m]; ok {
			share = &s
		}
		if _, err := tx.Exec(ctx, `
			insert into recurring_expense_splits (recurring_id, member_id, amount, share)
			values ($1, $2, $3, $4::text::numeric)`, id, m, v, share); err != nil {
			return err
		}
	}
	return nil
}

const recurringColumns = `id::text, title, category_id, amount, note, split_method::text, location_name, latitude,
	longitude, unit, every, starts_at, time_zone, to_char(ends_on, 'YYYY-MM-DD'), next_at, last_at, paused,
	created_by_member::text, created_at, updated_at, version`

// loadRecurring runs a query selecting recurringColumns and attaches payers and splits.
func loadRecurring(ctx context.Context, q querier, digits int, sql string, args ...any) ([]RecurringExpense, error) {
	rows, err := q.Query(ctx, sql, args...)
	if err != nil {
		return nil, err
	}
	list, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (RecurringExpense, error) {
		var r RecurringExpense
		var method, unit string
		var amount int64
		var place *string
		var lat, lng *float64
		err := row.Scan(&r.Id, &r.Title, &r.CategoryId, &amount, &r.Note, &method, &place, &lat, &lng, &unit,
			&r.Repeat.Every, &r.StartsAt, &r.TimeZone, &r.EndsOn, &r.NextAt, &r.LastAt, &r.Paused, &r.CreatedBy,
			&r.CreatedAt, &r.UpdatedAt, &r.Version)
		if place != nil || lat != nil {
			r.Location = &Location{Name: place}
			if lat != nil && lng != nil {
				r.Location.Point = &GeoPoint{Latitude: *lat, Longitude: *lng}
			}
		}
		r.SplitMethod = SplitMethod(method)
		r.Repeat.Unit = RepeatUnit(unit)
		r.Amount = domain.FormatAmount(amount, digits)
		r.Payers = []Payer{}
		r.Splits = []SplitPart{}
		return r, err
	})
	if err != nil || len(list) == 0 {
		return list, err
	}

	index := make(map[string]*RecurringExpense, len(list))
	ids := make([]string, len(list))
	for i := range list {
		index[list[i].Id] = &list[i]
		ids[i] = list[i].Id
	}

	rows, err = q.Query(ctx, `
		select p.recurring_id::text, p.member_id::text, p.amount
		from recurring_expense_payers p join members m on m.id = p.member_id
		where p.recurring_id = any($1::uuid[]) order by m.created_at, m.id`, ids)
	if err != nil {
		return nil, err
	}
	var rid, mid string
	var amount int64
	_, err = pgx.ForEachRow(rows, []any{&rid, &mid, &amount}, func() error {
		r := index[rid]
		r.Payers = append(r.Payers, Payer{MemberId: mid, Amount: domain.FormatAmount(amount, digits)})
		return nil
	})
	if err != nil {
		return nil, err
	}

	rows, err = q.Query(ctx, `
		select s.recurring_id::text, s.member_id::text, s.amount, s.share::text
		from recurring_expense_splits s join members m on m.id = s.member_id
		where s.recurring_id = any($1::uuid[]) order by m.created_at, m.id`, ids)
	if err != nil {
		return nil, err
	}
	var share *string
	_, err = pgx.ForEachRow(rows, []any{&rid, &mid, &amount, &share}, func() error {
		r := index[rid]
		part := SplitPart{MemberId: mid, Amount: domain.FormatAmount(amount, digits)}
		if share != nil {
			v := trimShare(*share)
			part.Share = &v
		}
		r.Splits = append(r.Splits, part)
		return nil
	})
	return list, err
}

// loadOneRecurring loads one of g's recurring expenses; lock holds its row
// until the transaction ends.
func loadOneRecurring(ctx context.Context, q querier, g *group, id string, lock bool) (*RecurringExpense, error) {
	if !validUUID(id) {
		return nil, errNotFound
	}
	sql := `select ` + recurringColumns + ` from recurring_expenses where id = $1 and group_id = $2`
	if lock {
		sql += ` for update`
	}
	list, err := loadRecurring(ctx, q, g.digits, sql, id, g.id)
	if err != nil {
		return nil, err
	}
	if len(list) == 0 {
		return nil, errNotFound
	}
	return &list[0], nil
}

// addDue adds r's occurrences that are due by now, at most maxDue, and moves
// it on to the next. On an occurrence that cannot be added it stops there,
// keeping those before, and returns why.
func addDue(ctx context.Context, tx pgx.Tx, g *group, r *RecurringExpense, now time.Time) ([]Expense, error) {
	s, err := scheduleOf(r)
	if err != nil {
		return nil, err
	}
	var added []Expense
	var members []member
	var failed error
	for r.NextAt != nil && !r.NextAt.After(now) && len(added) < maxDue {
		due := *r.NextAt
		if members == nil {
			if members, err = groupMembers(ctx, tx, g.id); err != nil {
				return nil, err
			}
		}
		d, err := validateExpense(ctx, tx, g, kindExpense, r.input(due), nil, members)
		if err == nil {
			err = checkGroupTotal(ctx, tx, g.id, d.amount, nil)
		}
		if err != nil {
			failed = err
			break
		}
		id, err := storeExpense(ctx, tx, g, r.CreatedBy, d)
		if err != nil {
			return nil, err
		}
		if _, err := tx.Exec(ctx, `update expenses set recurring_id = $2, recurring_due = $3 where id = $1`,
			id, r.Id, due); err != nil {
			return nil, err
		}
		payload := d.payload(g.digits)
		payload["recurring"] = true
		if err := logActivity(ctx, tx, g.id, r.CreatedBy, "expense.created", &id, payload); err != nil {
			return nil, err
		}
		e, err := loadExpense(ctx, tx, g, id)
		if err != nil {
			return nil, err
		}
		added = append(added, e)
		r.LastAt = &due
		r.NextAt = s.after(due)
	}
	if len(added) > 0 {
		if _, err := tx.Exec(ctx, `update recurring_expenses set next_at = $2, last_at = $3 where id = $1`,
			r.Id, r.NextAt, r.LastAt); err != nil {
			return nil, err
		}
	}
	return added, failed
}

// failureCode is the code of an error that a change of the group, not of the
// server, would fix, or "" for any other.
func failureCode(err error) string {
	var ae *apiError
	var dc domain.Code
	switch {
	case errors.As(err, &ae):
		return ae.code
	case errors.As(err, &dc):
		return string(dc)
	}
	return ""
}

// RunRecurring adds the occurrences that are due now and then every minute
// until ctx ends. Several servers sharing the database may each run it.
func (s *Server) RunRecurring(ctx context.Context) {
	tick := time.NewTicker(recurringEvery)
	defer tick.Stop()
	for {
		if n, err := s.runRecurring(ctx, time.Now()); err != nil && ctx.Err() == nil {
			s.log.Warn("adding recurring expenses failed", "err", err)
		} else if n > 0 {
			s.log.Debug("added recurring expenses", "expenses", n)
		}
		select {
		case <-tick.C:
		case <-ctx.Done():
			return
		}
	}
}

// runRecurring adds what is due by now, returning how many expenses it added.
func (s *Server) runRecurring(ctx context.Context, now time.Time) (int, error) {
	rows, err := s.db.Query(ctx, `
		select r.id::text from recurring_expenses r join groups g on g.id = r.group_id
		where r.next_at <= $1 and not r.paused and g.archived_at is null
		order by r.next_at limit 100`, now)
	if err != nil {
		return 0, err
	}
	ids, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil {
		return 0, err
	}
	total := 0
	var first error
	for _, id := range ids {
		n, err := s.runOneRecurring(ctx, id, now)
		total += n
		if err != nil && first == nil {
			first = err
		}
	}
	return total, first
}

func (s *Server) runOneRecurring(ctx context.Context, id string, now time.Time) (int, error) {
	var added []Expense
	var g *group
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		// The group first, as every change to it locks it first.
		g, err = scanGroup(tx.QueryRow(ctx, `
			select `+groupColumns+` from groups
			where id = (select group_id from recurring_expenses where id = $1) and archived_at is null
			for update`, id))
		if err != nil {
			return err
		}
		r, err := loadOneRecurring(ctx, tx, g, id, true)
		if err != nil {
			return err
		}
		// Another server may have added it meanwhile.
		if r.Paused || r.NextAt == nil || r.NextAt.After(now) {
			return nil
		}
		added, err = addDue(ctx, tx, g, r, now)
		code := failureCode(err)
		if code == "" {
			return err
		}
		// It cannot go on as it is, such as when someone in it left: it
		// waits for someone to change it and resume it.
		if _, err := tx.Exec(ctx, `
			update recurring_expenses set paused = true, updated_at = now(), version = version + 1
			where id = $1`, id); err != nil {
			return err
		}
		payload := r.payload()
		payload["reason"] = code
		return logActivity(ctx, tx, g.id, nil, "recurring.paused", &id, payload)
	})
	if errors.Is(err, errNotFound) {
		// Deleted, or its group was, since it was found due.
		return 0, nil
	}
	if err != nil {
		return 0, err
	}
	for _, e := range added {
		s.notifyExpense(g, nil, "added", e)
	}
	return len(added), nil
}

func (s *Server) ListRecurringExpenses(ctx context.Context, req ListRecurringExpensesRequestObject) (ListRecurringExpensesResponseObject, error) {
	var out []RecurringExpense
	err := s.groupSnapshot(ctx, req.Token, func(tx pgx.Tx, g *group) (err error) {
		out, err = loadRecurring(ctx, tx, g.digits, `
			select `+recurringColumns+` from recurring_expenses where group_id = $1
			order by next_at nulls last, created_at, id`, g.id)
		return err
	})
	if err != nil {
		return nil, err
	}
	if out == nil {
		out = []RecurringExpense{}
	}
	return ListRecurringExpenses200JSONResponse(out), nil
}

func (s *Server) GetRecurringExpense(ctx context.Context, req GetRecurringExpenseRequestObject) (GetRecurringExpenseResponseObject, error) {
	var out *RecurringExpense
	err := s.groupSnapshot(ctx, req.Token, func(tx pgx.Tx, g *group) (err error) {
		out, err = loadOneRecurring(ctx, tx, g, req.RecurringId, false)
		return err
	})
	if err != nil {
		return nil, err
	}
	return GetRecurringExpense200JSONResponse(*out), nil
}

func (s *Server) CreateRecurringExpense(ctx context.Context, req CreateRecurringExpenseRequestObject) (CreateRecurringExpenseResponseObject, error) {
	now := time.Now()
	var out *RecurringExpense
	var added []Expense
	var g *group
	var who *string
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		g, err = s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		d, sched, err := validateRecurring(ctx, tx, g, *req.Body)
		if err != nil {
			return err
		}
		next := sched.first()
		if err := sched.checkDue(next, now); err != nil {
			return err
		}
		who, err = actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		var end *string
		if sched.end != "" {
			end = &sched.end
		}
		var id string
		place, lat, lng := locationColumns(d.location)
		err = tx.QueryRow(ctx, `
			insert into recurring_expenses (group_id, title, category_id, amount, split_method, note, location_name,
				latitude, longitude, unit, every, starts_at, time_zone, ends_on, next_at, created_by_member)
			values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14::text::date, $15, $16)
			returning id::text`,
			g.id, d.title, d.category, d.amount, string(d.method), d.note, place, lat, lng, string(sched.unit),
			sched.every, sched.start, sched.loc.String(), end, next, who).Scan(&id)
		if err != nil {
			return err
		}
		if err := insertRecurringParts(ctx, tx, id, d); err != nil {
			return err
		}
		if out, err = loadOneRecurring(ctx, tx, g, id, false); err != nil {
			return err
		}
		if err := logActivity(ctx, tx, g.id, who, "recurring.created", &id, out.payload()); err != nil {
			return err
		}
		if added, err = addDue(ctx, tx, g, out, now); err != nil {
			return err
		}
		out, err = loadOneRecurring(ctx, tx, g, id, false)
		return err
	})
	if err != nil {
		return nil, err
	}
	for _, e := range added {
		s.notifyExpense(g, who, "added", e)
	}
	return CreateRecurringExpense201JSONResponse(*out), nil
}

func (s *Server) UpdateRecurringExpense(ctx context.Context, req UpdateRecurringExpenseRequestObject) (UpdateRecurringExpenseResponseObject, error) {
	if req.Body.Version == nil {
		return nil, badRequest("version_required")
	}
	now := time.Now()
	var out *RecurringExpense
	var added []Expense
	var g *group
	var who *string
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		g, err = s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		r, err := loadOneRecurring(ctx, tx, g, req.RecurringId, true)
		if err != nil {
			return err
		}
		if r.Version != *req.Body.Version {
			return &apiError{status: 409, code: "recurring_version_conflict", params: map[string]any{"version": r.Version}}
		}
		d, sched, err := validateRecurring(ctx, tx, g, *req.Body)
		if err != nil {
			return err
		}
		// The new schedule goes on from the latest occurrence added.
		next := sched.first()
		if r.LastAt != nil {
			next = sched.after(*r.LastAt)
		}
		if !r.Paused {
			if err := sched.checkDue(next, now); err != nil {
				return err
			}
		}
		who, err = actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		var end *string
		if sched.end != "" {
			end = &sched.end
		}
		place, lat, lng := locationColumns(d.location)
		_, err = tx.Exec(ctx, `
			update recurring_expenses set title = $2, category_id = $3, amount = $4, split_method = $5, note = $6,
				location_name = $7, latitude = $8, longitude = $9, unit = $10, every = $11, starts_at = $12,
				time_zone = $13, ends_on = $14::text::date, next_at = $15, updated_at = now(), version = version + 1
			where id = $1`,
			r.Id, d.title, d.category, d.amount, string(d.method), d.note, place, lat, lng, string(sched.unit),
			sched.every, sched.start, sched.loc.String(), end, next)
		if err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `delete from recurring_expense_payers where recurring_id = $1`, r.Id); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `delete from recurring_expense_splits where recurring_id = $1`, r.Id); err != nil {
			return err
		}
		if err := insertRecurringParts(ctx, tx, r.Id, d); err != nil {
			return err
		}
		if out, err = loadOneRecurring(ctx, tx, g, r.Id, false); err != nil {
			return err
		}
		if err := logActivity(ctx, tx, g.id, who, "recurring.updated", &r.Id, out.payload()); err != nil {
			return err
		}
		if !out.Paused {
			if added, err = addDue(ctx, tx, g, out, now); err != nil {
				return err
			}
		}
		out, err = loadOneRecurring(ctx, tx, g, r.Id, false)
		return err
	})
	if err != nil {
		return nil, err
	}
	for _, e := range added {
		s.notifyExpense(g, who, "added", e)
	}
	return UpdateRecurringExpense200JSONResponse(*out), nil
}

func (s *Server) PauseRecurringExpense(ctx context.Context, req PauseRecurringExpenseRequestObject) (PauseRecurringExpenseResponseObject, error) {
	now := time.Now()
	var out *RecurringExpense
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		r, err := loadOneRecurring(ctx, tx, g, req.RecurringId, true)
		if err != nil {
			return err
		}
		if r.Paused == req.Body.Paused {
			out = r
			return nil
		}
		next := r.NextAt
		action := "recurring.paused"
		if !req.Body.Paused {
			action = "recurring.resumed"
			// What it would add must still work, such as everyone in it
			// still being in the group.
			if _, err := validateExpense(ctx, tx, g, kindExpense, r.input(now), nil, nil); err != nil {
				return err
			}
			sched, err := scheduleOf(r)
			if err != nil {
				return err
			}
			// Occurrences missed while paused are skipped.
			from := now
			if r.LastAt != nil && r.LastAt.After(from) {
				from = *r.LastAt
			}
			next = sched.after(from)
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `
			update recurring_expenses set paused = $2, next_at = $3, updated_at = now(), version = version + 1
			where id = $1`, r.Id, req.Body.Paused, next); err != nil {
			return err
		}
		if err := logActivity(ctx, tx, g.id, who, action, &r.Id, r.payload()); err != nil {
			return err
		}
		out, err = loadOneRecurring(ctx, tx, g, r.Id, false)
		return err
	})
	if err != nil {
		return nil, err
	}
	return PauseRecurringExpense200JSONResponse(*out), nil
}

func (s *Server) DeleteRecurringExpense(ctx context.Context, req DeleteRecurringExpenseRequestObject) (DeleteRecurringExpenseResponseObject, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		r, err := loadOneRecurring(ctx, tx, g, req.RecurringId, true)
		if err != nil {
			return err
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		// The expenses it added stay, no longer linked to it.
		if _, err := tx.Exec(ctx, `delete from recurring_expenses where id = $1`, r.Id); err != nil {
			return err
		}
		return logActivity(ctx, tx, g.id, who, "recurring.deleted", &r.Id, r.payload())
	})
	if err != nil {
		return nil, err
	}
	return DeleteRecurringExpense204Response{}, nil
}
