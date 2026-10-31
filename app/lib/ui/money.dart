import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../core/currencies.dart';
import '../core/money.dart';
import 'colors.dart';

/// Formats [minor] units of [currency] for display, e.g. "$1,234.50" or
/// "-NT$300". The sign comes first; [signed] adds "+" to positive amounts.
String formatMoney(
  BuildContext context,
  BigInt minor,
  int digits,
  String currency, {
  bool signed = false,
  String? symbol,
}) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  symbol = moneySymbol(locale, currency, symbol);
  final number = formatAmountLocalized(minor.abs(), digits, locale);
  final sign = minor.isNegative ? '-' : (signed && minor > BigInt.zero ? '+' : '');
  return '$sign$symbol$number';
}

/// What amounts start with: the group's own [symbol] when it has one, else
/// [currencySymbol]. A symbol ending in a letter, such as "TWD", gets a space.
String moneySymbol(String locale, String currency, String? symbol) {
  if (symbol == null || symbol.isEmpty) return currencySymbol(locale, currency);
  return RegExp(r'\p{L}$', unicode: true).hasMatch(symbol) ? '$symbol ' : symbol;
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
  'CLF' || 'UYW' => 4,
  _ => 2,
};

/// The currency of [locale]'s region, if it has one. A language alone says
/// nothing about money: Arabic runs from Morocco to Oman.
String? localCurrency(Locale locale) => regionCurrencies[locale.countryCode];
