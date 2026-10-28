import 'dart:convert';

import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/core/session.dart';
import 'package:balnana/core/settings.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/features/account/account_section.dart';
import 'package:balnana/features/account/oauth.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget host(ProviderContainer container, Widget home) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);

/// A container whose API records each request and refuses it.
ProviderContainer recording(SharedPreferences prefs, List<RequestOptions> sent) => ProviderContainer(
  overrides: [
    prefsProvider.overrideWithValue(prefs),
    cacheDbProvider.overrideWithValue(null),
    apiProvider.overrideWith((ref) {
      final server = ref.watch(serverUrlProvider)!;
      final dio = Dio(BaseOptions(baseUrl: '$server/api/v1'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            sent.add(o);
            h.reject(
              DioException.badResponse(
                statusCode: 400,
                requestOptions: o,
                response: Response(requestOptions: o, statusCode: 400, data: {'code': 'invalid_token'}),
              ),
            );
          },
        ),
      );
      return dio;
    }),
  ],
);

/// A container whose API records each request and gets its status and body
/// from [answer], on a server with Google and Authentik sign-in.
ProviderContainer answering(
  SharedPreferences prefs,
  List<RequestOptions> sent,
  (int, Object?) Function(RequestOptions) answer, {
  List<Override> overrides = const [],
}) => ProviderContainer(
  overrides: [
    prefsProvider.overrideWithValue(prefs),
    cacheDbProvider.overrideWithValue(null),
    serverInfoProvider.overrideWithValue(
      const AsyncData(
        ServerInfo(
          version: 'test',
          authMode: AuthMode.accounts,
          password: true,
          publicUrl: 'https://a.example',
          oauthProviders: [
            OAuthProvider(id: 'google', name: 'Google'),
            OAuthProvider(id: 'authentik', name: 'Authentik'),
          ],
        ),
      ),
    ),
    apiProvider.overrideWith((ref) {
      final server = ref.watch(serverUrlProvider)!;
      final dio = Dio(BaseOptions(baseUrl: '$server/api/v1'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            sent.add(o);
            final (status, body) = answer(o);
            final res = Response<Object?>(requestOptions: o, statusCode: status, data: body);
            if (status >= 400) {
              h.reject(DioException.badResponse(statusCode: status, requestOptions: o, response: res));
            } else {
              h.resolve(res);
            }
          },
        ),
      );
      return dio;
    }),
    ...overrides,
  ],
);

void main() {
  testWidgets('an OAuth code started on one server is never sent to another', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.server': 'https://a.example',
      'oauth.attempt': jsonEncode({'server': 'https://a.example', 'verifier': 'verifier-for-a'}),
    });
    final prefs = await SharedPreferences.getInstance();
    final sent = <RequestOptions>[];
    final container = recording(prefs, sent);
    addTearDown(container.dispose);
    container.read(sessionProvider);
    container.read(settingsProvider.notifier).setServerUrl('https://b.example');
    await tester.pumpWidget(host(container, const OAuthDonePage(code: 'code-from-a')));
    await tester.pumpAndSettle();
    expect(sent.where((r) => r.path == '/auth/oauth/exchange'), isEmpty);
    expect(prefs.getString('oauth.attempt'), isNull);
    expect(find.textContaining('another server'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an OAuth code goes back to the server that started it', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.server': 'https://a.example',
      'oauth.attempt': jsonEncode({'server': 'https://a.example', 'verifier': 'verifier-for-a'}),
    });
    final prefs = await SharedPreferences.getInstance();
    final sent = <RequestOptions>[];
    final container = recording(prefs, sent);
    addTearDown(container.dispose);
    await tester.pumpWidget(host(container, const OAuthDonePage(code: 'code-from-a')));
    await tester.pumpAndSettle();
    final exchange = sent.singleWhere((r) => r.path == '/auth/oauth/exchange');
    expect(exchange.uri.host, 'a.example');
    expect(exchange.data, {'code': 'code-from-a', 'verifier': 'verifier-for-a'});
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a verifier saved without its server is not used', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.server': 'https://b.example',
      'oauth.verifier': 'verifier-of-unknown-server',
    });
    final prefs = await SharedPreferences.getInstance();
    final sent = <RequestOptions>[];
    final container = recording(prefs, sent);
    addTearDown(container.dispose);
    await tester.pumpWidget(host(container, const OAuthDonePage(code: 'some-code')));
    await tester.pumpAndSettle();
    expect(sent.where((r) => r.path == '/auth/oauth/exchange'), isEmpty);
    expect(prefs.getString('oauth.verifier'), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an account without a password can set one', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    for (final (hasPassword, email, title) in [
      (false, 'ana@example.com', 'Set a password'),
      (true, 'ana@example.com', 'Change password'),
      // Nothing to sign in with a password as.
      (false, null, null),
    ]) {
      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          currentAccountProvider.overrideWithValue(
            AsyncData(User(id: 'ana', name: 'Ana', email: email, hasPassword: hasPassword)),
          ),
          serverInfoProvider.overrideWithValue(
            const AsyncData(
              ServerInfo(
                version: 'test',
                authMode: AuthMode.accounts,
                password: true,
                email: false,
                publicUrl: 'https://a.example',
              ),
            ),
          ),
        ],
      );
      await tester.pumpWidget(host(container, const Scaffold(body: SingleChildScrollView(child: AccountSection()))));
      await tester.pumpAndSettle();
      if (title == null) {
        expect(find.byIcon(Icons.password), findsNothing);
      } else {
        expect(find.text(title), findsOneWidget);
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        // A first password asks for no current one.
        expect(find.text('Current password'), hasPassword ? findsOneWidget : findsNothing);
      }
      await tester.pumpWidget(const SizedBox());
      container.dispose();
    }
  });

  testWidgets('a sign-in matching an unconfirmed account lets the person choose', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'settings.server': 'https://a.example',
      'oauth.attempt': jsonEncode({'server': 'https://a.example', 'verifier': 'verifier-for-a'}),
    });
    final prefs = await SharedPreferences.getInstance();
    final sent = <RequestOptions>[];
    final container = answering(
      prefs,
      sent,
      (r) => switch (r.path) {
        '/auth/oauth/pending' => (
          200,
          {'email': 'ana@example.com', 'provider': 'google', 'hasPassword': true, 'signup': true},
        ),
        _ => (403, {'code': 'wrong_password'}),
      },
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(host(container, const Scaffold(body: OAuthDonePage(pending: 'pending-token'))));
    await tester.pumpAndSettle();
    expect(sent.single.data, {'token': 'pending-token'});
    expect(find.text('This email already has an account'), findsOneWidget);
    expect(find.textContaining('Google says ana@example.com is yours'), findsOneWidget);
    expect(find.text('Add to that account'), findsOneWidget);
    expect(find.text('Take over that account'), findsOneWidget);
    expect(find.text('Start a new account'), findsOneWidget);

    // Adding to the account proves it is theirs with its password.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(sent, hasLength(1));
    await tester.enterText(find.widgetWithText(TextFormField, 'Password of that account'), 'not it');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    final link = sent.last.data as Map<String, Object?>;
    expect(sent.last.path, '/auth/oauth/pending/finish');
    expect(link['token'], 'pending-token');
    expect(link['choice'], 'link');
    expect(link['password'], 'not it');
    expect(link['verifier'], 'verifier-for-a');
    expect(find.text("That password isn't right."), findsOneWidget);

    await tester.tap(find.text('Take over that account'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Password of that account'), findsNothing);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    final takeOver = sent.last.data as Map<String, Object?>;
    expect(takeOver['choice'], 'take_over');
    expect(takeOver.containsKey('password'), isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the account adds and removes ways to sign in', (tester) async {
    SharedPreferences.setMockInitialValues({'settings.server': 'https://a.example'});
    final prefs = await SharedPreferences.getInstance();
    final sent = <RequestOptions>[];
    final container = answering(
      prefs,
      sent,
      (r) => switch ((r.method, r.path)) {
        ('DELETE', '/me/oauth/google') => (409, {'code': 'last_sign_in_method'}),
        _ => (403, {'code': 'wrong_password'}),
      },
      overrides: [
        currentAccountProvider.overrideWithValue(
          const AsyncData(User(id: 'ana', name: 'Ana', email: 'ana@example.com', hasPassword: true)),
        ),
        myOAuthProvider.overrideWithValue(const AsyncData(['google'])),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(host(container, const Scaffold(body: SingleChildScrollView(child: AccountSection()))));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Google'),
        matching: find.text('Signs in to this account. Tap to remove.'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Authentik'),
        matching: find.text('Add as a way to sign in'),
      ),
      findsOneWidget,
    );

    // Removing the last way in is refused.
    await tester.tap(find.text('Google'));
    await tester.pumpAndSettle();
    expect(find.text('Remove Google?'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(sent.last.method, 'DELETE');
    expect(find.text('This is your only way to sign in. Set a password or add another way first.'), findsOneWidget);

    // Adding one asks for the account's password first.
    await tester.tap(find.text('Authentik'));
    await tester.pumpAndSettle();
    expect(find.text('Add Authentik'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'not it');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(sent.last.path, '/me/oauth/authentik');
    expect(sent.last.data, {'password': 'not it'});
    expect(find.text('Add Authentik'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
