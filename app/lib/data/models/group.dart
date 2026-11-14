import 'package:flutter/foundation.dart';

import '../../core/money.dart';
import 'json_fields.dart';

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
    this.paymentDetails = const [],
  });

  factory Member.fromJson(Object? data, int digits) {
    final json = jsonObject(data);
    return Member(
      id: requiredField(json, 'id'),
      name: requiredField(json, 'name'),
      color: optionalField(json, 'color'),
      left: optionalField<bool>(json, 'left') ?? false,
      owner: optionalField<bool>(json, 'owner') ?? false,
      claimed: optionalField<bool>(json, 'claimed') ?? false,
      balance: moneyField(json, 'balance', digits),
      paymentDetails: [
        for (final d in optionalField<List<Object?>>(json, 'paymentDetails') ?? const [])
          PaymentDetail.fromJson(d),
      ],
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

  /// How to pay them in this group, in the order they listed them.
  final List<PaymentDetail> paymentDetails;
}

/// One way to pay a member: a bank account, a payment app handle or a link.
@immutable
class PaymentDetail {
  const PaymentDetail({required this.label, required this.value});

  factory PaymentDetail.fromJson(Object? data) {
    final json = jsonObject(data);
    return PaymentDetail(label: requiredField(json, 'label'), value: requiredField(json, 'value'));
  }

  /// At most this many per member, as the server allows.
  static const max = 5;
  static const maxLabel = 40;
  static const maxValue = 200;

  final String label;
  final String value;

  /// A web address, which can be opened as well as copied.
  Uri? get link {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty ? uri : null;
  }

  Map<String, Object?> toJson() => {'label': label, 'value': value};

  @override
  bool operator ==(Object other) => other is PaymentDetail && other.label == label && other.value == value;

  @override
  int get hashCode => Object.hash(label, value);
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
    this.features = const GroupFeatures(),
  });

  factory Group.fromJson(Object? data) {
    final json = jsonObject(data);
    final digits = currencyDigits(json);
    return Group(
      token: requiredField(json, 'token'),
      name: requiredField(json, 'name'),
      emoji: optionalField(json, 'emoji'),
      color: optionalField(json, 'color'),
      currency: requiredField(json, 'currency'),
      symbol: optionalField(json, 'symbol'),
      minorDigits: digits,
      createdAt: dateField(json, 'createdAt'),
      members: [for (final m in requiredField<List<Object?>>(json, 'members')) Member.fromJson(m, digits)],
      categories: [
        for (final c in optionalField<List<Object?>>(json, 'categories') ?? const [])
          GroupCategory.fromJson(c),
      ],
      linkAccess: optionalField<bool>(json, 'linkAccess') ?? true,
      myMemberId: optionalField(json, 'myMemberId'),
      features: switch (json['features']) {
        null => const GroupFeatures(),
        final f => GroupFeatures.fromJson(f),
      },
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

  /// What can be added. All of it from a server that predates the switches.
  final GroupFeatures features;

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

/// What a group has switched on. One switched off can't be added to an
/// expense, but what expenses already have stays.
@immutable
class GroupFeatures {
  const GroupFeatures({
    this.foreignCurrency = true,
    this.recurring = true,
    this.places = true,
    this.receipts = true,
  });

  factory GroupFeatures.fromJson(Object? data) {
    final json = jsonObject(data);
    return GroupFeatures(
      foreignCurrency: requiredField(json, 'foreignCurrency'),
      recurring: requiredField(json, 'recurring'),
      places: requiredField(json, 'places'),
      receipts: requiredField(json, 'receipts'),
    );
  }

  /// Paid in another currency than the group's.
  final bool foreignCurrency;

  /// Expenses added on a schedule. Off, the schedules wait.
  final bool recurring;

  /// Where an expense happened.
  final bool places;

  /// A photo of the receipt.
  final bool receipts;

  GroupFeatures copyWith({bool? foreignCurrency, bool? recurring, bool? places, bool? receipts}) =>
      GroupFeatures(
        foreignCurrency: foreignCurrency ?? this.foreignCurrency,
        recurring: recurring ?? this.recurring,
        places: places ?? this.places,
        receipts: receipts ?? this.receipts,
      );

  Map<String, Object?> toJson() => {
    'foreignCurrency': foreignCurrency,
    'recurring': recurring,
    'places': places,
    'receipts': receipts,
  };

  @override
  bool operator ==(Object other) =>
      other is GroupFeatures &&
      other.foreignCurrency == foreignCurrency &&
      other.recurring == recurring &&
      other.places == places &&
      other.receipts == receipts;

  @override
  int get hashCode => Object.hash(foreignCurrency, recurring, places, receipts);
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
    final json = jsonObject(data);
    return GroupCategory(
      id: requiredField(json, 'id'),
      name: optionalField(json, 'name'),
      emoji: requiredField(json, 'emoji'),
      rgb: requiredField(json, 'color'),
      builtIn: optionalField<bool>(json, 'builtIn') ?? false,
      hidden: optionalField<bool>(json, 'hidden') ?? false,
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
    this.sharedPlan,
  });

  factory GroupSummary.fromJson(Object? data) {
    final json = jsonObject(data);
    final digits = currencyDigits(json);
    final balance = optionalField<String>(json, 'balance');
    return GroupSummary(
      token: requiredField(json, 'token'),
      name: requiredField(json, 'name'),
      emoji: optionalField(json, 'emoji'),
      color: optionalField(json, 'color'),
      currency: requiredField(json, 'currency'),
      symbol: optionalField(json, 'symbol'),
      minorDigits: digits,
      memberCount: requiredField(json, 'memberCount'),
      balance: balance == null ? null : parseMoneyField(balance, digits, 'balance'),
      updatedAt: dateField(json, 'updatedAt'),
      sharedPlan: switch (optionalField<String>(json, 'sharedPlan')) {
        'mine' => SharedPlan.mine,
        'other' => SharedPlan.other,
        _ => null,
      },
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

  /// Whose plan covers the group, among a signed-in account's groups on a
  /// server that charges. Null when nobody's does.
  final SharedPlan? sharedPlan;
}

/// Whose plan a group uses: the signed-in account's, or another member's.
enum SharedPlan { mine, other }

@immutable
class Balances {
  const Balances({required this.nets, required this.transfers});

  factory Balances.fromJson(Object? data, int digits) {
    final json = jsonObject(data);
    return Balances(
      nets: {
        for (final b in objectList(json, 'balances'))
          requiredField<String>(b, 'memberId'): moneyField(b, 'amount', digits),
      },
      transfers: [
        for (final t in objectList(json, 'transfers'))
          Transfer(
            requiredField(t, 'fromMemberId'),
            requiredField(t, 'toMemberId'),
            moneyField(t, 'amount', digits),
          ),
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
    final json = jsonObject(data);
    final digits = currencyDigits(json);
    return ImportPreview(
      currency: requiredField(json, 'currency'),
      minorDigits: digits,
      members: [
        for (final m in objectList(json, 'members'))
          (name: requiredField<String>(m, 'name'), balance: moneyField(m, 'balance', digits)),
      ],
      expenses: requiredField(json, 'expenses'),
      payments: requiredField(json, 'payments'),
      skipped: requiredField(json, 'skipped'),
      from: json['from'] == null ? null : dateField(json, 'from'),
      to: json['to'] == null ? null : dateField(json, 'to'),
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
    final json = jsonObject(data);
    return JoinInfo(
      name: requiredField(json, 'name'),
      emoji: optionalField(json, 'emoji'),
      color: optionalField(json, 'color'),
      currency: requiredField(json, 'currency'),
      member: optionalField<bool>(json, 'member') ?? false,
      members: [
        for (final m in objectList(json, 'members'))
          JoinMember(
            id: requiredField(m, 'id'),
            name: requiredField(m, 'name'),
            color: optionalField(m, 'color'),
            claimed: requiredField(m, 'claimed'),
          ),
      ],
      invitedMemberId: optionalField(json, 'invitedMemberId'),
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
