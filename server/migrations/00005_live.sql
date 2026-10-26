-- +goose Up

-- Every change to a group writes its activity log, so a notice on each new
-- entry tells the servers' open event streams to send it on. Postgres sends
-- notices only when the transaction commits.
-- +goose StatementBegin
create function notify_group_change() returns trigger language plpgsql as $$
begin
  perform pg_notify('balnana_group', new.group_id::text);
  return null;
end
$$;
-- +goose StatementEnd

create trigger activity_log_notify after insert on activity_log
  for each row execute function notify_group_change();

-- +goose Down

drop trigger activity_log_notify on activity_log;
drop function notify_group_change();
