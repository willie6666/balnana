import 'package:balnana/l10n/app_localizations.dart';
import 'package:balnana/ui/widgets/currency_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('a currency is picked from the list, or typed', (tester) async {
    final controller = TextEditingController(text: 'USD');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CurrencyField(controller: controller)),
      ),
    );
    expect(find.textContaining('US Dollar.'), findsOneWidget);

    await tester.tap(find.byTooltip('Choose a currency'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'taiwan');
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Taiwan Dollar'));
    await tester.pumpAndSettle();
    expect(controller.text, 'TWD');
    expect(find.textContaining('New Taiwan Dollar.'), findsOneWidget);

    // A code the list doesn't know can still be used.
    await tester.tap(find.byTooltip('Choose a currency'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'xbt');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use XBT'));
    await tester.pumpAndSettle();
    expect(controller.text, 'XBT');

    await tester.enterText(find.byType(TextFormField), 'jp1y');
    expect(controller.text, 'jpy');
    await tester.pump();
    expect(find.textContaining('Japanese Yen.'), findsOneWidget);
  });
}
