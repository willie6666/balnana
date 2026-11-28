import 'package:balnana/core/l10n.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/api.dart';
import 'package:balnana/l10n/app_localizations_en.dart';
import 'package:balnana/ui/widgets/error_snack.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _show(WidgetTester tester, ApiException error, {required bool billing}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        serverInfoProvider.overrideWithValue(
          AsyncValue.data(
            ServerInfo(
              version: '1',
              authMode: AuthMode.accounts,
              publicUrl: 'https://split.example.com',
              billing: billing,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: l10nDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showError(ScaffoldMessenger.of(context), context.l10n, error),
              child: const Text('fail'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('fail'));
  await tester.pumpAndSettle();
}

void main() {
  final l10n = AppLocalizationsEn();
  const limit = ApiException('plan_limit', status: 402, params: {'limit': 'members', 'max': 15});

  testWidgets('a plan limit leads to the plans, and still goes away by itself', (tester) async {
    await _show(tester, limit, billing: true);

    expect(find.text(l10n.errorLimitMembers(15)), findsOneWidget);
    expect(find.text(l10n.planView), findsOneWidget);
    expect(tester.widget<SnackBar>(find.byType(SnackBar)).persist, isFalse);
  });

  testWidgets('a server without plans offers none', (tester) async {
    await _show(tester, limit, billing: false);

    expect(find.text(l10n.errorLimitMembers(15)), findsOneWidget);
    expect(find.text(l10n.planView), findsNothing);
  });

  testWidgets('another error offers none', (tester) async {
    await _show(tester, const ApiException('payment_not_found'), billing: true);

    expect(find.text(l10n.planView), findsNothing);
  });
}
