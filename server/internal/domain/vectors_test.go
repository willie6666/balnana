package domain

import (
	"encoding/json"
	"errors"
	"os"
	"reflect"
	"strconv"
	"testing"
)

// vectors mirrors api/testdata/money.json, shared with the Dart tests.
type vectors struct {
	Parse []struct {
		Input  string `json:"input"`
		Digits int    `json:"digits"`
		Minor  string `json:"minor"`
		Error  string `json:"error"`
	} `json:"parse"`
	Format []struct {
		Minor  string `json:"minor"`
		Digits int    `json:"digits"`
		Output string `json:"output"`
	} `json:"format"`
	Split []struct {
		Name   string `json:"name"`
		Amount string `json:"amount"`
		Digits int    `json:"digits"`
		Method string `json:"method"`
		Parts  []struct {
			Member string `json:"member"`
			Value  string `json:"value"`
		} `json:"parts"`
		Expect map[string]string `json:"expect"`
		Error  string            `json:"error"`
	} `json:"split"`
	Settle []struct {
		Name   string            `json:"name"`
		Digits int               `json:"digits"`
		Nets   map[string]string `json:"nets"`
		Expect []struct {
			From   string `json:"from"`
			To     string `json:"to"`
			Amount string `json:"amount"`
		} `json:"expect"`
		Error string `json:"error"`
	} `json:"settle"`
	Spread []struct {
		Name    string            `json:"name"`
		Total   string            `json:"total"`
		Amounts map[string]string `json:"amounts"`
		Expect  map[string]string `json:"expect"`
		Error   string            `json:"error"`
	} `json:"spread"`
	CurrencyDigits map[string]int `json:"currencyDigits"`
}

func loadVectors(t *testing.T) vectors {
	t.Helper()
	data, err := os.ReadFile("../../../api/testdata/money.json")
	if err != nil {
		t.Fatal(err)
	}
	var v vectors
	if err := json.Unmarshal(data, &v); err != nil {
		t.Fatal(err)
	}
	return v
}

func codeOf(err error) string {
	var c Code
	if errors.As(err, &c) {
		return string(c)
	}
	if err != nil {
		return err.Error()
	}
	return ""
}

func TestParseVectors(t *testing.T) {
	for _, c := range loadVectors(t).Parse {
		got, err := ParseAmount(c.Input, c.Digits)
		if c.Error != "" {
			if codeOf(err) != c.Error {
				t.Errorf("ParseAmount(%q, %d): error %q, want %q", c.Input, c.Digits, codeOf(err), c.Error)
			}
			continue
		}
		if err != nil || strconv.FormatInt(got, 10) != c.Minor {
			t.Errorf("ParseAmount(%q, %d) = %d, %v; want %s", c.Input, c.Digits, got, err, c.Minor)
		}
	}
}

func TestFormatVectors(t *testing.T) {
	for _, c := range loadVectors(t).Format {
		minor, _ := strconv.ParseInt(c.Minor, 10, 64)
		if got := FormatAmount(minor, c.Digits); got != c.Output {
			t.Errorf("FormatAmount(%d, %d) = %q, want %q", minor, c.Digits, got, c.Output)
		}
	}
}

func TestSplitVectors(t *testing.T) {
	for _, c := range loadVectors(t).Split {
		t.Run(c.Name, func(t *testing.T) {
			total, err := ParseAmount(c.Amount, c.Digits)
			if err != nil {
				t.Fatal(err)
			}
			parts := make([]Part, len(c.Parts))
			for i, p := range c.Parts {
				parts[i] = Part{Member: p.Member, Value: p.Value}
			}
			got, err := Split(total, c.Digits, SplitMethod(c.Method), parts)
			if c.Error != "" {
				if codeOf(err) != c.Error {
					t.Fatalf("error %q, want %q", codeOf(err), c.Error)
				}
				return
			}
			if err != nil {
				t.Fatal(err)
			}
			formatted := map[string]string{}
			var sum int64
			for m, v := range got {
				formatted[m] = FormatAmount(v, c.Digits)
				sum += v
			}
			if !reflect.DeepEqual(formatted, c.Expect) {
				t.Fatalf("got %v, want %v", formatted, c.Expect)
			}
			if sum != total {
				t.Fatalf("parts add up to %d, want %d", sum, total)
			}
		})
	}
}

func TestSettleVectors(t *testing.T) {
	for _, c := range loadVectors(t).Settle {
		t.Run(c.Name, func(t *testing.T) {
			nets := map[string]int64{}
			for m, s := range c.Nets {
				v, err := ParseAmount(s, c.Digits)
				if err != nil {
					t.Fatal(err)
				}
				nets[m] = v
			}
			got, err := Simplify(nets)
			if c.Error != "" {
				if codeOf(err) != c.Error {
					t.Fatalf("error %q, want %q", codeOf(err), c.Error)
				}
				return
			}
			if err != nil {
				t.Fatal(err)
			}
			if len(got) != len(c.Expect) {
				t.Fatalf("got %d transfers %v, want %d", len(got), got, len(c.Expect))
			}
			for i, e := range c.Expect {
				g := got[i]
				if g.From != e.From || g.To != e.To || FormatAmount(g.Amount, c.Digits) != e.Amount {
					t.Errorf("transfer %d = %+v, want %+v", i, g, e)
				}
			}
		})
	}
}

func TestSpreadVectors(t *testing.T) {
	for _, c := range loadVectors(t).Spread {
		t.Run(c.Name, func(t *testing.T) {
			total, _ := strconv.ParseInt(c.Total, 10, 64)
			amounts := map[string]int64{}
			for m, s := range c.Amounts {
				amounts[m], _ = strconv.ParseInt(s, 10, 64)
			}
			got, err := Spread(total, amounts)
			if c.Error != "" {
				if codeOf(err) != c.Error {
					t.Fatalf("error %q, want %q", codeOf(err), c.Error)
				}
				return
			}
			if err != nil {
				t.Fatal(err)
			}
			formatted := map[string]string{}
			for m, v := range got {
				formatted[m] = strconv.FormatInt(v, 10)
			}
			if !reflect.DeepEqual(formatted, c.Expect) {
				t.Fatalf("got %v, want %v", formatted, c.Expect)
			}
		})
	}
}

func TestCurrencyDigitsVectors(t *testing.T) {
	for currency, want := range loadVectors(t).CurrencyDigits {
		if got := CurrencyDigits(currency); got != want {
			t.Errorf("CurrencyDigits(%q) = %d, want %d", currency, got, want)
		}
	}
}
