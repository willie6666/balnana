package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

// withKey is a client of the same server sending key as the group key.
func (c *client) withKey(key string) *client {
	k := *c
	k.header = http.Header{groupKeyHeader: {key}}
	return &k
}

func TestGroupPasswordLinkMode(t *testing.T) {
	ana := newClient(t)
	g := createGroup(ana, "Ana", "Ben")
	path := "/g/" + g.Token
	if g.HasPassword {
		t.Fatal("new group has a password")
	}
	if code := ana.errorCode(409, "POST", path+"/unlock", GroupPasswordInput{Password: "x"}); code != "no_password" {
		t.Fatal(code)
	}
	if code := ana.errorCode(400, "PUT", path+"/password", GroupPasswordInput{Password: ""}); code != "bad_request" && code != "invalid_password" {
		t.Fatal(code)
	}

	// Setting it gives this device the key.
	var k GroupKey
	ana.must(200, "PUT", path+"/password", GroupPasswordInput{Password: "banana split"}, &k)
	ana = ana.withKey(k.Key)
	ana.must(200, "GET", path, nil, &g)
	if !g.HasPassword {
		t.Fatal("hasPassword is false")
	}

	// Without the key the link no longer opens it, anywhere.
	ben := ana.another()
	for _, p := range []string{path, path + "/expenses", path + "/balances", path + "/activity", path + "/events"} {
		if code := ben.errorCode(403, "GET", p, nil); code != "password_required" {
			t.Fatalf("%s: %s", p, code)
		}
	}
	if code := ben.withKey("nope").errorCode(403, "GET", path, nil); code != "password_required" {
		t.Fatal(code)
	}
	if code := ben.errorCode(403, "PATCH", path, GroupUpdate{Name: ptr("Mine")}); code != "password_required" {
		t.Fatal(code)
	}
	if code := ben.errorCode(403, "DELETE", path+"/password", nil); code != "password_required" {
		t.Fatal(code)
	}
	var sums GroupSummaryList
	ben.must(200, "POST", "/groups/summaries", GroupSummaryRequest{Groups: []struct {
		Key      *string `json:"key,omitempty"`
		MemberId *string `json:"memberId,omitempty"`
		Token    string  `json:"token"`
	}{{Token: g.Token}}}, &sums)
	if len(sums.Groups) != 0 || len(sums.Locked) != 1 {
		t.Fatalf("summaries without key: %+v", sums)
	}

	// The wrong password is refused; the right one gives the same key.
	if code := ben.errorCode(403, "POST", path+"/unlock", GroupPasswordInput{Password: "banana"}); code != "wrong_password" {
		t.Fatal(code)
	}
	var bk GroupKey
	ben.must(200, "POST", path+"/unlock", GroupPasswordInput{Password: "banana split"}, &bk)
	if bk.Key != k.Key {
		t.Fatal("unlock gave another key")
	}
	ben = ben.withKey(bk.Key)
	ben.must(200, "GET", path, nil, nil)
	ben.must(200, "GET", path+"/expenses", nil, nil)
	ben.must(200, "POST", "/groups/summaries", GroupSummaryRequest{Groups: []struct {
		Key      *string `json:"key,omitempty"`
		MemberId *string `json:"memberId,omitempty"`
		Token    string  `json:"token"`
	}{{Token: g.Token, Key: &bk.Key}}}, &sums)
	if len(sums.Groups) != 1 || len(sums.Locked) != 0 {
		t.Fatalf("summaries with key: %+v", sums)
	}
	// The event stream takes the key as a query parameter, for EventSource.
	if rec := get(t, ana.h, BasePath+path+"/events?key=nope", nil); rec.Code != 403 {
		t.Fatalf("events with a wrong key: %d", rec.Code)
	}

	// A new password shuts out the old key.
	var k2 GroupKey
	ana.must(200, "PUT", path+"/password", GroupPasswordInput{Password: "apple crumble"}, &k2)
	if k2.Key == k.Key {
		t.Fatal("new password, same key")
	}
	if code := ben.errorCode(403, "GET", path, nil); code != "password_required" {
		t.Fatal(code)
	}
	ana = ana.withKey(k2.Key)
	ana.must(200, "GET", path, nil, nil)

	// Removing it opens the group to its link again.
	ana.must(204, "DELETE", path+"/password", nil, nil)
	ana.another().must(200, "GET", path, nil, &g)
	if g.HasPassword {
		t.Fatal("hasPassword after removing it")
	}
}

func TestGroupPasswordAccountsMode(t *testing.T) {
	ana := accountsClient(t, map[string]string{})
	register(ana, "ana@example.com", "Ana")
	var g Group
	ana.must(201, "POST", "/groups", GroupCreate{Name: "Flat", Currency: "EUR", Members: []string{"Ana", "Ben"}}, &g)
	path := "/g/" + g.Token
	ana.must(200, "PATCH", path, GroupUpdate{LinkAccess: ptr(true)}, nil)

	// Only the owner sets it, and members need no key.
	var k GroupKey
	ana.must(200, "PUT", path+"/password", GroupPasswordInput{Password: "banana split"}, &k)
	ana.must(200, "GET", path, nil, &g)
	if !g.HasPassword {
		t.Fatal("hasPassword is false")
	}

	// Link access is not enough any more.
	anon := ana.another()
	if code := anon.errorCode(403, "GET", path, nil); code != "password_required" {
		t.Fatal(code)
	}
	anon.withKey(k.Key).must(200, "GET", path, nil, nil)

	// Joining needs the key too, even to see who to join as.
	ben := ana.another()
	register(ben, "ben@example.com", "Ben")
	if code := ben.errorCode(403, "GET", path+"/join", nil); code != "password_required" {
		t.Fatal(code)
	}
	if code := ben.errorCode(403, "POST", path+"/join", JoinInput{}); code != "password_required" {
		t.Fatal(code)
	}
	var bk GroupKey
	ben.must(200, "POST", path+"/unlock", GroupPasswordInput{Password: "banana split"}, &bk)
	keyed := ben.withKey(bk.Key)
	keyed.must(200, "GET", path+"/join", nil, nil)
	var joined Group
	keyed.must(200, "POST", path+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, &joined)

	// Once a member, Ben needs no key, but may not change the password.
	ben.must(200, "GET", path, nil, nil)
	if code := ben.errorCode(403, "PUT", path+"/password", GroupPasswordInput{Password: "mine now"}); code != "owner_only" {
		t.Fatal(code)
	}
	if code := ben.errorCode(403, "DELETE", path+"/password", nil); code != "owner_only" {
		t.Fatal(code)
	}

	// Signed out and members-only, sign-in comes before the password.
	ana.must(200, "PATCH", path, GroupUpdate{LinkAccess: ptr(false)}, nil)
	if code := anon.errorCode(401, "GET", path, nil); code != "sign_in_required" {
		t.Fatal(code)
	}
}

func TestSetGroupPasswordRejectsBeforeHashing(t *testing.T) {
	ana := accountsClient(t, map[string]string{})
	register(ana, "ana@example.com", "Ana")
	g := createGroup(ana, "Ana", "Ben")
	base := "/g/" + g.Token
	ben := ana.another()
	register(ben, "ben@example.com", "Ben")
	ben.must(200, "POST", base+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)
	var key GroupKey
	ana.must(200, "PUT", base+"/password", GroupPasswordInput{Password: "secret"}, &key)
	ana.must(200, "PATCH", base, GroupUpdate{LinkAccess: ptr(true)}, nil)
	closed := createGroup(ana, "Ana", "Ben")

	for _, tc := range []struct {
		name, token, code string
		client            *client
		status            int
	}{
		{"malformed token", "not-a-token", "not_found", ana.another(), 404},
		{"unknown token", newToken(), "not_found", ana.another(), 404},
		{"signed out", closed.Token, "sign_in_required", ana.another(), 401},
		{"missing key", g.Token, "password_required", ana.another(), 403},
		{"wrong key", g.Token, "password_required", ana.another().withKey("wrong"), 403},
		{"non-member", g.Token, "not_a_member", ana.another().withKey(key.Key), 403},
		{"non-owner", g.Token, "owner_only", ben, 403},
	} {
		t.Run(tc.name, func(t *testing.T) {
			// Denied requests must finish even while every hashing slot is
			// occupied by other password operations.
			for range cap(hashSlots) {
				hashSlots <- struct{}{}
			}
			done := make(chan *httptest.ResponseRecorder, 1)
			go func() {
				done <- tc.client.do("PUT", "/g/"+tc.token+"/password", GroupPasswordInput{Password: "anything"})
			}()
			var response *httptest.ResponseRecorder
			select {
			case response = <-done:
			case <-time.After(2 * time.Second):
				t.Error("an unauthorized request waited for a hashing slot")
			}
			for range cap(hashSlots) {
				<-hashSlots
			}
			if response == nil {
				response = <-done
			}
			if response.Code != tc.status {
				t.Fatalf("status %d, want %d: %s", response.Code, tc.status, response.Body)
			}
			var body Error
			if err := json.Unmarshal(response.Body.Bytes(), &body); err != nil {
				t.Fatal(err)
			}
			if body.Code != tc.code {
				t.Fatalf("code %q, want %q", body.Code, tc.code)
			}
		})
	}
}
