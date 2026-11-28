import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../data/models/billing.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/grouped_list.dart';

/// One thing to buy, from a store or PayPal.
class PlanChoice {
  const PlanChoice({
    required this.id,
    required this.planName,
    required this.subscription,
    required this.days,
    required this.buy,
    this.period,
    this.price,
    this.note,
  });

  final String id;
  final String planName;

  /// Whether it charges again by itself.
  final bool subscription;

  /// About how long one payment lasts, for ordering; 0 when unknown.
  final int days;

  /// How long one payment lasts, in words.
  final String? period;

  /// What one payment costs; null when only the checkout page says.
  final String? price;

  /// How it is charged.
  final String? note;

  final VoidCallback buy;
}

/// [months] in words, with whole years as years.
String planMonthsLabel(AppLocalizations l10n, int months) =>
    months % 12 == 0 ? l10n.planPeriodYears(months ~/ 12) : l10n.planPeriodMonths(months);

/// [choices] with each plan's together, in the order the plans first appear,
/// and the longest first.
List<PlanChoice> sortedChoices(List<PlanChoice> choices) {
  final plans = [...{for (final c in choices) c.planName}];
  return [...choices]..sort((a, b) {
    final byPlan = plans.indexOf(a.planName).compareTo(plans.indexOf(b.planName));
    return byPlan != 0 ? byPlan : b.days.compareTo(a.days);
  });
}

/// The plan to show the benefits of: the one being bought when its name says
/// which, and otherwise the lowest that gives more than the current one. The
/// plans everyone gets without paying are never it.
Plan? planTarget(PlanComparisonData? comparison, String? buying) {
  if (comparison == null) return null;
  final current = comparison.plans.where((p) => p.id == comparison.currentPlanId).firstOrNull;
  if (current == null) return null;
  final free = {comparison.currentPlanId, comparison.unverifiedPlanId, comparison.verifiedPlanId};
  final paid = [
    for (final plan in comparison.plans)
      if (!free.contains(plan.id)) plan,
  ];
  return paid.where((p) => p.name == buying).firstOrNull ??
      paid.where((p) => _gains(current.limits, p.limits).isNotEmpty).firstOrNull;
}

enum _Limit { reminders, viewLink, receipts, recurring, members, joinedGroups }

/// What [to] allows beyond [from], with what it newly includes first.
List<(_Limit, int?, int?)> _gains(PlanLimits from, PlanLimits to) {
  bool more(int? a, int? b) => a != null && (b == null || b > a);
  return [
    if (to.reminders && !from.reminders) (_Limit.reminders, null, null),
    if (to.viewLink && !from.viewLink) (_Limit.viewLink, null, null),
    if (more(from.receiptsPerGroup, to.receiptsPerGroup))
      (_Limit.receipts, from.receiptsPerGroup, to.receiptsPerGroup),
    if (more(from.recurringPerGroup, to.recurringPerGroup))
      (_Limit.recurring, from.recurringPerGroup, to.recurringPerGroup),
    if (more(from.membersPerGroup, to.membersPerGroup)) (_Limit.members, from.membersPerGroup, to.membersPerGroup),
    if (more(from.joinedGroups, to.joinedGroups)) (_Limit.joinedGroups, from.joinedGroups, to.joinedGroups),
  ];
}

/// Why to get a plan: that one person's covers a whole group.
class PlanHero extends StatelessWidget {
  const PlanHero({super.key, this.target});

  final Plan? target;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shared = target?.limits.sponsoredGroups;
    final shares = target != null && shared != 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s8, BSpace.s16, BSpace.s24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
            child: Icon(
              shares ? Icons.groups_outlined : Icons.workspace_premium_outlined,
              size: 32,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: BSpace.s16),
          Semantics(
            header: true,
            child: Text(
              shares ? l10n.planHeroShare : l10n.planHeroTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (shares) ...[
            const SizedBox(height: BSpace.s8),
            Text(
              shared == null ? l10n.planHeroShareUnlimited : l10n.planHeroShareCount(shared),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

/// What [target] adds to the current plan. Nothing when it adds nothing.
class PlanBenefits extends StatelessWidget {
  const PlanBenefits({super.key, required this.comparison, required this.target});

  final PlanComparisonData comparison;
  final Plan target;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final numbers = NumberFormat.decimalPattern(Localizations.localeOf(context).toLanguageTag());
    final current = comparison.plans.firstWhere((p) => p.id == comparison.currentPlanId);
    final gains = _gains(current.limits, target.limits);
    if (gains.isEmpty) return const SizedBox.shrink();
    String number(int? n) => n == null ? l10n.planUnlimited : numbers.format(n);
    return GroupedList(
      title: l10n.planBenefits(target.name),
      children: [
        for (final (limit, from, to) in gains)
          MergeSemantics(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: BSpace.s16),
              leading: Icon(switch (limit) {
                _Limit.reminders => Icons.notifications_active_outlined,
                _Limit.viewLink => Icons.visibility_outlined,
                _Limit.receipts => Icons.receipt_outlined,
                _Limit.recurring => Icons.repeat,
                _Limit.members => Icons.groups_outlined,
                _Limit.joinedGroups => Icons.group_outlined,
              }, color: theme.colorScheme.primary),
              title: Text(switch (limit) {
                _Limit.reminders => l10n.planLimitReminders,
                _Limit.viewLink => l10n.planLimitViewLink,
                _Limit.receipts => l10n.planLimitReceipts,
                _Limit.recurring => l10n.planLimitRecurring,
                _Limit.members => l10n.planLimitMembers,
                _Limit.joinedGroups => l10n.planLimitJoinedGroups,
              }),
              // Under the name, so long names and numbers both have room.
              subtitle: from == null
                  ? null
                  : Text(
                      '${number(from)} → ${number(to)}',
                      // Numbers read from the old to the new in every language.
                      textDirection: TextDirection.ltr,
                      textAlign: Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
              trailing: from == null
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary, semanticLabel: l10n.planIncluded)
                  : null,
            ),
          ),
      ],
    );
  }
}

/// A [PlanChoice] to pick, with its price at the end.
class PlanChoiceCard extends StatelessWidget {
  const PlanChoiceCard({
    super.key,
    required this.choice,
    required this.selected,
    required this.onTap,
    this.showPlan = false,
  });

  final PlanChoice choice;
  final bool selected;
  final VoidCallback onTap;

  /// Whether the plan's name tells the choices apart.
  final bool showPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final period = choice.period;
    final title = period == null
        ? choice.planName
        : showPlan
        ? '${choice.planName} · $period'
        : period;
    final color = selected ? scheme.onSecondaryContainer : scheme.onSurface;
    const radius = BorderRadius.all(Radius.circular(BShape.md));
    return Padding(
      padding: const EdgeInsets.only(bottom: BSpace.s8),
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: selected,
        child: Material(
          color: selected ? scheme.secondaryContainer : scheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: selected ? scheme.primary : Colors.transparent, width: 2),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.all(BSpace.s16),
              child: Row(
                children: [
                  Icon(
                    selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: BSpace.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleMedium?.copyWith(color: color)),
                        if (choice.note case final note?)
                          Text(note, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (choice.price case final price?) ...[
                    const SizedBox(width: BSpace.s12),
                    Text(
                      price,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A row that shows or hides [child] under it.
class PlanFold extends StatelessWidget {
  const PlanFold({
    super.key,
    required this.icon,
    required this.title,
    required this.open,
    required this.onToggle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final bool open;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          expanded: open,
          child: GroupedList(
            children: [
              GroupedTile(
                icon: icon,
                title: title,
                trailing: Icon(open ? Icons.expand_less : Icons.expand_more),
                onTap: onToggle,
              ),
            ],
          ),
        ),
        if (open) child,
      ],
    );
  }
}
