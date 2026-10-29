package domain

// CurrencyDigits is how many decimals currency usually has: most use 2.
// app/lib/ui/money.dart keeps the same list.
func CurrencyDigits(currency string) int {
	switch currency {
	case "BIF", "CLP", "DJF", "GNF", "ISK", "JPY", "KMF", "KRW", "PYG", "RWF", "UGX", "UYI",
		"VND", "VUV", "XAF", "XOF", "XPF":
		return 0
	case "BHD", "IQD", "JOD", "KWD", "LYD", "OMR", "TND":
		return 3
	}
	return 2
}
