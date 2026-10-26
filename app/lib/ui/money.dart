import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../core/money.dart';
import 'colors.dart';

/// Formats [minor] units of [currency] for display, e.g. "$1,234.50" or
/// "-NT$300". The sign comes first; [signed] adds "+" to positive amounts.
String formatMoney(BuildContext context, BigInt minor, int digits, String currency, {bool signed = false}) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final symbol = currencySymbol(locale, currency);
  final number = formatAmountLocalized(minor.abs(), digits, locale);
  final sign = minor.isNegative ? '-' : (signed && minor > BigInt.zero ? '+' : '');
  return '$sign$symbol$number';
}

/// The symbol people expect for [currency], or the code itself followed by a
/// space when intl knows no better.
String currencySymbol(String locale, String currency) {
  try {
    final symbol = NumberFormat.simpleCurrency(locale: locale, name: currency).currencySymbol;
    return symbol == currency ? '$currency ' : symbol;
  } on ArgumentError {
    return '$currency ';
  }
}

/// Owed amounts in green, owing in red, zero in grey.
Color balanceColor(BuildContext context, BigInt amount) {
  final c = context.bColors;
  if (amount > BigInt.zero) return c.owed;
  if (amount < BigInt.zero) return c.owe;
  return c.settled;
}

/// How many decimals a currency uses; most use 2.
int defaultMinorDigits(String currency) => switch (currency) {
  'BIF' || 'CLP' || 'DJF' || 'GNF' || 'ISK' || 'JPY' || 'KMF' || 'KRW' || 'PYG' || 'RWF' || 'UGX' || 'UYI' ||
  'VND' || 'VUV' || 'XAF' || 'XOF' || 'XPF' => 0,
  'BHD' || 'IQD' || 'JOD' || 'KWD' || 'LYD' || 'OMR' || 'TND' => 3,
  _ => 2,
};

/// The currency of [locale]'s region, or USD.
String localCurrency(Locale locale) {
  try {
    final name = NumberFormat.simpleCurrency(locale: locale.toLanguageTag()).currencyName;
    if (name != null && RegExp(r'^[A-Z]{3}$').hasMatch(name)) return name;
  } on ArgumentError {
    // Unknown locale.
  }
  return 'USD';
}
