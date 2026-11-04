package api

import (
	"context"
	"testing"
)

func TestRenameMemberKeepsOldName(t *testing.T) {
	c, _, pool := adminClient(t, map[string]string{})
	g := createGroup(c, "Ana", "Ben")
	c.must(200, "PATCH", "/g/"+g.Token+"/members/"+g.Members[0].Id, MemberInput{Name: "Anna"}, nil)
	var oldName, name string
	err := pool.QueryRow(context.Background(), `select payload->>'oldName', payload->>'name'
		from activity_log where action = 'member.updated'`).Scan(&oldName, &name)
	if err != nil {
		t.Fatal(err)
	}
	if oldName != "Ana" || name != "Anna" {
		t.Fatalf("rename history: %q -> %q", oldName, name)
	}
}
