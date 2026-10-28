import 'dart:async';

import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/core/settings.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/features/settings/settings_page.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _a = 'https://a.example';
const _b = 'https://b.example';
const _info = ServerInfo(version: 'test', authMode: AuthMode.accounts, password: true, publicUrl: _a);

Map<String, Object?> _user(String? locale) => {'id': 'ana', 'name': 'Ana', 'locale': locale};

void main() {
  for (final (tag, expected) in [('en', 'en'), ('en-US', 'en'), (null, null), ('zz', null)]) {
    test('account language $tag loads as $expected', () async {
      SharedPreferences.setMockInitialValues({'settings.server': _a, 'settings.locale': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (o, h) => h.resolve(Response(requestOptions: o, data: _user(tag))),
          ),
        );
      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          cacheDbProvider.overrideWithValue(null),
          serverInfoProvider.overrideWithValue(const AsyncData(_info)),
          apiProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);
      await container.read(accountProvider.future);
      expect(container.read(settingsProvider).locale?.toLanguageTag(), expected);
      expect(prefs.getString('settings.locale'), expected);
    });
  }

  for (final failed in [false, true]) {
    testWidgets('changing account language persists only after a successful save (failed: $failed)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'settings.server': _a});
      final prefs = await SharedPreferences.getInstance();
      String? language = 'en';
      final patches = <Object?>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (o, h) {
              if (o.method == 'PATCH') {
                patches.add(o.data);
                if (failed) {
                  h.reject(
                    DioException.badResponse(
                      statusCode: 403,
                      requestOptions: o,
                      response: Response(requestOptions: o, statusCode: 403, data: {'code': 'not_allowed'}),
                    ),
                  );
                  return;
                }
                language = null;
              }
              h.resolve(Response(requestOptions: o, data: _user(language)));
            },
          ),
        );
      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          cacheDbProvider.overrideWithValue(null),
          serverInfoProvider.overrideWithValue(const AsyncData(_info)),
          apiProvider.overrideWithValue(dio),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Scrolling stops once the tile is built, which may be past the screen
      // edge, so then bring the tile itself into view.
      await tester.scrollUntilVisible(find.widgetWithText(ListTile, 'Language'), 200);
      await tester.ensureVisible(find.widgetWithText(ListTile, 'Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(RadioListTile<Locale>, 'System default'));
      await tester.pumpAndSettle();
      expect(patches, [
        {'locale': ''},
      ]);
      expect(prefs.getString('settings.locale'), failed ? 'en' : null);
      if (failed) expect(find.byType(SnackBar), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }

  test('a late profile from the last server cannot change the new account language', () async {
    SharedPreferences.setMockInitialValues({'settings.server': _a});
    final prefs = await SharedPreferences.getInstance();
    final started = Completer<void>(), release = Completer<void>();
    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        cacheDbProvider.overrideWithValue(null),
        serverInfoProvider.overrideWithValue(const AsyncData(_info)),
        apiProvider.overrideWith((ref) {
          final server = ref.watch(serverUrlProvider);
          return Dio()
            ..interceptors.add(
              InterceptorsWrapper(
                onRequest: (o, h) async {
                  if (server == _a) {
                    started.complete();
                    await release.future;
                  }
                  h.resolve(Response(requestOptions: o, data: _user(server == _a ? 'en' : null)));
                },
              ),
            );
        }),
      ],
    );
    addTearDown(container.dispose);
    container.read(accountProvider.future).ignore();
    await started.future;
    container.read(settingsProvider.notifier).setServerUrl(_b);
    await container.read(accountProvider.future);
    release.complete();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(prefs.getString('settings.locale'), isNull);
  });
}
