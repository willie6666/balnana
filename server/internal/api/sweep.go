package api

import (
	"context"
	"time"
)

// Requests already ignore sessions, tokens and links that ran out; the sweep
// deletes them so the tables do not grow forever.

const sweepEvery = time.Hour

// archiveKeep is how long a deleted group is kept before it is gone for
// good. Until then the administrator can bring it back by clearing its
// archived_at in the database.
const archiveKeep = 30 * 24 * time.Hour

// receiptKeep is how long the photo of a deleted expense is kept, for
// bringing the expense back. After that the expense comes back without it.
const receiptKeep = 30 * 24 * time.Hour

// checkoutKeep is how long a PayPal checkout may take to be paid. PayPal
// lets an order wait for its payer only a few hours.
const checkoutKeep = 30 * 24 * time.Hour

// sweepBatch is how many rows a statement deletes, so that a large backlog
// doesn't hold up everything else at once.
var sweepBatch = 1000

// groupSweepBatch is smaller: a group takes everything in it along.
const groupSweepBatch = 10

// expiringTables have an expires_at column.
var expiringTables = []string{"sessions", "email_tokens", "invites", "oauth_logins", "oauth_codes", "oauth_pending", "oauth_link_tickets", "admin_sessions"}

// SweepExpired deletes expired rows now and then every hour until ctx ends.
// Several servers sharing the database may each run it.
func (s *Server) SweepExpired(ctx context.Context) {
	tick := time.NewTicker(sweepEvery)
	defer tick.Stop()
	for {
		if n, err := s.sweepExpired(ctx); err != nil && ctx.Err() == nil {
			s.log.Warn("deleting expired rows failed", "err", err)
		} else if n > 0 {
			s.log.Debug("deleted expired rows", "rows", n)
		}
		select {
		case <-tick.C:
		case <-ctx.Done():
			return
		}
	}
}

func (s *Server) sweepExpired(ctx context.Context) (int64, error) {
	var total int64
	for _, table := range expiringTables {
		n, err := s.sweepBatches(ctx, sweepBatch, `delete from `+table+` where ctid = any (array(
			select ctid from `+table+` where expires_at < now() limit $1))`)
		total += n
		if err != nil {
			return total, err
		}
	}
	n, err := s.sweepBatches(ctx, sweepBatch, `
		delete from receipts where expense_id = any (array(
			select r.expense_id from receipts r join expenses e on e.id = r.expense_id
			where e.deleted_at < $2 limit $1))`, time.Now().Add(-receiptKeep))
	total += n
	if err != nil {
		return total, err
	}
	n, err = s.sweepBatches(ctx, groupSweepBatch, `
		delete from groups where archived_at < $2 and id = any (array(
			select id from groups where archived_at < $2 limit $1))`, time.Now().Add(-archiveKeep))
	total += n
	if err != nil {
		return total, err
	}
	// PayPal checkouts nobody finished. A paid one has its payment or
	// entitlement; a subscription that was approved, even one with no payment
	// yet, stays for its later payments to find.
	n, err = s.sweepBatches(ctx, sweepBatch, `
		delete from paypal_orders where order_id = any (array(
			select o.order_id from paypal_orders o where o.created_at < $2 and not exists (
				select 1 from payment_events p where p.provider = 'paypal' and p.reference = o.order_id)
			limit $1))`, time.Now().Add(-checkoutKeep))
	total += n
	if err != nil {
		return total, err
	}
	n, err = s.sweepBatches(ctx, sweepBatch, `
		delete from paypal_subscriptions where subscription_id = any (array(
			select subscription_id from paypal_subscriptions
			where created_at < $2 and entitlement_id is null and (state is null or state = any($3)) and not exists (
				select 1 from payment_events p where p.provider = 'paypal' and p.reference = subscription_id)
			limit $1))`, time.Now().Add(-checkoutKeep), []string{"APPROVAL_PENDING", "CANCELLED", "EXPIRED"})
	total += n
	if err != nil {
		return total, err
	}
	days := s.conf().PaymentKeepDays
	if days <= 0 {
		return total, nil
	}
	// A record of the sale stays; only who made it goes.
	n, err = s.sweepBatches(ctx, sweepBatch, `
		update payment_events set email = null, payer_name = null where id = any (array(
			select id from payment_events
			where (email is not null or payer_name is not null) and created_at < $2 limit $1))`,
		time.Now().AddDate(0, 0, -days))
	return total + n, err
}

// sweepBatches runs sql, a delete of up to $1 rows, until nothing is left.
func (s *Server) sweepBatches(ctx context.Context, batch int, sql string, args ...any) (int64, error) {
	var total int64
	for {
		tag, err := s.db.Exec(ctx, sql, append([]any{batch}, args...)...)
		if err != nil {
			return total, err
		}
		total += tag.RowsAffected()
		if tag.RowsAffected() < int64(batch) {
			return total, nil
		}
	}
}
