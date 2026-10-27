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
}
