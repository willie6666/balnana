package api

import (
	"context"
	"fmt"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
	"unicode/utf16"

	"balnana/internal/domain"
	"balnana/internal/importer"
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

// A preview reads the file and touches nothing.
func TestImportDryRunWritesNothing(t *testing.T) {
	c, _, pool := adminClient(t, map[string]string{})
	c.must(200, "POST", "/groups/import", importInputFor(settleUpFile(settleUpRows...), true), nil)
	var groups, members, expenses int
	err := pool.QueryRow(context.Background(), `select (select count(*) from groups),
		(select count(*) from members), (select count(*) from expenses)`).Scan(&groups, &members, &expenses)
	if err != nil {
		t.Fatal(err)
	}
	if groups+members+expenses != 0 {
		t.Fatalf("%d groups, %d members, %d expenses", groups, members, expenses)
	}
}

func TestImportBusy(t *testing.T) {
	old := importWait
	importWait = 50 * time.Millisecond
	t.Cleanup(func() { importWait = old })
	c := newClient(t)
	for range cap(importSlots) {
		importSlots <- struct{}{}
	}
	code := c.errorCode(503, "POST", "/groups/import", importInputFor(settleUpFile(settleUpRows...), true))
	for range cap(importSlots) {
		<-importSlots
	}
	if code != "busy" {
		t.Fatal(code)
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

// Refunds use negative spending and original payer/share roles in reports,
// while the balance ledger keeps the imported incoming-money effects.
func TestImportMemberLimit(t *testing.T) {
	c, _, s := billingServer(t)
	exec(t, s, `update plans set members_per_group = 1 where is_default`)
	u := register(c, "ana@example.test", "Ana")
	file := settleUpFile(settleUpRows...)
	in := importInputFor(file, false)
	in.Me = ptr("Ana")

	if code := c.errorCode(402, "POST", "/groups/import", importInputFor(file, true)); code != "plan_limit" {
		t.Fatal(code)
	}
	c.errorCode(402, "POST", "/groups/import", in)

	// With a plan the whole group comes in, and that plan covers it.
	grant(t, s, u.Id, "plus")
	c.must(200, "POST", "/groups/import", importInputFor(file, true), nil)
	var g Group
	c.must(201, "POST", "/groups/import", in, &g)
	var plan GroupPlan
	c.must(200, "GET", "/g/"+g.Token+"/plan", nil, &plan)
	if plan.PlanName != "Plus" || plan.SponsorMemberId == nil {
		t.Fatalf("%+v", plan)
	}
}

func TestImportIncomingStats(t *testing.T) {
	for _, tc := range []struct {
		refund    int
		converted bool
	}{{4, false}, {10, false}, {4, true}, {10, true}} {
		t.Run(fmt.Sprintf("%d/converted=%v", tc.refund, tc.converted), func(t *testing.T) {
			refund := tc.refund
			c := newClient(t)
			refundRow := fmt.Sprintf(`"Ana","-%d","USD","Ben","-%d","Refund","🍔","2026-02-01 10:00:00","","","","expense",""`, refund, refund)
			if tc.converted {
				refundRow = fmt.Sprintf(`"Ana","-%d","EUR","Ben","-%d","Refund","🍔","2026-02-01 10:00:00","","1","-%d","expense",""`, refund, refund, refund)
			}
			file := settleUpFile(
				`"Ana","10","USD","Ben","10","Purchase","🍔","2026-01-01 10:00:00","","","","expense",""`,
				refundRow,
				`"Ana","7","USD","Ben","7","Income","📦","2026-03-01 10:00:00","","","","income",""`,
			)
			var g Group
			c.must(201, "POST", "/groups/import", importInputFor(file, false), &g)
			base := "/g/" + g.Token
			ids := map[string]string{}
			for _, m := range g.Members {
				ids[m.Name] = m.Id
				want := 10 - refund - 7
				if m.Name == "Ben" {
					want = -want
				}
				if m.Balance != fmt.Sprintf("%d.00", want) {
					t.Fatalf("%s balance %s, want %d", m.Name, m.Balance, want)
				}
			}
			check := func(query, total string, count int, paid, share string) GroupStats {
				t.Helper()
				var stats GroupStats
				c.must(200, "GET", base+"/stats"+query, nil, &stats)
				if stats.Total != total || stats.Count != count {
					t.Fatalf("stats %+v", stats)
				}
				members := map[string]MemberStats{}
				for _, m := range stats.Members {
					members[m.MemberId] = m
				}
				if count > 0 && (members[ids["Ana"]].Paid != paid || members[ids["Ana"]].Share != "0.00" ||
					members[ids["Ben"]].Paid != "0.00" || members[ids["Ben"]].Share != share) {
					t.Fatalf("members %+v", stats.Members)
				}
				return stats
			}
			net := fmt.Sprintf("%d.00", 10-refund)
			all := check("", net, 2, net, net)
			if len(all.Categories) != 1 || *all.Categories[0].CategoryId != "food" || all.Categories[0].Amount != net || all.Categories[0].Count != 2 {
				t.Fatalf("categories %+v", all.Categories)
			}
			negative := fmt.Sprintf("-%d.00", refund)
			if len(all.Months) != 2 || all.Months[0].Amount != "10.00" || all.Months[1].Amount != negative {
				t.Fatalf("months %+v", all.Months)
			}
			check("?to=2026-02-01T00:00:00Z", "10.00", 1, "10.00", "10.00")
			onlyRefund := check("?from=2026-02-01T00:00:00Z&to=2026-03-01T00:00:00Z", negative, 1, negative, negative)
			if onlyRefund.Categories[0].Amount != negative || onlyRefund.Months[0].Amount != negative {
				t.Fatalf("refund %+v", onlyRefund)
			}
			onlyIncome := check("?from=2026-03-01T00:00:00Z", "0.00", 0, "", "")
			if len(onlyIncome.Categories) != 0 || len(onlyIncome.Months) != 0 || len(onlyIncome.Members) != 0 {
				t.Fatalf("income %+v", onlyIncome)
			}
			var page ExpensePage
			c.must(200, "GET", base+"/expenses?category=food&from=2026-02-01T00:00:00Z", nil, &page)
			if len(page.Items) != 1 || page.Items[0].TransactionType != "refund" {
				t.Fatalf("refund filter %+v", page)
			}
			e := page.Items[0]
			// Metadata survives ordinary edits and delete/restore.
			input := ExpenseInput{Title: "Edited refund", Amount: e.Amount, OccurredAt: e.OccurredAt,
				CategoryId: e.CategoryId, SplitMethod: e.SplitMethod, Version: &e.Version}
			for _, p := range e.Payers {
				input.Payers = append(input.Payers, PayerInput{MemberId: p.MemberId, Amount: p.Amount})
			}
			for _, p := range e.Splits {
				input.Splits = append(input.Splits, Share{MemberId: p.MemberId, Value: &p.Amount})
			}
			c.must(200, "PUT", base+"/expenses/"+e.Id, input, &e)
			if e.TransactionType != "refund" {
				t.Fatalf("edit lost direction: %+v", e)
			}
			c.must(204, "DELETE", base+"/expenses/"+e.Id, nil, nil)
			c.must(200, "POST", base+"/expenses/"+e.Id+"/restore", nil, &e)
			check("", net, 2, net, net)
			rec := httptest.NewRecorder()
			c.h.ServeHTTP(rec, httptest.NewRequest("GET", BasePath+base+"/export.csv", nil))
			if rec.Code != 200 || !strings.Contains(rec.Body.String(), ",refund,") || !strings.Contains(rec.Body.String(), ",income,") {
				t.Fatalf("export %d %s", rec.Code, rec.Body)
			}
		})
	}
}

// Rows that would overflow a sum are refused, and weights larger than a
// share may be are kept as the amounts they come to.
func TestImportInputLimits(t *testing.T) {
	ids := map[string]string{"Ana": "a", "Ben": "b"}
	// Each fits, but not twice.
	amount := "9999999999999"
	e := importer.Entry{Type: "expense", Currency: "USD"}
	e.ForWhom = []importer.Part{{Name: "Ana", Amount: "1"}}
	e.Payers = []importer.Part{{Name: "Ana", Amount: amount}, {Name: "Ana", Amount: amount}}
	if _, _, problem := importInput(e, "USD", 2, "Untitled", ids, nil); problem != "amount" {
		t.Errorf("overflowing payers: %q", problem)
	}

	e.Payers = []importer.Part{{Name: "Ana", Amount: "100.00"}}
	e.ForWhom = []importer.Part{{Name: "Ana", Amount: "20000000000"}, {Name: "Ben", Amount: "60000000000"}}
	_, in, problem := importInput(e, "USD", 2, "Untitled", ids, nil)
	if problem != "" || in.SplitMethod != SplitMethod(domain.SplitExact) || len(in.Splits) != 2 ||
		*in.Splits[0].Value != "25.00" || *in.Splits[1].Value != "75.00" {
		t.Fatalf("large weights: %q %+v", problem, in)
	}
}

// The sign of a row says which way its money went.
func TestImportSigns(t *testing.T) {
	ids := map[string]string{"Ana": "a", "Ben": "b"}
	entry := func(kind string, payers, split []importer.Part) importer.Entry {
		return importer.Entry{Type: kind, Currency: "USD", Payers: payers, ForWhom: split}
	}
	ana := func(amount string) importer.Part { return importer.Part{Name: "Ana", Amount: amount} }
	ben := func(amount string) importer.Part { return importer.Part{Name: "Ben", Amount: amount} }

	// Both signs in a split say nothing a split can: no weights fit them.
	e := entry("expense", []importer.Part{ana("100")}, []importer.Part{ana("-20"), ben("120")})
	if _, in, problem := importInput(e, "USD", 2, "Untitled", ids, nil); problem != "amount" {
		t.Errorf("mixed split: %q %+v", problem, in)
	}

	// A whole row of negatives is a refund.
	e = entry("expense", []importer.Part{ana("-12")}, []importer.Part{ana("-6"), ben("-6")})
	_, in, problem := importInput(e, "USD", 2, "Untitled", ids, nil)
	if problem != "" || !importReceived(e, "USD", 2) || len(in.Payers) != 2 || in.Splits[0].MemberId != "a" {
		t.Errorf("refund: %q %+v", problem, in)
	}

	// Income came in, and a negative income went back out.
	e = entry("income", []importer.Part{ana("12")}, []importer.Part{ana("6"), ben("6")})
	_, in, problem = importInput(e, "USD", 2, "Untitled", ids, nil)
	if problem != "" || !importReceived(e, "USD", 2) || len(in.Payers) != 2 || in.Splits[0].MemberId != "a" {
		t.Errorf("income: %q %+v", problem, in)
	}
	e = entry("income", []importer.Part{ana("-12")}, []importer.Part{ana("-6"), ben("-6")})
	_, in, problem = importInput(e, "USD", 2, "Untitled", ids, nil)
	if problem != "" || importReceived(e, "USD", 2) || len(in.Payers) != 1 || in.Payers[0].MemberId != "a" || len(in.Splits) != 2 {
		t.Errorf("negative income: %q %+v", problem, in)
	}

	// What one person paid is what the amounts of their name come to.
	e = entry("expense", []importer.Part{ana("150"), ana("-50")}, []importer.Part{ben("100")})
	_, in, problem = importInput(e, "USD", 2, "Untitled", ids, nil)
	if problem != "" || importReceived(e, "USD", 2) || in.Payers[0].Amount != "100.00" {
		t.Errorf("repeated name: %q %+v", problem, in)
	}
}
