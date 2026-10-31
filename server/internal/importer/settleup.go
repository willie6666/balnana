// Package importer reads other apps' group exports.
package importer

import (
	"bytes"
	"encoding/csv"
	"errors"
	"io"
	"strings"
	"time"
	"unicode/utf16"
	"unicode/utf8"
)

// MaxRows bounds an import.
const MaxRows = 20_000

// MaxRowParts bounds the names in one column of a row, and MaxParts those in
// a file. A name costs far more in memory than its few bytes in the file.
const (
	MaxRowParts = 500
	MaxParts    = 400_000
)

// Part is one person on a row, with an amount as written in the file.
type Part struct {
	Name   string
	Amount string
}

// Entry is one row of a Settle Up export.
type Entry struct {
	Line     int    // in the file, counting the header as 1
	Type     string // "expense", "transfer" or "income"
	Payers   []Part // who paid, with the amounts in Currency
	Currency string
	ForWhom  []Part // with the split amounts in Currency, which Settle Up rounds
	Purpose  string
	Category string
	Time     time.Time // UTC
	// Rate is empty when Currency is the group's currency. Otherwise
	// Converted holds the amount in the group's currency: one total, or
	// one per payer.
	Rate      string
	Converted []string
}

// File is a whole export.
type File struct {
	Entries []Entry
	// People in the order they first appear. Names that differ only in case
	// are one person, spelled as first seen.
	People []string
}

// Error says why a file or one of its rows cannot be read. Line is 0 for
// the file as a whole.
type Error struct {
	Line    int
	Problem string
}

func (e *Error) Error() string { return e.Problem }

// File problems.
const (
	ProblemEncoding    = "encoding"
	ProblemHeader      = "header"
	ProblemEmpty       = "empty"
	ProblemTooManyRows = "too_many_rows"
)

// Row problems.
const (
	ProblemNames  = "names"  // a row without payers or people it is for
	ProblemCounts = "counts" // the numbers of names and amounts differ, or are too large
	ProblemDate   = "date"
	ProblemType   = "type"
	ProblemCSV    = "csv"
)

var settleUpColumns = map[string]string{
	"who paid":         "payers",
	"amount":           "amount",
	"currency":         "currency",
	"for whom":         "for",
	"split amounts":    "splits",
	"purpose":          "purpose",
	"category":         "category",
	"date & time":      "time",
	"exchange rate":    "rate",
	"converted amount": "converted",
	"type":             "type",
}

// The order Settle Up writes, used when the header is in another language.
var settleUpOrder = []string{"payers", "amount", "currency", "for", "splits", "purpose", "category", "time", "", "rate", "converted", "type"}

var timeLayouts = []string{"2006-01-02 15:04:05", "2006-01-02 15:04", "2006-01-02T15:04:05Z07:00", "2006-01-02"}

// SettleUp reads the CSV that Settle Up exports for a group. Its times are
// UTC; the timezone column only says where the entry was made.
func SettleUp(data []byte) (*File, error) {
	text, err := decode(data)
	if err != nil {
		return nil, err
	}
	r := csv.NewReader(strings.NewReader(text))
	r.Comma = delimiter(text)
	r.FieldsPerRecord = -1
	r.LazyQuotes = true

	header, err := r.Read()
	if err != nil {
		return nil, &Error{Problem: ProblemHeader}
	}
	cols := map[string]int{}
	for i, h := range header {
		if key, ok := settleUpColumns[strings.ToLower(strings.TrimSpace(h))]; ok {
			cols[key] = i
		}
	}
	if len(cols) == 0 && len(header) >= len(settleUpOrder) {
		for i, key := range settleUpOrder {
			if key != "" {
				cols[key] = i
			}
		}
	}
	for _, key := range []string{"payers", "amount", "currency", "for", "splits", "time"} {
		if _, ok := cols[key]; !ok {
			return nil, &Error{Problem: ProblemHeader}
		}
	}

	f := &File{}
	people := map[string]string{} // lower case to first spelling
	person := func(name string) string {
		key := strings.ToLower(name)
		if first, ok := people[key]; ok {
			return first
		}
		people[key] = name
		f.People = append(f.People, name)
		return name
	}
	names := 0
	for {
		record, err := r.Read()
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			line := 0
			var pe *csv.ParseError
			if errors.As(err, &pe) {
				line = pe.StartLine
			}
			return nil, &Error{Line: line, Problem: ProblemCSV}
		}
		line, _ := r.FieldPos(0)
		field := func(key string) string {
			i, ok := cols[key]
			if !ok || i >= len(record) {
				return ""
			}
			return strings.TrimSpace(record[i])
		}
		if strings.TrimSpace(strings.Join(record, "")) == "" {
			continue
		}
		if len(f.Entries) == MaxRows {
			return nil, &Error{Problem: ProblemTooManyRows}
		}
		e := Entry{
			Line:     line,
			Type:     strings.ToLower(field("type")),
			Currency: strings.ToUpper(field("currency")),
			Purpose:  field("purpose"),
			Category: field("category"),
			Rate:     field("rate"),
		}
		if e.Type == "" {
			e.Type = "expense"
		}
		if e.Type != "expense" && e.Type != "transfer" && e.Type != "income" {
			return nil, &Error{Line: line, Problem: ProblemType}
		}
		if e.Payers, err = parts(field("payers"), field("amount"), line); err != nil {
			return nil, err
		}
		if e.ForWhom, err = parts(field("for"), field("splits"), line); err != nil {
			return nil, err
		}
		if names += len(e.Payers) + len(e.ForWhom); names > MaxParts {
			return nil, &Error{Problem: ProblemTooManyRows}
		}
		for _, list := range [][]Part{e.Payers, e.ForWhom} {
			for i := range list {
				list[i].Name = person(list[i].Name)
			}
		}
		if c := field("converted"); c != "" {
			e.Converted = split(c)
		}
		if e.Time, err = parseTime(field("time")); err != nil {
			return nil, &Error{Line: line, Problem: ProblemDate}
		}
		f.Entries = append(f.Entries, e)
	}
	if len(f.Entries) == 0 {
		return nil, &Error{Problem: ProblemEmpty}
	}
	return f, nil
}

// parts pairs "a;b" names with "1;2" amounts.
func parts(names, amounts string, line int) ([]Part, error) {
	if strings.Count(names, ";") >= MaxRowParts {
		return nil, &Error{Line: line, Problem: ProblemCounts}
	}
	ns, as := split(names), split(amounts)
	if len(ns) == 0 {
		return nil, &Error{Line: line, Problem: ProblemNames}
	}
	if len(as) != len(ns) {
		return nil, &Error{Line: line, Problem: ProblemCounts}
	}
	out := make([]Part, len(ns))
	for i := range ns {
		if ns[i] == "" {
			return nil, &Error{Line: line, Problem: ProblemNames}
		}
		out[i] = Part{Name: ns[i], Amount: as[i]}
	}
	return out, nil
}

func split(s string) []string {
	if strings.TrimSpace(s) == "" {
		return nil
	}
	out := strings.Split(s, ";")
	for i := range out {
		out[i] = strings.TrimSpace(out[i])
	}
	return out
}

func parseTime(s string) (time.Time, error) {
	for _, layout := range timeLayouts {
		if t, err := time.Parse(layout, s); err == nil {
			return t.UTC(), nil
		}
	}
	return time.Time{}, errors.New("unknown time format")
}

// decode returns the file as UTF-8. Settle Up writes UTF-16 with a byte
// order mark; files saved again by a spreadsheet are often UTF-8.
func decode(data []byte) (string, error) {
	var units []uint16
	switch {
	case bytes.HasPrefix(data, []byte{0xFF, 0xFE}), bytes.HasPrefix(data, []byte{0xFE, 0xFF}):
		big := data[0] == 0xFE
		data = data[2:]
		if len(data)%2 != 0 {
			return "", &Error{Problem: ProblemEncoding}
		}
		units = make([]uint16, len(data)/2)
		for i := range units {
			if big {
				units[i] = uint16(data[2*i])<<8 | uint16(data[2*i+1])
			} else {
				units[i] = uint16(data[2*i+1])<<8 | uint16(data[2*i])
			}
		}
		return string(utf16.Decode(units)), nil
	}
	data = bytes.TrimPrefix(data, []byte{0xEF, 0xBB, 0xBF})
	if !utf8.Valid(data) {
		return "", &Error{Problem: ProblemEncoding}
	}
	return string(data), nil
}

// delimiter guesses the separator from the header line: Settle Up writes
// commas, but spreadsheets in some languages save with semicolons or tabs.
func delimiter(text string) rune {
	header, _, _ := strings.Cut(text, "\n")
	best, bestCount := ',', -1
	for _, c := range []rune{',', ';', '\t'} {
		inQuotes, count := false, 0
		for _, r := range header {
			switch {
			case r == '"':
				inQuotes = !inQuotes
			case r == c && !inQuotes:
				count++
			}
		}
		if count > bestCount {
			best, bestCount = c, count
		}
	}
	return best
}
