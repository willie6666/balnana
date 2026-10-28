// Package domain holds pure money logic: parsing, formatting, splitting and
// settling. Money is always an int64 count of minor units (cents when the
// group has 2 decimal places); floats are never used.
//
// app/lib/core/money.dart implements the same rules. Both are checked against
// api/testdata/money.json, so keep them in step.
package domain

import (
	"errors"
	"strings"
)

// MaxMinor is the largest amount accepted, in minor units. It keeps sums of
// many amounts far away from int64 overflow.
const MaxMinor int64 = 999_999_999_999_999

// MaxDigits is the most decimal places a group (or a share) may have.
const MaxDigits = 4

// Code is a stable machine error code returned to clients, which translate it.
type Code string

func (c Code) Error() string { return string(c) }

const (
	ErrInvalidAmount   Code = "invalid_amount"
	ErrTooManyDecimals Code = "too_many_decimals"
	ErrAmountTooLarge  Code = "amount_too_large"
	ErrNoMembers       Code = "no_members"
	ErrDuplicateMember Code = "duplicate_member"
	ErrInvalidShare    Code = "invalid_share"
	ErrExactTotal      Code = "exact_total"
	ErrNoShares        Code = "no_shares"
	ErrUnbalanced      Code = "unbalanced"
)

// ParseAmount parses a decimal string such as "-12.34" into minor units.
// The syntax is strict: an optional "-", ASCII digits, and an optional "."
// followed by at least one digit. Extra decimal places are accepted only when
// they are zeros.
func ParseAmount(s string, digits int) (int64, error) {
	if digits < 0 || digits > MaxDigits {
		panic("domain: digits out of range")
	}
	neg := strings.HasPrefix(s, "-")
	if neg {
		s = s[1:]
	}
	whole, frac, hasDot := strings.Cut(s, ".")
	if !isDigits(whole) || (hasDot && !isDigits(frac)) {
		return 0, ErrInvalidAmount
	}
	if len(frac) > digits {
		if strings.Trim(frac[digits:], "0") != "" {
			return 0, ErrTooManyDecimals
		}
		frac = frac[:digits]
	}
	frac += strings.Repeat("0", digits-len(frac))

	var n int64
	for _, c := range strings.TrimLeft(whole, "0") + frac {
		if n > (MaxMinor-int64(c-'0'))/10 {
			return 0, ErrAmountTooLarge
		}
		n = n*10 + int64(c-'0')
	}
	if neg {
		n = -n
	}
	return n, nil
}

func isDigits(s string) bool {
	if s == "" {
		return false
	}
	for i := 0; i < len(s); i++ {
		if s[i] < '0' || s[i] > '9' {
			return false
		}
	}
	return true
}

// FormatAmount renders minor units with exactly `digits` decimal places,
// for example 1234 with 2 digits is "12.34". It is the API wire format, not a
// localized display format (the app formats for display).
func FormatAmount(minor int64, digits int) string {
	if digits < 0 || digits > MaxDigits {
		panic("domain: digits out of range")
	}
	var sign string
	u := uint64(minor)
	if minor < 0 {
		sign = "-"
		u = uint64(-minor)
	}
	s := uitoa(u)
	if digits == 0 {
		return sign + s
	}
	if len(s) <= digits {
		s = strings.Repeat("0", digits-len(s)+1) + s
	}
	return sign + s[:len(s)-digits] + "." + s[len(s)-digits:]
}

func uitoa(u uint64) string {
	if u == 0 {
		return "0"
	}
	var b [20]byte
	i := len(b)
	for u > 0 {
		i--
		b[i] = byte('0' + u%10)
		u /= 10
	}
	return string(b[i:])
}

// checkedAdd adds two amounts and reports overflow instead of wrapping.
func checkedAdd(a, b int64) (int64, error) {
	s := a + b
	if (b > 0 && s < a) || (b < 0 && s > a) {
		return 0, errors.New("domain: amount overflow")
	}
	return s, nil
}
