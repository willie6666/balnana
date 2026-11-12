import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/features/account/sign_in_page.dart';
import 'package:balnana/features/account/two_factor.dart';
import 'package:balnana/features/settings/share_plan_page.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:balnana/ui/widgets/grouped_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = 'https://a.example';

Widget _host(ProviderContainer container, Widget home) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);

/// A container on an accounts server whose API records each request and gets
/// its status and body from [answer].
Future<ProviderContainer> _answering(
  List<RequestOptions> sent,
  (int, Object?) Function(RequestOptions) answer, {
  bool email = true,
  bool billing = false,
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({'settings.server': _server});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    retry: (retryCount, error) => null,
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      cacheDbProvider.overrideWithValue(null),
      serverInfoProvider.overrideWithValue(
        AsyncData(
          ServerInfo(
            version: 'test',
            authMode: AuthMode.accounts,
            password: true,
            email: email,
            billing: billing,
            publicUrl: _server,
          ),
        ),
      ),
      apiProvider.overrideWith((ref) {
        final dio = Dio(BaseOptions(baseUrl: '$_server/api/v1'));
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
}

const _ana = {'id': 'ana', 'name': 'Ana', 'email': 'ana@example.com', 'emailVerified': true, 'hasPassword': true};

void main() {
  testWidgets('an account with two-step sign-in is asked for the emailed code', (tester) async {
    final sent = <RequestOptions>[];
    final container = await _answering(
      sent,
      (r) => switch ((r.method, r.path)) {
        ('POST', '/auth/login') => switch ((r.data as Map)['code']) {
          null => (
            401,
            {
              'code': 'two_factor_required',
              'params': {
                'methods': ['email'],
              },
            },
          ),
          _ => (401, {'code': 'invalid_code'}),
        },
        ('POST', '/auth/login/email-code') => (204, null),
        _ => (401, {'code': 'sign_in_required'}),
      },
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_host(container, const SignInPage()));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'ana@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'correct horse');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    // Only by email, so the code was sent without asking for it.
    expect(find.text('Two-step sign-in'), findsOneWidget);
    expect(find.text('Enter the code we emailed you.'), findsOneWidget);
    expect(find.text('A code is on its way to your email. It works for 10 minutes.'), findsOneWidget);
    final mailed = sent.singleWhere((r) => r.path == '/auth/login/email-code');
    expect(mailed.data, {'login': 'ana@example.com', 'password': 'correct horse'});

    // The code's field is its own: nothing typed before shows up in it.
    expect(tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Code')).controller!.text, isEmpty);
    expect(find.text('correct horse'), findsNothing);
    await tester.enterText(find.widgetWithText(TextFormField, 'Code'), ' 123456 ');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect((sent.last.data as Map)['code'], '123456');
    expect((sent.last.data as Map)['password'], 'correct horse');
    expect(find.text("That code isn't right, or it has expired."), findsOneWidget);

    // Back to the password, which starts over.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an authenticator app is added with a code from it, and shows its recovery codes', (tester) async {
    final sent = <RequestOptions>[];
    var totp = false;
    final container = await _answering(
      sent,
      (r) => switch ((r.method, r.path)) {
        ('GET', '/me') => (200, {..._ana, 'emailVerified': false, 'totp': totp}),
        ('POST', '/me/two-factor/totp') => (
          200,
          {'secret': 'ABCDEFGHIJKLMNOP', 'uri': 'otpauth://totp/Balnana:ana?secret=ABCDEFGHIJKLMNOP'},
        ),
        ('POST', '/me/two-factor/totp/confirm') => () {
          if ((r.data as Map)['code'] != '654321') return (400, {'code': 'invalid_code'});
          totp = true;
          return (
            200,
            {
              'codes': ['AAAAA-BBBBB', 'CCCCC-DDDDD'],
            },
          );
        }(),
        _ => (404, {'code': 'not_found'}),
      },
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      _host(container, const Scaffold(body: SingleChildScrollView(child: TwoFactorSection()))),
    );
    await tester.pumpAndSettle();

    // Codes by email wait for a confirmed address.
    final byEmail = tester.widget<GroupedSwitchTile>(find.widgetWithText(GroupedSwitchTile, 'Code by email'));
    expect(byEmail.onChanged, isNull);
    expect(find.text('Confirm your email first.'), findsOneWidget);

    await tester.tap(find.text('Authenticator app'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Your password'), 'correct horse');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(sent.last.data, {'password': 'correct horse'});
    expect(find.text('ABCD EFGH IJKL MNOP'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Code'), '111111');
    await tester.tap(find.text('Turn on'));
    await tester.pumpAndSettle();
    expect(find.text("That code isn't right, or it has expired."), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Code'), '654321');
    await tester.tap(find.text('Turn on'));
    await tester.pumpAndSettle();

    expect(find.text('Recovery codes'), findsOneWidget);
    expect(find.text('AAAAA-BBBBB\nCCCCC-DDDDD'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    final app = tester.widget<GroupedSwitchTile>(find.widgetWithText(GroupedSwitchTile, 'Authenticator app'));
    expect(app.value, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the plan sharing page switches the plan on for a group, up to what the plan shares', (tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final sent = <RequestOptions>[];
    final shared = {'flat'};
    Map<String, Object?> group(String token, String name, {String? other}) => {
      'token': token,
      'name': name,
      'currency': 'EUR',
      'minorDigits': 2,
      'memberCount': 2,
      'updatedAt': '2026-11-01T00:00:00Z',
      'sharedPlan': ?(shared.contains(token) ? 'mine' : other),
    };
    final container = await _answering(
      sent,
      billing: true,
      (r) => switch ((r.method, r.path)) {
        ('GET', '/me') => (200, _ana),
        ('GET', '/me/groups') => (
          200,
          {
            'groups': [group('flat', 'Flat'), group('trip', 'Trip'), group('club', 'Club', other: 'other')],
            'missing': <String>[],
            'locked': <String>[],
          },
        ),
        ('GET', '/me/plan') => (
          200,
          {
            'planName': 'Plus',
            'paid': true,
            'reminders': true,
            'joinedGroups': {'used': 3},
            'sponsoredGroups': {'used': shared.length, 'limit': 2},
          },
        ),
        ('PUT', '/g/trip/sponsor') => () {
          shared.add('trip');
          return (
            200,
            {
              'planName': 'Plus',
              'reminders': true,
              'canSponsor': false,
              'members': {'used': 2},
              'receipts': {'used': 0},
              'recurring': {'used': 0},
            },
          );
        }(),
        _ => (404, {'code': 'not_found'}),
      },
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(_host(container, const SharePlanPage()));
    await tester.pumpAndSettle();

    GroupedSwitchTile tile(String name) =>
        tester.widget<GroupedSwitchTile>(find.widgetWithText(GroupedSwitchTile, name));
    expect(find.textContaining('Groups sharing your plan: 1 of 2'), findsOneWidget);
    expect(tile('Flat').value, isTrue);
    expect(tile('Trip').value, isFalse);
    // Another member's plan covers it already.
    expect(tile('Club').onChanged, isNull);
    expect(find.text("Another member's plan already covers this group."), findsOneWidget);

    await tester.tap(find.text('Trip'));
    await tester.pumpAndSettle();
    expect(sent.where((r) => r.method == 'PUT' && r.path == '/g/trip/sponsor'), hasLength(1));
    expect(tile('Trip').value, isTrue);
    expect(find.textContaining('Groups sharing your plan: 2 of 2'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
