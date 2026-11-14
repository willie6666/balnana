import 'package:flutter/foundation.dart';

import '../../core/money.dart';
import 'json_fields.dart';

/// [unknown] is one a newer server sent: shown, but not edited.
enum ExpenseKind { expense, payment, unknown }

@immutable
class ExpensePart {
  const ExpensePart(this.memberId, this.amount, {this.share, this.foreignAmount});

  final String memberId;
  final BigInt amount;

  /// The weight entered, for shares splits.
  final String? share;

  /// This part in the expense's [Expense.foreign] currency.
  final BigInt? foreignAmount;
}

/// What an expense came to in the currency it was paid in, next to its
/// amount in the group's currency.
@immutable
class ForeignMoney {
  const ForeignMoney(this.currency, this.digits, this.amount);

  static ForeignMoney? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final digits = currencyDigits(json);
    return ForeignMoney(requiredField(json, 'currency'), digits, moneyField(json, 'amount', digits));
  }

  final String currency;
  final int digits;
  final BigInt amount;
}

/// A point on the map, in degrees (WGS 84).
@immutable
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  Map<String, Object?> toJson() => {'latitude': latitude, 'longitude': longitude};

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// Where an expense happened: a name people typed, a point on the map, or both.
@immutable
class ExpenseLocation {
  const ExpenseLocation({this.name, this.point});

  /// Null when [json] holds neither a name nor a point.
  static ExpenseLocation? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final name = optionalField<String>(json, 'name');
    final point = switch (json['point']) {
      {'latitude': final num lat, 'longitude': final num lng} => GeoPoint(lat.toDouble(), lng.toDouble()),
      _ => null,
    };
    if ((name == null || name.isEmpty) && point == null) return null;
    return ExpenseLocation(name: name, point: point);
  }

  final String? name;
  final GeoPoint? point;

  Map<String, Object?> toJson() => {'name': ?name, 'point': ?point?.toJson()};

  @override
  bool operator ==(Object other) => other is ExpenseLocation && other.name == name && other.point == point;

  @override
  int get hashCode => Object.hash(name, point);
}

@immutable
class Expense {
  const Expense({
    required this.id,
    required this.kind,
    required this.title,
    this.categoryId,
    required this.amount,
    required this.occurredAt,
    this.note,
    this.location,
    required this.splitMethod,
    required this.payers,
    required this.splits,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.hasReceipt = false,
    this.transactionType = 'expense',
    this.recurringId,
    this.foreign,
  });

  factory Expense.fromJson(Object? data, int digits) {
    final json = jsonObject(data);
    final foreign = ForeignMoney.fromJson(json['foreign']);
    BigInt? inForeign(Map<String, Object?> part) => foreign == null || part['foreignAmount'] == null
        ? null
        : moneyField(part, 'foreignAmount', foreign.digits);
    final kind = ExpenseKind.values.asNameMap()[requiredField<String>(json, 'kind')] ?? ExpenseKind.unknown;
    final method =
        SplitMethod.values.asNameMap()[requiredField<String>(json, 'splitMethod')] ?? SplitMethod.unknown;
    final deleted = optionalField<String>(json, 'deletedAt');
    return Expense(
      id: requiredField(json, 'id'),
      kind: kind,
      title: requiredField(json, 'title'),
      categoryId: optionalField(json, 'categoryId'),
      amount: moneyField(json, 'amount', digits),
      occurredAt: dateField(json, 'occurredAt'),
      note: optionalField(json, 'note'),
      location: ExpenseLocation.fromJson(json['location']),
      splitMethod: method,
      payers: [
        for (final p in objectList(json, 'payers'))
          ExpensePart(
            requiredField(p, 'memberId'),
            moneyField(p, 'amount', digits),
            foreignAmount: inForeign(p),
          ),
      ],
      splits: [
        for (final s in objectList(json, 'splits'))
          ExpensePart(
            requiredField(s, 'memberId'),
            moneyField(s, 'amount', digits),
            share: optionalField(s, 'share'),
            foreignAmount: inForeign(s),
          ),
      ],
      createdBy: optionalField(json, 'createdBy'),
      createdAt: dateField(json, 'createdAt'),
      updatedAt: dateField(json, 'updatedAt'),
      deletedAt: deleted == null ? null : DateTime.tryParse(deleted),
      version: requiredField(json, 'version'),
      // Answers cached before receipts existed do not say.
      hasReceipt: optionalField<bool>(json, 'hasReceipt') ?? false,
      transactionType: optionalField<String>(json, 'transactionType') ?? 'expense',
      recurringId: optionalField(json, 'recurringId'),
      foreign: foreign,
    );
  }

  final String id;
  final ExpenseKind kind;
  final String title;
  final String? categoryId;
  final BigInt amount;
  final DateTime occurredAt;
  final String? note;
  final ExpenseLocation? location;
  final SplitMethod splitMethod;
  final List<ExpensePart> payers;
  final List<ExpensePart> splits;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;

  /// Whether a photo of the receipt is attached.
  final bool hasReceipt;

  /// Imported direction, preserved independently of the balance ledger.
  final String transactionType;

  /// The recurring expense that added it.
  final String? recurringId;

  /// What it came to in the currency it was paid in, when that is not the
  /// group's. [amount] and the parts' amounts stay in the group's currency.
  final ForeignMoney? foreign;

  bool get isPayment => kind == ExpenseKind.payment;

  /// Whether the form can hold it without losing what a newer server sent.
  bool get editable => kind != ExpenseKind.unknown && splitMethod != SplitMethod.unknown;

  /// Money that came in, a refund or income. Its ledger roles are reversed:
  /// whom it is for "paid" it, and whoever received it owes it to them.
  bool get isReceived => !isPayment && transactionType != 'expense';

  BigInt paidBy(String memberId) =>
      payers.where((p) => p.memberId == memberId).fold(BigInt.zero, (a, p) => a + p.amount);

  BigInt owedBy(String memberId) =>
      splits.where((s) => s.memberId == memberId).fold(BigInt.zero, (a, s) => a + s.amount);
}

/// [unknown] is one a newer server sent: shown, but not edited.
enum RepeatUnit { day, week, month, year, unknown }

/// How often a recurring expense comes back: every [every] [unit]s.
typedef Repeat = ({RepeatUnit unit, int every});

/// An expense the server adds again at every occurrence of its schedule.
@immutable
class RecurringExpense {
  const RecurringExpense({
    required this.id,
    required this.title,
    this.categoryId,
    required this.amount,
    this.note,
    this.location,
    required this.splitMethod,
    required this.payers,
    required this.splits,
    required this.repeat,
    required this.startsAt,
    this.endsOn,
    required this.timeZone,
    this.nextAt,
    this.lastAt,
    this.paused = false,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory RecurringExpense.fromJson(Object? data, int digits) {
    final json = jsonObject(data);
    final method =
        SplitMethod.values.asNameMap()[requiredField<String>(json, 'splitMethod')] ?? SplitMethod.unknown;
    final repeat = jsonObject(json['repeat']);
    final unit = RepeatUnit.values.asNameMap()[requiredField<String>(repeat, 'unit')] ?? RepeatUnit.unknown;
    final endsOn = optionalField<String>(json, 'endsOn');
    return RecurringExpense(
      id: requiredField(json, 'id'),
      title: requiredField(json, 'title'),
      categoryId: optionalField(json, 'categoryId'),
      amount: moneyField(json, 'amount', digits),
      note: optionalField(json, 'note'),
      location: ExpenseLocation.fromJson(json['location']),
      splitMethod: method,
      payers: [
        for (final p in objectList(json, 'payers'))
          ExpensePart(requiredField(p, 'memberId'), moneyField(p, 'amount', digits)),
      ],
      splits: [
        for (final s in objectList(json, 'splits'))
          ExpensePart(
            requiredField(s, 'memberId'),
            moneyField(s, 'amount', digits),
            share: optionalField(s, 'share'),
          ),
      ],
      repeat: (unit: unit, every: requiredField<int>(repeat, 'every')),
      startsAt: dateField(json, 'startsAt'),
      endsOn: endsOn == null ? null : DateTime.tryParse(endsOn),
      timeZone: requiredField(json, 'timeZone'),
      nextAt: json['nextAt'] == null ? null : dateField(json, 'nextAt'),
      lastAt: json['lastAt'] == null ? null : dateField(json, 'lastAt'),
      paused: optionalField<bool>(json, 'paused') ?? false,
      createdBy: optionalField(json, 'createdBy'),
      createdAt: dateField(json, 'createdAt'),
      updatedAt: dateField(json, 'updatedAt'),
      version: requiredField(json, 'version'),
    );
  }

  final String id;
  final String title;
  final String? categoryId;
  final BigInt amount;
  final String? note;
  final ExpenseLocation? location;
  final SplitMethod splitMethod;
  final List<ExpensePart> payers;
  final List<ExpensePart> splits;
  final Repeat repeat;

  /// Whether the form can hold it without losing what a newer server sent.
  bool get editable => splitMethod != SplitMethod.unknown && repeat.unit != RepeatUnit.unknown;

  /// The first occurrence.
  final DateTime startsAt;

  /// The last day an occurrence may fall on, a date without a time.
  final DateTime? endsOn;

  /// The IANA time zone whose calendar the schedule follows.
  final String timeZone;

  /// When the next occurrence is added; null once it has ended.
  final DateTime? nextAt;

  /// The latest occurrence added.
  final DateTime? lastAt;
  final bool paused;

  /// Whoever set it up; its expenses are added as theirs.
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  bool get ended => nextAt == null;

  /// What the editor starts from: the expense its first occurrence adds.
  Expense get asExpense => Expense(
    id: id,
    kind: ExpenseKind.expense,
    title: title,
    categoryId: categoryId,
    amount: amount,
    occurredAt: startsAt,
    note: note,
    location: location,
    splitMethod: splitMethod,
    payers: payers,
    splits: splits,
    createdBy: createdBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
    version: version,
  );
}

/// A span of time: [from] inclusive, [to] exclusive.
typedef Period = ({DateTime from, DateTime to});

/// What to narrow a group's expenses to. Empty fields match everything.
@immutable
class ExpenseFilter {
  const ExpenseFilter({this.text = '', this.member, this.category, this.payments = false, this.period});

  /// Words to find in the title, note or location.
  final String text;

  /// Only expenses this member paid for or had a share in.
  final String? member;

  /// Only expenses of this category.
  final String? category;

  /// Only payments between members.
  final bool payments;

  final Period? period;

  bool get isEmpty =>
      text.trim().isEmpty && member == null && category == null && !payments && period == null;

  ExpenseFilter copyWith({
    String? text,
    ValueGetter<String?>? member,
    ValueGetter<String?>? category,
    bool? payments,
    ValueGetter<Period?>? period,
  }) => ExpenseFilter(
    text: text ?? this.text,
    member: member == null ? this.member : member(),
    category: category == null ? this.category : category(),
    payments: payments ?? this.payments,
    period: period == null ? this.period : period(),
  );

  Map<String, Object> get query => {
    if (text.trim() case final q when q.isNotEmpty) 'q': q,
    'member': ?member,
    'category': ?category,
    if (payments) 'kind': 'payment',
    if (period case final p?) ...{
      'from': p.from.toUtc().toIso8601String(),
      'to': p.to.toUtc().toIso8601String(),
    },
  };

  @override
  bool operator ==(Object other) =>
      other is ExpenseFilter &&
      other.text == text &&
      other.member == member &&
      other.category == category &&
      other.payments == payments &&
      other.period == period;

  @override
  int get hashCode => Object.hash(text, member, category, payments, period);
}

/// What a group spent over some time, see `GET /g/{token}/stats`. Payments
/// between members are not spending and are left out.
@immutable
class GroupStats {
  const GroupStats({
    required this.total,
    required this.count,
    required this.categories,
    required this.members,
    required this.months,
  });

  factory GroupStats.fromJson(Object? data, int digits) {
    final json = jsonObject(data);
    return GroupStats(
      total: moneyField(json, 'total', digits),
      count: requiredField(json, 'count'),
      categories: [
        for (final c in objectList(json, 'categories'))
          (
            category: optionalField<String>(c, 'categoryId'),
            amount: moneyField(c, 'amount', digits),
            count: requiredField<int>(c, 'count'),
          ),
      ],
      members: [
        for (final m in objectList(json, 'members'))
          (
            member: requiredField<String>(m, 'memberId'),
            paid: moneyField(m, 'paid', digits),
            share: moneyField(m, 'share', digits),
          ),
      ],
      months: [
        for (final m in objectList(json, 'months'))
          (month: _month(requiredField(m, 'month')), amount: moneyField(m, 'amount', digits)),
      ],
    );
  }

  static final _monthPattern = RegExp(r'^(\d{4})-(0[1-9]|1[0-2])$');

  static DateTime _month(String value) {
    final match = _monthPattern.firstMatch(value);
    if (match == null) throw const FormatException('field month must be YYYY-MM');
    return DateTime(int.parse(match[1]!), int.parse(match[2]!));
  }

  final BigInt total;

  /// How many expenses [total] is made of.
  final int count;

  /// Largest first. A null category is spending without one.
  final List<({String? category, BigInt amount, int count})> categories;

  /// Everyone who paid or had a share, in member order.
  final List<({String member, BigInt paid, BigInt share})> members;

  /// Oldest first, only months with spending.
  final List<({DateTime month, BigInt amount})> months;
}

/// GET /exchange-rate: what one unit of a currency is worth in another.
class ExchangeRate {
  const ExchangeRate({required this.rate, required this.source, required this.updatedAt});

  factory ExchangeRate.fromJson(Object? data) {
    final json = jsonObject(data);
    return ExchangeRate(
      rate: requiredField(json, 'rate'),
      source: requiredField(json, 'source'),
      updatedAt: dateField(json, 'updatedAt'),
    );
  }

  /// A decimal with a dot, as the rate field takes it.
  final String rate;

  /// Where it came from: `frankfurter` or `openexchangerates`.
  final String source;

  /// When the source published it.
  final DateTime updatedAt;
}
