package api

import (
	"context"
	"net/http"
	"reflect"
	"time"

	"github.com/jackc/pgx/v5"
)

// featureOff refuses something new that the group has switched off.
func featureOff(feature string) error {
	return &apiError{status: http.StatusConflict, code: "feature_off", params: map[string]any{"feature": feature}}
}

// withFeatures is base with what in switches.
func withFeatures(base GroupFeatures, in *GroupFeaturesInput) GroupFeatures {
	if in == nil {
		return base
	}
	for _, f := range []struct {
		to *bool
		in *bool
	}{
		{&base.ForeignCurrency, in.ForeignCurrency},
		{&base.Recurring, in.Recurring},
		{&base.Places, in.Places},
		{&base.Receipts, in.Receipts},
	} {
		if f.in != nil {
			*f.to = *f.in
		}
	}
	return base
}

// checkFeatures refuses a foreign currency or a place on d that g has
// switched off, unless the expense had it already: wasLocation and
// wasForeign are what it had before an edit.
func checkFeatures(g *group, d *expenseData, wasLocation *Location, wasForeign bool) error {
	if d.foreign != nil && !g.features.ForeignCurrency && !wasForeign {
		return featureOff("foreignCurrency")
	}
	if d.location != nil && !g.features.Places && !reflect.DeepEqual(d.location, wasLocation) {
		return featureOff("places")
	}
	return nil
}

// skipMissed moves each running schedule of g that came due while
// recurring was off on to its first occurrence after now, as resuming does.
func skipMissed(ctx context.Context, tx pgx.Tx, g *group, now time.Time) error {
	rows, err := tx.Query(ctx, `
		select id::text from recurring_expenses
		where group_id = $1 and paused_at is null and next_at <= $2`, g.id, now)
	if err != nil {
		return err
	}
	ids, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil {
		return err
	}
	for _, id := range ids {
		r, err := loadOneRecurring(ctx, tx, g, id, true)
		if err != nil {
			return err
		}
		sched, err := scheduleOf(r)
		if err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `
			update recurring_expenses set next_at = $2, skipped_until = $3, updated_at = now(), version = version + 1
			where id = $1`, id, sched.after(now), now); err != nil {
			return err
		}
	}
	return nil
}
