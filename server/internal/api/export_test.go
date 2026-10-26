package api

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestExportCsv(t *testing.T) {
	c, base, m := statsGroup(t)
	ana, ben := m[0], m[1]
	var e Expense
	c.must(201, "POST", base+"/expenses", ExpenseInput{Title: "=SUM(A1)", Amount: "4",
		OccurredAt: mustTime(t, "2026-10-23T10:00:00Z"), Payers: []PayerInput{{MemberId: ana, Amount: "4"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ben}}}, &e)
	c.must(201, "POST", base+"/expenses", ExpenseInput{Title: "Gone", Amount: "7",
		OccurredAt: mustTime(t, "2026-10-24T10:00:00Z"), Payers: []PayerInput{{MemberId: ana, Amount: "7"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ben}}}, &e)
	c.must(204, "DELETE", base+"/expenses/"+e.Id, nil, nil)

	rec := httptest.NewRecorder()
	c.h.ServeHTTP(rec, httptest.NewRequest("GET", BasePath+base+"/export.csv?utcOffset=480", nil))
	if rec.Code != http.StatusOK {
		t.Fatalf("status %d: %s", rec.Code, rec.Body)
	}
	if got := rec.Header().Get("Content-Disposition"); got != `attachment; filename="Trip.csv"; filename*=UTF-8''Trip.csv` {
		t.Fatalf("disposition: %q", got)
	}
	want := "\xef\xbb\xbf" + strings.Join([]string{
		"Date,Title,Category,Type,Amount,Currency,Note,Ana,Ben,Cleo,Dan",
		"2026-10-01,Taxi,transport,expense,30.00,EUR,,15.00,-15.00,0.00,0.00",
		`2026-10-02,Dinner,food,expense,90.00,EUR,100% fun_night,-30.00,60.00,-30.00,0.00`,
		"2026-10-20,Groceries,groceries,expense,12.00,EUR,,6.00,0.00,-6.00,0.00",
		"2026-10-21,Snacks,,expense,6.00,EUR,,0.00,0.00,0.00,0.00",
		"2026-10-22,,,payment,15.00,EUR,,-15.00,15.00,0.00,0.00",
		"2026-10-23,'=SUM(A1),,expense,4.00,EUR,,4.00,-4.00,0.00,0.00",
	}, "\n") + "\n"
	if got := rec.Body.String(); got != want {
		t.Fatalf("got\n%s\nwant\n%s", got, want)
	}

	if code := c.errorCode(400, "GET", base+"/export.csv?utcOffset=-900", nil); code != "invalid_offset" {
		t.Fatalf("bad offset: %q", code)
	}
	c.errorCode(404, "GET", "/g/not-a-group/export.csv", nil)
}

func TestAttachment(t *testing.T) {
	for name, want := range map[string]string{
		"Japan 2026": `attachment; filename="Japan_2026.csv"; filename*=UTF-8''Japan%202026.csv`,
		"🏖":          `attachment; filename="balnana.csv"; filename*=UTF-8''%F0%9F%8F%96.csv`,
		"Café":       `attachment; filename="Caf.csv"; filename*=UTF-8''Caf%C3%A9.csv`,
		`a"b/c`:      `attachment; filename="abc.csv"; filename*=UTF-8''a%22b%2Fc.csv`,
	} {
		if got := attachment(name, ".csv"); got != want {
			t.Errorf("%q: got %q, want %q", name, got, want)
		}
	}
}
