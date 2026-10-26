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

BigInt _money(Map<String, Object?> json, String key, int digits) =>
    parseAmount(_req<String>(json, key), digits);

@immutable
class Member {
  const Member({
    required this.id,
    required this.name,
    this.color,
    this.left = false,
    this.owner = false,
    this.claimed = false,
    required this.balance,
  });

  factory Member.fromJson(Object? data, int digits) {
    final json = _object(data);
    return Member(
      id: _req(json, 'id'),
      name: _req(json, 'name'),
      color: _opt(json, 'color'),
      left: _opt<bool>(json, 'left') ?? false,
      owner: _opt<bool>(json, 'owner') ?? false,
      claimed: _opt<bool>(json, 'claimed') ?? false,
      balance: _money(json, 'balance', digits),
    );
  }

  final String id;
  final String name;

  /// 0xRRGGBB, or null for a color picked from the id.
  final int? color;

  /// Removed from the group; kept so old expenses still name them.
  final bool left;

  /// May change the group's access settings (accounts mode).
  final bool owner;

  /// Linked to an account (accounts mode).
  final bool claimed;

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
    this.linkAccess = true,
    this.myMemberId,
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
      linkAccess: _opt<bool>(json, 'linkAccess') ?? true,
      myMemberId: _opt(json, 'myMemberId'),
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

  /// The link alone opens the group. Always true in link mode.
  final bool linkAccess;

  /// The signed-in account's member (accounts mode).
  final String? myMemberId;

  List<Member> get activeMembers => [
    for (final m in members)
      if (!m.left) m,
  ];

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
        for (final p in _objects(json, 'payers'))
          ExpensePart(_req(p, 'memberId'), _money(p, 'amount', digits)),
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
      nets: {
        for (final b in _objects(json, 'balances')) _req<String>(b, 'memberId'): _money(b, 'amount', digits),
      },
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

/// What importing a file would create, see `POST /groups/import`.
@immutable
class ImportPreview {
  const ImportPreview({
    required this.currency,
    required this.minorDigits,
    required this.members,
    required this.expenses,
    required this.payments,
    required this.skipped,
    this.from,
    this.to,
  });

  factory ImportPreview.fromJson(Object? data) {
    final json = _object(data);
    final digits = _req<int>(json, 'minorDigits');
    return ImportPreview(
      currency: _req(json, 'currency'),
      minorDigits: digits,
      members: [for (final m in _objects(json, 'members')) (name: _req<String>(m, 'name'), balance: _money(m, 'balance', digits))],
      expenses: _req(json, 'expenses'),
      payments: _req(json, 'payments'),
      skipped: _req(json, 'skipped'),
      from: json['from'] == null ? null : _time(json, 'from'),
      to: json['to'] == null ? null : _time(json, 'to'),
    );
  }

  final String currency;
  final int minorDigits;

  /// Everyone in the file, with the balance they would start with.
  final List<({String name, BigInt balance})> members;
  final int expenses;
  final int payments;

  /// Rows that move no money.
  final int skipped;

  /// When the first and last entries happened.
  final DateTime? from;
  final DateTime? to;
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

  int? number(String key) => payload[key] is num ? (payload[key] as num).toInt() : null;
}

@immutable
class Page<T> {
  const Page(this.items, this.nextCursor);

  final List<T> items;
  final String? nextCursor;
}

/// A signed-in account (accounts mode).
@immutable
class User {
  const User({
    required this.id,
    this.email,
    this.emailVerified = false,
    required this.name,
    this.locale,
    required this.hasPassword,
  });

  factory User.fromJson(Object? data) {
    final json = _object(data);
    return User(
      id: _req(json, 'id'),
      email: _opt(json, 'email'),
      emailVerified: _opt<bool>(json, 'emailVerified') ?? false,
      name: _req(json, 'name'),
      locale: _opt(json, 'locale'),
      hasPassword: _opt<bool>(json, 'hasPassword') ?? false,
    );
  }

  final String id;
  final String? email;
  final bool emailVerified;
  final String name;
  final String? locale;
  final bool hasPassword;
}

/// An invitation to a group, sent by email (accounts mode).
@immutable
class InviteInfo {
  const InviteInfo({required this.email, required this.groupToken, required this.groupName, this.invitedBy});

  factory InviteInfo.fromJson(Object? data) {
    final json = _object(data);
    return InviteInfo(
      email: _req(json, 'email'),
      groupToken: _req(json, 'groupToken'),
      groupName: _req(json, 'groupName'),
      invitedBy: _opt(json, 'invitedBy'),
    );
  }

  final String email;
  final String groupToken;
  final String groupName;
  final String? invitedBy;
}

/// What someone sees before joining a group by its link.
@immutable
class JoinInfo {
  const JoinInfo({
    required this.name,
    this.emoji,
    this.color,
    required this.currency,
    required this.member,
    required this.members,
    this.invitedMemberId,
  });

  factory JoinInfo.fromJson(Object? data) {
    final json = _object(data);
    return JoinInfo(
      name: _req(json, 'name'),
      emoji: _opt(json, 'emoji'),
      color: _opt(json, 'color'),
      currency: _req(json, 'currency'),
      member: _opt<bool>(json, 'member') ?? false,
      members: [
        for (final m in _objects(json, 'members'))
          JoinMember(
            id: _req(m, 'id'),
            name: _req(m, 'name'),
            color: _opt(m, 'color'),
            claimed: _req(m, 'claimed'),
          ),
      ],
      invitedMemberId: _opt(json, 'invitedMemberId'),
    );
  }

  final String name;
  final String? emoji;
  final int? color;
  final String currency;

  /// The account already belongs to the group.
  final bool member;
  final List<JoinMember> members;

  /// The unclaimed member an email invitation asked this account to be.
  final String? invitedMemberId;
}

@immutable
class JoinMember {
  const JoinMember({required this.id, required this.name, this.color, required this.claimed});

  final String id;
  final String name;
  final int? color;

  /// Someone's account already is this member.
  final bool claimed;
}

/// A span of time: [from] inclusive, [to] exclusive.
typedef Period = ({DateTime from, DateTime to});

/// What to narrow a group's expenses to. Empty fields match everything.
@immutable
class ExpenseFilter {
  const ExpenseFilter({this.text = '', this.member, this.category, this.payments = false, this.period});

  /// Words to find in the title or note.
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
    if (period case final p?) ...{'from': p.from.toUtc().toIso8601String(), 'to': p.to.toUtc().toIso8601String()},
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
    final json = _object(data);
    return GroupStats(
      total: _money(json, 'total', digits),
      count: _req(json, 'count'),
      categories: [
        for (final c in _objects(json, 'categories'))
          (category: _opt<String>(c, 'categoryId'), amount: _money(c, 'amount', digits), count: _req<int>(c, 'count')),
      ],
      members: [
        for (final m in _objects(json, 'members'))
          (member: _req<String>(m, 'memberId'), paid: _money(m, 'paid', digits), share: _money(m, 'share', digits)),
      ],
      months: [
        for (final m in _objects(json, 'months')) (month: _month(_req(m, 'month')), amount: _money(m, 'amount', digits)),
      ],
    );
  }

  static DateTime _month(String s) {
    final [year, month] = s.split('-').map(int.parse).toList();
    return DateTime(year, month);
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
