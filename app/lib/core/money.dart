/// Exact money: parsing, formatting, splitting and settling.
///
/// Money is a [BigInt] count of minor units (cents when a group has 2 decimal
/// places). Never `double`, and never `int` either: on the web `int` is a
/// JavaScript number and loses precision above 2^53.
///
/// server/internal/domain implements the same rules in Go. Both are checked
/// against api/testdata/money.json, so keep them in step.
library;

import 'package:intl/intl.dart';

/// The largest amount accepted, in minor units.
final maxMinor = BigInt.parse('999999999999999');

/// The most decimal places a group (or a share) may have.
const maxDigits = 4;

/// Stable error codes, shared with the server, which the UI translates.
enum MoneyError {
  invalidAmount('invalid_amount'),
  tooManyDecimals('too_many_decimals'),
  amountTooLarge('amount_too_large'),
  noMembers('no_members'),
  duplicateMember('duplicate_member'),
  invalidShare('invalid_share'),
  exactTotal('exact_total'),
  percentTotal('percent_total'),
  noShares('no_shares'),
  unbalanced('unbalanced');

  const MoneyError(this.code);
  final String code;
}

class MoneyException implements Exception {
  const MoneyException(this.error);
  final MoneyError error;

  @override
  String toString() => 'MoneyException(${error.code})';
}

final _digitsOnly = RegExp(r'^[0-9]+$');

void _checkDigits(int digits) {
  if (digits < 0 || digits > maxDigits) throw ArgumentError.value(digits, 'digits');
}

/// Parses a decimal string such as "-12.34" into minor units.
///
/// The syntax is strict: an optional "-", ASCII digits, and an optional "."
/// followed by at least one digit. Extra decimal places are accepted only when
/// they are zeros. Localized input (other separators, grouping) is the
/// caller's job to normalize first.
///
/// One transaction holds at most [maxMinor]. Pass [total] for a sum of them,
/// such as a balance from the server, which has no such limit.
BigInt parseAmount(String s, int digits, {bool total = false}) {
  _checkDigits(digits);
  final neg = s.startsWith('-');
  if (neg) s = s.substring(1);
  final dot = s.indexOf('.');
  final whole = dot < 0 ? s : s.substring(0, dot);
  var frac = dot < 0 ? '' : s.substring(dot + 1);
  if (!_digitsOnly.hasMatch(whole) || (dot >= 0 && !_digitsOnly.hasMatch(frac))) {
    throw const MoneyException(MoneyError.invalidAmount);
  }
  if (frac.length > digits) {
    if (frac.substring(digits).replaceAll('0', '').isNotEmpty) {
      throw const MoneyException(MoneyError.tooManyDecimals);
    }
    frac = frac.substring(0, digits);
  }
  final n = BigInt.parse(whole + frac.padRight(digits, '0'));
  if (!total && n > maxMinor) throw const MoneyException(MoneyError.amountTooLarge);
  return neg ? -n : n;
}

/// Renders minor units with exactly [digits] decimal places: 1234 with 2
/// digits is "12.34". This is the API wire format; see [formatAmountLocalized]
/// for display.
String formatAmount(BigInt minor, int digits) {
  _checkDigits(digits);
  final sign = minor.isNegative ? '-' : '';
  final s = minor.abs().toString().padLeft(digits + 1, '0');
  if (digits == 0) return '$sign$s';
  final cut = s.length - digits;
  return '$sign${s.substring(0, cut)}.${s.substring(cut)}';
}

/// Renders minor units for people: grouped and with the decimal separator of
/// [locale], e.g. "1,234.50" in English or "1.234,50" in German. No currency
/// symbol. The digits are produced from the integer, never through a double.
String formatAmountLocalized(BigInt minor, int digits, String locale) {
  final symbols = NumberFormat.decimalPattern(locale).symbols;
  final plain = formatAmount(minor.abs(), digits);
  final dot = plain.indexOf('.');
  final whole = dot < 0 ? plain : plain.substring(0, dot);
  final grouped = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) grouped.write(symbols.GROUP_SEP);
    grouped.write(whole[i]);
  }
  final frac = dot < 0 ? '' : '${symbols.DECIMAL_SEP}${plain.substring(dot + 1)}';
  return '${minor.isNegative ? symbols.MINUS_SIGN : ''}$grouped$frac';
}

enum SplitMethod { equal, exact, percent, shares }

/// One participant of a split. [value] is ignored for equal splits; otherwise
/// it is a decimal string: an amount (exact), a percentage (percent) or a
/// weight (shares). Percentages and weights allow up to 4 decimal places.
class SplitPart {
  const SplitPart(this.member, [this.value = '']);
  final String member;
  final String value;
}

const _shareDigits = 4;
final _hundredPercent = BigInt.from(100 * 10000);

/// Divides [total] (minor units, > 0) between [parts]. The results always add
/// up to [total] exactly.
///
/// Weighted splits use the largest-remainder method: everyone gets the floor
/// of their exact share, then the leftover minor units go one at a time to the
/// largest remainders, ties broken by member id. The result does not depend on
/// the order of [parts].
Map<String, BigInt> split(BigInt total, int digits, SplitMethod method, List<SplitPart> parts) {
  if (total <= BigInt.zero || total > maxMinor) throw const MoneyException(MoneyError.invalidAmount);
  if (parts.isEmpty) throw const MoneyException(MoneyError.noMembers);
  if (parts.map((p) => p.member).toSet().length != parts.length) {
    throw const MoneyException(MoneyError.duplicateMember);
  }

  BigInt value(SplitPart p, int digits) {
    try {
      final v = parseAmount(p.value, digits);
      if (!v.isNegative) return v;
    } on MoneyException {
      // Reported as invalidShare below.
    }
    throw const MoneyException(MoneyError.invalidShare);
  }

  switch (method) {
    case SplitMethod.equal:
      return _weighted(total, parts, List.filled(parts.length, BigInt.one));

    case SplitMethod.exact:
      final out = {for (final p in parts) p.member: value(p, digits)};
      if (out.values.fold(BigInt.zero, (a, b) => a + b) != total) {
        throw const MoneyException(MoneyError.exactTotal);
      }
      return out;

    case SplitMethod.percent:
    case SplitMethod.shares:
      final weights = [for (final p in parts) value(p, _shareDigits)];
      final sum = weights.fold(BigInt.zero, (a, b) => a + b);
      if (method == SplitMethod.percent && sum != _hundredPercent) {
        throw const MoneyException(MoneyError.percentTotal);
      }
      if (sum == BigInt.zero) throw const MoneyException(MoneyError.noShares);
      return _weighted(total, parts, weights);
  }
}

Map<String, BigInt> _weighted(BigInt total, List<SplitPart> parts, List<BigInt> weights) {
  final sum = weights.fold(BigInt.zero, (a, b) => a + b);
  final slots = [
    for (final (i, p) in parts.indexed)
      (member: p.member, amount: total * weights[i] ~/ sum, rem: total * weights[i] % sum),
  ];
  final allocated = slots.fold(BigInt.zero, (a, s) => a + s.amount);

  slots.sort((a, b) {
    final c = b.rem.compareTo(a.rem);
    return c != 0 ? c : a.member.compareTo(b.member);
  });
  // leftover < parts.length, since each floor loses less than one unit.
  final leftover = (total - allocated).toInt();
  return {for (final (i, s) in slots.indexed) s.member: i < leftover ? s.amount + BigInt.one : s.amount};
}

/// One suggested payment: [from] pays [to] the [amount] (minor units).
class Transfer {
  const Transfer(this.from, this.to, this.amount);
  final String from;
  final String to;
  final BigInt amount;

  @override
  bool operator ==(Object other) =>
      other is Transfer && other.from == from && other.to == to && other.amount == amount;

  @override
  int get hashCode => Object.hash(from, to, amount);

  @override
  String toString() => 'Transfer($from -> $to: $amount)';
}

/// Turns net balances (positive = is owed, negative = owes; they must add up
/// to zero) into at most n-1 transfers.
///
/// Greedy: the largest debtor pays the largest creditor as much as possible,
/// repeat. Ties are broken by member id so every client gets the same answer.
/// Member ids are compared by code unit, which matches Go's byte order for the
/// ASCII ids the server issues.
List<Transfer> simplify(Map<String, BigInt> nets) {
  if (nets.values.fold(BigInt.zero, (a, b) => a + b) != BigInt.zero) {
    throw const MoneyException(MoneyError.unbalanced);
  }
  final bal = {
    for (final MapEntry(:key, :value) in nets.entries)
      if (value != BigInt.zero) key: value,
  };

  final transfers = <Transfer>[];
  while (bal.isNotEmpty) {
    String? debtor, creditor;
    for (final MapEntry(key: m, value: v) in bal.entries) {
      if (v.isNegative &&
          (debtor == null || v < bal[debtor]! || (v == bal[debtor]! && m.compareTo(debtor) < 0))) {
        debtor = m;
      }
      if (v > BigInt.zero &&
          (creditor == null || v > bal[creditor]! || (v == bal[creditor]! && m.compareTo(creditor) < 0))) {
        creditor = m;
      }
    }
    final d = debtor!, c = creditor!;
    final amount = -bal[d]! < bal[c]! ? -bal[d]! : bal[c]!;
    transfers.add(Transfer(d, c, amount));
    if ((bal[d] = bal[d]! + amount) == BigInt.zero) bal.remove(d);
    if ((bal[c] = bal[c]! - amount) == BigInt.zero) bal.remove(c);
  }
  return transfers;
}
