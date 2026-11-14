package api

import "testing"

func TestCleanText(t *testing.T) {
	for _, tc := range []struct {
		in, want string
		ok       bool
	}{
		{"  Ana ", "Ana", true},
		{"A\u202eB", "AB", true},
		{"a\nb", "a\nb", true},
		{"a\tb", "", false},
		{"", "", false},
		{"bad \xff byte", "", false},
	} {
		if got, ok := cleanText(tc.in, 1, 10); got != tc.want || ok != tc.ok {
			t.Errorf("cleanText(%q) = %q, %v; want %q, %v", tc.in, got, ok, tc.want, tc.ok)
		}
	}
}
