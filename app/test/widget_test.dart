import 'package:balnana/app.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/features/settings/my_groups.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Future<void> _boot(
  WidgetTester tester,
  SharedPreferences prefs, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [prefsProvider.overrideWithValue(prefs), ...overrides],
      child: const BalnanaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('without a server, groups asks to choose one', (tester) async {
    await _boot(tester, await _prefs());

    expect(find.text('Connect to a server'), findsOneWidget);
    await tester.tap(find.text('Choose server'));
    await tester.pumpAndSettle();
    expect(find.text('Server address'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'not a url');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a web address, like balnana.example.com'), findsOneWidget);
  });

  testWidgets('settings change the theme and persist it', (tester) async {
    final prefs = await _prefs();
    await _boot(tester, prefs);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(prefs.getString('settings.theme'), 'dark');
    // No server, so no server-provided source link.
    expect(find.text('Source code', skipOffstage: false), findsNothing);
  });

  testWidgets('about links to the source code the server names', (tester) async {
    final info = ServerInfo(
      version: '1.0.0',
      authMode: AuthMode.link,
      publicUrl: 'https://split.example.com',
      sourceUrl: Uri.parse('https://git.example.com/balnana'),
    );
    await _boot(
      tester,
      await _prefs({'settings.server': 'https://split.example.com'}),
      overrides: [serverInfoProvider.overrideWithValue(AsyncValue.data(info))],
    );

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Source code'), 200);
    expect(find.text('https://git.example.com/balnana'), findsOneWidget);
  });

  testWidgets('link mode copies every group link out and pastes them back in', (tester) async {
    const server = 'https://split.example.com';
    const older = 'AAAAAAAAAAAAAAAAAAAAAA', newer = 'BBBBBBBBBBBBBBBBBBBBBB', other = 'CCCCCCCCCCCCCCCCCCCCCC';
    final prefs = await _prefs({
      'settings.server': server,
      'groups.known':
          '[{"server":"$server","token":"$newer","addedAt":"2026-02-01T00:00:00Z"},'
          '{"server":"$server","token":"$older","addedAt":"2026-01-01T00:00:00Z"}]',
    });
    final info = ServerInfo(version: '1.0.0', authMode: AuthMode.link, publicUrl: server);
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    await _boot(
      tester,
      prefs,
      overrides: [
        serverInfoProvider.overrideWithValue(AsyncValue.data(info)),
        summariesProvider.overrideWith((ref) async => (groups: <GroupSummary>[], missing: <String>[])),
      ],
    );

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Import groups'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export your groups'));
    await tester.pumpAndSettle();
    expect(copied, '$server/g/$older\n$server/g/$newer\n');
    expect(find.text('Copied 2 group links'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Import groups'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    expect(find.text('There are no Balnana group links in that text.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Our trip: $server/g/$other\n$server/g/$older, $other');
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    expect(find.text('Added 1 group'), findsOneWidget);
    final known = prefs.getString('groups.known')!;
    expect(RegExp('"token":"(\\w+)"').allMatches(known).map((m) => m[1]), [other, newer, older]);
  });

  test('pasted text yields each group token once', () {
    const a = 'AAAAAAAAAAAAAAAAAAAAAA', b = 'BBBBBBBBBBBBBBBBBBBBBB';
    expect(tokensIn('https://x.example/g/$a\n\n$b;https://y.example/g/$a?x=1 junk'), [a, b]);
    expect(tokensIn(''), isEmpty);
  });

  testWidgets('a closed server offers sign-up only for its first account', (tester) async {
    for (final first in [true, false]) {
      final info = ServerInfo(
        version: '1.0.0',
        authMode: AuthMode.accounts,
        password: true,
        signup: SignupPolicy.closed,
        firstAccount: first,
        publicUrl: 'https://split.example.com',
      );
      await _boot(
        tester,
        await _prefs({'settings.server': 'https://split.example.com'}),
        overrides: [
          serverInfoProvider.overrideWithValue(AsyncValue.data(info)),
          accountProvider.overrideWithValue(const AsyncValue.data(null)),
        ],
      );
      expect(find.text('Create an account'), first ? findsOneWidget : findsNothing);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('a wide window uses a navigation rail', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _boot(tester, await _prefs());

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
