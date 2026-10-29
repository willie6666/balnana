package domain

// CurrencyDigits is how many decimals currency usually has: most use 2.
// app/lib/ui/money.dart keeps the same list, and api/testdata/money.json
// holds both to it.
func CurrencyDigits(currency string) int {
	switch currency {
	case "BIF", "CLP", "DJF", "GNF", "ISK", "JPY", "KMF", "KRW", "PYG", "RWF", "UGX", "UYI",
		"VND", "VUV", "XAF", "XOF", "XPF":
		return 0
	case "BHD", "IQD", "JOD", "KWD", "LYD", "OMR", "TND":
		return 3
	case "CLF", "UYW":
		return 4
	}
	return 2
}
