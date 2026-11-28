-- +goose Up

-- The price the Plan page shows for a product, as the administrator words it.
-- Nothing is charged or matched by it.
alter table plan_products add column display_price text;

-- +goose Down
alter table plan_products drop column display_price;
