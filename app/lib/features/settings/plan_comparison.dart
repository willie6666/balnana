import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../data/models/billing.dart';
import '../../ui/tokens.dart';

/// Compares the server's plan limits, with the current plan highlighted.
class PlanComparisonTable extends StatefulWidget {
  const PlanComparisonTable({super.key, required this.comparison});

  final PlanComparisonData comparison;

  @override
  State<PlanComparisonTable> createState() => _PlanComparisonTableState();
}

class _PlanComparisonTableState extends State<PlanComparisonTable> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final comparison = widget.comparison;
    final plans = comparison.plans;
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    String limit(int? value) => value?.toString() ?? l10n.planUnlimited;
    final rows = <(String, String Function(PlanLimits))>[
      (l10n.planLimitJoinedGroups, (p) => limit(p.joinedGroups)),
      (l10n.planLimitSponsored, (p) => limit(p.sponsoredGroups)),
      (l10n.planLimitMembers, (p) => limit(p.membersPerGroup)),
      (l10n.planLimitReceipts, (p) => limit(p.receiptsPerGroup)),
      (l10n.planLimitRecurring, (p) => limit(p.recurringPerGroup)),
      (l10n.planLimitReminders, (p) => p.reminders ? l10n.planIncluded : l10n.planNotIncluded),
    ];

    Widget cell(Widget child, {Plan? plan, bool header = false}) {
      final current = plan?.id == comparison.currentPlanId;
      return TableCell(
        verticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
        child: ColoredBox(
          color: current
              ? scheme.primaryContainer
              : header
              ? scheme.surfaceContainerHigh
              : scheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(BSpace.s16),
            child: Align(
              alignment: plan == null ? AlignmentDirectional.centerStart : Alignment.center,
              child: DefaultTextStyle(
                style: (header ? theme.textTheme.titleSmall! : theme.textTheme.bodyMedium!).copyWith(
                  color: current ? scheme.onPrimaryContainer : scheme.onSurface,
                  fontWeight: current ? FontWeight.w600 : null,
                ),
                textAlign: plan == null ? TextAlign.start : TextAlign.center,
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    Widget heading(Plan plan) {
      final current = plan.id == comparison.currentPlanId;
      final eligibility = comparison.unverifiedPlanId == comparison.verifiedPlanId
          ? null
          : plan.id == comparison.unverifiedPlanId
          ? l10n.adminUnverifiedPlan
          : plan.id == comparison.verifiedPlanId
          ? l10n.adminVerifiedPlan
          : null;
      return Semantics(
        header: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(plan.name),
            if (current) ...[
              const SizedBox(height: BSpace.s8),
              Text(
                l10n.planCurrent,
                style: theme.textTheme.labelMedium?.copyWith(color: scheme.onPrimaryContainer),
              ),
            ],
            if (eligibility != null) ...[
              const SizedBox(height: BSpace.s8),
              Text(eligibility, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: BSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: BSpace.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.planCompare, style: theme.textTheme.titleMedium),
                const SizedBox(height: BSpace.s8),
                Text(
                  l10n.planCompareHelp,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: BSpace.s16),
          LayoutBuilder(
            builder: (context, constraints) {
              final featureWidth = 144 * scale;
              final width = math.max(constraints.maxWidth, featureWidth + plans.length * 104 * scale);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (width > constraints.maxWidth)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(BSpace.s16, 0, BSpace.s16, BSpace.s8),
                      child: Text(l10n.planCompareScroll, style: theme.textTheme.bodySmall),
                    ),
                  Scrollbar(
                    controller: _scroll,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scroll,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: BSpace.s12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(BShape.lg),
                        child: SizedBox(
                          width: width,
                          child: Table(
                            columnWidths: {0: FixedColumnWidth(featureWidth)},
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            border: TableBorder(horizontalInside: BorderSide(color: scheme.outlineVariant)),
                            children: [
                              TableRow(
                                children: [
                                  cell(
                                    Semantics(header: true, child: Text(l10n.planCompareFeature)),
                                    header: true,
                                  ),
                                  for (final plan in plans) cell(heading(plan), plan: plan, header: true),
                                ],
                              ),
                              for (final (label, value) in rows)
                                TableRow(
                                  children: [
                                    cell(Text(label)),
                                    for (final plan in plans) cell(Text(value(plan.limits)), plan: plan),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
