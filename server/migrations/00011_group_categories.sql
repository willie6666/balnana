-- +goose Up

-- A group can add its own categories next to the built-in ones and hide the
-- built-in ones it does not use. Custom categories carry their own name;
-- built-in ones are named by the app, in the reader's language.
alter table categories
  add column group_id   uuid references groups(id) on delete cascade,
  add column name       text,
  add column position   integer not null default 0,
  add column created_at timestamptz not null default now(),
  add constraint categories_custom_named check ((group_id is null) = (name is null));

update categories set position = array_position(
  array['food', 'groceries', 'transport', 'travel', 'lodging', 'rent', 'utilities', 'entertainment', 'shopping',
        'health', 'gifts', 'other'], id)
where group_id is null;

create index categories_by_group on categories (group_id) where group_id is not null;

create table group_hidden_categories (
  group_id    uuid not null references groups(id) on delete cascade,
  category_id text not null references categories(id) on delete cascade,
  primary key (group_id, category_id)
);

-- Deleting a custom category leaves its expenses without one.
alter table expenses
  drop constraint expenses_category_id_fkey,
  add constraint expenses_category_id_fkey foreign key (category_id) references categories(id) on delete set null;

-- +goose Down

alter table expenses
  drop constraint expenses_category_id_fkey,
  add constraint expenses_category_id_fkey foreign key (category_id) references categories(id);
drop table group_hidden_categories;
update expenses set category_id = null where category_id in (select id from categories where group_id is not null);
delete from categories where group_id is not null;
alter table categories
  drop constraint categories_custom_named,
  drop column created_at,
  drop column position,
  drop column name,
  drop column group_id;
