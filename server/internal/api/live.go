package api

import (
	"context"
	"errors"
	"net/http"
	"strconv"
	"sync"
	"time"
)

// Live updates: a trigger on activity_log (migration 00005) sends a Postgres
// notice naming the group after every committed change. One connection per
// server listens for them and wakes the event streams open on that group,
// which tell the apps to reload. Notices go through the database, so this
// works with any number of servers behind one database.

const (
	changeChannel = "balnana_group"
	maxStreams    = 10_000
	// Proxies and phones drop connections that stay quiet too long.
	streamPing = 25 * time.Second
	// How long apps wait before connecting again after losing the stream.
	streamRetry = 3 * time.Second
)

// hub fans change notices out to the open event streams.
type hub struct {
	mu      sync.Mutex
	streams map[string]map[chan struct{}]struct{} // by group id
	count   int
	ready   chan struct{} // closed once the server listens for notices
	done    chan struct{} // closed when the server stops listening: streams end
}

func newHub() *hub {
	return &hub{
		streams: map[string]map[chan struct{}]struct{}{},
		ready:   make(chan struct{}),
		done:    make(chan struct{}),
	}
}

// subscribe returns a channel that receives a value when the group changes.
// Several changes in a row may arrive as one.
func (h *hub) subscribe(groupID string) (chan struct{}, error) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if h.count >= maxStreams {
		return nil, &apiError{status: http.StatusServiceUnavailable, code: "busy"}
	}
	ch := make(chan struct{}, 1)
	if h.streams[groupID] == nil {
		h.streams[groupID] = map[chan struct{}]struct{}{}
	}
	h.streams[groupID][ch] = struct{}{}
	h.count++
	return ch, nil
}

func (h *hub) unsubscribe(groupID string, ch chan struct{}) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if _, ok := h.streams[groupID][ch]; !ok {
		return
	}
	delete(h.streams[groupID], ch)
	if len(h.streams[groupID]) == 0 {
		delete(h.streams, groupID)
	}
	h.count--
}

func wake(ch chan struct{}) {
	select {
	case ch <- struct{}{}:
	default: // a change is already waiting to be sent
	}
}

func (h *hub) changed(groupID string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	for ch := range h.streams[groupID] {
		wake(ch)
	}
}

// changedAll wakes every stream: after the listening connection was lost,
// any group may have changed unseen.
func (h *hub) changedAll() {
	h.mu.Lock()
	defer h.mu.Unlock()
	for _, group := range h.streams {
		for ch := range group {
			wake(ch)
		}
	}
}

// ListenForChanges keeps a database connection listening for group changes
// and saved settings
// until ctx ends, then closes all event streams. Run it once per server.
func (s *Server) ListenForChanges(ctx context.Context) {
	defer close(s.hub.done)
	backoff := time.Second
	first := true
	for {
		err := s.listenOnce(ctx, func() {
			if first {
				close(s.hub.ready)
				first = false
			} else {
				s.hub.changedAll()
				// Settings may have changed while nobody was listening.
				go s.reloadSettings(ctx)
			}
			backoff = time.Second
		})
		if ctx.Err() != nil {
			return
		}
		s.log.Warn("live updates: lost the database connection, retrying", "err", err, "in", backoff)
		select {
		case <-time.After(backoff):
		case <-ctx.Done():
			return
		}
		backoff = min(backoff*2, 30*time.Second)
	}
}

func (s *Server) listenOnce(ctx context.Context, listening func()) error {
	pooled, err := s.db.Acquire(ctx)
	if err != nil {
		return err
	}
	// The connection leaves the pool for good: it stays in LISTEN.
	conn := pooled.Hijack()
	defer conn.Close(context.Background())
	if _, err := conn.Exec(ctx, "listen "+changeChannel+"; listen "+settingsChannel); err != nil {
		return err
	}
	listening()
	for {
		n, err := conn.WaitForNotification(ctx)
		if err != nil {
			return err
		}
		if n.Channel == settingsChannel {
			go s.reloadSettings(ctx)
			continue
		}
		s.hub.changed(n.Payload)
	}
}

func (s *Server) GroupEvents(ctx context.Context, req GroupEventsRequestObject) (GroupEventsResponseObject, error) {
	g, err := s.groupByToken(ctx, s.db, req.Token, false)
	if err != nil {
		return nil, err
	}
	ch, err := s.hub.subscribe(g.id)
	if err != nil {
		return nil, err
	}
	return eventStream{s: s, ctx: ctx, token: req.Token, groupID: g.id, changes: ch}, nil
}

// eventStream writes the text/event-stream of one group.
type eventStream struct {
	s       *Server
	ctx     context.Context
	token   string
	groupID string
	changes chan struct{}
}

func (e eventStream) VisitGroupEventsResponse(w http.ResponseWriter) error {
	defer e.s.hub.unsubscribe(e.groupID, e.changes)
	rc := http.NewResponseController(w)
	_ = rc.SetWriteDeadline(time.Time{}) // the stream stays open
	h := w.Header()
	h.Set("Content-Type", "text/event-stream")
	h.Set("Cache-Control", "no-store")
	h.Set("X-Accel-Buffering", "no") // nginx: do not hold events back
	w.WriteHeader(http.StatusOK)

	send := func(msg string) bool {
		if _, err := w.Write([]byte(msg)); err != nil {
			return false
		}
		return rc.Flush() == nil
	}
	if !send("retry: " + strconv.FormatInt(streamRetry.Milliseconds(), 10) + "\n\n") {
		return nil
	}
	ping := time.NewTicker(streamPing)
	defer ping.Stop()
	for {
		select {
		case <-e.ctx.Done():
			return nil
		case <-e.s.hub.done:
			return nil
		case <-ping.C:
			if !send(": ping\n\n") {
				return nil
			}
		case <-e.changes:
			gone, err := e.gone()
			if err != nil {
				e.s.log.Warn("live updates: checking access failed", "err", err)
			}
			if gone {
				send("event: gone\ndata: {}\n\n")
				return nil
			}
			if !send("event: change\ndata: {}\n\n") {
				return nil
			}
		}
	}
}

// gone reports whether the request may no longer see the group: its link
// was reset, the account left or was removed, or the session ended.
func (e eventStream) gone() (bool, error) {
	if st, _ := e.ctx.Value(authKey{}).(*authState); st != nil {
		st.loaded, st.user = false, nil
	}
	_, err := e.s.groupByToken(e.ctx, e.s.db, e.token, false)
	var ae *apiError
	if errors.As(err, &ae) {
		return true, nil
	}
	return false, err
}
