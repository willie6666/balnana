import 'package:balnana/core/l10n.dart';
import 'package:balnana/data/api.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/features/admin/admin_page.dart';
import 'package:balnana/features/admin/admin_plans_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _catalog = PlanCatalog(
  unverifiedPlanId: 'unverified',
  verifiedPlanId: 'free',
  plans: [
    Plan(id: 'unverified', name: 'Unverified', limits: PlanLimits(receiptsPerGroup: 0, joinedGroups: 5)),
    Plan(id: 'free', name: 'Free', isDefault: true),
    Plan(id: 'plus', name: 'Plus'),
  ],
  products: [PlanProduct(provider: 'play', product: 'monthly', planId: 'plus', days: 30)],
);

class _Api extends AdminApi {
  _Api() : super(Dio());
  PlanCatalog catalog = _catalog;
  final saved = <PlanCatalog>[];
  bool fail = false;

  @override
  Future<PlanCatalog> plans(String token) async => catalog;

  @override
  Future<PlanCatalog> savePlans(String token, PlanCatalog next) async {
    saved.add(next);
    if (fail) throw const ApiException('invalid_plan');
    return catalog = next;
  }
}

Future<void> _pump(WidgetTester tester, _Api api) async {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [adminApiProvider.overrideWithValue(api)],
      child: const MaterialApp(
        localizationsDelegates: l10nDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AdminPlansPage(token: 'admin'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('catalog round trip preserves automatic assignments across plan and product edits', () {
    final catalog = PlanCatalog.fromJson(_catalog.toJson());
    final edited = catalog.copyWith(products: []);
    expect(edited.unverifiedPlanId, 'unverified');
    expect(edited.verifiedPlanId, 'free');
    expect(PlanCatalog.fromJson(edited.toJson()).unverifiedPlanId, 'unverified');
  });

  testWidgets('automatic plans save independently and stay selected after editing a plan', (tester) async {
    final api = _Api();
    await _pump(tester, api);
    expect(find.text('Without a verified email'), findsOneWidget);
    expect(find.text('With a verified email'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plus').last);
    await tester.pumpAndSettle();
    expect(api.catalog.unverifiedPlanId, 'plus');
    expect(api.catalog.verifiedPlanId, 'free');
    expect(api.catalog.products, _catalog.products);

    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unverified').last);
    await tester.pumpAndSettle();
    expect(api.catalog.unverifiedPlanId, 'plus');
    expect(api.catalog.verifiedPlanId, 'unverified');

    // The selected automatic plans and group default cannot be deleted.
    expect(find.byIcon(Icons.delete_outline), findsOneWidget); // the product only
    await tester.tap(find.text('Unverified').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Limited');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(api.catalog.unverifiedPlanId, 'plus');
    expect(api.catalog.verifiedPlanId, 'unverified');
    expect(api.catalog.plans.first.name, 'Limited');
    expect(api.catalog.products, _catalog.products);
  });

  testWidgets('a failed assignment restores the saved selection', (tester) async {
    final api = _Api()..fail = true;
    await _pump(tester, api);
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plus').last);
    await tester.pumpAndSettle();
    expect(api.catalog.unverifiedPlanId, 'unverified');
    final dropdown = tester.widget<DropdownButton<String>>(find.byType(DropdownButton<String>).first);
    expect(dropdown.value, 'unverified');
    expect(api.saved.single.unverifiedPlanId, 'plus');
  });
}
