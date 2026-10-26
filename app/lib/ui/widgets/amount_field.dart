import 'package:flutter/services.dart';

import '../../core/money.dart';

/// Lets through a plain decimal number with at most [digits] decimals.
/// A comma counts as the decimal point, so either keyboard works.
class AmountFormatter extends TextInputFormatter {
  AmountFormatter(int digits) : _pattern = RegExp(digits == 0 ? r'^\d*$' : '^\\d*([.,]\\d{0,$digits})?\$');

  final RegExp _pattern;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      _pattern.hasMatch(newValue.text) ? newValue : oldValue;
}

/// Minor units from what someone typed, or null when it is empty or not a
/// number. Throws [MoneyException] for amounts that are too large.
BigInt? parseInput(String text, int digits) {
  final s = text.trim().replaceAll(',', '.');
  if (s.isEmpty || s == '.') return null;
  try {
    return parseAmount(s.startsWith('.') ? '0$s' : (s.endsWith('.') ? s.substring(0, s.length - 1) : s), digits);
  } on MoneyException catch (e) {
    if (e.error == MoneyError.amountTooLarge) rethrow;
    return null;
  }
}

/// The decimal string the API expects for a share typed as [text], or "".
String shareValue(String text) {
  var s = text.trim().replaceAll(',', '.');
  if (s.startsWith('.')) s = '0$s';
  if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  return s;
}
