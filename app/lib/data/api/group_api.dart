import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/money.dart';
import '../models/activity.dart';
import '../models/billing.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../models/page.dart';
import 'expense_draft.dart';
import 'time_zone.dart';
import 'transport.dart';

class GroupApi {
  GroupApi(this._transport, this.token, {this.memberId});

  final ApiTransport _transport;
  final String token;
  final String? memberId;

  Dio get _dio => _transport.dio;
  String get _base => '/g/${Uri.encodeComponent(token)}';
  Options get _as => Options(headers: {'X-Balnana-Member': ?memberId});
  Options _once(String? key) => Options(headers: {'X-Balnana-Member': ?memberId, 'Idempotency-Key': ?key});

  Future<Group> get() => _transport.send(() => _dio.get<Object?>(_base), Group.fromJson);

  /// The limits that apply to the group and how much of them is used.
  Future<GroupPlan> plan() => _transport.send(() => _dio.get<Object?>('$_base/plan'), GroupPlan.fromJson);

  /// Shares the signed-in account's plan with the whole group.
  Future<GroupPlan> sponsor() =>
      _transport.send(() => _dio.put<Object?>('$_base/sponsor'), GroupPlan.fromJson);

  Future<GroupPlan> unsponsor() =>
      _transport.send(() => _dio.delete<Object?>('$_base/sponsor'), GroupPlan.fromJson);

  /// An empty [emoji] removes it. [linkAccess] is for owners in accounts mode.
  /// An empty [emoji] or [symbol] clears it.
  Future<Group> update({
    String? name,
    String? emoji,
    int? color,
    String? symbol,
    bool? linkAccess,
    GroupFeatures? features,
  }) => _transport.send(
    () => _dio.patch<Object?>(
      _base,
      data: {
        'name': ?name,
        'emoji': ?emoji,
        'color': ?color,
        'symbol': ?symbol,
        'linkAccess': ?linkAccess,
        'features': ?features?.toJson(),
      },
      options: _as,
    ),
    Group.fromJson,
  );

  /// The group as seen before joining it (accounts mode).
  Future<JoinInfo> joinInfo() => _transport.send(() => _dio.get<Object?>('$_base/join'), JoinInfo.fromJson);

  /// Joins as the unclaimed member [claim], or as someone new called [name]
  /// (the account's name when null).
  Future<Group> join({String? claim, String? name}) => _transport.send(
    () => _dio.post<Object?>('$_base/join', data: {'claimMemberId': ?claim, 'name': ?name}),
    Group.fromJson,
  );

  /// Emails [email] a link to join, optionally as the unclaimed [member].
  Future<void> invite(String email, {String? member}) => _transport.send(
    () => _dio.post<Object?>('$_base/invites', data: {'email': email, 'memberId': ?member}),
    (_) {},
  );

  /// Deletes the group with everything in it. In accounts mode only its
  /// owner may.
  Future<void> delete() => _transport.send(() => _dio.delete<Object?>(_base, options: _as), (_) {});

  /// Issues a new link; the old one stops working.
  Future<Group> resetLink() =>
      _transport.send(() => _dio.post<Object?>('$_base/reset-link', options: _as), Group.fromJson);

  Future<Member> addMember(String name, {int? color, required int digits}) => _transport.send(
    () => _dio.post<Object?>('$_base/members', data: {'name': name, 'color': ?color}, options: _as),
    (data) => Member.fromJson(data, digits),
  );

  /// Leaving out [paymentDetails] keeps the member's as they are.
  Future<Member> updateMember(
    String id,
    String name, {
    int? color,
    List<PaymentDetail>? paymentDetails,
    required int digits,
  }) => _transport.send(
    () => _dio.patch<Object?>(
      '$_base/members/$id',
      data: {
        'name': name,
        'color': ?color,
        'paymentDetails': ?paymentDetails?.map((d) => d.toJson()).toList(),
      },
      options: _as,
    ),
    (data) => Member.fromJson(data, digits),
  );

  Future<void> removeMember(String id) =>
      _transport.send(() => _dio.delete<Object?>('$_base/members/$id', options: _as), (_) {});

  /// Reminds member [id] of what they owe this device's member. Returns the
  /// phones it reached.
  Future<int> remindMember(String id) => _transport.send(
    () => _dio.post<Object?>('$_base/members/$id/remind', options: _as),
    (data) => switch (data) {
      {'devices': final num n} => n.toInt(),
      _ => throw const FormatException('reminder'),
    },
  );

  Future<GroupCategory> addCategory({required String name, required String emoji, int? color}) =>
      _transport.send(
        () => _dio.post<Object?>(
          '$_base/categories',
          data: {'name': name, 'emoji': emoji, 'color': ?color},
          options: _as,
        ),
        GroupCategory.fromJson,
      );

  /// Built-in categories can only be hidden or shown.
  Future<GroupCategory> updateCategory(String id, {String? name, String? emoji, int? color, bool? hidden}) =>
      _transport.send(
        () => _dio.patch<Object?>(
          '$_base/categories/$id',
          data: {'name': ?name, 'emoji': ?emoji, 'color': ?color, 'hidden': ?hidden},
          options: _as,
        ),
        GroupCategory.fromJson,
      );

  Future<void> deleteCategory(String id) =>
      _transport.send(() => _dio.delete<Object?>('$_base/categories/$id', options: _as), (_) {});

  Future<Page<Expense>> expenses(
    int digits, {
    String? cursor,
    int limit = 50,
    ExpenseFilter filter = const ExpenseFilter(),
  }) => _transport.send(
    () => _dio.get<Object?>(
      '$_base/expenses',
      queryParameters: {'cursor': ?cursor, 'limit': limit, ...filter.query},
    ),
    (data) => Page.fromJson(data, (item) => Expense.fromJson(item, digits)),
  );

  Future<Expense> expense(String id, int digits) => _transport.send(
    () => _dio.get<Object?>('$_base/expenses/$id'),
    (data) => Expense.fromJson(data, digits),
  );

  /// [key] makes sending it again safe: see [newClientKey].
  Future<Expense> createExpense(ExpenseDraft draft, int digits, {String? key}) => _transport.send(
    () => _dio.post<Object?>('$_base/expenses', data: draft.toJson(digits), options: _once(key)),
    (data) => Expense.fromJson(data, digits),
  );

  /// Fails with `expense_version_conflict` when someone else changed it since [version].
  Future<Expense> updateExpense(String id, ExpenseDraft draft, int digits, {required int version}) =>
      _transport.send(
        () => _dio.put<Object?>(
          '$_base/expenses/$id',
          data: draft.toJson(digits, version: version),
          options: _as,
        ),
        (data) => Expense.fromJson(data, digits),
      );

  Future<void> deleteExpense(String id) =>
      _transport.send(() => _dio.delete<Object?>('$_base/expenses/$id', options: _as), (_) {});

  /// The photo of the expense's receipt, as JPEG bytes.
  Future<Uint8List> receipt(String id) => _transport.send(
    () =>
        _dio.get<Object?>('$_base/expenses/$id/receipt', options: Options(responseType: ResponseType.bytes)),
    (data) => data is List<int> ? Uint8List.fromList(data) : throw const FormatException('bad receipt'),
  );

  /// Attaches a photo of the receipt ([contentType] image/jpeg, image/png or
  /// image/webp), replacing any earlier one.
  Future<Expense> putReceipt(String id, Uint8List bytes, String contentType, int digits) => _transport.send(
    () => _dio.put<Object?>(
      '$_base/expenses/$id/receipt',
      data: bytes,
      options: _as.copyWith(contentType: contentType),
    ),
    (data) => Expense.fromJson(data, digits),
  );

  Future<void> deleteReceipt(String id) =>
      _transport.send(() => _dio.delete<Object?>('$_base/expenses/$id/receipt', options: _as), (_) {});

  Future<Expense> restoreExpense(String id, int digits) => _transport.send(
    () => _dio.post<Object?>('$_base/expenses/$id/restore', options: _as),
    (data) => Expense.fromJson(data, digits),
  );

  Future<Expense> recordPayment(
    String from,
    String to,
    BigInt amount,
    int digits, {
    String? key,
    DateTime? occurredAt,
  }) => _transport.send(
    () => _dio.post<Object?>(
      '$_base/payments',
      data: paymentBody(from, to, amount, digits, occurredAt: occurredAt ?? DateTime.now()),
      options: _once(key),
    ),
    (data) => Expense.fromJson(data, digits),
  );

  static Map<String, Object?> paymentBody(
    String from,
    String to,
    BigInt amount,
    int digits, {
    required DateTime occurredAt,
  }) => {
    'fromMemberId': from,
    'toMemberId': to,
    'amount': formatAmount(amount, digits),
    'occurredAt': occurredAt.toUtc().toIso8601String(),
  };

  /// Sends [body] to [path] in the group as it was kept while offline, with
  /// the same [key], so it is added once however often it is sent.
  Future<void> resend(String path, Object? body, {required String key}) =>
      _transport.send(() => _dio.post<Object?>('$_base$path', data: body, options: _once(key)), (_) {});

  Future<List<RecurringExpense>> recurringExpenses(int digits) => _transport.send(
    () => _dio.get<Object?>('$_base/recurring'),
    (data) => [
      for (final r in data is List<Object?> ? data : throw const FormatException('bad list'))
        RecurringExpense.fromJson(r, digits),
    ],
  );

  Future<RecurringExpense> recurringExpense(String id, int digits) => _transport.send(
    () => _dio.get<Object?>('$_base/recurring/$id'),
    (data) => RecurringExpense.fromJson(data, digits),
  );

  /// Occurrences already due are added at once. Without a time zone, the
  /// schedule follows this device's.
  Future<RecurringExpense> createRecurring(RecurringDraft draft, int digits, {String? key}) =>
      withRecurringTimeZone(
        draft,
        (json) => _transport.send(
          () => _dio.post<Object?>('$_base/recurring', data: json(digits), options: _once(key)),
          (data) => RecurringExpense.fromJson(data, digits),
        ),
      );

  /// Fails with `recurring_version_conflict` when someone else changed it since [version].
  Future<RecurringExpense> updateRecurring(
    String id,
    RecurringDraft draft,
    int digits, {
    required int version,
  }) => withRecurringTimeZone(
    draft,
    (json) => _transport.send(
      () => _dio.put<Object?>(
        '$_base/recurring/$id',
        data: json(digits, version: version),
        options: _as,
      ),
      (data) => RecurringExpense.fromJson(data, digits),
    ),
  );

  /// Resuming adds what came due before it was paused and skips what came
  /// due while it was.
  Future<RecurringExpense> pauseRecurring(String id, {required bool paused, required int digits}) =>
      _transport.send(
        () => _dio.patch<Object?>('$_base/recurring/$id', data: {'paused': paused}, options: _as),
        (data) => RecurringExpense.fromJson(data, digits),
      );

  /// The expenses it added stay.
  Future<void> deleteRecurring(String id) =>
      _transport.send(() => _dio.delete<Object?>('$_base/recurring/$id', options: _as), (_) {});

  Future<Balances> balances(int digits) =>
      _transport.send(() => _dio.get<Object?>('$_base/balances'), (data) => Balances.fromJson(data, digits));

  /// What the group spent in [period], with months starting in this device's time zone.
  Future<GroupStats> stats(int digits, {Period? period}) => withLocalTimeZone(
    (zone) => _transport.send(
      () => _dio.get<Object?>(
        '$_base/stats',
        queryParameters: {
          if (period != null) ...{
            'from': period.from.toUtc().toIso8601String(),
            'to': period.to.toUtc().toIso8601String(),
          },
          ...zone,
        },
      ),
      (data) => GroupStats.fromJson(data, digits),
    ),
  );

  /// Every expense and payment as a CSV file, dated in this device's time zone.
  Future<Uint8List> exportCsv() => withLocalTimeZone(
    (zone) => _transport.send(
      () => _dio.get<Object?>(
        '$_base/export.csv',
        queryParameters: zone,
        options: Options(responseType: ResponseType.bytes),
      ),
      (data) => data is List<int> ? Uint8List.fromList(data) : throw const FormatException('bad csv'),
    ),
  );

  Future<Page<Activity>> activity({String? cursor, int limit = 50}) => _transport.send(
    () => _dio.get<Object?>('$_base/activity', queryParameters: {'cursor': ?cursor, 'limit': limit}),
    (data) => Page.fromJson(data, Activity.fromJson),
  );
}
