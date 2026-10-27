package api

import (
	"context"
	"encoding/csv"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
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

// A category's name is typed by the group's members, so it is kept from being
// read as a formula as the other text is.
func TestExportCsvCategoryFormula(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben")
	ana, ben := g.Members[0].Id, g.Members[1].Id
	base := "/g/" + g.Token
	names := []string{"=1+1", "+1", "-1", "@SUM(A1)"}
	for i, name := range names {
		var cat Category
		c.must(201, "POST", base+"/categories", CategoryInput{Name: name, Emoji: "\U0001F436"}, &cat)
		c.must(201, "POST", base+"/expenses", ExpenseInput{Title: "Item", CategoryId: &cat.Id, Amount: "1",
			OccurredAt: mustTime(t, "2026-10-0"+string(rune('1'+i))+"T10:00:00Z"),
			Payers:     []PayerInput{{MemberId: ana, Amount: "1"}}, SplitMethod: "equal",
			Splits: []Share{{MemberId: ben}}}, nil)
	}

	rec := httptest.NewRecorder()
	c.h.ServeHTTP(rec, httptest.NewRequest("GET", BasePath+base+"/export.csv", nil))
	if rec.Code != http.StatusOK {
		t.Fatalf("status %d: %s", rec.Code, rec.Body)
	}
	records, err := csv.NewReader(strings.NewReader(strings.TrimPrefix(rec.Body.String(), "\xef\xbb\xbf"))).ReadAll()
	if err != nil {
		t.Fatal(err)
	}
	if len(records) != len(names)+1 {
		t.Fatalf("got %d rows: %q", len(records), records)
	}
	for i, name := range names {
		if got := records[i+1][2]; got != "'"+name {
			t.Errorf("category %q exported as %q", name, got)
		}
	}
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

// exportBarrier commits a writer's change at a precise read boundary in the
// exporter's connection. The writer uses another pool, as a real request does.
type exportBarrier struct {
	before func(string)
}

func (b *exportBarrier) TraceQueryStart(ctx context.Context, _ *pgx.Conn, data pgx.TraceQueryStartData) context.Context {
	b.before(data.SQL)
	return ctx
}
func (*exportBarrier) TraceQueryEnd(context.Context, *pgx.Conn, pgx.TraceQueryEndData) {}

func TestExportCsvSnapshot(t *testing.T) {
	for _, boundary := range []string{"select x.expense_id", "coalesce(c.name, e.category_id"} {
		t.Run(boundary, func(t *testing.T) {
			pool := testDB(t)
			cfg := baseConfig(t, map[string]string{})
			log := slog.New(slog.DiscardHandler)
			writer := &client{t: t, h: NewHandler(NewServer(cfg, pool, log, "test"), http.NotFoundHandler())}
			g := createGroup(writer, "Ana", "Ben")
			base := "/g/" + g.Token
			in := ExpenseInput{Title: "Edit", Amount: "10", OccurredAt: mustTime(t, "2026-01-01T00:00:00Z"),
				Payers:      []PayerInput{{MemberId: g.Members[0].Id, Amount: "10"}},
				SplitMethod: "equal", Splits: []Share{{MemberId: g.Members[1].Id}}}
			var edit, gone, restored Expense
			writer.must(201, "POST", base+"/expenses", in, &edit)
			in.Title = "Delete"
			writer.must(201, "POST", base+"/expenses", in, &gone)
			in.Title = "Restore"
			writer.must(201, "POST", base+"/expenses", in, &restored)
			writer.must(204, "DELETE", base+"/expenses/"+restored.Id, nil, nil)
			baseline := get(t, writer.h, BasePath+base+"/export.csv", nil).Body.String()

			changed := false
			traced := pool.Config()
			traced.ConnConfig.Tracer = &exportBarrier{before: func(sql string) {
				if changed || !strings.Contains(sql, boundary) {
					return
				}
				changed = true
				in.Title, in.Amount, in.Version = "Edited", "20", &edit.Version
				in.Payers[0].Amount = "20"
				writer.must(200, "PUT", base+"/expenses/"+edit.Id, in, nil)
				writer.must(204, "DELETE", base+"/expenses/"+gone.Id, nil, nil)
				writer.must(200, "POST", base+"/expenses/"+restored.Id+"/restore", nil, nil)
				var member Member
				writer.must(201, "POST", base+"/members", MemberInput{Name: "New member"}, &member)
				in.Title, in.Amount, in.Version = "Inserted", "30", nil
				in.Payers[0].Amount = "30"
				in.Splits[0].MemberId = member.Id
				writer.must(201, "POST", base+"/expenses", in, nil)
			}}
			readerPool, err := pgxpool.NewWithConfig(context.Background(), traced)
			if err != nil {
				t.Fatal(err)
			}
			defer readerPool.Close()
			reader := NewHandler(NewServer(cfg, readerPool, log, "test"), http.NotFoundHandler())
			got := get(t, reader, BasePath+base+"/export.csv", nil)
			if !changed || got.Code != 200 || got.Body.String() != baseline {
				t.Fatalf("changed=%v status=%d\ngot %s\nwant %s", changed, got.Code, got.Body, baseline)
			}
			current := get(t, writer.h, BasePath+base+"/export.csv", nil).Body.String()
			if current == baseline || !strings.Contains(current, "New member") || !strings.Contains(current, "Inserted") {
				t.Fatalf("writer did not commit: %s", current)
			}
		})
	}
}

// An expense read while someone edits it is one version throughout: its
// payers and splits never come from a newer one than its amount.
func TestExpenseReadSnapshot(t *testing.T) {
	for _, path := range []string{"", "/expenses"} {
		t.Run("GET"+path, func(t *testing.T) {
			pool := testDB(t)
			cfg := baseConfig(t, map[string]string{})
			log := slog.New(slog.DiscardHandler)
			writer := &client{t: t, h: NewHandler(NewServer(cfg, pool, log, "test"), http.NotFoundHandler())}
			g := createGroup(writer, "Ana", "Ben")
			base := "/g/" + g.Token
			in := ExpenseInput{Title: "Pizza", Amount: "10", OccurredAt: mustTime(t, "2026-01-01T00:00:00Z"),
				Payers:      []PayerInput{{MemberId: g.Members[0].Id, Amount: "10"}},
				SplitMethod: "equal", Splits: []Share{{MemberId: g.Members[1].Id}}}
			var e Expense
			writer.must(201, "POST", base+"/expenses", in, &e)

			changed := false
			traced := pool.Config()
			traced.ConnConfig.Tracer = &exportBarrier{before: func(sql string) {
				if changed || !strings.Contains(sql, "from expense_payers p") {
					return
				}
				changed = true
				in.Amount, in.Version, in.Payers[0].Amount = "20", &e.Version, "20"
				writer.must(200, "PUT", base+"/expenses/"+e.Id, in, nil)
			}}
			readerPool, err := pgxpool.NewWithConfig(context.Background(), traced)
			if err != nil {
				t.Fatal(err)
			}
			defer readerPool.Close()
			reader := &client{t: t, h: NewHandler(NewServer(cfg, readerPool, log, "test"), http.NotFoundHandler())}
			var got Expense
			if path == "" {
				reader.must(200, "GET", base+"/expenses/"+e.Id, nil, &got)
			} else {
				var page ExpensePage
				reader.must(200, "GET", base+"/expenses", nil, &page)
				got = page.Items[0]
			}
			if !changed || got.Amount != "10.00" || got.Version != e.Version ||
				got.Payers[0].Amount != "10.00" || got.Splits[0].Amount != "10.00" {
				t.Fatalf("changed=%v, read %+v", changed, got)
			}
		})
	}
}

// A group or its balances read while someone joins and spends is one state
// throughout: no transfer names a member missing from the members read.
func TestGroupReadSnapshot(t *testing.T) {
	for _, path := range []string{"", "/balances"} {
		t.Run("GET"+path, func(t *testing.T) {
			pool := testDB(t)
			cfg := baseConfig(t, map[string]string{})
			log := slog.New(slog.DiscardHandler)
			writer := &client{t: t, h: NewHandler(NewServer(cfg, pool, log, "test"), http.NotFoundHandler())}
			g := createGroup(writer, "Ana", "Ben")
			base := "/g/" + g.Token

			changed := false
			traced := pool.Config()
			traced.ConnConfig.Tracer = &exportBarrier{before: func(sql string) {
				if changed || !strings.Contains(sql, "select member_id::text, sum(amount)") {
					return
				}
				changed = true
				var m Member
				writer.must(201, "POST", base+"/members", MemberInput{Name: "Cy"}, &m)
				writer.must(201, "POST", base+"/expenses", ExpenseInput{
					Title: "Pizza", Amount: "10", OccurredAt: mustTime(t, "2026-01-01T00:00:00Z"),
					Payers:      []PayerInput{{MemberId: g.Members[0].Id, Amount: "10"}},
					SplitMethod: "equal", Splits: []Share{{MemberId: m.Id}},
				}, nil)
			}}
			readerPool, err := pgxpool.NewWithConfig(context.Background(), traced)
			if err != nil {
				t.Fatal(err)
			}
			defer readerPool.Close()
			reader := &client{t: t, h: NewHandler(NewServer(cfg, readerPool, log, "test"), http.NotFoundHandler())}
			if path == "" {
				var got Group
				reader.must(200, "GET", base, nil, &got)
				if !changed || len(got.Members) != 2 || got.Members[0].Balance != "0.00" {
					t.Fatalf("changed=%v, read %+v", changed, got.Members)
				}
			} else {
				var got Balances
				reader.must(200, "GET", base+path, nil, &got)
				if !changed || len(got.Balances) != 2 || len(got.Transfers) != 0 {
					t.Fatalf("changed=%v, read %+v", changed, got)
				}
			}
		})
	}
}
