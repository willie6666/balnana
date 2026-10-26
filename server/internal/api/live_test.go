package api

import (
	"bufio"
	"context"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

// liveClient is a client whose server listens for changes, served over real
// HTTP so event streams can stay open.
func liveClient(t *testing.T, env map[string]string) (*client, *httptest.Server) {
	s := NewServer(baseConfig(t, env), testDB(t), slog.New(slog.DiscardHandler), "test")
	ctx, cancel := context.WithCancel(context.Background())
	go s.ListenForChanges(ctx)
	t.Cleanup(func() {
		cancel()
		<-s.hub.done
	})
	select {
	case <-s.hub.ready:
	case <-time.After(5 * time.Second):
		t.Fatal("not listening for changes")
	}
	c := &client{t: t, h: NewHandler(s, http.NotFoundHandler())}
	ts := httptest.NewServer(c.h)
	t.Cleanup(ts.Close)
	return c, ts
}

// events opens a group's event stream as c and returns the names of the
// events that arrive; the channel closes with the stream.
func (c *client) events(ts *httptest.Server, token string) <-chan string {
	c.t.Helper()
	ctx, cancel := context.WithCancel(context.Background())
	c.t.Cleanup(cancel)
	req, _ := http.NewRequestWithContext(ctx, "GET", ts.URL+BasePath+"/g/"+token+"/events", nil)
	if c.token != "" {
		req.Header.Set("Authorization", "Bearer "+c.token)
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		c.t.Fatal(err)
	}
	if res.StatusCode != 200 || res.Header.Get("Content-Type") != "text/event-stream" {
		c.t.Fatalf("events: %s %s", res.Status, res.Header.Get("Content-Type"))
	}
	out := make(chan string, 10)
	sc := bufio.NewScanner(res.Body)
	if !sc.Scan() || !strings.HasPrefix(sc.Text(), "retry: ") {
		c.t.Fatalf("stream starts with %q", sc.Text())
	}
	go func() {
		defer close(out)
		defer res.Body.Close()
		for sc.Scan() {
			if name, ok := strings.CutPrefix(sc.Text(), "event: "); ok {
				out <- name
			}
		}
	}()
	return out
}

func nextEvent(t *testing.T, events <-chan string) string {
	t.Helper()
	select {
	case e, ok := <-events:
		if !ok {
			return "closed"
		}
		return e
	case <-time.After(5 * time.Second):
		t.Fatal("no event")
		return ""
	}
}

func noEvent(t *testing.T, events <-chan string) {
	t.Helper()
	select {
	case e := <-events:
		t.Fatalf("unexpected event %q", e)
	case <-time.After(200 * time.Millisecond):
	}
}

func TestEventsLinkMode(t *testing.T) {
	c, ts := liveClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben")
	other := createGroup(c, "Cy")
	path := "/g/" + g.Token
	events := c.events(ts, g.Token)
	noEvent(t, events)

	c.must(201, "POST", path+"/members", MemberInput{Name: "Dee"}, nil)
	if e := nextEvent(t, events); e != "change" {
		t.Fatalf("event %q", e)
	}
	// Changes to other groups and failed writes send nothing.
	c.must(201, "POST", "/g/"+other.Token+"/members", MemberInput{Name: "Eve"}, nil)
	c.errorCode(409, "POST", path+"/members", MemberInput{Name: "dee"})
	noEvent(t, events)

	// The old link stops working, and so does its stream.
	c.must(200, "POST", path+"/reset-link", nil, nil)
	if e := nextEvent(t, events); e != "gone" {
		t.Fatalf("event %q", e)
	}
	if e := nextEvent(t, events); e != "closed" {
		t.Fatalf("event %q after gone", e)
	}

	if code := c.errorCode(404, "GET", path+"/events", nil); code != "not_found" {
		t.Fatal(code)
	}
}

func TestEventsAccounts(t *testing.T) {
	ana, ts := liveClient(t, map[string]string{"BALNANA_AUTH_MODE": "accounts"})
	register(ana, "ana@example.com", "Ana")
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana"}}, &g)
	path := "/g/" + g.Token

	ben := ana.another()
	register(ben, "ben@example.com", "Ben")
	if code := ben.errorCode(403, "GET", path+"/events", nil); code != "not_a_member" {
		t.Fatal(code)
	}
	ana.must(200, "PATCH", path, GroupUpdate{LinkAccess: ptr(true)}, nil)
	var joined Group
	ben.must(200, "POST", path+"/join", JoinInput{}, &joined)
	ana.must(200, "PATCH", path, GroupUpdate{LinkAccess: ptr(false)}, nil)

	anaEvents, benEvents := ana.events(ts, g.Token), ben.events(ts, g.Token)
	ana.must(200, "PATCH", path, GroupUpdate{Name: ptr("Flat 2")}, nil)
	for _, events := range []<-chan string{anaEvents, benEvents} {
		if e := nextEvent(t, events); e != "change" {
			t.Fatalf("event %q", e)
		}
	}

	// Ben leaves: his stream ends, Ana's carries on.
	ben.must(204, "DELETE", path+"/members/"+*joined.MyMemberId, nil, nil)
	if e := nextEvent(t, benEvents); e != "gone" {
		t.Fatalf("ben: event %q", e)
	}
	if e := nextEvent(t, anaEvents); e != "change" {
		t.Fatalf("ana: event %q", e)
	}

	// Signing out ends the stream at the next change.
	ana.must(204, "POST", "/auth/logout", nil, nil)
	again := ana.another()
	var s Session
	again.must(200, "POST", "/auth/login", LoginInput{Login: "ana@example.com", Password: "correct horse"}, &s)
	again.token = *s.Token
	again.must(201, "POST", path+"/members", MemberInput{Name: "Cy"}, nil)
	if e := nextEvent(t, anaEvents); e != "gone" {
		t.Fatalf("ana after signing out: event %q", e)
	}
}
