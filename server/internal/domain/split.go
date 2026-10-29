package domain

import (
	"math/big"
	"sort"
)

type SplitMethod string

const (
	SplitEqual  SplitMethod = "equal"
	SplitExact  SplitMethod = "exact"
	SplitShares SplitMethod = "shares"
)

// Part is one participant of a split. Value is ignored for equal splits;
// otherwise it is a decimal string: an amount (exact) or a weight (shares).
// Weights allow up to 4 decimal places.
type Part struct {
	Member string
	Value  string
}

// shareDigits is the precision of share inputs.
const shareDigits = 4

// Split divides total (minor units, > 0) between the parts. The results always
// add up to total exactly.
//
// Weighted splits use the largest-remainder method: everyone gets the floor of
// their exact share, then the leftover minor units go one at a time to the
// largest remainders, ties broken by member id. The result does not depend on
// the order of parts.
func Split(total int64, digits int, method SplitMethod, parts []Part) (map[string]int64, error) {
	if total <= 0 || total > MaxMinor {
		return nil, ErrInvalidAmount
	}
	if len(parts) == 0 {
		return nil, ErrNoMembers
	}
	seen := make(map[string]bool, len(parts))
	for _, p := range parts {
		if seen[p.Member] {
			return nil, ErrDuplicateMember
		}
		seen[p.Member] = true
	}

	switch method {
	case SplitEqual:
		weights := make([]int64, len(parts))
		for i := range weights {
			weights[i] = 1
		}
		return weighted(total, parts, weights), nil

	case SplitExact:
		out := make(map[string]int64, len(parts))
		var sum int64
		for _, p := range parts {
			v, err := ParseAmount(p.Value, digits)
			if err != nil || v < 0 {
				return nil, ErrInvalidShare
			}
			out[p.Member] = v
			sum += v // each v <= MaxMinor and parts are few: no overflow
		}
		if sum != total {
			return nil, ErrExactTotal
		}
		return out, nil

	case SplitShares:
		weights := make([]int64, len(parts))
		var sum int64
		for i, p := range parts {
			w, err := ParseAmount(p.Value, shareDigits)
			if err != nil || w < 0 {
				return nil, ErrInvalidShare
			}
			weights[i] = w
			sum += w
		}
		if sum == 0 {
			return nil, ErrNoShares
		}
		return weighted(total, parts, weights), nil
	}
	return nil, ErrInvalidShare
}

// weighted splits total in proportion to weights (sum > 0). total*weight can
// exceed 64 bits, so the products are computed with math/big.
func weighted(total int64, parts []Part, weights []int64) map[string]int64 {
	var sum int64
	for _, w := range weights {
		sum += w
	}
	bigTotal, bigSum := big.NewInt(total), big.NewInt(sum)

	type slot struct {
		member string
		amount int64
		rem    *big.Int
	}
	slots := make([]slot, len(parts))
	var allocated int64
	for i, p := range parts {
		q, r := new(big.Int).QuoRem(new(big.Int).Mul(bigTotal, big.NewInt(weights[i])), bigSum, new(big.Int))
		slots[i] = slot{member: p.Member, amount: q.Int64(), rem: r}
		allocated += q.Int64()
	}

	sort.Slice(slots, func(i, j int) bool {
		if c := slots[i].rem.Cmp(slots[j].rem); c != 0 {
			return c > 0
		}
		return slots[i].member < slots[j].member
	})
	// leftover < len(parts), since each floor loses less than one unit.
	for i := int64(0); i < total-allocated; i++ {
		slots[i].amount++
	}

	out := make(map[string]int64, len(slots))
	for _, s := range slots {
		out[s.member] = s.amount
	}
	return out
}

// Spread divides total (minor units, > 0) between the members of amounts in
// proportion to them, by the same largest-remainder method as weighted
// splits. It turns what each payer or share of an expense came to in another
// currency into the group's. amounts must not be negative and must add up to
// more than zero.
func Spread(total int64, amounts map[string]int64) (map[string]int64, error) {
	if total <= 0 || total > MaxMinor {
		return nil, ErrInvalidAmount
	}
	if len(amounts) == 0 {
		return nil, ErrNoMembers
	}
	parts := make([]Part, 0, len(amounts))
	weights := make([]int64, 0, len(amounts))
	var sum int64
	for m, v := range amounts {
		if v < 0 || v > MaxMinor {
			return nil, ErrInvalidAmount
		}
		parts = append(parts, Part{Member: m})
		weights = append(weights, v)
		sum += v // each v <= MaxMinor and there are few: no overflow
	}
	if sum == 0 {
		return nil, ErrInvalidAmount
	}
	return weighted(total, parts, weights), nil
}
