import 'package:balnana/app.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
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

  testWidgets('a wide window uses a navigation rail', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _boot(tester, await _prefs());

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
