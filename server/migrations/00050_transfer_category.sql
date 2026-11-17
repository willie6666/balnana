-- +goose Up

-- Money handed from one member to another is an expense in the built-in
-- "transfer" category, not a kind of its own. It sits just before "other".
update categories set position = 13 where id = 'other' and group_id is null;
insert into categories (id, emoji, color, position) values ('transfer', '💸', x'2E8B8B'::int, 12);

-- Earlier payments become such expenses. They had no title: name them by who
-- paid whom. Their payer and split stay as they are, and so do balances.
update expenses e set
  kind = 'expense',
  category_id = 'transfer',
  title = case when e.title <> '' then e.title else coalesce((
    select left(f.display_name || ' → ' || t.display_name, 200)
    from expense_payers p join members f on f.id = p.member_id,
         expense_splits s join members t on t.id = s.member_id
    where p.expense_id = e.id and s.expense_id = e.id
    limit 1), '→') end
where e.kind = 'payment';

-- Members no longer keep how to pay them.
alter table members drop column payment_details;

-- +goose Down

alter table members add column payment_details jsonb not null default '[]';
update expenses set category_id = null where category_id = 'transfer';
delete from categories where id = 'transfer';
update categories set position = 12 where id = 'other' and group_id is null;
