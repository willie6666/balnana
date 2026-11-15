import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../data/models/billing.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import 'plan_comparison.dart';

/// Sample limits for checking the comparison without an account or server.
const previewPlanComparison = PlanComparisonData(
  currentPlanId: 'free',
  verifiedPlanId: 'free',
  unverifiedPlanId: 'unverified',
  plans: [
    Plan(
      id: 'free',
      name: 'Free',
      limits: PlanLimits(
        joinedGroups: 5,
        sponsoredGroups: 0,
        receiptsPerGroup: 20,
        recurringPerGroup: 2,
        membersPerGroup: 15,
      ),
    ),
    Plan(
      id: 'plus',
      name: 'Plus',
      limits: PlanLimits(
        joinedGroups: 50,
        sponsoredGroups: 10,
        receiptsPerGroup: 2000,
        recurringPerGroup: 50,
        membersPerGroup: 100,
        reminders: true,
      ),
    ),
  ],
);

@Preview(name: 'Phone', group: 'Plan comparison', size: Size(390, 780))
@Preview(name: 'Large text', group: 'Plan comparison', size: Size(320, 780), textScaleFactor: 2)
@Preview(name: 'Dark', group: 'Plan comparison', size: Size(720, 780), brightness: Brightness.dark)
Widget planComparisonPreview() => MaterialApp(
  locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  localizationsDelegates: l10nDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: buildTheme(brandScheme(Brightness.light)),
  darkTheme: buildTheme(brandScheme(Brightness.dark)),
  home: const Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(BSpace.s16),
        child: PlanComparisonTable(comparison: previewPlanComparison),
      ),
    ),
  ),
);
