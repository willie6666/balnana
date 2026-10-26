import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../core/server.dart';
import 'models.dart';

/// A failed request. [code] is the server's error code (see api/openapi.yaml),
/// or [network] when no answer came back.
class ApiException implements Exception {
  const ApiException(this.code, {this.status, this.params = const {}});

  static const network = 'network';

  final String code;
  final int? status;
  final Map<String, Object?> params;

  bool get isNotFound => status == 404;

  @override
  String toString() => 'ApiException($status $code)';
}

/// What the expense editor sends. Amounts are minor units.
class ExpenseDraft {
  const ExpenseDraft({
    required this.title,
    this.categoryId,
    required this.amount,
    required this.occurredAt,
    this.note,
    required this.payers,
    required this.splitMethod,
    required this.splits,
  });

  final String title;
  final String? categoryId;
  final BigInt amount;
  final DateTime occurredAt;
  final String? note;

  /// Member id to amount paid.
  final Map<String, BigInt> payers;
  final SplitMethod splitMethod;

  /// Who shares the cost; values as [SplitPart.value] describes.
  final List<SplitPart> splits;

  Map<String, Object?> toJson(int digits, {int? version}) => {
    'title': title,
    'categoryId': ?categoryId,
    'amount': formatAmount(amount, digits),
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    'note': ?note,
    'payers': [
      for (final MapEntry(:key, :value) in payers.entries)
        {'memberId': key, 'amount': formatAmount(value, digits)},
    ],
    'splitMethod': splitMethod.name,
    'splits': [
      for (final s in splits) {'memberId': s.member, if (splitMethod != SplitMethod.equal) 'value': s.value},
    ],
    'version': ?version,
  };
}

/// The Balnana HTTP API. Every call throws [ApiException] on failure.
class BalnanaApi {
  BalnanaApi(this._dio);

  final Dio _dio;

  Future<T> _send<T>(Future<Response<Object?>> Function() request, T Function(Object? data) parse) async {
    try {
      final res = await request();
      return parse(res.data);
    } on DioException catch (e) {
      final res = e.response;
      if (res == null) throw const ApiException(ApiException.network);
      final body = res.data;
      if (body is Map<String, Object?> && body['code'] is String) {
        final params = body['params'];
        throw ApiException(
          body['code'] as String,
          status: res.statusCode,
          params: params is Map<String, Object?> ? params : const {},
        );
      }
      throw ApiException('http_${res.statusCode}', status: res.statusCode);
    } on FormatException {
      throw const ApiException('bad_response');
    }
  }

  /// Where to keep the session: the web keeps it in an HttpOnly cookie,
  /// Android gets a token back.
  static const _cookie = kIsWeb;

  /// Returns the session token, or null on the web.
  Future<(String?, User)> register({
    required String email,
    required String password,
    required String name,
    String? locale,
    String? invite,
  }) => _send(
    () => _dio.post<Object?>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
        'locale': ?locale,
        'invite': ?invite,
        'cookie': _cookie,
      },
    ),
    _session,
  );

  /// Returns the session token, or null on the web.
  Future<(String?, User)> login({required String email, required String password}) => _send(
    () => _dio.post<Object?>('/auth/login', data: {'email': email, 'password': password, 'cookie': _cookie}),
    _session,
  );

  static (String?, User) _session(Object? data) {
    if (data is! Map<String, Object?>) throw const FormatException('expected an object');
    final token = data['token'];
    return (token is String ? token : null, User.fromJson(data['user']));
  }

  /// Emails a link for choosing a new password, if the address has an account.
  Future<void> requestPasswordReset(String email) =>
      _send(() => _dio.post<Object?>('/auth/password-reset', data: {'email': email}), (_) {});

  /// Signs out every session of the account.
  Future<void> resetPassword({required String token, required String password}) => _send(
    () => _dio.post<Object?>('/auth/password-reset/confirm', data: {'token': token, 'newPassword': password}),
    (_) {},
  );

  Future<void> verifyEmail(String token) =>
      _send(() => _dio.post<Object?>('/auth/verify-email', data: {'token': token}), (_) {});

  /// Emails the signed-in account a link confirming its address.
  Future<void> sendVerifyEmail() => _send(() => _dio.post<Object?>('/me/verify-email'), (_) {});

  Future<InviteInfo> invite(String token) =>
      _send(() => _dio.get<Object?>('/auth/invites/${Uri.encodeComponent(token)}'), InviteInfo.fromJson);

  Future<void> logout() => _send(() => _dio.post<Object?>('/auth/logout'), (_) {});

  Future<User> me() => _send(() => _dio.get<Object?>('/me'), User.fromJson);

  Future<User> updateMe({String? name, String? locale}) =>
      _send(() => _dio.patch<Object?>('/me', data: {'name': ?name, 'locale': ?locale}), User.fromJson);

  /// Signs out every other session of the account.
  Future<void> changePassword({String? current, required String next}) => _send(
    () => _dio.post<Object?>('/me/password', data: {'currentPassword': ?current, 'newPassword': next}),
    (_) {},
  );

  /// The signed-in account's groups, most recently changed first.
  Future<List<GroupSummary>> myGroups() => _send(() => _dio.get<Object?>('/me/groups'), (data) {
    if (data is! Map<String, Object?> || data['groups'] is! List<Object?>) throw const FormatException('bad groups');
    return [for (final g in data['groups'] as List<Object?>) GroupSummary.fromJson(g)];
  });

  Future<Group> createGroup({
    required String name,
    String? emoji,
    int? color,
    required String currency,
    required int minorDigits,
    required List<String> members,
  }) => _send(
    () => _dio.post<Object?>(
      '/groups',
      data: {
        'name': name,
        'emoji': ?emoji,
        'color': ?color,
        'currency': currency,
        'minorDigits': minorDigits,
        'members': members,
      },
    ),
    Group.fromJson,
  );

  /// Summaries of the groups this device knows. The second list holds the
  /// tokens the server no longer recognizes.
  Future<(List<GroupSummary>, List<String>)> summaries(Map<String, String?> memberByToken) => _send(
    () => _dio.post<Object?>(
      '/groups/summaries',
      data: {
        'groups': [
          for (final MapEntry(:key, :value) in memberByToken.entries) {'token': key, 'memberId': ?value},
        ],
      },
    ),
    (data) {
      if (data is! Map<String, Object?>) throw const FormatException('expected an object');
      final groups = data['groups'], missing = data['missing'];
      if (groups is! List<Object?> || missing is! List<Object?>) throw const FormatException('bad summaries');
      return ([for (final g in groups) GroupSummary.fromJson(g)], missing.whereType<String>().toList());
    },
  );

  /// Calls about one group, made as [memberId] when this device knows who it is.
  GroupApi group(String token, {String? memberId}) => GroupApi._(this, token, memberId);
}

class GroupApi {
  GroupApi._(this._api, this.token, this.memberId);

  final BalnanaApi _api;
  final String token;
  final String? memberId;

  Dio get _dio => _api._dio;
  String get _base => '/g/${Uri.encodeComponent(token)}';
  Options get _as => Options(headers: {'X-Balnana-Member': ?memberId});

  Future<T> _send<T>(Future<Response<Object?>> Function() request, T Function(Object? data) parse) =>
      _api._send(request, parse);

  Future<Group> get() => _send(() => _dio.get<Object?>(_base), Group.fromJson);

  /// An empty [emoji] removes it. [linkAccess] is for owners in accounts mode.
  Future<Group> update({String? name, String? emoji, int? color, bool? linkAccess}) => _send(
    () => _dio.patch<Object?>(
      _base,
      data: {'name': ?name, 'emoji': ?emoji, 'color': ?color, 'linkAccess': ?linkAccess},
      options: _as,
    ),
    Group.fromJson,
  );

  /// The group as seen before joining it (accounts mode).
  Future<JoinInfo> joinInfo() => _send(() => _dio.get<Object?>('$_base/join'), JoinInfo.fromJson);

  /// Joins as the unclaimed member [claim], or as someone new called [name]
  /// (the account's name when null).
  Future<Group> join({String? claim, String? name}) => _send(
    () => _dio.post<Object?>('$_base/join', data: {'claimMemberId': ?claim, 'name': ?name}),
    Group.fromJson,
  );

  /// Emails [email] a link to join, optionally as the unclaimed [member].
  Future<void> invite(String email, {String? member}) => _send(
    () => _dio.post<Object?>('$_base/invites', data: {'email': email, 'memberId': ?member}),
    (_) {},
  );

  /// Issues a new link; the old one stops working.
  Future<Group> resetLink() =>
      _send(() => _dio.post<Object?>('$_base/reset-link', options: _as), Group.fromJson);

  Future<Member> addMember(String name, {int? color, required int digits}) => _send(
    () => _dio.post<Object?>('$_base/members', data: {'name': name, 'color': ?color}, options: _as),
    (data) => Member.fromJson(data, digits),
  );

  Future<Member> updateMember(String id, String name, {int? color, required int digits}) => _send(
    () => _dio.patch<Object?>('$_base/members/$id', data: {'name': name, 'color': ?color}, options: _as),
    (data) => Member.fromJson(data, digits),
  );

  Future<void> removeMember(String id) =>
      _send(() => _dio.delete<Object?>('$_base/members/$id', options: _as), (_) {});

  Future<Page<Expense>> expenses(int digits, {String? cursor, int limit = 50}) => _send(
    () => _dio.get<Object?>('$_base/expenses', queryParameters: {'cursor': ?cursor, 'limit': limit}),
    (data) {
      if (data is! Map<String, Object?> || data['items'] is! List<Object?>) {
        throw const FormatException('bad page');
      }
      return Page([
        for (final e in data['items'] as List<Object?>) Expense.fromJson(e, digits),
      ], data['nextCursor'] as String?);
    },
  );

  Future<Expense> expense(String id, int digits) =>
      _send(() => _dio.get<Object?>('$_base/expenses/$id'), (data) => Expense.fromJson(data, digits));

  Future<Expense> createExpense(ExpenseDraft draft, int digits) => _send(
    () => _dio.post<Object?>('$_base/expenses', data: draft.toJson(digits), options: _as),
    (data) => Expense.fromJson(data, digits),
  );

  /// Fails with `expense_version_conflict` when someone else changed it since [version].
  Future<Expense> updateExpense(String id, ExpenseDraft draft, int digits, {required int version}) => _send(
    () => _dio.put<Object?>(
      '$_base/expenses/$id',
      data: draft.toJson(digits, version: version),
      options: _as,
    ),
    (data) => Expense.fromJson(data, digits),
  );

  Future<void> deleteExpense(String id) =>
      _send(() => _dio.delete<Object?>('$_base/expenses/$id', options: _as), (_) {});

  Future<Expense> restoreExpense(String id, int digits) => _send(
    () => _dio.post<Object?>('$_base/expenses/$id/restore', options: _as),
    (data) => Expense.fromJson(data, digits),
  );

  Future<Expense> recordPayment(String from, String to, BigInt amount, int digits) => _send(
    () => _dio.post<Object?>(
      '$_base/payments',
      data: {'fromMemberId': from, 'toMemberId': to, 'amount': formatAmount(amount, digits)},
      options: _as,
    ),
    (data) => Expense.fromJson(data, digits),
  );

  Future<Balances> balances(int digits) =>
      _send(() => _dio.get<Object?>('$_base/balances'), (data) => Balances.fromJson(data, digits));

  Future<Page<Activity>> activity({String? cursor, int limit = 50}) => _send(
    () => _dio.get<Object?>('$_base/activity', queryParameters: {'cursor': ?cursor, 'limit': limit}),
    (data) {
      if (data is! Map<String, Object?> || data['items'] is! List<Object?>) {
        throw const FormatException('bad page');
      }
      return Page([
        for (final a in data['items'] as List<Object?>) Activity.fromJson(a),
      ], data['nextCursor'] as String?);
    },
  );
}

/// The API of the chosen server, or null when none is set.
final balnanaApiProvider = Provider<BalnanaApi?>((ref) {
  final dio = ref.watch(apiProvider);
  return dio == null ? null : BalnanaApi(dio);
});
