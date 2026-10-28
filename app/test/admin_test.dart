import 'package:balnana/app.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/api.dart';
import 'package:balnana/features/admin/admin_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = 'https://split.example.com';

Map<String, Object?> _setting(
  String key, {
  String? value,
  String def = '',
  bool locked = false,
  bool secret = false,
}) => {
  'key': key,
  'value': ?value,
  'default': def,
  'locked': locked,
  'secret': secret,
  'set': value != null || secret,
};

final _settings = {
  'settings': [
    _setting('BALNANA_PUBLIC_URL', value: _server, locked: true),
    _setting('BALNANA_SOURCE_URL', def: 'https://github.com/willie6666/balnana'),
    _setting('BALNANA_AUTH_MODE', def: 'link'),
    _setting('BALNANA_AUTH_PASSWORD', def: 'true'),
    _setting('BALNANA_AUTH_SIGNUP', def: 'open'),
    _setting('BALNANA_LINK_GROUPS', def: 'true'),
    _setting('BALNANA_SMTP_HOST'),
    _setting('BALNANA_SMTP_PORT', def: '587'),
    _setting('BALNANA_SMTP_USER'),
    _setting('BALNANA_SMTP_PASSWORD', secret: true),
    _setting('BALNANA_SMTP_FROM'),
  ],
};

/// A fake server: [answer] gets each admin request and returns its status
/// and body.
AdminApi _api(List<RequestOptions> seen, (int, Object?) Function(RequestOptions) answer) {
  final dio = Dio(BaseOptions(baseUrl: '$_server/api/v1'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        seen.add(options);
        final (status, body) = answer(options);
        final res = Response<Object?>(requestOptions: options, statusCode: status, data: body);
        if (status >= 400) {
          handler.reject(
            DioException(requestOptions: options, response: res, type: DioExceptionType.badResponse),
          );
        } else {
          handler.resolve(res);
        }
      },
    ),
  );
  return AdminApi(dio);
}

Future<void> _boot(WidgetTester tester, {required ServerInfo info, required AdminApi api}) async {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'settings.server': _server});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        serverInfoProvider.overrideWithValue(AsyncValue.data(info)),
        adminApiProvider.overrideWithValue(api),
      ],
      child: const BalnanaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a new server sends people to set the administrator password', (tester) async {
    final seen = <RequestOptions>[];
    final api = _api(
      seen,
      (r) => switch (r.path) {
        '/admin/setup' => (201, {'token': 'admin-token', 'expiresAt': '2026-10-27T00:00:00Z'}),
        '/admin/settings' => (200, _settings),
        _ => (404, {'code': 'not_found'}),
      },
    );
    await _boot(
      tester,
      info: const ServerInfo(version: '1', authMode: AuthMode.link, publicUrl: _server, setupRequired: true),
      api: api,
    );

    expect(find.text('Set up this server'), findsOneWidget);
    expect(find.text('Setup code'), findsNothing);
    await tester.enterText(find.widgetWithText(TextFormField, 'Administrator password'), 'a long password');
    await tester.enterText(find.widgetWithText(TextFormField, 'Repeat the password'), 'another password');
    await tester.tap(find.text('Set password'));
    await tester.pumpAndSettle();
    expect(find.text("The passwords don't match."), findsOneWidget);
    expect(seen, isEmpty);

    await tester.enterText(find.widgetWithText(TextFormField, 'Repeat the password'), 'a long password');
    await tester.tap(find.text('Set password'));
    await tester.pumpAndSettle();
    expect(seen.first.data, {'password': 'a long password'});
    expect(find.text('Server settings'), findsOneWidget);
    expect(seen.last.headers['X-Balnana-Admin'], 'admin-token');
  });

  testWidgets('an upgraded server also asks for the setup code', (tester) async {
    final seen = <RequestOptions>[];
    final api = _api(seen, (r) => (403, {'code': 'invalid_setup_code'}));
    await _boot(
      tester,
      info: const ServerInfo(
        version: '1',
        authMode: AuthMode.link,
        publicUrl: _server,
        setupRequired: true,
        setupCode: true,
      ),
      api: api,
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Setup code'), ' abcd-efgh ');
    await tester.enterText(find.widgetWithText(TextFormField, 'Administrator password'), 'a long password');
    await tester.enterText(find.widgetWithText(TextFormField, 'Repeat the password'), 'a long password');
    await tester.tap(find.text('Set password'));
    await tester.pumpAndSettle();
    expect(seen.single.data, {'password': 'a long password', 'code': 'abcd-efgh'});
    expect(find.text("That setup code isn't right. Look for it in the server's log."), findsOneWidget);
  });

  testWidgets('settings send only what changed and show what the server refused', (tester) async {
    final seen = <RequestOptions>[];
    final api = _api(
      seen,
      (r) => switch ((r.method, r.path)) {
        ('POST', '/admin/login') => (200, {'token': 'admin-token', 'expiresAt': '2026-10-27T00:00:00Z'}),
        ('GET', '/admin/settings') => (200, _settings),
        ('PUT', '/admin/settings') => (
          400,
          {
            'code': 'invalid_settings',
            'params': {
              'keys': ['BALNANA_AUTH_MODE'],
            },
          },
        ),
        _ => (404, {'code': 'not_found'}),
      },
    );
    await _boot(
      tester,
      info: const ServerInfo(version: '1', authMode: AuthMode.link, publicUrl: _server),
      api: api,
    );
    // Nothing links to administration; people type its address.
    expect(find.text('Server settings'), findsNothing);
    final router = tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig! as GoRouter;
    router.go('/admin');
    await tester.pumpAndSettle();

    expect(find.text('Administration'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'the admin password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Server settings'), findsOneWidget);
    expect(find.text('Set on the server by BALNANA_PUBLIC_URL'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save')).onPressed, isNull);

    await tester.tap(
      find.descendant(of: find.byType(SegmentedButton<String>).first, matching: find.text('Accounts')),
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Mail server'), findsNothing);
    await tester.tap(find.text('Send email'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Mail server'), 'smtp.example.com');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final put = seen.lastWhere((r) => r.method == 'PUT');
    expect(put.data, {
      'values': {'BALNANA_AUTH_MODE': 'accounts', 'BALNANA_SMTP_HOST': 'smtp.example.com'},
    });
    expect(
      find.text('Accounts need a way to sign in: turn on email and password, or set up a provider.'),
      findsOneWidget,
    );
  });

  testWidgets('sign-in switches keep a way in and show only what is on', (tester) async {
    final seen = <RequestOptions>[];
    final api = _api(
      seen,
      (r) => switch ((r.method, r.path)) {
        ('POST', '/admin/login') => (200, {'token': 'admin-token', 'expiresAt': '2026-10-27T00:00:00Z'}),
        ('GET', '/admin/settings') => (
          200,
          {
            'settings': [
              _setting('BALNANA_PUBLIC_URL', value: _server, locked: true),
              _setting('BALNANA_AUTH_MODE', value: 'accounts'),
              _setting('BALNANA_AUTH_PASSWORD', value: 'false'),
              _setting('BALNANA_AUTH_REQUIRE_EMAIL', def: 'true'),
              _setting('BALNANA_AUTH_SIGNUP', value: 'invite_only'),
              _setting('BALNANA_SMTP_HOST', value: 'smtp.example.com'),
              _setting('BALNANA_SMTP_FROM', value: 'Balnana <balnana@example.com>'),
              _setting('BALNANA_OAUTH_GOOGLE_CLIENT_ID', value: 'google-id'),
              _setting('BALNANA_OAUTH_GOOGLE_SECRET', secret: true),
            ],
          },
        ),
        ('PUT', '/admin/settings') => (
          400,
          {
            'code': 'invalid_settings',
            'params': {'keys': <String>[]},
          },
        ),
        _ => (404, {'code': 'not_found'}),
      },
    );
    await _boot(
      tester,
      info: const ServerInfo(version: '1', authMode: AuthMode.accounts, publicUrl: _server),
      api: api,
    );
    final router = tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig! as GoRouter;
    router.go('/admin');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'the admin password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    SwitchListTile tile(String title) => tester.widget(find.widgetWithText(SwitchListTile, title));
    // Google signs people in, so email and password may stay off, and the
    // email requirement, which only it uses, is dimmed.
    expect(tile('Email and password sign-in').value, isFalse);
    expect(tile('Email and password sign-in').onChanged, isNotNull);
    expect(tile('Require an email address').onChanged, isNull);
    expect(find.text('Only applies to email and password sign-in, which is off.'), findsOneWidget);
    expect(find.textContaining('Only people invited to a group by email may sign up'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Mail server'), findsOneWidget);

    // Without Google there would be no way in: email and password turns on
    // and stays on.
    await tester.tap(find.text('Offer Google sign-in'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Client ID'), findsNothing);
    expect(tile('Email and password sign-in').value, isTrue);
    expect(tile('Email and password sign-in').onChanged, isNull);
    expect(tile('Require an email address').onChanged, isNotNull);

    // Switching email off clears its mail server alone.
    await tester.tap(find.text('Send email'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Mail server'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(seen.lastWhere((r) => r.method == 'PUT').data, {
      'values': {
        'BALNANA_AUTH_PASSWORD': 'true',
        'BALNANA_SMTP_HOST': '',
        'BALNANA_OAUTH_GOOGLE_CLIENT_ID': '',
      },
    });
  });
}
