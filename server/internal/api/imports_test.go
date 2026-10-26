package api

import (
	"strings"
	"testing"
	"unicode/utf16"
)

const settleUpHeader = `"Who paid","Amount","Currency","For whom","Split amounts","Purpose","Category","Date & time","Timezone","Exchange rate","Converted amount","Type","Receipt"` + "\n"

// A made-up export: Ana, Ben and Cy in USD, with one row in EUR.
var settleUpRows = []string{
	`"Ana","30.00","USD","Ana;Ben;Cy","10;10;10","Dinner` + "\n" + `at Joe's","🍔","2026-01-02 10:00:00","+08:00","","","expense",""`,
	`"Ben","10","USD","Ana;Cy","3.33;6.66","Taxi"," ","2026-01-03 10:00:00","","","","expense",""`,
	`"ana","20","EUR","Ben;Cy","10;10","Museum"," ","2026-01-04 10:00:00","","1.1","22.00","expense",""`,
	`"Cy","5","USD","Ana","5","","","2026-01-05 10:00:00","","","","transfer",""`,
	`"Ben","12","USD","Ana;Ben;Cy","4;4;4","Deposit back","","2026-01-06 10:00:00","","","","income",""`,
	`"Ana","0","USD","Ben","0","Nothing","","2026-01-07 10:00:00","","","","expense",""`,
	`"Ana","-6","USD","Ana;Ben","-3;-3","","","2026-01-08 10:00:00","","","","expense",""`,
}

func settleUpFile(rows ...string) []byte {
	s := settleUpHeader + strings.Join(rows, "\n") + "\n"
	out := []byte{0xFF, 0xFE}
	for _, u := range utf16.Encode([]rune(s)) {
		out = append(out, byte(u), byte(u>>8))
	}
	return out
}

func importInputFor(file []byte, dryRun bool) ImportInput {
	return ImportInput{Format: SettleUp, File: file, Name: ptr("Flat"), DryRun: ptr(dryRun)}
}

func TestImportSettleUp(t *testing.T) {
	c := newClient(t)
	file := settleUpFile(settleUpRows...)

	var p ImportPreview
	c.must(200, "POST", "/groups/import", importInputFor(file, true), &p)
	if p.Currency != "USD" || p.MinorDigits != 2 || p.Expenses != 5 || p.Payments != 1 || p.Skipped != 1 {
		t.Fatalf("preview %+v", p)
	}
	if p.From == nil || p.From.Format("2006-01-02") != "2026-01-02" || p.To == nil || p.To.Format("2006-01-02") != "2026-01-08" {
		t.Fatalf("dates %v %v", p.From, p.To)
	}
	want := map[string]string{"Ana": "34.67", "Ben": "-16.00", "Cy": "-18.67"}
	if len(p.Members) != 3 {
		t.Fatalf("members %+v", p.Members)
	}
	for _, m := range p.Members {
		if want[m.Name] != m.Balance {
			t.Errorf("preview %s: %s, want %s", m.Name, m.Balance, want[m.Name])
		}
	}

	in := importInputFor(file, false)
	in.Me = ptr("cy")
	var g Group
	c.must(201, "POST", "/groups/import", in, &g)
	if g.Name != "Flat" || g.Currency != "USD" || len(g.Members) != 3 || !g.LinkAccess {
		t.Fatalf("group %+v", g)
	}
	ids := map[string]string{}
	for _, m := range g.Members {
		ids[m.Id] = m.Name
		if want[m.Name] != m.Balance || m.Owner != (m.Name == "Cy") {
			t.Errorf("%s: balance %s owner %v", m.Name, m.Balance, m.Owner)
		}
	}

	base := "/g/" + g.Token
	var page ExpensePage
	c.must(200, "GET", base+"/expenses", nil, &page)
	byTitle := map[string]Expense{}
	for _, e := range page.Items {
		byTitle[e.Title] = e
	}
	if len(page.Items) != 6 {
		t.Fatalf("%d expenses", len(page.Items))
	}
	dinner := byTitle["Dinner at Joe's"]
	if dinner.SplitMethod != "equal" || dinner.CategoryId == nil || *dinner.CategoryId != "food" || dinner.OccurredAt.UTC().Hour() != 10 {
		t.Errorf("dinner %+v", dinner)
	}
	if taxi := byTitle["Taxi"]; taxi.SplitMethod != "shares" {
		t.Errorf("taxi %+v", taxi)
	}
	if museum := byTitle["Museum"]; museum.Amount != "22.00" || ids[museum.Payers[0].MemberId] != "Ana" || museum.CategoryId != nil {
		t.Errorf("museum %+v", museum)
	}
	if back := byTitle["Deposit back"]; back.SplitMethod != "exact" || len(back.Payers) != 3 || len(back.Splits) != 1 || ids[back.Splits[0].MemberId] != "Ben" {
		t.Errorf("income %+v", back)
	}
	if refund := byTitle["Untitled"]; refund.Amount != "6.00" || len(refund.Payers) != 2 {
		t.Errorf("refund %+v", refund)
	}
	if pay := byTitle[""]; pay.Kind != "payment" || ids[pay.Payers[0].MemberId] != "Cy" || ids[pay.Splits[0].MemberId] != "Ana" {
		t.Errorf("transfer %+v", pay)
	}

	var log ActivityPage
	c.must(200, "GET", base+"/activity", nil, &log)
	if len(log.Items) != 2 || log.Items[0].Action != "group.imported" || log.Items[0].Payload["count"] != float64(6) {
		t.Errorf("activity %+v", log.Items)
	}
}

// A cent left over in a tie goes to whoever comes first in the file, so the
// preview always matches the import.
func TestImportLeftoverCent(t *testing.T) {
	c := newClient(t)
	file := settleUpFile(`"Ana","10","USD","Cy;Ben;Ana","3.33;3.33;3.33","Pizza","","2026-01-02 10:00:00","","","","expense",""`)
	want := map[string]string{"Ana": "6.66", "Cy": "-3.33", "Ben": "-3.33"}
	for range 5 {
		var p ImportPreview
		c.must(200, "POST", "/groups/import", importInputFor(file, true), &p)
		for _, m := range p.Members {
			if want[m.Name] != m.Balance {
				t.Fatalf("preview %s: %s, want %s", m.Name, m.Balance, want[m.Name])
			}
		}
		var g Group
		c.must(201, "POST", "/groups/import", importInputFor(file, false), &g)
		for _, m := range g.Members {
			if want[m.Name] != m.Balance {
				t.Fatalf("import %s: %s, want %s", m.Name, m.Balance, want[m.Name])
			}
		}
	}
}

func TestImportErrors(t *testing.T) {
	c := newClient(t)
	importError := func(file []byte, wantCode string, wantParams map[string]any) {
		t.Helper()
		var e Error
		if got := c.call("POST", "/groups/import", importInputFor(file, false), &e); got != 400 || e.Code != wantCode {
			t.Fatalf("status %d code %q, want %s", got, e.Code, wantCode)
		}
		for k, v := range wantParams {
			if e.Params == nil || (*e.Params)[k] != v {
				t.Errorf("%s params %v, want %s=%v", wantCode, e.Params, k, v)
			}
		}
	}
	importError([]byte("nothing here"), "import_file", map[string]any{"problem": "header"})
	importError(settleUpFile(`"Ana","5","EUR","Ben","5","","","2026-01-01 00:00:00","","1.1","","expense",""`), "import_file", map[string]any{"problem": "currency"})
	// The good rows before a bad one are not kept.
	importError(settleUpFile(settleUpRows[0], `"Ana","5","USD","Ana","5","","","2026-01-01 00:00:00","","","","transfer",""`), "import_row", map[string]any{"line": float64(4), "problem": "transfer"})
	importError(settleUpFile(settleUpRows[1], `"Ana","five","USD","Ben","5","Pens","","2026-01-01 00:00:00","","","","expense",""`), "import_row", map[string]any{"line": float64(3), "problem": "amount"})
	importError(settleUpFile(settleUpRows[1], `"Ana;Ben","5","USD","Ben","5","Pens","","2026-01-01 00:00:00","","","","expense",""`), "import_row", map[string]any{"line": float64(3), "problem": "counts"})

	in := importInputFor(settleUpFile(settleUpRows...), false)
	in.Me = ptr("Dee")
	if code := c.errorCode(400, "POST", "/groups/import", in); code != "import_me" {
		t.Errorf("unknown me: %s", code)
	}
	in = importInputFor(settleUpFile(settleUpRows...), false)
	in.Name = ptr(" ")
	if code := c.errorCode(400, "POST", "/groups/import", in); code != "invalid_name" {
		t.Errorf("no name: %s", code)
	}
	// The name may wait until after the preview.
	in.DryRun = ptr(true)
	c.must(200, "POST", "/groups/import", in, nil)

	big := importInputFor(make([]byte, maxImportBody), true)
	if code := c.errorCode(413, "POST", "/groups/import", big); code != "too_large" {
		t.Errorf("big file: %s", code)
	}
	if code := c.errorCode(413, "POST", "/groups", GroupCreate{Name: strings.Repeat("a", maxBody), Currency: "USD", Members: []string{"A"}}); code != "too_large" {
		t.Errorf("big body: %s", code)
	}
}

func TestImportWithAccounts(t *testing.T) {
	c := accountsClient(t, map[string]string{})
	register(c, "ana@example.test", "Ana Account")
	file := settleUpFile(settleUpRows...)
	if code := c.errorCode(400, "POST", "/groups/import", importInputFor(file, false)); code != "import_me" {
		t.Errorf("no me: %s", code)
	}
	c.must(200, "POST", "/groups/import", importInputFor(file, true), nil)
	in := importInputFor(file, false)
	in.Me = ptr("Ben")
	var g Group
	c.must(201, "POST", "/groups/import", in, &g)
	if g.LinkAccess || g.MyMemberId == nil {
		t.Fatalf("group %+v", g)
	}
	for _, m := range g.Members {
		if (m.Id == *g.MyMemberId) != (m.Name == "Ben") || m.Owner != (m.Name == "Ben") {
			t.Errorf("member %+v", m)
		}
	}
	if code := c.another().errorCode(401, "POST", "/groups/import", importInputFor(file, true)); code == "" {
		t.Error("no code without a session")
	}
}
