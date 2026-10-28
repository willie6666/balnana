-- +goose Up

-- Where an expense happened: a name people typed, a point on the map, or both.
alter table expenses
    add column location_name text,
    add column latitude double precision,
    add column longitude double precision,
    add constraint expenses_location_point check (
        (latitude is null) = (longitude is null)
        and (latitude is null or (latitude between -90 and 90 and longitude between -180 and 180))
    );

-- +goose Down

alter table expenses
    drop constraint expenses_location_point,
    drop column longitude,
    drop column latitude,
    drop column location_name;
