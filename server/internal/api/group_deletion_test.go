package api

import "testing"

func TestDeletingGroupRemovesItForEveryAccount(t *testing.T) {
	ana := accountsClient(t, map[string]string{})
	register(ana, "ana@example.com", "Ana")
	g := createGroup(ana, "Ana", "Ben")
	ben := ana.another()
	register(ben, "ben@example.com", "Ben")
	base := "/g/" + g.Token
	ben.must(200, "POST", base+"/join", JoinInput{ClaimMemberId: &g.Members[1].Id}, nil)
	for _, c := range []*client{ana, ben} {
		var list GroupSummaryList
		c.must(200, "GET", "/me/groups", nil, &list)
		if len(list.Groups) != 1 || list.Groups[0].Token != g.Token {
			t.Fatalf("before deletion: %+v", list)
		}
	}
	ana.must(204, "DELETE", base, nil, nil)
	for _, c := range []*client{ana, ben} {
		var list GroupSummaryList
		c.must(200, "GET", "/me/groups", nil, &list)
		if len(list.Groups) != 0 {
			t.Fatalf("deleted group still listed: %+v", list)
		}
		c.must(404, "GET", base, nil, nil)
	}
}
