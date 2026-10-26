-- +goose Up

-- Incoming imports keep reversed payer/split rows for the balance ledger.
-- Their original direction must also survive for spending reports. Older
-- imports have no recoverable direction marker and retain the expense default.
alter table expenses add column transaction_type text not null default 'expense'
  check (transaction_type in ('expense', 'refund', 'income'));
alter table expenses add constraint payment_transaction_type
  check (kind <> 'payment' or transaction_type = 'expense');

-- +goose Down

alter table expenses drop constraint payment_transaction_type;
alter table expenses drop column transaction_type;
