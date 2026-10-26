import 'package:flutter/foundation.dart';

import '../core/money.dart';

/// Reads one field of a JSON object, or throws [FormatException].
T _req<T>(Map<String, Object?> json, String key) {
  final v = json[key];
  if (v is! T) throw FormatException('field $key is missing or has the wrong type');
  return v;
}

T? _opt<T>(Map<String, Object?> json, String key) {
  final v = json[key];
  return v is T ? v : null;
}

Map<String, Object?> _object(Object? json) {
  if (json is! Map<String, Object?>) throw const FormatException('expected an object');
  return json;
}

List<Map<String, Object?>> _objects(Map<String, Object?> json, String key) =>
    _req<List<Object?>>(json, key).map(_object).toList();

DateTime _time(Map<String, Object?> json, String key) {
  final t = DateTime.tryParse(_req<String>(json, key));
  if (t == null) throw FormatException('field $key is not a date');
  return t;
}

BigInt _money(Map<String, Object?> json, String key, int digits) => parseAmount(_req<String>(json, key), digits);

@immutable
class Member {
  const Member({required this.id, required this.name, this.color, this.left = false, required this.balance});

  factory Member.fromJson(Object? data, int digits) {
    final json = _object(data);
    return Member(
      id: _req(json, 'id'),
      name: _req(json, 'name'),
      color: _opt(json, 'color'),
      left: _opt<bool>(json, 'left') ?? false,
      balance: _money(json, 'balance', digits),
    );
  }

  final String id;
  final String name;

  /// 0xRRGGBB, or null for a color picked from the id.
  final int? color;

  /// Removed from the group; kept so old expenses still name them.
  final bool left;

  /// Positive: is owed. Negative: owes.
  final BigInt balance;
}

@immutable
class Group {
  const Group({
    required this.token,
    required this.name,
    this.emoji,
    this.color,
    required this.currency,
    required this.minorDigits,
    required this.createdAt,
    required this.members,
  });

  factory Group.fromJson(Object? data) {
    final json = _object(data);
    final digits = _req<int>(json, 'minorDigits');
    return Group(
      token: _req(json, 'token'),
      name: _req(json, 'name'),
      emoji: _opt(json, 'emoji'),
      color: _opt(json, 'color'),
      currency: _req(json, 'currency'),
      minorDigits: digits,
      createdAt: _time(json, 'createdAt'),
      members: [for (final m in _req<List<Object?>>(json, 'members')) Member.fromJson(m, digits)],
    );
  }

  final String token;
  final String name;
  final String? emoji;
  final int? color;
  final String currency;
  final int minorDigits;
  final DateTime createdAt;

  /// Everyone who ever belonged, current members first in the order they joined.
  final List<Member> members;

  List<Member> get activeMembers => [for (final m in members) if (!m.left) m];

  Member? member(String? id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }
}

@immutable
class GroupSummary {
  const GroupSummary({
    required this.token,
    required this.name,
    this.emoji,
    this.color,
    required this.currency,
    required this.minorDigits,
    required this.memberCount,
    this.balance,
    required this.updatedAt,
  });

  factory GroupSummary.fromJson(Object? data) {
    final json = _object(data);
    final digits = _req<int>(json, 'minorDigits');
    final balance = _opt<String>(json, 'balance');
    return GroupSummary(
      token: _req(json, 'token'),
      name: _req(json, 'name'),
      emoji: _opt(json, 'emoji'),
      color: _opt(json, 'color'),
      currency: _req(json, 'currency'),
      minorDigits: digits,
      memberCount: _req(json, 'memberCount'),
      balance: balance == null ? null : parseAmount(balance, digits),
      updatedAt: _time(json, 'updatedAt'),
    );
  }

  final String token;
  final String name;
  final String? emoji;
  final int? color;
  final String currency;
  final int minorDigits;
  final int memberCount;

  /// This device's member's balance, when it knows who it is in the group.
  final BigInt? balance;
  final DateTime updatedAt;
}

enum ExpenseKind { expense, payment }

@immutable
class ExpensePart {
  const ExpensePart(this.memberId, this.amount, [this.share]);

  final String memberId;
  final BigInt amount;

  /// The percentage or weight entered, for percent and shares splits.
  final String? share;
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
    required this.splitMethod,
    required this.payers,
    required this.splits,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
  });

  factory Expense.fromJson(Object? data, int digits) {
    final json = _object(data);
    final kind = ExpenseKind.values.asNameMap()[_req<String>(json, 'kind')];
    final method = SplitMethod.values.asNameMap()[_req<String>(json, 'splitMethod')];
    if (kind == null || method == null) throw const FormatException('unknown kind or split method');
    final deleted = _opt<String>(json, 'deletedAt');
    return Expense(
      id: _req(json, 'id'),
      kind: kind,
      title: _req(json, 'title'),
      categoryId: _opt(json, 'categoryId'),
      amount: _money(json, 'amount', digits),
      occurredAt: _time(json, 'occurredAt'),
      note: _opt(json, 'note'),
      splitMethod: method,
      payers: [
        for (final p in _objects(json, 'payers')) ExpensePart(_req(p, 'memberId'), _money(p, 'amount', digits)),
      ],
      splits: [
        for (final s in _objects(json, 'splits'))
          ExpensePart(_req(s, 'memberId'), _money(s, 'amount', digits), _opt(s, 'share')),
      ],
      createdBy: _opt(json, 'createdBy'),
      createdAt: _time(json, 'createdAt'),
      updatedAt: _time(json, 'updatedAt'),
      deletedAt: deleted == null ? null : DateTime.tryParse(deleted),
      version: _req(json, 'version'),
    );
  }

  final String id;
  final ExpenseKind kind;
  final String title;
  final String? categoryId;
  final BigInt amount;
  final DateTime occurredAt;
  final String? note;
  final SplitMethod splitMethod;
  final List<ExpensePart> payers;
  final List<ExpensePart> splits;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;

  bool get isPayment => kind == ExpenseKind.payment;

  BigInt paidBy(String memberId) =>
      payers.where((p) => p.memberId == memberId).fold(BigInt.zero, (a, p) => a + p.amount);

  BigInt owedBy(String memberId) =>
      splits.where((s) => s.memberId == memberId).fold(BigInt.zero, (a, s) => a + s.amount);

  /// What this expense did to [memberId]'s balance: positive means they lent.
  BigInt effectOn(String memberId) => paidBy(memberId) - owedBy(memberId);
}

@immutable
class Balances {
  const Balances({required this.nets, required this.transfers});

  factory Balances.fromJson(Object? data, int digits) {
    final json = _object(data);
    return Balances(
      nets: {for (final b in _objects(json, 'balances')) _req<String>(b, 'memberId'): _money(b, 'amount', digits)},
      transfers: [
        for (final t in _objects(json, 'transfers'))
          Transfer(_req(t, 'fromMemberId'), _req(t, 'toMemberId'), _money(t, 'amount', digits)),
      ],
    );
  }

  /// Member id to net balance, in member order.
  final Map<String, BigInt> nets;

  /// Suggested payments that settle everyone up.
  final List<Transfer> transfers;
}

@immutable
class Activity {
  const Activity({
    required this.id,
    required this.action,
    this.actorMemberId,
    this.subjectId,
    required this.payload,
    required this.createdAt,
  });

  factory Activity.fromJson(Object? data) {
    final json = _object(data);
    return Activity(
      id: _req(json, 'id'),
      action: _req(json, 'action'),
      actorMemberId: _opt(json, 'actorMemberId'),
      subjectId: _opt(json, 'subjectId'),
      payload: _opt<Map<String, Object?>>(json, 'payload') ?? const {},
      createdAt: _time(json, 'createdAt'),
    );
  }

  final String id;

  /// Such as `expense.created` or `member.added`.
  final String action;
  final String? actorMemberId;
  final String? subjectId;
  final Map<String, Object?> payload;
  final DateTime createdAt;

  String? text(String key) => payload[key] is String ? payload[key] as String : null;
}

@immutable
class Page<T> {
  const Page(this.items, this.nextCursor);

  final List<T> items;
  final String? nextCursor;
}
