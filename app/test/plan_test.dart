import 'package:balnana/core/errors.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/api.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/features/settings/plan_page.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:balnana/l10n/app_localizations_en.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _server = 'https://split.example.com';

const _plan = MyPlan(
  planName: 'Plus',
  paid: true,
  ownGroups: PlanUsage(limit: 50, used: 3),
  sponsoredGroups: PlanUsage(used: 2),
  receiptsPerGroup: 2000,
);

Future<void> _pump(WidgetTester tester, MyPlan plan) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myPlanProvider.overrideWith((ref) async => plan),
        serverInfoProvider.overrideWithValue(
          AsyncValue.data(
            ServerInfo(
              version: '1',
              authMode: AuthMode.accounts,
              publicUrl: _server,
              billing: true,
              kofiUrl: Uri.parse('https://ko-fi.com/example'),
            ),
          ),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlanPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final l10n = AppLocalizationsEn();

  group('server info', () {
    Map<String, Object?> json([Map<String, Object?> extra = const {}]) => {
      'name': 'balnana',
      'version': '1',
      'authMode': 'accounts',
      'publicUrl': _server,
      ...extra,
    };

    test('has no plans unless the server says so', () {
      final info = ServerInfo.fromJson(json());
      expect(info.billing, isFalse);
      expect(info.kofiUrl, isNull);
    });

    test('reads the Ko-fi page', () {
      final info = ServerInfo.fromJson(
        json({
          'billing': {'kofiUrl': 'https://ko-fi.com/example'},
        }),
      );
      expect(info.billing, isTrue);
      expect(info.kofiUrl, Uri.parse('https://ko-fi.com/example'));
    });

    test('plans can have no page to pay on', () {
      final info = ServerInfo.fromJson(json({'billing': <String, Object?>{}}));
      expect(info.billing, isTrue);
      expect(info.kofiUrl, isNull);
    });
  });

  test('a limit says which limit it is', () {
    String message(Map<String, Object?> params) =>
        errorMessage(l10n, ApiException('plan_limit', status: 402, params: params));

    expect(message({'limit': 'receipts', 'max': 20}), l10n.errorLimitReceipts(20));
    expect(message({'limit': 'recurring', 'max': 2}), l10n.errorLimitRecurring(2));
    expect(message({'limit': 'own_groups', 'max': 5}), l10n.errorLimitOwnGroups(5));
    expect(message({'limit': 'sponsored_groups', 'max': 10}), l10n.errorLimitSponsored(10));
    expect(message({'limit': 'something_new'}), l10n.errorLimitOther);
  });

  test('usage shows the limit only when there is one', () {
    expect(planUsage(l10n, const PlanUsage(limit: 50, used: 3)), '3 of 50');
    expect(planUsage(l10n, const PlanUsage(used: 3)), l10n.planUsed(3));
  });

  test('a plan is read with empty limits as none', () {
    final plan = MyPlan.fromJson({
      'planName': 'Free',
      'ownGroups': {'used': 1, 'limit': 5},
      'sponsoredGroups': {'used': 0, 'limit': 0},
      'receiptsPerGroup': 20,
      'paymentEmails': ['me@example.com', 42],
    });
    expect(plan.paid, isFalse);
    expect(plan.expiresAt, isNull);
    expect(plan.ownGroups.limit, 5);
    expect(plan.sponsoredGroups.limit, 0);
    expect(plan.receiptsPerGroup, 20);
    expect(plan.recurringPerGroup, isNull);
    expect(plan.paymentEmails, ['me@example.com']);
  });

  testWidgets('the plan page shows the plan and how much of it is used', (tester) async {
    await _pump(tester, _plan);

    expect(find.text('Plus'), findsOneWidget);
    expect(find.text('3 of 50'), findsOneWidget);
    expect(find.text('2000'), findsOneWidget);
    expect(find.text(l10n.planUnlimited), findsOneWidget);
  });

  // Google Play doesn't allow pointing people elsewhere to pay.
  testWidgets('a build without external payments has no way to pay', (tester) async {
    expect(externalPayments, isFalse);
    await _pump(tester, _plan);

    expect(find.text(l10n.planKofi), findsNothing);
    expect(find.text(l10n.planGet), findsNothing);
    expect(find.text(l10n.planPaymentEmailAdd), findsNothing);
  });
}
