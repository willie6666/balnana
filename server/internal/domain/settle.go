package domain

// Transfer is one suggested payment: From pays To the Amount (minor units).
type Transfer struct {
	From   string
	To     string
	Amount int64
}

// Simplify turns net balances (positive = is owed, negative = owes; they must
// add up to zero) into at most n-1 transfers.
//
// Greedy: the largest debtor pays the largest creditor as much as possible,
// repeat. Ties are broken by member id so every client gets the same answer.
func Simplify(nets map[string]int64) ([]Transfer, error) {
	var sum int64
	bal := make(map[string]int64, len(nets))
	for m, v := range nets {
		var err error
		if sum, err = checkedAdd(sum, v); err != nil {
			return nil, err
		}
		if v != 0 {
			bal[m] = v
		}
	}
	if sum != 0 {
		return nil, ErrUnbalanced
	}

	transfers := []Transfer{}
	for len(bal) > 0 {
		debtor, creditor := "", ""
		for m, v := range bal {
			if v < 0 && (debtor == "" || v < bal[debtor] || (v == bal[debtor] && m < debtor)) {
				debtor = m
			}
			if v > 0 && (creditor == "" || v > bal[creditor] || (v == bal[creditor] && m < creditor)) {
				creditor = m
			}
		}
		amount := min(-bal[debtor], bal[creditor])
		transfers = append(transfers, Transfer{From: debtor, To: creditor, Amount: amount})
		if bal[debtor] += amount; bal[debtor] == 0 {
			delete(bal, debtor)
		}
		if bal[creditor] -= amount; bal[creditor] == 0 {
			delete(bal, creditor)
		}
	}
	return transfers, nil
}
