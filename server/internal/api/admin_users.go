package api

import (
	"context"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
)

// maxAdminUsers is how many accounts one listing shows.
const maxAdminUsers = 200

func (s *Server) ListAdminUsers(ctx context.Context, req ListAdminUsersRequestObject) (ListAdminUsersResponseObject, error) {
	if err := s.requireAdmin(ctx, req.Params.XBalnanaAdmin); err != nil {
		return nil, err
	}
	q := ""
	if req.Params.Q != nil {
		q = strings.TrimSpace(*req.Params.Q)
	}
	// strpos rather than like, so "%" and "_" are just characters.
	const match = `($1 = '' or strpos(lower(u.display_name), lower($1)) > 0
		or strpos(lower(coalesce(u.email::text, '')), lower($1)) > 0
		or strpos(lower(coalesce(u.username::text, '')), lower($1)) > 0)`
	out := AdminUserList{Users: []AdminUser{}}
	if err := s.db.QueryRow(ctx, `select count(*) from users u where `+match, q).Scan(&out.Total); err != nil {
		return nil, err
	}
	rows, err := s.db.Query(ctx, `
		select u.id::text, u.display_name, u.email::text, u.username::text, u.email_verified,
		       u.password_hash is not null, u.created_at,
		       array(select provider from oauth_identities i where i.user_id = u.id order by provider),
		       (select count(*) from members m join groups g on g.id = m.group_id
		        where m.user_id = u.id and m.left_at is null and g.archived_at is null)
		from users u where `+match+`
		order by u.created_at desc limit $2`, q, maxAdminUsers)
	if err != nil {
		return nil, err
	}
	out.Users, err = pgx.CollectRows(rows, func(row pgx.CollectableRow) (AdminUser, error) {
		var a AdminUser
		var created time.Time
		err := row.Scan(&a.Id, &a.Name, &a.Email, &a.Username, &a.EmailVerified, &a.HasPassword, &created,
			&a.Oauth, &a.Groups)
		a.CreatedAt = created.UTC()
		return a, err
	})
	if err != nil {
		return nil, err
	}
	return ListAdminUsers200JSONResponse(out), nil
}

func (s *Server) DeleteAdminUser(ctx context.Context, req DeleteAdminUserRequestObject) (DeleteAdminUserResponseObject, error) {
	if err := s.requireAdmin(ctx, req.Params.XBalnanaAdmin); err != nil {
		return nil, err
	}
	if !validUUID(req.UserId) {
		return nil, errNotFound
	}
	if err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error { return s.deleteAccount(ctx, tx, req.UserId) }); err != nil {
		return nil, err
	}
	s.log.Info("account deleted by the administrator", "user", req.UserId)
	return DeleteAdminUser204Response{}, nil
}
