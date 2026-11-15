package api

import (
	"context"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/base64"
	"net/http"
	"strings"
	"unicode/utf8"

	"github.com/jackc/pgx/v5"

	"balnana/internal/config"
)

// A group with a password opens for someone who is not a member only with
// its key: what /unlock gives for the password. The key is derived from the
// password's hash, whose salt is new with every password, so setting one
// shuts every older key out without a table of keys to keep.

const groupKeyHeader = "X-Balnana-Group-Key"

type groupKeyCtx struct{}

// groupKeys puts the group key a request carries in its context: the
// header, or for the event stream a browser's EventSource reads, which
// cannot send headers, the key query parameter.
func groupKeys(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		key := r.Header.Get(groupKeyHeader)
		if key == "" && r.Method == http.MethodGet && strings.HasSuffix(r.URL.Path, "/events") {
			key = r.URL.Query().Get("key")
		}
		if key != "" {
			r = r.WithContext(withGroupKey(r.Context(), &key))
		}
		next.ServeHTTP(w, r)
	})
}

// withGroupKey makes key the one requests in ctx carry; nil for none, as for
// each group of a request about several.
func withGroupKey(ctx context.Context, key *string) context.Context {
	k := ""
	if key != nil {
		k = *key
	}
	return context.WithValue(ctx, groupKeyCtx{}, k)
}

func groupKey(hash string) string {
	sum := sha256.Sum256([]byte("balnana group key\x00" + hash))
	return base64.RawURLEncoding.EncodeToString(sum[:])
}

// keyOpens reports whether key opens g; any key opens a group without a
// password.
func keyOpens(g *group, key string) bool {
	if g.passwordHash == nil {
		return true
	}
	return subtle.ConstantTimeCompare([]byte(key), []byte(groupKey(*g.passwordHash))) == 1
}

// checkGroupKey answers password_required when g has a password, the request
// is not from a member, and its key does not open g.
func checkGroupKey(ctx context.Context, g *group) error {
	if g.me != nil || g.passwordHash == nil {
		return nil
	}
	key, _ := ctx.Value(groupKeyCtx{}).(string)
	if !keyOpens(g, key) {
		return forbidden("password_required")
	}
	return nil
}

func cleanGroupPassword(p string) (string, error) {
	if p == "" || utf8.RuneCountInString(p) > maxPasswordLen || !utf8.ValidString(p) {
		return "", badRequest("invalid_password")
	}
	return p, nil
}

func (s *Server) UnlockGroup(ctx context.Context, req UnlockGroupRequestObject) (UnlockGroupResponseObject, error) {
	password, err := cleanGroupPassword(req.Body.Password)
	if err != nil {
		return nil, err
	}
	g, err := s.findGroup(ctx, s.db, req.Token, false)
	if err != nil {
		return nil, err
	}
	if g.passwordHash == nil {
		return nil, conflict("no_password")
	}
	release, err := s.holdGuess(ctx, "group:"+g.id)
	if err != nil {
		return nil, err
	}
	if !checkPassword(*g.passwordHash, password) {
		return nil, forbidden("wrong_password")
	}
	release()
	return UnlockGroup200JSONResponse{Key: groupKey(*g.passwordHash)}, nil
}

func (s *Server) SetGroupPassword(ctx context.Context, req SetGroupPasswordRequestObject) (SetGroupPasswordResponseObject, error) {
	password, err := cleanGroupPassword(req.Body.Password)
	if err != nil {
		return nil, err
	}
	// Reject requests that cannot manage the group before spending a hash
	// slot. The transaction checks again after hashing, without holding the
	// group locked through that slow work.
	g, err := s.groupByToken(ctx, s.db, req.Token, false)
	if err != nil {
		return nil, err
	}
	if err := s.mayManage(ctx, s.db, g); err != nil {
		return nil, err
	}
	hash := hashPassword(password)
	err = s.changeGroupPassword(ctx, req.Token, req.Params.XBalnanaMember, &hash)
	if err != nil {
		return nil, err
	}
	return SetGroupPassword200JSONResponse{Key: groupKey(hash)}, nil
}

func (s *Server) RemoveGroupPassword(ctx context.Context, req RemoveGroupPasswordRequestObject) (RemoveGroupPasswordResponseObject, error) {
	if err := s.changeGroupPassword(ctx, req.Token, req.Params.XBalnanaMember, nil); err != nil {
		return nil, err
	}
	return RemoveGroupPassword204Response{}, nil
}

func (s *Server) changeGroupPassword(ctx context.Context, token string, member *string, hash *string) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, token, true)
		if err != nil {
			return err
		}
		if err := s.mayManage(ctx, tx, g); err != nil {
			return err
		}
		who, err := actor(ctx, tx, g, member)
		if err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `update groups set password_hash = $2 where id = $1`, g.id, hash); err != nil {
			return err
		}
		if hash != nil {
			// A new password revokes link follows; removing it keeps them.
			// Follows registered concurrently carry the old hash, which
			// pushDevices also checks before sending.
			if _, err := tx.Exec(ctx, `delete from push_follows where group_id = $1`, g.id); err != nil {
				return err
			}
		}
		action := "group.password_set"
		if hash == nil {
			action = "group.password_removed"
		}
		if err := logActivity(ctx, tx, g.id, who, action, nil, map[string]any{"name": g.name}); err != nil {
			return err
		}
		// Open apps reload: those without the new key are asked for it.
		_, err = tx.Exec(ctx, `select pg_notify($1, $2)`, changeChannel, g.id)
		return err
	})
}

// mayManage checks the request may change who can open g or delete it. In
// accounts mode that is its owner; when the owner has gone, any member; and
// when no account is a member any more, anyone the link opens it for. In
// link mode, anyone it is open to.
func (s *Server) mayManage(ctx context.Context, q querier, g *group) error {
	if s.conf().AuthMode != config.AuthModeAccounts || g.owner {
		return nil
	}
	var owned, claimed bool
	err := q.QueryRow(ctx, `
		select exists (select 1 from members
		               where group_id = $1 and is_owner and user_id is not null and left_at is null),
		       exists (select 1 from members
		               where group_id = $1 and user_id is not null and left_at is null)`,
		g.id).Scan(&owned, &claimed)
	if err != nil {
		return err
	}
	if g.me == nil && (!g.open || claimed) {
		return forbidden("not_a_member")
	}
	if owned {
		return forbidden("owner_only")
	}
	return nil
}
