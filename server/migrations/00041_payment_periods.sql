-- +goose Up

-- Keep each subscription payment's period fixed, even when the next billing
-- attempt moves. Older records use the configured fallback, capped at the
-- entitlement's existing end.
alter table payment_events add column paid_until timestamptz;
update payment_events p set paid_until = least(e.expires_at,
  p.paid_at + make_interval(days => p.days) + interval '2 days')
from entitlements e
where p.entitlement_id = e.id and p.provider = 'paypal' and p.recurring;

-- A shop order may need manual assignment; keep every item for that decision.
alter table payment_events add column shop_items jsonb not null default '[]';

-- +goose Down
alter table payment_events drop column shop_items;
alter table payment_events drop column paid_until;
