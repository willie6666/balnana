import 'package:balnana/core/l10n.dart';
import 'package:balnana/data/models/billing.dart';
import 'package:balnana/features/settings/plan_comparison.dart';
import 'package:balnana/l10n/app_localizations_en.dart';
import 'package:balnana/ui/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _comparison = PlanComparisonData(
  currentPlanId: 'free',
  unverifiedPlanId: 'unverified',
  verifiedPlanId: 'free',
  plans: [
    Plan(
      id: 'unverified',
      name: 'Email unverified',
      limits: PlanLimits(receiptsPerGroup: 0, sponsoredGroups: 0),
    ),
    Plan(id: 'free', name: 'Free', limits: PlanLimits(receiptsPerGroup: 20, membersPerGroup: 15)),
    Plan(
      id: 'plus',
      name: 'Plus',
      limits: PlanLimits(receiptsPerGroup: 2000, membersPerGroup: 100, reminders: true),
    ),
  ],
);

Future<void> _pump(
  WidgetTester tester, {
  double width = 320,
  double scale = 1,
  bool dark = false,
  PlanComparisonData comparison = _comparison,
}) async {
  tester.view.physicalSize = Size(width, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(brandScheme(dark ? Brightness.dark : Brightness.light)),
      localizationsDelegates: l10nDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(child: PlanComparisonTable(comparison: comparison)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final l10n = AppLocalizationsEn();

  testWidgets('a phone can scroll to each plan without clipping the rows', (tester) async {
    await _pump(tester);
    expect(tester.takeException(), isNull);
    expect(find.text(l10n.planCompareScroll), findsOneWidget);
    // Nonzero row height catches TableCell.fill collapsing all cells.
    expect(tester.getSize(find.byType(Table)).height, greaterThan(350));
    final scroll = find.byWidgetPredicate(
      (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
    );
    await tester.drag(scroll, const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.text('Plus').hitTestable(), findsOneWidget);
    expect(find.text('2000').hitTestable(), findsOneWidget);
    expect(find.text(l10n.planIncluded).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text and long plan names fit in dark mode', (tester) async {
    await _pump(
      tester,
      scale: 2,
      dark: true,
      comparison: const PlanComparisonData(
        currentPlanId: 'a',
        plans: [
          Plan(id: 'a', name: 'A very long current plan name that wraps over several lines'),
          Plan(id: 'b', name: 'Another very long plan name for a small phone'),
        ],
      ),
    );
    expect(find.text(l10n.planCurrent), findsOneWidget);
    expect(tester.takeException(), isNull);
    final table = find.byType(Table);
    expect(tester.getSize(table).height, greaterThan(700));
  });

  testWidgets('two plans fit side by side on a regular phone', (tester) async {
    await _pump(
      tester,
      width: 390,
      comparison: PlanComparisonData(currentPlanId: 'free', plans: _comparison.plans.skip(1).toList()),
    );
    expect(find.text('Free').hitTestable(), findsOneWidget);
    expect(find.text('Plus').hitTestable(), findsOneWidget);
    expect(find.text('2000').hitTestable(), findsOneWidget);
    expect(find.text(l10n.planCompareScroll), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('current plan uses the ID and zero differs from unlimited', (tester) async {
    await _pump(
      tester,
      width: 1200,
      comparison: const PlanComparisonData(
        currentPlanId: 'b',
        plans: [
          Plan(id: 'a', name: 'Same name', limits: PlanLimits(sponsoredGroups: 0)),
          Plan(id: 'b', name: 'Same name'),
        ],
      ),
    );
    expect(find.text(l10n.planCurrent), findsOneWidget);
    expect(find.text(l10n.planCompareScroll), findsNothing);
    expect(find.text('0'), findsOneWidget);
    expect(find.text(l10n.planUnlimited), findsWidgets);
    expect(find.text(l10n.planNotIncluded), findsNWidgets(2));
    final badge = tester.getTopLeft(find.text(l10n.planCurrent));
    final names = tester.getTopLeft(find.text('Same name').last);
    expect(badge.dx, greaterThan(600));
    expect((badge.dx - names.dx).abs(), lessThan(100));
    expect(tester.takeException(), isNull);
  });
}
