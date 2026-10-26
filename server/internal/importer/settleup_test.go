package importer

import (
	"errors"
	"testing"
	"time"
	"unicode/utf16"
)

const header = `"Who paid","Amount","Currency","For whom","Split amounts","Purpose","Category","Date & time","Timezone","Exchange rate","Converted amount","Type","Receipt"` + "\n"

// utf16LE encodes s the way Settle Up writes its export.
func utf16LE(s string) []byte {
	out := []byte{0xFF, 0xFE}
	for _, u := range utf16.Encode([]rune(s)) {
		out = append(out, byte(u), byte(u>>8))
	}
	return out
}

func TestSettleUp(t *testing.T) {
	file := header +
		`"Ana","30.00","USD","Ana;Ben;Cy","10;10;10","Dinner` + "\n" + `at Joe's","🍔","2026-01-02 10:00:00","+08:00","","","expense",""` + "\n" +
		`"ben","20","EUR","ANA;Ben","10;10","Museum"," ","2026-01-03 11:30:00","","1.1","22.00","expense",""` + "\n" +
		"\n" +
		`"Cy","5","USD","Ana","5","","","2026-01-04 08:00","","","","transfer",""` + "\n"
	f, err := SettleUp(utf16LE(file))
	if err != nil {
		t.Fatal(err)
	}
	if got := f.People; len(got) != 3 || got[0] != "Ana" || got[1] != "Ben" || got[2] != "Cy" {
		t.Fatalf("people %q", got)
	}
	if len(f.Entries) != 3 {
		t.Fatalf("%d entries", len(f.Entries))
	}
	e := f.Entries[0]
	if e.Line != 2 || e.Purpose != "Dinner\nat Joe's" || e.Category != "🍔" || e.Payers[0] != (Part{"Ana", "30.00"}) ||
		len(e.ForWhom) != 3 || e.ForWhom[2] != (Part{"Cy", "10"}) || !e.Time.Equal(time.Date(2026, 1, 2, 10, 0, 0, 0, time.UTC)) {
		t.Fatalf("first entry %+v", e)
	}
	e = f.Entries[1]
	if e.Line != 4 || e.Payers[0].Name != "Ben" || e.ForWhom[0].Name != "Ana" || e.Rate != "1.1" || len(e.Converted) != 1 || e.Converted[0] != "22.00" || e.Category != "" {
		t.Fatalf("second entry %+v", e)
	}
	e = f.Entries[2]
	if e.Line != 6 || e.Type != "transfer" || !e.Time.Equal(time.Date(2026, 1, 4, 8, 0, 0, 0, time.UTC)) {
		t.Fatalf("third entry %+v", e)
	}
}

func TestSettleUpSpreadsheetCopy(t *testing.T) {
	// Saved again as UTF-8 with semicolons and without the Type column.
	file := "\uFEFFWho paid;Amount;Currency;For whom;Split amounts;Purpose;Date & time\r\n" +
		`Ana;12.5;JPY;"Ana;Ben";"6.25;6.25";Taxi;2026-02-01` + "\r\n"
	f, err := SettleUp([]byte(file))
	if err != nil {
		t.Fatal(err)
	}
	e := f.Entries[0]
	if e.Type != "expense" || e.Currency != "JPY" || e.Payers[0].Amount != "12.5" || len(e.ForWhom) != 2 || e.Purpose != "Taxi" {
		t.Fatalf("%+v", e)
	}
}

func TestSettleUpErrors(t *testing.T) {
	for _, tc := range []struct {
		name    string
		data    []byte
		line    int
		problem string
	}{
		{"empty", utf16LE(header), 0, ProblemEmpty},
		{"not csv", []byte("hello\nworld\n"), 0, ProblemHeader},
		{"odd utf16", append(utf16LE(header), 0x41), 0, ProblemEncoding},
		{"not utf8", []byte{0xC3, 0x28}, 0, ProblemEncoding},
		{"counts", []byte(header + `"Ana;Ben","5","USD","Ana","5","","","2026-01-01 00:00:00","","","","expense",""` + "\n"), 2, ProblemCounts},
		{"names", []byte(header + `"","5","USD","Ana","5","","","2026-01-01 00:00:00","","","","expense",""` + "\n"), 2, ProblemNames},
		{"date", []byte(header + "\n" + `"Ana","5","USD","Ana","5","","","yesterday","","","","expense",""` + "\n"), 3, ProblemDate},
		{"type", []byte(header + `"Ana","5","USD","Ana","5","","","2026-01-01 00:00:00","","","","loan",""` + "\n"), 2, ProblemType},
	} {
		_, err := SettleUp(tc.data)
		var e *Error
		if !errors.As(err, &e) || e.Line != tc.line || e.Problem != tc.problem {
			t.Errorf("%s: got %v, want line %d %s", tc.name, err, tc.line, tc.problem)
		}
	}
}
