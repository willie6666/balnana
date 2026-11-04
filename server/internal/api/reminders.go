package api

import (
	"context"

	"github.com/jackc/pgx/v5"

	"balnana/internal/domain"
)

// RemindMember tells the member's phones what they owe whoever asks, under
// the suggested payments. Nothing limits how often: the request limiter is
// enough, and only someone owed money can send one.
func (s *Server) RemindMember(ctx context.Context, req RemindMemberRequestObject) (RemindMemberResponseObject, error) {
	var g *group
	var members []member
	var nets map[string]int64
	var who *string
	err := s.groupSnapshot(ctx, req.Token, func(tx pgx.Tx, found *group) (err error) {
		g = found
		if who, err = actor(ctx, tx, g, req.Params.XBalnanaMember); err != nil {
			return err
		}
		if members, err = groupMembers(ctx, tx, g.id); err != nil {
			return err
		}
		if findMember(members, req.MemberId) == nil {
			return errNotFound
		}
		if s.conf().Billing {
			p, _, err := groupPlan(ctx, tx, g)
			if err != nil {
				return err
			}
			if !p.reminders {
				return planLimit("reminders", 0)
			}
		}
		nets, err = groupNets(ctx, tx, g.id)
		return err
	})
	if err != nil {
		return nil, err
	}
	transfers, err := domain.Simplify(nets)
	if err != nil {
		return nil, err
	}
	var owed *int64
	for _, t := range transfers {
		if who != nil && t.From == req.MemberId && t.To == *who {
			owed = &t.Amount
		}
	}
	if owed == nil {
		return nil, conflict("nothing_owed")
	}
	if s.push == nil {
		return RemindMember200JSONResponse{Devices: 0}, nil
	}
	devices, err := s.pushDevices(ctx, g, []string{req.MemberId})
	if err != nil {
		return nil, err
	}
	if len(devices) > 0 {
		n := notification{
			Group:   g.token,
			Expense: req.MemberId,
			Title:   clip(g.name),
			Key:     "push_reminder",
			Args:    []string{clip(findMember(members, *who).name), pushAmount(g, domain.FormatAmount(*owed, g.digits))},
		}
		s.pushing.Add(1)
		go func() {
			defer s.pushing.Done()
			ctx, cancel := context.WithTimeout(context.Background(), pushTimeout)
			defer cancel()
			s.sendAll(ctx, g, devices, n)
		}()
	}
	return RemindMember200JSONResponse{Devices: len(devices)}, nil
}
