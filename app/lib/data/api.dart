import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../core/money.dart';
import '../core/server.dart';
import '../core/session.dart';
import 'models.dart';
import 'providers.dart';

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
    this.location,
    required this.payers,
    required this.splitMethod,
    required this.splits,
  });

  final String title;
  final String? categoryId;
  final BigInt amount;
  final DateTime occurredAt;
  final String? note;
  final ExpenseLocation? location;

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
    'location': ?location?.toJson(),
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

/// Where a push service delivers this device's Web Push messages: the
/// [endpoint] to send to and the keys to encrypt for (RFC 8291), base64url.
typedef PushSubscription = ({String endpoint, String p256dh, String auth});

/// The Balnana HTTP API. Every call throws [ApiException] on failure.
class BalnanaApi {
  BalnanaApi(this._dio, {this.onSignInRequired});

  final Dio _dio;

  /// Called when the server says the session this was made with is gone.
  final void Function()? onSignInRequired;

  Future<T> _send<T>(Future<Response<Object?>> Function() request, T Function(Object? data) parse) async {
    try {
      final res = await request();
      return parse(res.data);
    } on DioException catch (e) {
      final res = e.response;
      if (res == null) throw const ApiException(ApiException.network);
      final body = _errorBody(res.data);
      if (body is Map<String, Object?> && body['code'] is String) {
        final params = body['params'];
        if (res.statusCode == 401 && body['code'] == 'sign_in_required') onSignInRequired?.call();
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

  /// The error of a request that asked for bytes is JSON all the same.
  static Object? _errorBody(Object? data) {
    if (data is! List<int>) return data;
    try {
      return jsonDecode(utf8.decode(data));
    } on FormatException {
      return null;
    }
  }

  /// Where to keep the session: the web app on its own server keeps it in an
  /// HttpOnly cookie, others get a token back.
  bool get _cookie => cookieSession(_dio.options.baseUrl);

  /// Returns the session token, or null on the web.
  Future<(String?, User)> register({
    String? email,
    String? username,
    required String password,
    required String name,
    String? locale,
    String? invite,
  }) => _send(
    () => _dio.post<Object?>(
      '/auth/register',
      data: {
        'email': ?email,
        'username': ?username,
        'password': password,
        'name': name,
        'locale': ?locale,
        'invite': ?invite,
        'cookie': _cookie,
      },
    ),
    _session,
  );

  /// Signs in with an email address or username. Returns the session token,
  /// or null on the web.
  Future<(String?, User)> login({required String login, required String password}) => _send(
    () => _dio.post<Object?>('/auth/login', data: {'login': login, 'password': password, 'cookie': _cookie}),
    _session,
  );

  /// Trades the code a Google or OpenID Connect sign-in sent back to the
  /// Android app for a session; [verifier] proves this app started it.
  Future<(String?, User)> exchangeOAuthCode({required String code, required String verifier}) => _send(
    () => _dio.post<Object?>('/auth/oauth/exchange', data: {'code': code, 'verifier': verifier}),
    _session,
  );

  /// What a sign-in that stopped to ask is about: the address of the
  /// account it matched, which has not confirmed it.
  Future<OAuthPending> oauthPending(String token) =>
      _send(() => _dio.post<Object?>('/auth/oauth/pending', data: {'token': token}), OAuthPending.fromJson);

  /// Ends a sign-in that stopped to ask: [choice] is `link` (with the
  /// account's [password]), `take_over` or `new_account`. [verifier] is the
  /// one the sign-in started with, if it did.
  Future<(String?, User)> finishOAuthPending({
    required String token,
    required String choice,
    String? password,
    String? verifier,
  }) => _send(
    () => _dio.post<Object?>(
      '/auth/oauth/pending/finish',
      data: {
        'token': token,
        'choice': choice,
        'password': ?password,
        'verifier': ?verifier,
        'cookie': _cookie,
      },
    ),
    _session,
  );

  /// Ids of the providers the signed-in account signs in with.
  Future<List<String>> myOAuth() => _send(() => _dio.get<Object?>('/me/oauth'), (data) {
    if (data is! Map<String, Object?> || data['providers'] is! List<Object?>) {
      throw const FormatException('bad providers');
    }
    return [...(data['providers'] as List<Object?>).whereType<String>()];
  });

  /// A ticket for adding [provider] to the signed-in account: the sign-in
  /// started with it adds the identity instead of signing in.
  Future<String> linkOAuth(String provider, {String? password}) => _send(
    () => _dio.post<Object?>('/me/oauth/${Uri.encodeComponent(provider)}', data: {'password': ?password}),
    (data) => switch (data) {
      {'ticket': final String ticket} => ticket,
      _ => throw const FormatException('bad ticket'),
    },
  );

  Future<void> unlinkOAuth(String provider) =>
      _send(() => _dio.delete<Object?>('/me/oauth/${Uri.encodeComponent(provider)}'), (_) {});

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

  /// Sets the account's email address, or removes it when [email] is empty
  /// (accounts with a username only). A new address needs verifying again.
  Future<User> changeEmail(String email, {String? password}) => _send(
    () => _dio.post<Object?>('/me/email', data: {'email': email, 'password': ?password}),
    User.fromJson,
  );

  /// Deletes the account for good. Its members stay in their groups,
  /// unclaimed; groups nobody else could reach go with it.
  Future<void> deleteMe({String? password}) =>
      _send(() => _dio.post<Object?>('/me/delete', data: {'password': ?password}), (_) {});

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
    String? symbol,
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
        'symbol': ?symbol,
        'minorDigits': minorDigits,
        'members': members,
      },
    ),
    Group.fromJson,
  );

  /// A large export takes the server a while to read: longer than other
  /// requests may, and an import given up on too soon would be made again.
  static final _importTime = Options(receiveTimeout: const Duration(minutes: 5));

  /// What importing a Settle Up export would create. Nothing is kept.
  Future<ImportPreview> previewImport(Uint8List file) => _send(
    () => _dio.post<Object?>('/groups/import', data: _import(file, dryRun: true), options: _importTime),
    ImportPreview.fromJson,
  );

  /// Creates a group from a Settle Up export. [me] is the person in the file
  /// this app is; [untitled] names expenses without a purpose.
  Future<Group> importGroup(Uint8List file, {required String name, required String me, required String untitled}) =>
      _send(
        () => _dio.post<Object?>(
          '/groups/import',
          data: _import(file, name: name, me: me, untitled: untitled),
          options: _importTime,
        ),
        Group.fromJson,
      );

  static Map<String, Object?> _import(
    Uint8List file, {
    bool dryRun = false,
    String? name,
    String? me,
    String? untitled,
  }) => {
    'format': 'settle_up',
    'file': base64Encode(file),
    'dryRun': dryRun,
    'name': ?name,
    'me': ?me,
    'untitled': ?untitled,
  };

  /// Summaries of the groups this device knows. [missing] holds the tokens
  /// the server no longer recognizes, [locked] those of groups it has that
  /// this device may not open as it is, such as without signing in.
  Future<({List<GroupSummary> groups, List<String> missing, List<String> locked})> summaries(
    Map<String, String?> memberByToken,
  ) => _send(
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
      final groups = data['groups'], missing = data['missing'], locked = data['locked'] ?? const <Object?>[];
      if (groups is! List<Object?> || missing is! List<Object?> || locked is! List<Object?>) {
        throw const FormatException('bad summaries');
      }
      return (
        groups: [for (final g in groups) GroupSummary.fromJson(g)],
        missing: missing.whereType<String>().toList(),
        locked: locked.whereType<String>().toList(),
      );
    },
  );

  /// Calls about one group, made as [memberId] when this device knows who it is.
  GroupApi group(String token, {String? memberId}) => GroupApi._(this, token, memberId);

  /// Asks for notifications about [groups] (and, signed in, the account's
  /// groups) on [device], this app's own random ID for the phone, sent to
  /// the Web Push subscription [sub].
  Future<void> registerPushDevice(
    String device,
    PushSubscription sub,
    List<({String token, String memberId})> groups,
  ) => _send(
    () => _dio.put<Object?>(
      '/push/devices/${Uri.encodeComponent(device)}',
      data: {
        'endpoint': sub.endpoint,
        'p256dh': sub.p256dh,
        'auth': sub.auth,
        'groups': [for (final g in groups) {'token': g.token, 'memberId': g.memberId}],
      },
    ),
    (_) {},
  );

  Future<void> removePushDevice(String device) =>
      _send(() => _dio.delete<Object?>('/push/devices/${Uri.encodeComponent(device)}'), (_) {});
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
  /// An empty [emoji] or [symbol] clears it.
  Future<Group> update({String? name, String? emoji, int? color, String? symbol, bool? linkAccess}) => _send(
    () => _dio.patch<Object?>(
      _base,
      data: {'name': ?name, 'emoji': ?emoji, 'color': ?color, 'symbol': ?symbol, 'linkAccess': ?linkAccess},
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

  /// Deletes the group with everything in it. In accounts mode only its
  /// owner may.
  Future<void> delete() => _send(() => _dio.delete<Object?>(_base, options: _as), (_) {});

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

  Future<GroupCategory> addCategory({required String name, required String emoji, int? color}) => _send(
    () => _dio.post<Object?>(
      '$_base/categories',
      data: {'name': name, 'emoji': emoji, 'color': ?color},
      options: _as,
    ),
    GroupCategory.fromJson,
  );

  /// Built-in categories can only be hidden or shown.
  Future<GroupCategory> updateCategory(String id, {String? name, String? emoji, int? color, bool? hidden}) => _send(
    () => _dio.patch<Object?>(
      '$_base/categories/$id',
      data: {'name': ?name, 'emoji': ?emoji, 'color': ?color, 'hidden': ?hidden},
      options: _as,
    ),
    GroupCategory.fromJson,
  );

  Future<void> deleteCategory(String id) =>
      _send(() => _dio.delete<Object?>('$_base/categories/$id', options: _as), (_) {});

  Future<Page<Expense>> expenses(
    int digits, {
    String? cursor,
    int limit = 50,
    ExpenseFilter filter = const ExpenseFilter(),
  }) => _send(
    () => _dio.get<Object?>(
      '$_base/expenses',
      queryParameters: {'cursor': ?cursor, 'limit': limit, ...filter.query},
    ),
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

  /// The photo of the expense's receipt, as JPEG bytes.
  Future<Uint8List> receipt(String id) => _send(
    () => _dio.get<Object?>('$_base/expenses/$id/receipt', options: Options(responseType: ResponseType.bytes)),
    (data) => data is List<int> ? Uint8List.fromList(data) : throw const FormatException('bad receipt'),
  );

  /// Attaches a photo of the receipt ([contentType] image/jpeg, image/png or
  /// image/webp), replacing any earlier one.
  Future<Expense> putReceipt(String id, Uint8List bytes, String contentType, int digits) => _send(
    () => _dio.put<Object?>(
      '$_base/expenses/$id/receipt',
      data: bytes,
      options: _as.copyWith(contentType: contentType),
    ),
    (data) => Expense.fromJson(data, digits),
  );

  Future<void> deleteReceipt(String id) =>
      _send(() => _dio.delete<Object?>('$_base/expenses/$id/receipt', options: _as), (_) {});

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

  Future<List<RecurringExpense>> recurringExpenses(int digits) => _send(
    () => _dio.get<Object?>('$_base/recurring'),
    (data) => [
      for (final r in data is List<Object?> ? data : throw const FormatException('bad list'))
        RecurringExpense.fromJson(r, digits),
    ],
  );

  Future<RecurringExpense> recurringExpense(String id, int digits) =>
      _send(() => _dio.get<Object?>('$_base/recurring/$id'), (data) => RecurringExpense.fromJson(data, digits));

  /// Occurrences already due are added at once. Without a time zone, the
  /// schedule follows this device's.
  Future<RecurringExpense> createRecurring(RecurringDraft draft, int digits) => _inZone(
    draft,
    (json) => _send(
      () => _dio.post<Object?>('$_base/recurring', data: json(digits), options: _as),
      (data) => RecurringExpense.fromJson(data, digits),
    ),
  );

  /// Fails with `recurring_version_conflict` when someone else changed it since [version].
  Future<RecurringExpense> updateRecurring(String id, RecurringDraft draft, int digits, {required int version}) =>
      _inZone(
        draft,
        (json) => _send(
          () => _dio.put<Object?>('$_base/recurring/$id', data: json(digits, version: version), options: _as),
          (data) => RecurringExpense.fromJson(data, digits),
        ),
      );

  /// Sends [draft] in this device's time zone when it names none: by its
  /// IANA name, or as the fixed offset at the start when the device does not
  /// say or the server does not know the name, so the schedule keeps its
  /// local day and time.
  Future<T> _inZone<T>(
    RecurringDraft draft,
    Future<T> Function(Map<String, Object?> Function(int digits, {int? version}) json) send,
  ) async {
    if (draft.timeZone != null) return send(draft.toJson);
    Map<String, Object?> Function(int, {int? version}) inZone(String zone) =>
        (digits, {version}) => {...draft.toJson(digits, version: version), 'timeZone': zone};
    final offset = fixedZone(draft.expense.occurredAt.toLocal().timeZoneOffset);
    final name = await deviceTimeZone();
    if (name == null) return send(inZone(offset));
    try {
      return await send(inZone(name));
    } on ApiException catch (e) {
      if (e.code != 'invalid_time_zone') rethrow;
      return send(inZone(offset));
    }
  }

  /// Resuming adds what came due before it was paused and skips what came
  /// due while it was.
  Future<RecurringExpense> pauseRecurring(String id, {required bool paused, required int digits}) => _send(
    () => _dio.patch<Object?>('$_base/recurring/$id', data: {'paused': paused}, options: _as),
    (data) => RecurringExpense.fromJson(data, digits),
  );

  /// The expenses it added stay.
  Future<void> deleteRecurring(String id) =>
      _send(() => _dio.delete<Object?>('$_base/recurring/$id', options: _as), (_) {});

  Future<Balances> balances(int digits) =>
      _send(() => _dio.get<Object?>('$_base/balances'), (data) => Balances.fromJson(data, digits));

  /// What the group spent in [period], with months starting in this device's time zone.
  Future<GroupStats> stats(int digits, {Period? period}) => _inLocalTime(
    (zone) => _send(
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
  Future<Uint8List> exportCsv() => _inLocalTime(
    (zone) => _send(
      () => _dio.get<Object?>(
        '$_base/export.csv',
        queryParameters: zone,
        options: Options(responseType: ResponseType.bytes),
      ),
      (data) => data is List<int> ? Uint8List.fromList(data) : throw const FormatException('bad csv'),
    ),
  );

  /// Asks with this device's time zone. Its name lets the server date each
  /// expense by the offset in force then, across daylight saving time; the
  /// current offset is for a server that does not know the name.
  Future<T> _inLocalTime<T>(Future<T> Function(Map<String, Object> zone) ask) async {
    final offset = {'utcOffset': DateTime.now().timeZoneOffset.inMinutes};
    final name = await deviceTimeZone();
    if (name == null) return ask(offset);
    try {
      return await ask({...offset, 'timeZone': name});
    } on ApiException catch (e) {
      if (e.code != 'invalid_time_zone') rethrow;
      return ask(offset);
    }
  }

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

/// The administrator's part of the API. It goes through a client without
/// the account's session; the token comes from [setup] or [login].
class AdminApi {
  AdminApi(Dio dio) : _api = BalnanaApi(dio), _dio = dio;

  final BalnanaApi _api;
  final Dio _dio;

  Options _as(String token) => Options(headers: {'X-Balnana-Admin': token});

  static String _token(Object? data) {
    if (data case {'token': final String token}) return token;
    throw const FormatException('expected a session');
  }

  /// Sets the password on a new server; [code] is the setup code from the
  /// server's log, when it asks for one. Returns a session token.
  Future<String> setup({required String password, String? code}) => _api._send(
    () => _dio.post<Object?>('/admin/setup', data: {'password': password, 'code': ?code}),
    _token,
  );

  Future<String> login(String password) =>
      _api._send(() => _dio.post<Object?>('/admin/login', data: {'password': password}), _token);

  Future<void> logout(String token) =>
      _api._send(() => _dio.post<Object?>('/admin/logout', options: _as(token)), (_) {});

  /// Ends every other admin session.
  Future<void> changePassword(String token, {required String current, required String next}) => _api._send(
    () => _dio.post<Object?>(
      '/admin/password',
      data: {'currentPassword': current, 'newPassword': next},
      options: _as(token),
    ),
    (_) {},
  );

  Future<List<AdminSetting>> settings(String token) =>
      _api._send(() => _dio.get<Object?>('/admin/settings', options: _as(token)), AdminSetting.listFromJson);

  /// Changes the settings in [values] (empty for the default) and returns
  /// all of them as now in force. Throws `invalid_settings` with the keys at
  /// fault in `params['keys']`, changing nothing.
  Future<List<AdminSetting>> save(String token, Map<String, String> values) => _api._send(
    () => _dio.put<Object?>('/admin/settings', data: {'values': values}, options: _as(token)),
    AdminSetting.listFromJson,
  );

  /// Accounts whose name, address or username contains [query], newest
  /// first, with how many match in all.
  Future<(List<AdminUser>, int)> users(String token, {String query = ''}) => _api._send(
    () => _dio.get<Object?>('/admin/users', queryParameters: {'q': query}, options: _as(token)),
    (data) {
      if (data case {'users': final List<Object?> users, 'total': final num total}) {
        return ([for (final u in users) AdminUser.fromJson(u)], total.toInt());
      }
      throw const FormatException('bad users');
    },
  );

  /// Deletes an account as the owner deleting it would.
  Future<void> deleteUser(String token, String id) => _api._send(
    () => _dio.delete<Object?>('/admin/users/${Uri.encodeComponent(id)}', options: _as(token)),
    (_) {},
  );
}

/// A fixed time zone the server knows by its offset, such as "UTC+05:30".
@visibleForTesting
String fixedZone(Duration offset) {
  if (offset == Duration.zero) return 'UTC';
  final minutes = offset.inMinutes.abs();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'UTC${offset.isNegative ? '-' : '+'}${two(minutes ~/ 60)}:${two(minutes % 60)}';
}

/// This device's IANA time zone, such as "Europe/Berlin", or null when the
/// platform does not say. Tests replace it.
@visibleForTesting
Future<String?> Function() deviceTimeZone = () async {
  try {
    final zone = (await FlutterTimezone.getLocalTimezone()).identifier;
    return zone.isEmpty ? null : zone;
  } on Object {
    return null;
  }
};

/// The API of the chosen server, or null when none is set.
final balnanaApiProvider = Provider<BalnanaApi?>((ref) {
  final dio = ref.watch(apiProvider);
  if (dio == null) return null;
  final who = ref.watch(identityProvider);
  return BalnanaApi(
    dio,
    // A session ended elsewhere, such as by a password change on another
    // device, ends here too, so the app stops showing it as signed in.
    onSignInRequired: () => scheduleMicrotask(() {
      if (ref.mounted) ref.read(sessionProvider.notifier).lost(who, signedIn: ref.read(signedInProvider));
    }),
  );
});
