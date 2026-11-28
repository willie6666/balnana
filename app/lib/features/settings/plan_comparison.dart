import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../data/models/billing.dart';
import '../../ui/tokens.dart';

/// Compares the server's plan limits, with the current plan highlighted.
///
/// Reads like a [GroupedList]: a header with a column per plan, then one
/// segment per limit, its name across the top and each plan's value under
/// that plan's column. The columns share the full width, so a phone fits
/// several plans; only when they would get too narrow does it scroll sideways.
class PlanComparisonTable extends StatelessWidget {
  const PlanComparisonTable({super.key, required this.comparison, this.titled = true});

  final PlanComparisonData comparison;

  /// Off where a row above already names the table.
  final bool titled;

  /// The narrowest a plan's column gets, at the default text size.
  static const _minColumn = 88.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final plans = comparison.plans;
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final numbers = NumberFormat.decimalPattern(Localizations.localeOf(context).toLanguageTag());

    final rows = <(IconData, String, _Value Function(PlanLimits))>[
      (Icons.group_outlined, l10n.planLimitJoinedGroups, (p) => _Value.limit(p.joinedGroups)),
      (Icons.upgrade, l10n.planLimitSponsored, (p) => _Value.limit(p.sponsoredGroups)),
      (Icons.groups_outlined, l10n.planLimitMembers, (p) => _Value.limit(p.membersPerGroup)),
      (Icons.receipt_outlined, l10n.planLimitReceipts, (p) => _Value.limit(p.receiptsPerGroup)),
      (Icons.repeat, l10n.planLimitRecurring, (p) => _Value.limit(p.recurringPerGroup)),
      (Icons.notifications_active_outlined, l10n.planLimitReminders, (p) => _Value.included(p.reminders)),
      (Icons.visibility_outlined, l10n.planLimitViewLink, (p) => _Value.included(p.viewLink)),
    ];

    bool isCurrent(Plan plan) => plan.id == comparison.currentPlanId;

    // Who gets a plan without paying, when that differs by verification.
    String? eligibility(Plan plan) => comparison.unverifiedPlanId == comparison.verifiedPlanId
        ? null
        : plan.id == comparison.unverifiedPlanId
        ? l10n.adminUnverifiedPlan
        : plan.id == comparison.verifiedPlanId
        ? l10n.adminVerifiedPlan
        : null;

    Widget column(Widget child, {EdgeInsetsGeometry padding = EdgeInsets.zero}) => Expanded(
      child: Padding(
        padding: padding,
        child: Center(child: child),
      ),
    );

    Widget heading(Plan plan) {
      final current = isCurrent(plan);
      final note = eligibility(plan);
      final content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            plan.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
          ),
          if (current) ...[
            const SizedBox(height: BSpace.s4),
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(BShape.sm),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: BSpace.s8, vertical: 2),
                child: Text(
                  l10n.planCurrent,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(color: scheme.onPrimary),
                ),
              ),
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: BSpace.s4),
            Text(
              note,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      );
      return Semantics(
        header: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: current ? scheme.primary.withValues(alpha: 0.12) : null,
            border: current ? Border.all(color: scheme.primary, width: 1.5) : null,
            borderRadius: BorderRadius.circular(BShape.md),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: BSpace.s4, vertical: BSpace.s12),
            child: Center(child: content),
          ),
        ),
      );
    }

    Widget value(Plan plan, _Value v) {
      final current = isCurrent(plan);
      final style = theme.textTheme.titleSmall?.copyWith(
        color: current ? scheme.onSurface : scheme.onSurfaceVariant,
        fontWeight: current ? FontWeight.w700 : FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
      Widget mark(IconData icon, Color color, String label) =>
          Icon(icon, size: 20, color: color, semanticLabel: label);
      return switch (v) {
        _Value(included: true) => mark(Icons.check_circle, scheme.primary, l10n.planIncluded),
        _Value(included: false) => mark(Icons.remove, scheme.outline, l10n.planNotIncluded),
        _Value(limit: null) => Text(l10n.planUnlimited, textAlign: TextAlign.center, style: style),
        _Value(limit: 0) => mark(Icons.remove, scheme.outline, numbers.format(0)),
        _Value(:final limit?) => Text(numbers.format(limit), textAlign: TextAlign.center, style: style),
      };
    }

    Widget segment({required Widget child, required bool first, required bool last}) => ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: first ? BShape.rLg : BShape.rXs,
        bottom: last ? BShape.rLg : BShape.rXs,
      ),
      child: ColoredBox(
        color: scheme.surfaceContainer,
        child: Padding(padding: const EdgeInsets.all(BSpace.s12), child: child),
      ),
    );

    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        segment(
          first: true,
          last: false,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final plan in plans)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: BSpace.s4 / 2),
                      child: heading(plan),
                    ),
                  ),
              ],
            ),
          ),
        ),
        for (final (i, (icon, label, of)) in rows.indexed) ...[
          const SizedBox(height: BSpace.tileGap),
          segment(
            first: false,
            last: i == rows.length - 1,
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: BSpace.s4),
                    child: Row(
                      children: [
                        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
                        const SizedBox(width: BSpace.s8),
                        Expanded(
                          child: Text(
                            label,
                            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: BSpace.s8),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final plan in plans)
                          column(
                            value(plan, of(plan.limits)),
                            padding: const EdgeInsets.symmetric(horizontal: BSpace.s4, vertical: BSpace.s8),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: BSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(BSpace.s16, 0, BSpace.s16, BSpace.s8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titled) ...[
                  Text(l10n.planCompare, style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary)),
                  const SizedBox(height: BSpace.s4),
                ],
                Text(
                  l10n.planCompareHelp,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              // Padding of the segments, then each plan's narrowest column.
              final needed = 2 * BSpace.s12 + plans.length * _minColumn * scale;
              if (needed <= constraints.maxWidth) return card;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(BSpace.s16, 0, BSpace.s16, BSpace.s8),
                    child: Text(
                      l10n.planCompareScroll,
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(width: needed, child: card),
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

/// A plan's value for one row: a limit (null for no limit) or whether
/// something is included.
class _Value {
  const _Value.limit(this.limit) : included = null;
  const _Value.included(bool this.included) : limit = null;

  final int? limit;
  final bool? included;
}
