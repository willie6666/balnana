import 'dart:convert';

import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/core/settings.dart';
import 'package:balnana/data/known_groups.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/features/groups/open_link.dart';
import 'package:balnana/features/settings/my_groups.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = 'https://a.example/split';
const _one = 'AAAAAAAAAAAAAAAAAAAAAA';
const _two = 'BBBBBBBBBBBBBBBBBBBBBB';
const _foreign = 'FFFFFFFFFFFFFFFFFFFFFF';

void main() {
  test('a whole list validates aliases and paths before returning tokens', () {
    expect(
      tokensFromLinks(
        '$_server/g/$_one\nhttps://public.example/g/$_two\n$_one',
        serverUrl: _server,
        publicUrl: 'https://public.example',
      ),
      [_one, _two],
    );
    for (final link in ['https://foreign.example/g/$_foreign', 'https://a.example/other/g/$_foreign']) {
      expect(() => tokensFromLinks('$_one\n$link', serverUrl: _server), throwsA(isA<ForeignGroupLink>()));
    }
    for (final text in ['', '$_one\nnot-a-link']) {
      expect(() => tokensFromLinks(text, serverUrl: _server), throwsFormatException);
    }
  });

  for (final switchServer in [false, true]) {
    testWidgets('an invalid or obsolete import saves and sends nothing (switch: $switchServer)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'settings.server': _server});
      final prefs = await SharedPreferences.getInstance();
      final requests = <RequestOptions>[];
      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          serverInfoProvider.overrideWithValue(
            const AsyncData(ServerInfo(version: 'test', authMode: AuthMode.link, publicUrl: _server)),
          ),
          accountProvider.overrideWithValue(const AsyncData(null)),
          apiProvider.overrideWith((ref) {
            final server = ref.watch(serverUrlProvider)!;
            return Dio(BaseOptions(baseUrl: '$server/api/v1'))
              ..interceptors.add(
                InterceptorsWrapper(
                  onRequest: (o, h) {
                    requests.add(o);
                    h.resolve(Response(requestOptions: o, data: {'groups': [], 'missing': []}));
                  },
                ),
              );
          }),
        ],
      );
      addTearDown(container.dispose);
      // Keep actual summaries active: a catalog write would send its secrets.
      final sub = container.listen(summariesProvider, (_, _) {});
      addTearDown(sub.close);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: MyGroupsSection()),
          ),
        ),
      );
      await tester.tap(find.text('Import groups'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        switchServer ? _one : '$_one\nhttps://foreign.example/g/$_foreign',
      );
      if (switchServer) container.read(settingsProvider.notifier).setServerUrl('https://b.example');
      await tester.tap(find.text('Import links'));
      await tester.pumpAndSettle();
      expect(prefs.getString('groups.known'), isNull);
      expect(requests, isEmpty);
      expect(
        find.textContaining(switchServer ? 'selected server changed' : 'another server'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('imports deduplicate, preserve identities, and export only this server', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.server': _server,
      'groups.known': jsonEncode([
        {'server': _server, 'token': _one, 'memberId': 'ana'},
        {'server': 'https://foreign.example', 'token': _foreign},
      ]),
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        serverInfoProvider.overrideWithValue(
          const AsyncData(
            ServerInfo(version: 'test', authMode: AuthMode.link, publicUrl: 'https://public.example'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: MyGroupsSection()),
        ),
      ),
    );
    await tester.tap(find.text('Import groups'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'https://public.example/g/$_two\n$_one\n$_two');
    await tester.tap(find.text('Import links'));
    await tester.pumpAndSettle();
    final known = container.read(knownGroupsProvider);
    expect(known.map((g) => g.token), [_two, _one]);
    expect(known.last.memberId, 'ana');
    final saved = jsonDecode(prefs.getString('groups.known')!) as List;
    expect(saved.where((g) => (g as Map)['token'] == _foreign), hasLength(1));
    expect(find.text('Imported 1 new group link.'), findsOneWidget);

    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') clipboard = (call.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.tap(find.text('Export my groups'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy links'));
    await tester.pumpAndSettle();
    expect(clipboard, 'https://public.example/g/$_two\nhttps://public.example/g/$_one');
    await tester.pumpWidget(const SizedBox());
  });

  test('an import exceeding the summaries limit is rejected atomically', () async {
    SharedPreferences.setMockInitialValues({'settings.server': _server});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [prefsProvider.overrideWithValue(prefs)]);
    addTearDown(container.dispose);
    final catalog = container.read(knownGroupsProvider.notifier);
    expect(
      () => catalog.importOn(_server, [for (var i = 0; i <= maxKnownGroups; i++) '$i'.padLeft(22, 'A')]),
      throwsFormatException,
    );
    expect(prefs.getString('groups.known'), isNull);
  });
}
