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

/// A value drawn as an icon, which the row reads out by [label].
Finder _mark(String label) => find.byWidgetPredicate((w) => w is Icon && w.semanticLabel == label);

void main() {
  final l10n = AppLocalizationsEn();

  testWidgets('three plans fit side by side on a small phone, with no sideways scrolling', (tester) async {
    await _pump(tester);
    expect(tester.takeException(), isNull);
    expect(find.text(l10n.planCompareScroll), findsNothing);
    for (final name in ['Email unverified', 'Free', 'Plus', '2,000']) {
      expect(find.text(name).hitTestable(), findsOneWidget, reason: name);
    }
    expect(_mark(l10n.planIncluded), findsOneWidget);
    // Each plan's value sits under its own heading.
    final plus = tester.getCenter(find.text('Plus')).dx;
    expect(tester.getCenter(find.text('2,000')).dx, moreOrLessEquals(plus, epsilon: 1));
    expect(tester.getCenter(_mark(l10n.planIncluded)).dx, moreOrLessEquals(plus, epsilon: 1));
  });

  testWidgets('large text scrolls sideways rather than squeezing the columns', (tester) async {
    await _pump(tester, scale: 2);
    expect(tester.takeException(), isNull);
    expect(find.text(l10n.planCompareScroll), findsOneWidget);
    final scroll = find.byWidgetPredicate(
      (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
    );
    await tester.drag(scroll, const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.text('Plus').hitTestable(), findsOneWidget);
    expect(find.text('2,000').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long plan names wrap in dark mode', (tester) async {
    await _pump(
      tester,
      scale: 2,
      dark: true,
      width: 390,
      comparison: const PlanComparisonData(
        currentPlanId: 'a',
        plans: [
          Plan(id: 'a', name: 'A very long current plan name that wraps over several lines'),
          Plan(id: 'b', name: 'Another very long plan name for a small phone'),
        ],
      ),
    );
    expect(find.text(l10n.planCurrent), findsOneWidget);
    expect(find.text(l10n.planCompareScroll), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the current plan goes by its ID, and none differs from no limit', (tester) async {
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
    expect(_mark('0'), findsOneWidget);
    expect(find.text(l10n.planUnlimited), findsNWidgets(9));
    expect(_mark(l10n.planNotIncluded), findsNWidgets(4));
    final badge = tester.getCenter(find.text(l10n.planCurrent));
    final names = tester.getCenter(find.text('Same name').last);
    expect(badge.dx, greaterThan(600));
    expect(badge.dx, moreOrLessEquals(names.dx, epsilon: 1));
    expect(tester.takeException(), isNull);
  });
}
