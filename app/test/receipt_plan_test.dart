import 'package:balnana/core/server.dart';
import 'package:balnana/core/session.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/features/expense/receipt.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final allowed in [false, true]) {
    testWidgets('receipt picker follows the current plan: uploads allowed=$allowed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            identityProvider.overrideWithValue((
              server: 'https://example.test',
              token: 'signed-in',
              generation: 0,
            )),
            signedInProvider.overrideWithValue(true),
            serverInfoProvider.overrideWithValue(
              const AsyncData(
                ServerInfo(
                  version: '1',
                  authMode: AuthMode.accounts,
                  publicUrl: 'https://example.test',
                  billing: true,
                ),
              ),
            ),
            myPlanProvider.overrideWith(
              (ref) async => MyPlan(
                planName: allowed ? 'Free' : 'Unverified',
                paid: false,
                joinedGroups: const PlanUsage(used: 0),
                sponsoredGroups: const PlanUsage(used: 0),
                receiptsPerGroup: allowed ? 20 : 0,
              ),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ReceiptField(
                token: 'group',
                expenseId: null,
                saved: false,
                picked: null,
                onPicked: (_) {},
                onRemoved: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.photo_camera_outlined), allowed ? findsOneWidget : findsNothing);
      expect(find.byIcon(Icons.photo_library_outlined), allowed ? findsOneWidget : findsNothing);
      expect(find.text('Your plan does not allow photo uploads.'), allowed ? findsNothing : findsOneWidget);
    });
  }
}
