package domain

import (
	"fmt"
	"math/rand/v2"
	"testing"
)

// Properties that must hold for any input, beyond the fixed vectors.

func TestFormatParseRoundTrip(t *testing.T) {
	r := rand.New(rand.NewPCG(1, 2))
	for i := 0; i < 10000; i++ {
		digits := r.IntN(MaxDigits + 1)
		v := r.Int64N(2*MaxMinor+1) - MaxMinor
		got, err := ParseAmount(FormatAmount(v, digits), digits)
		if err != nil || got != v {
			t.Fatalf("round trip %d (%d digits): %d, %v", v, digits, got, err)
		}
	}
}

func TestSplitConservesTotal(t *testing.T) {
	r := rand.New(rand.NewPCG(3, 4))
	for i := 0; i < 5000; i++ {
		total := r.Int64N(MaxMinor) + 1
		n := r.IntN(12) + 1
		parts := make([]Part, n)
		for j := range parts {
			parts[j] = Part{Member: fmt.Sprintf("m%02d", j), Value: FormatAmount(r.Int64N(1_000_000), 4)}
		}
		parts[0].Value = "1" // at least one non-zero weight
		for _, method := range []SplitMethod{SplitEqual, SplitShares} {
			got, err := Split(total, 2, method, parts)
			if err != nil {
				t.Fatal(err)
			}
			var sum int64
			for _, v := range got {
				if v < 0 {
					t.Fatalf("negative part %d", v)
				}
				sum += v
			}
			if sum != total {
				t.Fatalf("%s split of %d adds up to %d", method, total, sum)
			}
		}
	}
}

func TestSimplifySettlesEveryone(t *testing.T) {
	r := rand.New(rand.NewPCG(5, 6))
	for i := 0; i < 2000; i++ {
		n := r.IntN(10) + 2
		nets := map[string]int64{}
		var sum int64
		for j := 0; j < n-1; j++ {
			v := r.Int64N(2_000_001) - 1_000_000
			nets[fmt.Sprintf("m%02d", j)] = v
			sum += v
		}
		nets[fmt.Sprintf("m%02d", n-1)] = -sum

		transfers, err := Simplify(nets)
		if err != nil {
			t.Fatal(err)
		}
		if len(transfers) > n-1 {
			t.Fatalf("%d transfers for %d members", len(transfers), n)
		}
		after := map[string]int64{}
		for m, v := range nets {
			after[m] = v
		}
		for _, tr := range transfers {
			if tr.Amount <= 0 {
				t.Fatalf("non-positive transfer %+v", tr)
			}
			after[tr.From] += tr.Amount
			after[tr.To] -= tr.Amount
		}
		for m, v := range after {
			if v != 0 {
				t.Fatalf("%s left with %d", m, v)
			}
		}
	}
}
