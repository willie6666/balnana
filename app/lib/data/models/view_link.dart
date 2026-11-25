import 'package:flutter/foundation.dart';

import '../../core/money.dart';
import 'expense.dart';
import 'group.dart';
import 'json_fields.dart';

/// What a view-only link shows besides the group's name, look, currency and
/// member names. Notes, places and receipts belong to expenses.
@immutable
class ViewLinkShow {
  const ViewLinkShow({
    this.balances = true,
    this.expenses = true,
    this.spending = true,
    this.notes = false,
    this.places = false,
    this.receipts = false,
  });

  factory ViewLinkShow.fromJson(Object? data) {
    final json = jsonObject(data);
    return ViewLinkShow(
      balances: requiredField(json, 'balances'),
      expenses: requiredField(json, 'expenses'),
      spending: requiredField(json, 'spending'),
      notes: requiredField(json, 'notes'),
      places: requiredField(json, 'places'),
      receipts: requiredField(json, 'receipts'),
    );
  }

  final bool balances;
  final bool expenses;
  final bool spending;
  final bool notes;
  final bool places;
  final bool receipts;

  /// The server asks for at least one of these.
  bool get showsSomething => balances || expenses || spending;

  ViewLinkShow copyWith({
    bool? balances,
    bool? expenses,
    bool? spending,
    bool? notes,
    bool? places,
    bool? receipts,
  }) => ViewLinkShow(
    balances: balances ?? this.balances,
    expenses: expenses ?? this.expenses,
    spending: spending ?? this.spending,
    notes: notes ?? this.notes,
    places: places ?? this.places,
    receipts: receipts ?? this.receipts,
  );

  Map<String, Object> toJson() => {
    'balances': balances,
    'expenses': expenses,
    'spending': spending,
    'notes': notes,
    'places': places,
    'receipts': receipts,
  };

  @override
  bool operator ==(Object other) =>
      other is ViewLinkShow &&
      other.balances == balances &&
      other.expenses == expenses &&
      other.spending == spending &&
      other.notes == notes &&
      other.places == places &&
      other.receipts == receipts;

  @override
  int get hashCode => Object.hash(balances, expenses, spending, notes, places, receipts);
}

/// A group's view-only link, as its members see it.
@immutable
class ViewLink {
  const ViewLink({
    required this.token,
    required this.live,
    this.snapshotAt,
    required this.show,
    required this.createdAt,
    this.expiresAt,
    this.lastViewedAt,
    this.paused = false,
  });

  factory ViewLink.fromJson(Object? data) {
    final json = jsonObject(data);
    return ViewLink(
      token: requiredField(json, 'token'),
      live: requiredField(json, 'live'),
      snapshotAt: optionalDateField(json, 'snapshotAt'),
      show: ViewLinkShow.fromJson(json['show']),
      createdAt: dateField(json, 'createdAt'),
      expiresAt: optionalDateField(json, 'expiresAt'),
      lastViewedAt: optionalDateField(json, 'lastViewedAt'),
      paused: optionalField<bool>(json, 'paused') ?? false,
    );
  }

  /// The secret of its URL, /v/[token].
  final String token;

  /// Shows the group as it is, rather than as it was at [snapshotAt].
  final bool live;
  final DateTime? snapshotAt;
  final ViewLinkShow show;
  final DateTime createdAt;
  final DateTime? expiresAt;

  /// When it was last opened, to the hour.
  final DateTime? lastViewedAt;

  /// The group's plan does not include it, so it shows nothing for now.
  final bool paused;
}

/// A group as its view-only link shows it, see `GET /v/{viewToken}`.
@immutable
class ViewGroup {
  const ViewGroup({
    required this.name,
    this.emoji,
    this.color,
    required this.currency,
    this.symbol,
    required this.minorDigits,
    required this.live,
    this.asOf,
    required this.show,
    required this.members,
    required this.categories,
    this.transfers = const [],
  });

  factory ViewGroup.fromJson(Object? data) {
    final json = jsonObject(data);
    final digits = currencyDigits(json);
    return ViewGroup(
      name: requiredField(json, 'name'),
      emoji: optionalField(json, 'emoji'),
      color: optionalField(json, 'color'),
      currency: requiredField(json, 'currency'),
      symbol: optionalField(json, 'symbol'),
      minorDigits: digits,
      live: requiredField(json, 'live'),
      asOf: optionalDateField(json, 'asOf'),
      show: ViewLinkShow.fromJson(json['show']),
      members: [
        for (final m in objectList(json, 'members'))
          Member(
            id: requiredField(m, 'id'),
            name: requiredField(m, 'name'),
            color: optionalField(m, 'color'),
            left: optionalField<bool>(m, 'left') ?? false,
            balance: m['balance'] == null ? BigInt.zero : moneyField(m, 'balance', digits),
          ),
      ],
      categories: [
        for (final c in requiredField<List<Object?>>(json, 'categories')) GroupCategory.fromJson(c),
      ],
      transfers: [
        for (final t
            in json['transfers'] == null ? const <Map<String, Object?>>[] : objectList(json, 'transfers'))
          Transfer(
            requiredField(t, 'fromMemberId'),
            requiredField(t, 'toMemberId'),
            moneyField(t, 'amount', digits),
          ),
      ],
    );
  }

  final String name;
  final String? emoji;
  final int? color;
  final String currency;
  final String? symbol;
  final int minorDigits;
  final bool live;

  /// When the snapshot was taken; null for a live link.
  final DateTime? asOf;
  final ViewLinkShow show;

  /// Everyone, including members who left. Balances are zero unless shown.
  final List<Member> members;
  final List<GroupCategory> categories;
  final List<Transfer> transfers;

  /// The group in the shape the group's own widgets take. Its [Group.token]
  /// is not a group's: [viewToken] keeps its filters apart from real groups'.
  Group asGroup(String viewToken) => Group(
    token: 'view:$viewToken',
    name: name,
    emoji: emoji,
    color: color,
    currency: currency,
    symbol: symbol,
    minorDigits: minorDigits,
    createdAt: asOf ?? DateTime.now(),
    members: members,
    categories: categories,
  );
}

/// Reads an expense of a view-only link, which leaves out who added it and
/// its version.
Expense viewExpenseFromJson(Object? data, int digits) =>
    Expense.fromJson({...jsonObject(data), 'kind': 'expense', 'version': 0}, digits);
