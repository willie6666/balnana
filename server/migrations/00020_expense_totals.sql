-- +goose Up

-- Check the final ledger at commit, after an expense and all of its parts
-- have been written. Existing rows are not rewritten by this migration.
-- A group deletes both members and ledger rows. Check these cross-cascade
-- references after both cascades, regardless of which PostgreSQL runs first.
alter table expense_payers alter constraint expense_payers_member_id_fkey deferrable initially deferred;
alter table expense_splits alter constraint expense_splits_member_id_fkey deferrable initially deferred;
alter table expenses alter constraint expenses_created_by_member_fkey deferrable initially deferred;
alter table activity_log alter constraint activity_log_actor_member_fkey deferrable initially deferred;

-- +goose StatementBegin
create function assert_expense_totals(expense uuid) returns void language plpgsql as $$
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

-- +goose StatementBegin
create function check_expense_totals() returns trigger language plpgsql as $$
begin
  if tg_table_name = 'expenses' then
    if tg_op <> 'DELETE' then
      perform assert_expense_totals(new.id);
    end if;
  else
    if tg_op <> 'INSERT' then
      perform assert_expense_totals(old.expense_id);
    end if;
    if tg_op <> 'DELETE' then
      if tg_op = 'INSERT' or new.expense_id is distinct from old.expense_id then
        perform assert_expense_totals(new.expense_id);
      end if;
    end if;
  end if;
  return null;
end;
$$;
-- +goose StatementEnd

create constraint trigger expenses_totals
after insert or update on expenses deferrable initially deferred
for each row execute function check_expense_totals();

create constraint trigger expense_payers_totals
after insert or update or delete on expense_payers deferrable initially deferred
for each row execute function check_expense_totals();

create constraint trigger expense_splits_totals
after insert or update or delete on expense_splits deferrable initially deferred
for each row execute function check_expense_totals();

-- +goose Down

drop trigger expense_splits_totals on expense_splits;
drop trigger expense_payers_totals on expense_payers;
drop trigger expenses_totals on expenses;
drop function check_expense_totals();
drop function assert_expense_totals(uuid);

alter table expense_payers alter constraint expense_payers_member_id_fkey not deferrable;
alter table expense_splits alter constraint expense_splits_member_id_fkey not deferrable;
alter table expenses alter constraint expenses_created_by_member_fkey not deferrable;
alter table activity_log alter constraint activity_log_actor_member_fkey not deferrable;
