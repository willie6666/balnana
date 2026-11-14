import 'dart:math';

import '../../core/money.dart';
import '../models/expense.dart';

/// A random UUID (v4) for the Idempotency-Key header: the server keeps one
/// expense per key, so a request whose answer was lost can be sent again.
String newClientKey() {
  final random = Random.secure();
  final bytes = [for (var i = 0; i < 16; i++) random.nextInt(256)];
  bytes[6] = bytes[6] & 0x0f | 0x40;
  bytes[8] = bytes[8] & 0x3f | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// What the expense editor sends. Amounts are minor units.
class ExpenseDraft {
  const ExpenseDraft({
    required this.title,
    this.categoryId,
    required this.amount,
    required this.occurredAt,
    this.note,
    this.location,
    required this.payers,
    required this.splitMethod,
    required this.splits,
    this.foreign,
  });

  final String title;
  final String? categoryId;
  final BigInt amount;
  final DateTime occurredAt;
  final String? note;
  final ExpenseLocation? location;

  /// Member id to amount paid, in [foreign]'s currency when there is one.
  final Map<String, BigInt> payers;
  final SplitMethod splitMethod;

  /// Who shares the cost; values as [SplitPart.value] describes.
  final List<SplitPart> splits;

  /// What it came to in another currency; [amount] is then what was paid in
  /// the group's.
  final ForeignMoney? foreign;

  Map<String, Object?> toJson(int digits, {int? version}) => {
    'title': title,
    'categoryId': ?categoryId,
    'amount': formatAmount(amount, digits),
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    'note': ?note,
    'location': ?location?.toJson(),
    'payers': [
      for (final MapEntry(:key, :value) in payers.entries)
        {'memberId': key, 'amount': formatAmount(value, foreign?.digits ?? digits)},
    ],
    'splitMethod': splitMethod.name,
    'splits': [
      for (final s in splits) {'memberId': s.member, if (splitMethod != SplitMethod.equal) 'value': s.value},
    ],
    if (foreign case final f?)
      'foreign': {'currency': f.currency, 'amount': formatAmount(f.amount, f.digits)},
    'version': ?version,
  };
}

/// How a new or changed recurring expense repeats.
class RecurringDraft {
  const RecurringDraft({required this.expense, required this.repeat, this.endsOn, this.timeZone});

  /// What every occurrence adds; its [ExpenseDraft.occurredAt] is the first.
  final ExpenseDraft expense;
  final Repeat repeat;

  /// The last day an occurrence may fall on.
  final DateTime? endsOn;

  /// The time zone whose calendar the schedule follows: an IANA name, or a
  /// fixed offset such as "UTC+05:30"; this device's when null.
  final String? timeZone;

  Map<String, Object?> toJson(int digits, {int? version}) {
    final json = expense.toJson(digits, version: version);
    final startsAt = json.remove('occurredAt');
    final end = endsOn;
    return {
      ...json,
      'startsAt': startsAt,
      'repeat': {'unit': repeat.unit.name, 'every': repeat.every},
      if (end != null)
        'endsOn':
            '${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}',
      'timeZone': ?timeZone,
    };
  }
}
