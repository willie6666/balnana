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

/// The server checked what it accepted, and sums of it, such as balances and
/// totals, may exceed what one transaction holds.
DateTime? _optTime(Map<String, Object?> json, String key) => json[key] == null ? null : _time(json, key);

BigInt _money(Map<String, Object?> json, String key, int digits) =>
    parseAmount(_req<String>(json, key), digits, total: true);

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
    this.symbol,
    required this.minorDigits,
    required this.createdAt,
    required this.members,
    this.categories = const [],
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
      symbol: _opt(json, 'symbol'),
      minorDigits: digits,
      createdAt: _time(json, 'createdAt'),
      members: [for (final m in _req<List<Object?>>(json, 'members')) Member.fromJson(m, digits)],
      categories: [for (final c in _opt<List<Object?>>(json, 'categories') ?? const []) GroupCategory.fromJson(c)],
      linkAccess: _opt<bool>(json, 'linkAccess') ?? true,
      myMemberId: _opt(json, 'myMemberId'),
    );
  }

  final String token;
  final String name;
  final String? emoji;
  final int? color;
  final String currency;

  /// Shown before amounts in place of the currency's own symbol.
  final String? symbol;
  final int minorDigits;
  final DateTime createdAt;

  /// Everyone who ever belonged, current members first in the order they joined.
  final List<Member> members;

  /// The built-in categories, then the group's own, hidden ones included.
  /// Empty from a server that predates them.
  final List<GroupCategory> categories;

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

/// A category expenses can have: a built-in one, which the app names, or one
/// the group added under its own name.
@immutable
class GroupCategory {
  const GroupCategory({
    required this.id,
    this.name,
    required this.emoji,
    required this.rgb,
    this.builtIn = false,
    this.hidden = false,
  });

  factory GroupCategory.fromJson(Object? data) {
    final json = _object(data);
    return GroupCategory(
      id: _req(json, 'id'),
      name: _opt(json, 'name'),
      emoji: _req(json, 'emoji'),
      rgb: _req(json, 'color'),
      builtIn: _opt<bool>(json, 'builtIn') ?? false,
      hidden: _opt<bool>(json, 'hidden') ?? false,
    );
  }

  final String id;

  /// Only for the group's own categories.
  final String? name;
  final String emoji;
  final int rgb;
  final bool builtIn;

  /// Not offered for new expenses.
  final bool hidden;
}

@immutable
class GroupSummary {
  const GroupSummary({
    required this.token,
    required this.name,
    this.emoji,
    this.color,
    required this.currency,
    this.symbol,
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
      symbol: _opt(json, 'symbol'),
      minorDigits: digits,
      memberCount: _req(json, 'memberCount'),
      balance: balance == null ? null : parseAmount(balance, digits, total: true),
      updatedAt: _time(json, 'updatedAt'),
    );
  }

  final String token;
  final String name;
  final String? emoji;
  final int? color;
  final String currency;

  /// Shown before amounts in place of the currency's own symbol.
  final String? symbol;
  final int minorDigits;
  final int memberCount;

  /// This device's member's balance, when it knows who it is in the group.
  final BigInt? balance;
  final DateTime updatedAt;
}

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
    final digits = _req<int>(json, 'minorDigits');
    return ForeignMoney(_req(json, 'currency'), digits, _money(json, 'amount', digits));
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
    final name = _opt<String>(json, 'name');
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
    final json = _object(data);
    final foreign = ForeignMoney.fromJson(json['foreign']);
    BigInt? inForeign(Map<String, Object?> part) => foreign == null || part['foreignAmount'] == null
        ? null
        : _money(part, 'foreignAmount', foreign.digits);
    final kind = ExpenseKind.values.asNameMap()[_req<String>(json, 'kind')] ?? ExpenseKind.unknown;
    final method = SplitMethod.values.asNameMap()[_req<String>(json, 'splitMethod')] ?? SplitMethod.unknown;
    final deleted = _opt<String>(json, 'deletedAt');
    return Expense(
      id: _req(json, 'id'),
      kind: kind,
      title: _req(json, 'title'),
      categoryId: _opt(json, 'categoryId'),
      amount: _money(json, 'amount', digits),
      occurredAt: _time(json, 'occurredAt'),
      note: _opt(json, 'note'),
      location: ExpenseLocation.fromJson(json['location']),
      splitMethod: method,
      payers: [
        for (final p in _objects(json, 'payers'))
          ExpensePart(_req(p, 'memberId'), _money(p, 'amount', digits), foreignAmount: inForeign(p)),
      ],
      splits: [
        for (final s in _objects(json, 'splits'))
          ExpensePart(
            _req(s, 'memberId'),
            _money(s, 'amount', digits),
            share: _opt(s, 'share'),
            foreignAmount: inForeign(s),
          ),
      ],
      createdBy: _opt(json, 'createdBy'),
      createdAt: _time(json, 'createdAt'),
      updatedAt: _time(json, 'updatedAt'),
      deletedAt: deleted == null ? null : DateTime.tryParse(deleted),
      version: _req(json, 'version'),
      // Answers cached before receipts existed do not say.
      hasReceipt: _opt<bool>(json, 'hasReceipt') ?? false,
      transactionType: _opt<String>(json, 'transactionType') ?? 'expense',
      recurringId: _opt(json, 'recurringId'),
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

  /// What this expense did to [memberId]'s balance: positive means they lent.
  BigInt effectOn(String memberId) => paidBy(memberId) - owedBy(memberId);
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
    final json = _object(data);
    final method = SplitMethod.values.asNameMap()[_req<String>(json, 'splitMethod')] ?? SplitMethod.unknown;
    final repeat = _object(json['repeat']);
    final unit = RepeatUnit.values.asNameMap()[_req<String>(repeat, 'unit')] ?? RepeatUnit.unknown;
    final endsOn = _opt<String>(json, 'endsOn');
    return RecurringExpense(
      id: _req(json, 'id'),
      title: _req(json, 'title'),
      categoryId: _opt(json, 'categoryId'),
      amount: _money(json, 'amount', digits),
      note: _opt(json, 'note'),
      location: ExpenseLocation.fromJson(json['location']),
      splitMethod: method,
      payers: [
        for (final p in _objects(json, 'payers'))
          ExpensePart(_req(p, 'memberId'), _money(p, 'amount', digits)),
      ],
      splits: [
        for (final s in _objects(json, 'splits'))
          ExpensePart(_req(s, 'memberId'), _money(s, 'amount', digits), share: _opt(s, 'share')),
      ],
      repeat: (unit: unit, every: _req<int>(repeat, 'every')),
      startsAt: _time(json, 'startsAt'),
      endsOn: endsOn == null ? null : DateTime.tryParse(endsOn),
      timeZone: _req(json, 'timeZone'),
      nextAt: json['nextAt'] == null ? null : _time(json, 'nextAt'),
      lastAt: json['lastAt'] == null ? null : _time(json, 'lastAt'),
      paused: _opt<bool>(json, 'paused') ?? false,
      createdBy: _opt(json, 'createdBy'),
      createdAt: _time(json, 'createdAt'),
      updatedAt: _time(json, 'updatedAt'),
      version: _req(json, 'version'),
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
      members: [
        for (final m in _objects(json, 'members'))
          (name: _req<String>(m, 'name'), balance: _money(m, 'balance', digits)),
      ],
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
    this.username,
    this.emailVerified = false,
    this.pendingEmail,
    required this.name,
    this.locale,
    required this.hasPassword,
  });

  factory User.fromJson(Object? data) {
    final json = _object(data);
    return User(
      id: _req(json, 'id'),
      email: _opt(json, 'email'),
      username: _opt(json, 'username'),
      emailVerified: _opt<bool>(json, 'emailVerified') ?? false,
      pendingEmail: _opt(json, 'pendingEmail'),
      name: _req(json, 'name'),
      locale: _opt(json, 'locale'),
      hasPassword: _opt<bool>(json, 'hasPassword') ?? false,
    );
  }

  final String id;
  final String? email;

  /// Set on accounts made without an email address.
  final String? username;
  final bool emailVerified;

  /// A new address waiting for its verification link to be opened; [email]
  /// stays in force until then.
  final String? pendingEmail;
  final String name;
  final String? locale;
  final bool hasPassword;
}

/// A provider sign-in that matched an account by an address the account
/// never confirmed, waiting for the person to say what it is to them.
@immutable
class OAuthPending {
  const OAuthPending({
    required this.email,
    required this.provider,
    required this.hasPassword,
    required this.signup,
  });

  factory OAuthPending.fromJson(Object? data) {
    final json = _object(data);
    return OAuthPending(
      email: _req(json, 'email'),
      provider: _req(json, 'provider'),
      hasPassword: _req(json, 'hasPassword'),
      signup: _req(json, 'signup'),
    );
  }

  final String email;

  /// The provider's id.
  final String provider;

  /// The account has a password, so linking can prove it is theirs.
  final bool hasPassword;

  /// A new account may be made instead.
  final bool signup;
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
    final json = _object(data);
    return GroupStats(
      total: _money(json, 'total', digits),
      count: _req(json, 'count'),
      categories: [
        for (final c in _objects(json, 'categories'))
          (
            category: _opt<String>(c, 'categoryId'),
            amount: _money(c, 'amount', digits),
            count: _req<int>(c, 'count'),
          ),
      ],
      members: [
        for (final m in _objects(json, 'members'))
          (
            member: _req<String>(m, 'memberId'),
            paid: _money(m, 'paid', digits),
            share: _money(m, 'share', digits),
          ),
      ],
      months: [
        for (final m in _objects(json, 'months'))
          (month: _month(_req(m, 'month')), amount: _money(m, 'amount', digits)),
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

/// One server setting on the admin page, by the environment variable that
/// sets it (see .env.example).
@immutable
class AdminSetting {
  const AdminSetting({
    required this.key,
    this.value,
    this.defaultValue = '',
    this.locked = false,
    this.secret = false,
    this.set = false,
  });

  factory AdminSetting.fromJson(Object? data) {
    final json = _object(data);
    return AdminSetting(
      key: _req(json, 'key'),
      value: _opt(json, 'value'),
      defaultValue: _opt<String>(json, 'default') ?? '',
      locked: _opt<bool>(json, 'locked') ?? false,
      secret: _opt<bool>(json, 'secret') ?? false,
      set: _opt<bool>(json, 'set') ?? false,
    );
  }

  static List<AdminSetting> listFromJson(Object? data) => [
    for (final s in _objects(_object(data), 'settings')) AdminSetting.fromJson(s),
  ];

  final String key;

  /// The value in force; never sent for secrets.
  final String? value;
  final String defaultValue;

  /// Set by an environment variable on the server, which wins.
  final bool locked;
  final bool secret;

  /// Something sets it: the environment or the admin page.
  final bool set;

  /// What is in force, the default when nothing sets it.
  String get effective => value ?? defaultValue;
}

/// One account, as the administrator sees it.
@immutable
class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    this.email,
    this.username,
    this.emailVerified = false,
    this.hasPassword = false,
    this.oauth = const [],
    this.groups = 0,
    required this.createdAt,
    this.planName,
    this.planExpiresAt,
  });

  factory AdminUser.fromJson(Object? data) {
    final json = _object(data);
    return AdminUser(
      id: _req(json, 'id'),
      name: _req(json, 'name'),
      email: _opt(json, 'email'),
      username: _opt(json, 'username'),
      emailVerified: _opt<bool>(json, 'emailVerified') ?? false,
      hasPassword: _opt<bool>(json, 'hasPassword') ?? false,
      oauth: [...?_opt<List<Object?>>(json, 'oauth')?.whereType<String>()],
      groups: _opt<num>(json, 'groups')?.toInt() ?? 0,
      createdAt: _time(json, 'createdAt'),
      planName: _opt(json, 'planName'),
      planExpiresAt: _optTime(json, 'planExpiresAt'),
    );
  }

  final String id;
  final String name;
  final String? email;
  final String? username;
  final bool emailVerified;
  final bool hasPassword;

  /// The sign-in providers linked to the account, such as "google".
  final List<String> oauth;

  /// How many groups it is in.
  final int groups;
  final DateTime createdAt;

  /// The plan an entitlement gives it; null on the default plan.
  final String? planName;

  /// When [planName] ends; null when it doesn't.
  final DateTime? planExpiresAt;
}

/// How much of a limit is used. A null [limit] means there is none.
class PlanUsage {
  const PlanUsage({this.limit, this.used = 0});

  factory PlanUsage.fromJson(Object? data) {
    final json = _object(data);
    return PlanUsage(limit: _opt<num>(json, 'limit')?.toInt(), used: _opt<num>(json, 'used')?.toInt() ?? 0);
  }

  final int? limit;
  final int used;
}

/// What the server sells on Google Play, for an account that can buy it.
class PlayBilling {
  const PlayBilling({
    required this.accountId,
    required this.packageName,
    this.products = const [],
    this.subscribed = const [],
    this.onHold = const [],
  });

  factory PlayBilling.fromJson(Object? data) {
    final json = _object(data);
    return PlayBilling(
      accountId: _req(json, 'accountId'),
      packageName: _req(json, 'packageName'),
      products: [...?_opt<List<Object?>>(json, 'products')?.whereType<String>()],
      subscribed: [...?_opt<List<Object?>>(json, 'subscribed')?.whereType<String>()],
      onHold: [...?_opt<List<Object?>>(json, 'onHold')?.whereType<String>()],
    );
  }

  /// Goes with a purchase, for Google to say whose it is.
  final String accountId;
  final String packageName;
  final List<String> products;

  /// The products the account has a running subscription to.
  final List<String> subscribed;

  /// The products the account still holds but Google stopped charging for
  /// after a failed payment. Buying again would pay twice once it is fixed.
  final List<String> onHold;

  /// The products the account holds, whether or not they give a plan now.
  List<String> get held => [...subscribed, ...onHold];
}

/// The signed-in account's plan and how much of it is used.
class MyPlan {
  const MyPlan({
    required this.planName,
    this.paid = false,
    this.expiresAt,
    required this.ownGroups,
    required this.sponsoredGroups,
    this.paymentCode,
    this.receiptsPerGroup,
    this.recurringPerGroup,
    this.play,
  });

  factory MyPlan.fromJson(Object? data) {
    final json = _object(data);
    return MyPlan(
      planName: _req(json, 'planName'),
      paid: _opt<bool>(json, 'paid') ?? false,
      expiresAt: _optTime(json, 'expiresAt'),
      ownGroups: PlanUsage.fromJson(json['ownGroups']),
      sponsoredGroups: PlanUsage.fromJson(json['sponsoredGroups']),
      paymentCode: _opt(json, 'paymentCode'),
      receiptsPerGroup: _opt<num>(json, 'receiptsPerGroup')?.toInt(),
      recurringPerGroup: _opt<num>(json, 'recurringPerGroup')?.toInt(),
      play: json['play'] == null ? null : PlayBilling.fromJson(json['play']),
    );
  }

  final String planName;

  /// Whether an entitlement gives the plan, rather than the server's default.
  final bool paid;

  /// When the plan ends; null when it doesn't.
  final DateTime? expiresAt;
  final PlanUsage ownGroups;
  final PlanUsage sponsoredGroups;

  /// What to write in a Ko-fi message for the payment to reach this account.
  /// Null when the server takes no Ko-fi payments.
  final String? paymentCode;

  /// Null means no limit.
  final int? receiptsPerGroup;

  /// Null means no limit.
  final int? recurringPerGroup;

  /// Null when the server doesn't sell on Google Play.
  final PlayBilling? play;
}

/// The limits that apply to a group and how much of them is used.
class GroupPlan {
  const GroupPlan({
    required this.planName,
    this.canSponsor = false,
    required this.receipts,
    required this.recurring,
    this.sponsorMemberId,
  });

  factory GroupPlan.fromJson(Object? data) {
    final json = _object(data);
    return GroupPlan(
      planName: _req(json, 'planName'),
      canSponsor: _opt<bool>(json, 'canSponsor') ?? false,
      receipts: PlanUsage.fromJson(json['receipts']),
      recurring: PlanUsage.fromJson(json['recurring']),
      sponsorMemberId: _opt(json, 'sponsorMemberId'),
    );
  }

  final String planName;

  /// Whether the signed-in account could share its plan with the group.
  final bool canSponsor;
  final PlanUsage receipts;
  final PlanUsage recurring;

  /// The member whose plan covers the group, if any.
  final String? sponsorMemberId;
}

/// What a plan allows. Null means no limit.
class PlanLimits {
  const PlanLimits({this.receiptsPerGroup, this.recurringPerGroup, this.ownGroups, this.sponsoredGroups});

  factory PlanLimits.fromJson(Object? data) {
    final json = _object(data);
    return PlanLimits(
      receiptsPerGroup: _opt<num>(json, 'receiptsPerGroup')?.toInt(),
      recurringPerGroup: _opt<num>(json, 'recurringPerGroup')?.toInt(),
      ownGroups: _opt<num>(json, 'ownGroups')?.toInt(),
      sponsoredGroups: _opt<num>(json, 'sponsoredGroups')?.toInt(),
    );
  }

  final int? receiptsPerGroup;
  final int? recurringPerGroup;
  final int? ownGroups;
  final int? sponsoredGroups;

  Map<String, Object?> toJson() => {
    'receiptsPerGroup': ?receiptsPerGroup,
    'recurringPerGroup': ?recurringPerGroup,
    'ownGroups': ?ownGroups,
    'sponsoredGroups': ?sponsoredGroups,
  };
}

/// A plan the administrator set up.
class Plan {
  const Plan({
    required this.id,
    required this.name,
    this.rank = 0,
    this.isDefault = false,
    this.limits = const PlanLimits(),
  });

  factory Plan.fromJson(Object? data) {
    final json = _object(data);
    return Plan(
      id: _req(json, 'id'),
      name: _req(json, 'name'),
      rank: _opt<num>(json, 'rank')?.toInt() ?? 0,
      isDefault: _opt<bool>(json, 'isDefault') ?? false,
      limits: PlanLimits.fromJson(json['limits']),
    );
  }

  final String id;
  final String name;

  /// When someone has several plans, the highest counts.
  final int rank;

  /// What anyone without an entitlement has.
  final bool isDefault;
  final PlanLimits limits;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'rank': rank,
    'isDefault': isDefault,
    'limits': limits.toJson(),
  };
}

/// What a payment has to be for to give a plan.
class PlanProduct {
  const PlanProduct({
    required this.provider,
    required this.product,
    required this.planId,
    required this.days,
    this.minAmount,
    this.currency,
  });

  factory PlanProduct.fromJson(Object? data) {
    final json = _object(data);
    return PlanProduct(
      provider: _req(json, 'provider'),
      product: _req(json, 'product'),
      planId: _req(json, 'planId'),
      days: (_req<num>(json, 'days')).toInt(),
      minAmount: _opt(json, 'minAmount'),
      currency: _opt(json, 'currency'),
    );
  }

  /// "kofi" or "play".
  final String provider;

  /// The Ko-fi tier or Play product; empty for any Ko-fi payment of at least
  /// [minAmount].
  final String product;
  final String planId;
  final int days;

  /// A decimal amount such as "5.00".
  final String? minAmount;
  final String? currency;

  Map<String, Object?> toJson() => {
    'provider': provider,
    'product': product,
    'planId': planId,
    'days': days,
    'minAmount': ?minAmount,
    'currency': ?currency,
  };
}

/// Everything the administrator can sell and what it allows.
class PlanCatalog {
  const PlanCatalog({this.plans = const [], this.products = const []});

  factory PlanCatalog.fromJson(Object? data) {
    final json = _object(data);
    return PlanCatalog(
      plans: [for (final p in _opt<List<Object?>>(json, 'plans') ?? const <Object?>[]) Plan.fromJson(p)],
      products: [
        for (final p in _opt<List<Object?>>(json, 'products') ?? const <Object?>[]) PlanProduct.fromJson(p),
      ],
    );
  }

  final List<Plan> plans;
  final List<PlanProduct> products;

  Map<String, Object?> toJson() => {
    'plans': [for (final p in plans) p.toJson()],
    'products': [for (final p in products) p.toJson()],
  };
}

/// A plan an account was given, by an administrator or a payment.
class Entitlement {
  const Entitlement({
    required this.id,
    required this.planId,
    required this.planName,
    required this.source,
    this.note,
    required this.startsAt,
    this.expiresAt,
    this.revokedAt,
    required this.createdAt,
  });

  factory Entitlement.fromJson(Object? data) {
    final json = _object(data);
    return Entitlement(
      id: _req(json, 'id'),
      planId: _req(json, 'planId'),
      planName: _req(json, 'planName'),
      source: _req(json, 'source'),
      note: _opt(json, 'note'),
      startsAt: _time(json, 'startsAt'),
      expiresAt: _optTime(json, 'expiresAt'),
      revokedAt: _optTime(json, 'revokedAt'),
      createdAt: _time(json, 'createdAt'),
    );
  }

  final String id;
  final String planId;
  final String planName;

  /// "admin", "kofi" or "play".
  final String source;
  final String? note;
  final DateTime startsAt;

  /// Null when it doesn't end.
  final DateTime? expiresAt;
  final DateTime? revokedAt;
  final DateTime createdAt;

  /// Whether it still counts at [now].
  bool activeAt(DateTime now) =>
      revokedAt == null && !startsAt.isAfter(now) && (expiresAt == null || expiresAt!.isAfter(now));
}

/// A payment a provider told the server about.
class AdminPayment {
  const AdminPayment({
    required this.id,
    required this.provider,
    required this.kind,
    required this.state,
    this.email,
    this.payerName,
    this.amount,
    this.currency,
    this.product,
    this.planId,
    this.days,
    this.userId,
    this.userName,
    required this.paidAt,
    this.reference,
  });

  factory AdminPayment.fromJson(Object? data) {
    final json = _object(data);
    return AdminPayment(
      id: _req(json, 'id'),
      provider: _req(json, 'provider'),
      kind: _req(json, 'kind'),
      state: _req(json, 'state'),
      email: _opt(json, 'email'),
      payerName: _opt(json, 'payerName'),
      amount: _opt(json, 'amount'),
      currency: _opt(json, 'currency'),
      product: _opt(json, 'product'),
      planId: _opt(json, 'planId'),
      days: _opt<num>(json, 'days')?.toInt(),
      userId: _opt(json, 'userId'),
      userName: _opt(json, 'userName'),
      paidAt: _time(json, 'paidAt'),
      reference: _opt(json, 'reference'),
    );
  }

  final String id;
  final String provider;

  /// The provider's word for it, such as "Donation" or "Subscription".
  final String kind;

  /// "applied", "unclaimed" or "unmatched".
  final String state;
  final String? email;
  final String? payerName;
  final String? amount;
  final String? currency;
  final String? product;
  final String? planId;
  final int? days;
  final String? userId;
  final String? userName;
  final DateTime paidAt;

  /// The provider's ID for the transaction.
  final String? reference;
}
