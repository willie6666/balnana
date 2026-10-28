import 'package:balnana/data/models.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:balnana/ui/widgets/member_picker.dart';
import 'package:balnana/ui/widgets/menu_chip.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Ana, Ben and Person 3 to Person [count].
List<Member> _people(int count) => [
  Member(id: 'a', name: 'Ana', balance: BigInt.zero),
  Member(id: 'b', name: 'Ben', balance: BigInt.zero),
  for (var i = 3; i <= count; i++) Member(id: 'p$i', name: 'Person $i', balance: BigInt.zero),
];

/// Shows a button that runs [open] with a context under the app.
Future<void> _host(WidgetTester tester, Future<void> Function(BuildContext context) open) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(onPressed: () => open(context), child: const Text('Open')),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  test('only more than a dozen people make a crowd', () {
    expect(isCrowd(crowdSize), isFalse);
    expect(isCrowd(crowdSize + 1), isTrue);
  });

  test('a search matches any part of a name, ignoring case', () {
    expect(nameMatches('Ana', ''), isTrue);
    expect(nameMatches('Ana', '  '), isTrue);
    expect(nameMatches('Ana', 'NA'), isTrue);
    expect(nameMatches('Ana', 'ben'), isFalse);
  });

  testWidgets('one person is picked by search, or anyone', (tester) async {
    ({String? id})? picked;
    Future<void> open(BuildContext context) async =>
        picked = await pickMember(context, title: 'Who?', members: _people(40), anyone: 'Anyone');
    await _host(tester, open);
    expect(find.text('Anyone'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'person 2');
    await tester.pumpAndSettle();
    // Person 2 does not exist: 20 to 29 do, and the anyone choice hides.
    expect(find.text('Anyone'), findsNothing);
    expect(find.text('Ana'), findsNothing);
    expect(find.text('Person 21'), findsOneWidget);
    await tester.tap(find.text('Person 21'));
    await tester.pumpAndSettle();
    expect(picked?.id, 'p21');

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anyone'));
    await tester.pumpAndSettle();
    expect(picked, isNotNull);
    expect(picked?.id, isNull);
  });

  testWidgets('no match says so', (tester) async {
    await _host(tester, (context) => pickMember(context, title: 'Who?', members: _people(20)));
    await tester.enterText(find.byType(EditableText), 'zz');
    await tester.pumpAndSettle();
    expect(find.text('No one matches.'), findsOneWidget);
  });

  testWidgets('All and None tick only the people searched for', (tester) async {
    Set<String>? picked;
    await _host(
      tester,
      (context) async =>
          picked = await pickMembers(context, title: 'Who paid?', members: _people(30), selected: {'a'}),
    );
    expect(find.text('1 of 30 chosen'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'person 1');
    await tester.pumpAndSettle();
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    // Person 10 to 19.
    expect(find.text('11 of 30 chosen'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'a');
    await tester.pumpAndSettle();
    await tester.tap(find.text('None'));
    await tester.pumpAndSettle();
    expect(find.text('10 of 30 chosen'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(picked, {for (var i = 10; i <= 19; i++) 'p$i'});
  });

  testWidgets('a long list shows its first part until asked for more', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ShowMore(limit: 3, children: [for (var i = 1; i <= 5; i++) Text('Row $i')]),
          ),
        ),
      ),
    );
    expect(find.text('Row 3'), findsOneWidget);
    expect(find.text('Row 4'), findsNothing);
    await tester.tap(find.text('2 more'));
    await tester.pumpAndSettle();
    expect(find.text('Row 5'), findsOneWidget);
    await tester.tap(find.text('Show fewer'));
    await tester.pumpAndSettle();
    expect(find.text('Row 4'), findsNothing);
  });

  testWidgets('a short list shows everything with no button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ShowMore(limit: 3, children: [for (var i = 1; i <= 3; i++) Text('Row $i')])),
      ),
    );
    expect(find.text('Row 3'), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('a menu chip with its own action opens no menu', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MenuChip(
            label: 'Anyone',
            selected: false,
            onPressed: () => pressed++,
            items: [MenuItemButton(onPressed: () {}, child: const Text('Ben'))],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Anyone'));
    await tester.pumpAndSettle();
    expect(pressed, 1);
    expect(find.text('Ben'), findsNothing);
  });
}
