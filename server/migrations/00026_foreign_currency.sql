-- +goose Up

-- An expense paid in another currency than the group's keeps what it was in
-- that currency next to the ledger. amount and the payer and split amounts
-- stay in the group's currency, so balances never depend on a rate; the
-- rate shown is foreign_amount against amount. foreign_digits is kept so a
-- currency's usual decimals changing later cannot change a stored amount.
alter table expenses drop column exchange_rate;
alter table expenses
  add column foreign_currency char(3),
  add column foreign_digits   smallint check (foreign_digits between 0 and 4),
  add column foreign_amount   bigint check (foreign_amount > 0),
  add constraint expenses_foreign_check check (
    (foreign_currency is null) = (foreign_amount is null)
    and (foreign_currency is null) = (foreign_digits is null));

alter table expense_payers add column foreign_amount bigint check (foreign_amount > 0);
alter table expense_splits add column foreign_amount bigint check (foreign_amount >= 0);

-- The totals check also holds the foreign amounts to the expense's: either
-- every part has one and they add up, or none has.
-- +goose StatementBegin
create or replace function assert_expense_totals(expense uuid) returns void language plpgsql as $$
declare
  expected bigint;
  expected_foreign bigint;
  paid numeric;
  owed numeric;
  paid_foreign numeric;
  owed_foreign numeric;
begin
  -- Serialize checks of one expense, including direct SQL changes to parts.
  -- NO KEY UPDATE remains compatible with the parts' foreign-key locks.
  select amount, foreign_amount into expected, expected_foreign from expenses where id = expense for no key update;
  if not found then
    return; -- The parent was deleted, possibly through a group cascade.
  end if;
  select coalesce(sum(amount), 0), coalesce(sum(foreign_amount), 0)
    into paid, paid_foreign from expense_payers where expense_id = expense;
  select coalesce(sum(amount), 0), coalesce(sum(foreign_amount), 0)
    into owed, owed_foreign from expense_splits where expense_id = expense;
  if paid <> expected or owed <> expected then
    raise exception 'Expense payer and split totals must equal its amount'
      using errcode = '23514', constraint = 'expense_totals', table = 'expenses';
  end if;
  if expected_foreign is null then
    if exists (select 1 from expense_payers where expense_id = expense and foreign_amount is not null)
        or exists (select 1 from expense_splits where expense_id = expense and foreign_amount is not null) then
      raise exception 'Only an expense in a foreign currency has foreign amounts'
        using errcode = '23514', constraint = 'expense_totals', table = 'expenses';
    end if;
    return;
  end if;
  if exists (select 1 from expense_payers where expense_id = expense and foreign_amount is null)
      or exists (select 1 from expense_splits where expense_id = expense and foreign_amount is null)
      or paid_foreign <> expected_foreign or owed_foreign <> expected_foreign then
    raise exception 'Expense payer and split foreign totals must equal its foreign amount'
      using errcode = '23514', constraint = 'expense_totals', table = 'expenses';
  end if;
end;
$$;
-- +goose StatementEnd

-- +goose Down

-- +goose StatementBegin
create or replace function assert_expense_totals(expense uuid) returns void language plpgsql as $$
declare
  expected bigint;
  paid numeric;
  owed numeric;
begin
  -- Serialize checks of one expense, including direct SQL changes to parts.
  -- NO KEY UPDATE remains compatible with the parts' foreign-key locks.
  select amount into expected from expenses where id = expense for no key update;
  if not found then
    return; -- The parent was deleted, possibly through a group cascade.
  end if;
  select coalesce(sum(amount), 0) into paid from expense_payers where expense_id = expense;
  select coalesce(sum(amount), 0) into owed from expense_splits where expense_id = expense;
  if paid <> expected or owed <> expected then
    raise exception 'Expense payer and split totals must equal its amount'
      using errcode = '23514', constraint = 'expense_totals', table = 'expenses';
  end if;
end;
$$;
-- +goose StatementEnd

alter table expense_splits drop column foreign_amount;
alter table expense_payers drop column foreign_amount;
alter table expenses
  drop constraint expenses_foreign_check,
  drop column foreign_amount,
  drop column foreign_digits,
  drop column foreign_currency,
  add column exchange_rate numeric(20,10) not null default 1;
