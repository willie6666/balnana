import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/server.dart';
import '../models/account.dart';
import '../models/billing.dart';
import '../models/expense.dart';
import '../models/group.dart';
import 'group_api.dart';
import 'transport.dart';

/// Where a push service delivers this device's Web Push messages: the
/// [endpoint] to send to and the keys to encrypt for (RFC 8291), base64url.
typedef PushSubscription = ({String endpoint, String p256dh, String auth});

/// The Balnana HTTP API. Every call throws [ApiException] on failure.
class BalnanaApi {
  BalnanaApi(Dio dio, {this.onSignInRequired})
    : _transport = ApiTransport(dio, onSignInRequired: onSignInRequired);

  final ApiTransport _transport;
  Dio get _dio => _transport.dio;

  /// Called when the server says the session this was made with is gone.
  final void Function()? onSignInRequired;

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
  }) => _transport.send(
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
  /// An account with two-step sign-in answers `two_factor_required` until
  /// [code] comes too; `params['methods']` lists what gives one, `totp` or
  /// `email`.
  Future<(String?, User)> login({required String login, required String password, String? code}) =>
      _transport.send(
        () => _dio.post<Object?>(
          '/auth/login',
          data: {'login': login, 'password': password, 'code': ?code, 'cookie': _cookie},
        ),
        _session,
      );

  /// Emails a sign-in code to an account that takes them, at most one a minute.
  Future<void> emailLoginCode({required String login, required String password}) => _transport.send(
    () => _dio.post<Object?>('/auth/login/email-code', data: {'login': login, 'password': password}),
    (_) {},
  );

  /// Starts adding an authenticator app to the signed-in account.
  Future<TotpSetup> setupTotp({String? password}) => _transport.send(
    () => _dio.post<Object?>('/me/two-factor/totp', data: {'password': ?password}),
    TotpSetup.fromJson,
  );

  /// Turns the authenticator app on with a code from it, and returns the
  /// recovery codes, shown only now.
  Future<List<String>> confirmTotp(String code) => _transport.send(
    () => _dio.post<Object?>('/me/two-factor/totp/confirm', data: {'code': code}),
    (data) => switch (data) {
      {'codes': final List<Object?> codes} => [...codes.whereType<String>()],
      _ => throw const FormatException('bad recovery codes'),
    },
  );

  Future<User> disableTotp({String? password}) => _transport.send(
    () => _dio.post<Object?>('/me/two-factor/totp/disable', data: {'password': ?password}),
    User.fromJson,
  );

  /// Turns sign-in codes by email on or off.
  Future<User> setEmailTwoFactor(bool enabled, {String? password}) => _transport.send(
    () => _dio.put<Object?>('/me/two-factor/email', data: {'enabled': enabled, 'password': ?password}),
    User.fromJson,
  );

  /// Trades the code a Google or OpenID Connect sign-in sent back to the
  /// Android app for a session; [verifier] proves this app started it.
  Future<(String?, User)> exchangeOAuthCode({required String code, required String verifier}) =>
      _transport.send(
        () => _dio.post<Object?>('/auth/oauth/exchange', data: {'code': code, 'verifier': verifier}),
        _session,
      );

  /// What a sign-in that stopped to ask is about: the address of the
  /// account it matched, which has not confirmed it.
  Future<OAuthPending> oauthPending(String token) => _transport.send(
    () => _dio.post<Object?>('/auth/oauth/pending', data: {'token': token}),
    OAuthPending.fromJson,
  );

  /// Ends a sign-in that stopped to ask: [choice] is `link` (with the
  /// account's [password]), `take_over` or `new_account`. [verifier] is the
  /// one the sign-in started with, if it did.
  Future<(String?, User)> finishOAuthPending({
    required String token,
    required String choice,
    String? password,
    String? verifier,
  }) => _transport.send(
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
  Future<List<String>> myOAuth() => _transport.send(() => _dio.get<Object?>('/me/oauth'), (data) {
    if (data is! Map<String, Object?> || data['providers'] is! List<Object?>) {
      throw const FormatException('bad providers');
    }
    return [...(data['providers'] as List<Object?>).whereType<String>()];
  });

  /// A ticket for adding [provider] to the signed-in account: the sign-in
  /// started with it adds the identity instead of signing in.
  Future<String> linkOAuth(String provider, {String? password}) => _transport.send(
    () => _dio.post<Object?>('/me/oauth/${Uri.encodeComponent(provider)}', data: {'password': ?password}),
    (data) => switch (data) {
      {'ticket': final String ticket} => ticket,
      _ => throw const FormatException('bad ticket'),
    },
  );

  Future<void> unlinkOAuth(String provider, {String? password}) => _transport.send(
    () => _dio.delete<Object?>('/me/oauth/${Uri.encodeComponent(provider)}', data: {'password': ?password}),
    (_) {},
  );

  static (String?, User) _session(Object? data) {
    if (data is! Map<String, Object?>) throw const FormatException('expected an object');
    final token = data['token'];
    return (token is String ? token : null, User.fromJson(data['user']));
  }

  /// Emails a link for choosing a new password, if the address has an account.
  Future<void> requestPasswordReset(String email) =>
      _transport.send(() => _dio.post<Object?>('/auth/password-reset', data: {'email': email}), (_) {});

  /// Signs out every session of the account.
  Future<void> resetPassword({required String token, required String password}) => _transport.send(
    () => _dio.post<Object?>('/auth/password-reset/confirm', data: {'token': token, 'newPassword': password}),
    (_) {},
  );

  Future<void> verifyEmail(String token) =>
      _transport.send(() => _dio.post<Object?>('/auth/verify-email', data: {'token': token}), (_) {});

  /// Emails the signed-in account a link confirming its address.
  Future<void> sendVerifyEmail() => _transport.send(() => _dio.post<Object?>('/me/verify-email'), (_) {});

  /// The account's plan, after taking in payments made with its addresses.
  Future<MyPlan> myPlan() => _transport.send(() => _dio.get<Object?>('/me/plan'), MyPlan.fromJson);

  /// Tells the server about a Google Play purchase, which it checks with
  /// Google. Doing it again changes nothing.
  Future<MyPlan> reportPlayPurchase(String token) => _transport.send(
    () => _dio.post<Object?>('/me/play/purchases', data: {'purchaseToken': token}),
    MyPlan.fromJson,
  );

  /// Takes a Ko-fi payment by its transaction ID, or the link with it in.
  Future<MyPlan> claimPayment(String reference) => _transport.send(
    () => _dio.post<Object?>('/me/payments/claim', data: {'reference': reference}),
    MyPlan.fromJson,
  );

  /// The PayPal page to pay for [product] on. PayPal sends the payer back to
  /// the plan page on [app], web or android.
  Future<Uri> paypalCheckout(String product, String app) => _transport.send(
    () => _dio.post<Object?>('/me/paypal/checkout', data: {'product': product, 'app': app}),
    (data) => switch (data) {
      {'url': final String url} => Uri.parse(url),
      _ => throw const FormatException('bad checkout'),
    },
  );

  /// What one [from] is worth in [to], from the server's source of rates.
  Future<ExchangeRate> exchangeRate(String from, String to) => _transport.send(
    () => _dio.get<Object?>('/exchange-rate', queryParameters: {'from': from, 'to': to}),
    ExchangeRate.fromJson,
  );

  Future<InviteInfo> invite(String token) => _transport.send(
    () => _dio.get<Object?>('/auth/invites/${Uri.encodeComponent(token)}'),
    InviteInfo.fromJson,
  );

  Future<void> logout() => _transport.send(() => _dio.post<Object?>('/auth/logout'), (_) {});

  Future<User> me() => _transport.send(() => _dio.get<Object?>('/me'), User.fromJson);

  Future<User> updateMe({String? name, String? locale}) => _transport.send(
    () => _dio.patch<Object?>('/me', data: {'name': ?name, 'locale': ?locale}),
    User.fromJson,
  );

  /// Signs out every other session of the account.
  Future<void> changePassword({String? current, required String next}) => _transport.send(
    () => _dio.post<Object?>('/me/password', data: {'currentPassword': ?current, 'newPassword': next}),
    (_) {},
  );

  /// Sets the account's email address, or removes it when [email] is empty
  /// (accounts with a username only). A new address needs verifying again.
  Future<User> changeEmail(String email, {String? password}) => _transport.send(
    () => _dio.post<Object?>('/me/email', data: {'email': email, 'password': ?password}),
    User.fromJson,
  );

  /// Deletes the account for good. Its members stay in their groups,
  /// unclaimed; groups nobody else could reach go with it.
  Future<void> deleteMe({String? password}) =>
      _transport.send(() => _dio.post<Object?>('/me/delete', data: {'password': ?password}), (_) {});

  /// The signed-in account's groups, most recently changed first.
  Future<List<GroupSummary>> myGroups() => _transport.send(() => _dio.get<Object?>('/me/groups'), (data) {
    if (data is! Map<String, Object?> || data['groups'] is! List<Object?>) {
      throw const FormatException('bad groups');
    }
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
    GroupFeatures? features,
    bool sharePlan = false,
  }) => _transport.send(
    () => _dio.post<Object?>(
      '/groups',
      data: {
        if (sharePlan) 'sharePlan': true,
        'name': name,
        'emoji': ?emoji,
        'color': ?color,
        'currency': currency,
        'symbol': ?symbol,
        'minorDigits': minorDigits,
        'members': members,
        'features': ?features?.toJson(),
      },
    ),
    Group.fromJson,
  );

  /// A large export takes the server a while to read: longer than other
  /// requests may, and an import given up on too soon would be made again.
  static final _importTime = Options(receiveTimeout: const Duration(minutes: 5));

  /// What importing a Settle Up export would create. Nothing is kept.
  Future<ImportPreview> previewImport(Uint8List file) => _transport.send(
    () => _dio.post<Object?>('/groups/import', data: _import(file, dryRun: true), options: _importTime),
    ImportPreview.fromJson,
  );

  /// Creates a group from a Settle Up export. [me] is the person in the file
  /// this app is; [untitled] names expenses without a purpose.
  Future<Group> importGroup(
    Uint8List file, {
    required String name,
    required String me,
    required String untitled,
  }) => _transport.send(
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
  ) => _transport.send(
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
  GroupApi group(String token, {String? memberId}) => GroupApi(_transport, token, memberId: memberId);

  /// Asks for notifications about [groups] (and, signed in, the account's
  /// groups) on [device], this app's own random ID for the phone, sent to
  /// the Web Push subscription [sub].
  Future<void> registerPushDevice(
    String device,
    PushSubscription sub,
    List<({String token, String memberId})> groups,
  ) => _transport.send(
    () => _dio.put<Object?>(
      '/push/devices/${Uri.encodeComponent(device)}',
      data: {
        'endpoint': sub.endpoint,
        'p256dh': sub.p256dh,
        'auth': sub.auth,
        'groups': [
          for (final g in groups) {'token': g.token, 'memberId': g.memberId},
        ],
      },
    ),
    (_) {},
  );

  Future<void> removePushDevice(String device) =>
      _transport.send(() => _dio.delete<Object?>('/push/devices/${Uri.encodeComponent(device)}'), (_) {});
}
