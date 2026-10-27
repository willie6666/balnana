package api

import (
	"context"
	"time"
)

// Requests already ignore sessions, tokens and links that ran out; the sweep
// deletes them so the tables do not grow forever.

const sweepEvery = time.Hour

// archiveKeep is how long a deleted group is kept before it is gone for
// good. Until then the administrator can bring it back by clearing its
// archived_at in the database.
const archiveKeep = 30 * 24 * time.Hour

// expiringTables have an expires_at column.
var expiringTables = []string{"sessions", "email_tokens", "invites", "oauth_logins", "oauth_codes", "admin_sessions"}

// SweepExpired deletes expired rows now and then every hour until ctx ends.
// Several servers sharing the database may each run it.
func (s *Server) SweepExpired(ctx context.Context) {
	tick := time.NewTicker(sweepEvery)
	defer tick.Stop()
	for {
		if n, err := s.sweepExpired(ctx); err != nil && ctx.Err() == nil {
			s.log.Warn("deleting expired rows failed", "err", err)
		} else if n > 0 {
			s.log.Debug("deleted expired rows", "rows", n)
		}
		select {
		case <-tick.C:
		case <-ctx.Done():
			return
		}
	}
}

func (s *Server) sweepExpired(ctx context.Context) (int64, error) {
	var total int64
	for _, table := range expiringTables {
		tag, err := s.db.Exec(ctx, `delete from `+table+` where expires_at < now()`)
		if err != nil {
			return total, err
		}
		total += tag.RowsAffected()
	}
	tag, err := s.db.Exec(ctx, `delete from groups where archived_at < $1`, time.Now().Add(-archiveKeep))
	if err != nil {
		return total, err
	}
	return total + tag.RowsAffected(), nil
}
