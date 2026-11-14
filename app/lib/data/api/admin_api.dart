import 'package:dio/dio.dart';

import '../models/admin.dart';
import '../models/billing.dart';
import 'transport.dart';

/// The administrator's part of the API. It goes through a client without
/// the account's session; the token comes from [setup] or [login].
class AdminApi {
  AdminApi(Dio dio) : _transport = ApiTransport(dio);

  final ApiTransport _transport;
  Dio get _dio => _transport.dio;

  Options _as(String token) => Options(headers: {'X-Balnana-Admin': token});

  static String _token(Object? data) {
    if (data case {'token': final String token}) return token;
    throw const FormatException('expected a session');
  }

  /// Sets the password on a new server; [code] is the setup code from the
  /// server's log, when it asks for one. Returns a session token.
  Future<String> setup({required String password, String? code}) => _transport.send(
    () => _dio.post<Object?>('/admin/setup', data: {'password': password, 'code': ?code}),
    _token,
  );

  Future<String> login(String password) =>
      _transport.send(() => _dio.post<Object?>('/admin/login', data: {'password': password}), _token);

  Future<void> logout(String token) =>
      _transport.send(() => _dio.post<Object?>('/admin/logout', options: _as(token)), (_) {});

  /// Ends every other admin session.
  Future<void> changePassword(String token, {required String current, required String next}) =>
      _transport.send(
        () => _dio.post<Object?>(
          '/admin/password',
          data: {'currentPassword': current, 'newPassword': next},
          options: _as(token),
        ),
        (_) {},
      );

  Future<AdminSettings> settings(String token) => _transport.send(
    () => _dio.get<Object?>('/admin/settings', options: _as(token)),
    AdminSettings.fromJson,
  );

  /// Changes the settings in [values] (empty for the default) and returns
  /// all of them as now in force. Throws `invalid_settings` with the keys at
  /// fault in `params['keys']`, changing nothing.
  Future<AdminSettings> save(String token, Map<String, String> values) => _transport.send(
    () => _dio.put<Object?>('/admin/settings', data: {'values': values}, options: _as(token)),
    AdminSettings.fromJson,
  );

  /// The saved settings as the lines of a .env file, secrets and all, which
  /// is why the administrator [password] is asked for again: `wrong_password`
  /// when it is not right.
  Future<String> exportSettings(String token, String password) => _transport.send(
    () => _dio.post<Object?>('/admin/settings/export', data: {'password': password}, options: _as(token)),
    (data) => switch (data) {
      {'env': final String env} => env,
      _ => throw const FormatException('bad export'),
    },
  );

  /// Accounts whose name, address or username contains [query], newest
  /// first, with how many match in all.
  Future<(List<AdminUser>, int)> users(String token, {String query = ''}) => _transport.send(
    () => _dio.get<Object?>('/admin/users', queryParameters: {'q': query}, options: _as(token)),
    (data) {
      if (data case {'users': final List<Object?> users, 'total': final num total}) {
        return ([for (final u in users) AdminUser.fromJson(u)], total.toInt());
      }
      throw const FormatException('bad users');
    },
  );

  /// Deletes an account as the owner deleting it would.
  Future<void> deleteUser(String token, String id) => _transport.send(
    () => _dio.delete<Object?>('/admin/users/${Uri.encodeComponent(id)}', options: _as(token)),
    (_) {},
  );

  Future<PlanCatalog> plans(String token) =>
      _transport.send(() => _dio.get<Object?>('/admin/plans', options: _as(token)), PlanCatalog.fromJson);

  /// Replaces every plan and product. Throws `plan_in_use` when it would
  /// drop a plan someone has, changing nothing.
  Future<PlanCatalog> savePlans(String token, PlanCatalog catalog) => _transport.send(
    () => _dio.put<Object?>('/admin/plans', data: catalog.toJson(), options: _as(token)),
    PlanCatalog.fromJson,
  );

  /// The plans the account was given, newest first.
  Future<List<Entitlement>> entitlements(String token, String userId) => _transport.send(
    () => _dio.get<Object?>('/admin/users/${Uri.encodeComponent(userId)}/entitlements', options: _as(token)),
    (data) {
      if (data case {'entitlements': final List<Object?> list}) {
        return [for (final e in list) Entitlement.fromJson(e)];
      }
      throw const FormatException('bad entitlements');
    },
  );

  /// Gives the account [planId] for [days], or for good without them.
  Future<Entitlement> grantEntitlement(
    String token,
    String userId, {
    required String planId,
    int? days,
    String? note,
  }) => _transport.send(
    () => _dio.post<Object?>(
      '/admin/users/${Uri.encodeComponent(userId)}/entitlements',
      data: {'planId': planId, 'days': ?days, 'note': ?note},
      options: _as(token),
    ),
    Entitlement.fromJson,
  );

  Future<void> revokeEntitlement(String token, String id) => _transport.send(
    () => _dio.delete<Object?>('/admin/entitlements/${Uri.encodeComponent(id)}', options: _as(token)),
    (_) {},
  );

  /// The latest payments, of [state] when given, with how many there are.
  Future<(List<AdminPayment>, int)> payments(String token, {String? state}) => _transport.send(
    () => _dio.get<Object?>('/admin/payments', queryParameters: {'state': ?state}, options: _as(token)),
    (data) {
      if (data case {'payments': final List<Object?> payments, 'total': final num total}) {
        return ([for (final p in payments) AdminPayment.fromJson(p)], total.toInt());
      }
      throw const FormatException('bad payments');
    },
  );

  /// Gives [userId] what the payment paid for; a payment no product matched
  /// also needs [planId] and [days].
  Future<AdminPayment> assignPayment(
    String token,
    String id, {
    required String userId,
    String? planId,
    int? days,
  }) => _transport.send(
    () => _dio.post<Object?>(
      '/admin/payments/${Uri.encodeComponent(id)}/assign',
      data: {'userId': userId, 'planId': ?planId, 'days': ?days},
      options: _as(token),
    ),
    AdminPayment.fromJson,
  );
}
