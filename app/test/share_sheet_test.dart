import 'package:balnana/core/server.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/features/group/share_sheet.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _server = 'https://split.example.com';

Group _group({bool linkAccess = true}) => Group(
  token: 'tok',
  name: 'Kyoto trip',
  currency: 'JPY',
  minorDigits: 0,
  createdAt: DateTime.utc(2026),
  linkAccess: linkAccess,
  members: [Member(id: 'a', name: 'Ana', balance: BigInt.zero)],
);

/// Opens the share sheet for [group] on a server in [mode].
Future<void> _open(WidgetTester tester, Group group, {AuthMode mode = AuthMode.link}) async {
  final info = ServerInfo(version: '1.0.0', authMode: mode, publicUrl: _server);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [serverInfoProvider.overrideWithValue(AsyncValue.data(info))],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) =>
                TextButton(onPressed: () => showShareSheet(context, group), child: const Text('Open')),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the QR code holds the group link, and copying it closes the sheet', (tester) async {
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') clipboard = (call.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await _open(tester, _group());

    expect(tester.widget<QrCodeView>(find.byType(QrCodeView)).data, '$_server/g/tok');
    expect(find.bySemanticsLabel('QR code for the link to Kyoto trip'), findsOneWidget);
    expect(find.text('Kyoto trip'), findsOneWidget);
    expect(find.text('$_server/g/tok'), findsOneWidget);
    expect(find.text('Anyone with the link can see and edit this group.'), findsOneWidget);

    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();
    expect(clipboard, '$_server/g/tok');
    expect(find.byType(QrCodeView), findsNothing);
    expect(find.text('Link copied. Anyone with it can open this group.'), findsOneWidget);
  });

  testWidgets('with link access off, the sheet says people sign in to ask to join', (tester) async {
    await _open(tester, _group(linkAccess: false), mode: AuthMode.accounts);
    expect(find.text('People with the link can ask to join after signing in.'), findsOneWidget);
  });

  testWidgets('the sheet fits a phone held sideways', (tester) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _open(tester, _group());
    expect(tester.getSize(find.byType(QrCodeView)).height, 160);
    await tester.scrollUntilVisible(find.text('Share link'), 50, scrollable: find.byType(Scrollable).last);
    expect(find.text('Share link'), findsOneWidget);
  });
}
