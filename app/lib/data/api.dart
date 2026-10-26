import 'package:dio/dio.dart';
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
      for (final MapEntry(:key, :value) in payers.entries) {'memberId': key, 'amount': formatAmount(value, digits)},
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

  /// An empty [emoji] removes it.
  Future<Group> update({String? name, String? emoji, int? color}) => _send(
    () => _dio.patch<Object?>(_base, data: {'name': ?name, 'emoji': ?emoji, 'color': ?color}, options: _as),
    Group.fromJson,
  );

  /// Issues a new link; the old one stops working.
  Future<Group> resetLink() => _send(() => _dio.post<Object?>('$_base/reset-link', options: _as), Group.fromJson);

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
      return Page(
        [for (final e in data['items'] as List<Object?>) Expense.fromJson(e, digits)],
        data['nextCursor'] as String?,
      );
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
    () => _dio.put<Object?>('$_base/expenses/$id', data: draft.toJson(digits, version: version), options: _as),
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
      return Page([for (final a in data['items'] as List<Object?>) Activity.fromJson(a)], data['nextCursor'] as String?);
    },
  );
}

/// The API of the chosen server, or null when none is set.
final balnanaApiProvider = Provider<BalnanaApi?>((ref) {
  final dio = ref.watch(apiProvider);
  return dio == null ? null : BalnanaApi(dio);
});
