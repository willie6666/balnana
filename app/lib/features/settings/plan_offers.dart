import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../data/models/billing.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/grouped_list.dart';

/// Who takes a payment that isn't the app store's.
enum PlanProvider { paypal, kofi }

/// One thing to buy, from a store, PayPal or Ko-fi.
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
    this.provider,
    this.priceNote,
  });

  final String id;
  final String planName;

  /// Whether it charges again by itself.
  final bool subscription;

  /// About how long one payment lasts, for ordering; 0 when unknown.
  final int days;

  /// How long one payment lasts, in words.
  final String? period;

  /// What one payment costs; null when only the checkout page says, as
  /// [priceNote] then tells.
  final String? price;
  final String? priceNote;

  /// How it is charged.
  final String? note;

  final VoidCallback buy;

  /// Null for the app store's.
  final PlanProvider? provider;
}

/// What PayPal and Ko-fi sell, as choices.
List<PlanChoice> externalChoices(
  AppLocalizations l10n, {
  required List<PayPalOffer> paypal,
  required List<KofiOffer> kofi,
  required void Function(PayPalOffer) buyPayPal,
  required VoidCallback openKofi,
}) => [
  for (final offer in paypal)
    PlanChoice(
      id: 'paypal:${offer.product}',
      provider: PlanProvider.paypal,
      planName: offer.planName,
      subscription: offer.subscription,
      days: offer.days,
      period: l10n.planPayPalDays(offer.days),
      price: offer.price,
      priceNote: l10n.planPriceAtPayPal,
      note: offer.subscription ? l10n.planAutoRenews : l10n.planOnceNote,
      buy: () => buyPayPal(offer),
    ),
  for (final offer in kofi)
    PlanChoice(
      id: 'kofi:${offer.planName}:${offer.days}',
      provider: PlanProvider.kofi,
      planName: offer.planName,
      subscription: false,
      days: offer.days,
      period: l10n.planPayPalDays(offer.days),
      price: offer.price,
      priceNote: l10n.planPriceAtKofi,
      note: l10n.planOnceNote,
      buy: openKofi,
    ),
];

/// [months] in words, with whole years as years.
String planMonthsLabel(AppLocalizations l10n, int months) =>
    months % 12 == 0 ? l10n.planPeriodYears(months ~/ 12) : l10n.planPeriodMonths(months);

/// [choices] with each plan's together, in the order the plans first appear,
/// and the longest first.
List<PlanChoice> sortedChoices(List<PlanChoice> choices) {
  final plans = [...{for (final c in choices) c.planName}];
  // Equals keep their order, so PayPal's stays on the same side of each pair.
  final sorted = [...choices.indexed]..sort((a, b) {
    final byPlan = plans.indexOf(a.$2.planName).compareTo(plans.indexOf(b.$2.planName));
    if (byPlan != 0) return byPlan;
    final byDays = b.$2.days.compareTo(a.$2.days);
    return byDays != 0 ? byDays : a.$1.compareTo(b.$1);
  });
  return [for (final (_, choice) in sorted) choice];
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

/// The [choices] to pick from, two side by side where there is room. A plan
/// with an odd number of them gives its first a row of its own.
class PlanChoiceGrid extends StatelessWidget {
  const PlanChoiceGrid({super.key, required this.choices, required this.selected, required this.onSelect});

  /// In the order of [sortedChoices].
  final List<PlanChoice> choices;
  final String? selected;
  final ValueChanged<PlanChoice> onSelect;

  /// The narrowest a card beside another gets, at the default text size.
  static const _minColumn = 140.0;

  @override
  Widget build(BuildContext context) {
    final plans = {for (final c in choices) c.planName};
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    Widget card(PlanChoice choice, {bool narrow = false}) => PlanChoiceCard(
      choice: choice,
      selected: choice.id == selected,
      showPlan: plans.length > 1,
      narrow: narrow,
      onTap: () => onSelect(choice),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final paired = constraints.maxWidth >= 2 * _minColumn * scale + BSpace.s8;
        final rows = <Widget>[];
        for (final plan in plans) {
          var left = [...choices.where((c) => c.planName == plan)];
          if (!paired || left.length.isOdd) {
            final alone = paired ? 1 : left.length;
            rows.addAll(left.take(alone).map(card));
            left = left.sublist(alone);
          }
          for (var i = 0; i < left.length; i += 2) {
            rows.add(
              // As tall as each other, however their words wrap.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: card(left[i], narrow: true)),
                    const SizedBox(width: BSpace.s8),
                    Expanded(child: card(left[i + 1], narrow: true)),
                  ],
                ),
              ),
            );
          }
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
      },
    );
  }
}

/// PayPal's choices and Ko-fi's, each in a box of its own that says how it is
/// charged: side by side where there is room.
class PlanProviderBoxes extends StatelessWidget {
  const PlanProviderBoxes({
    super.key,
    required this.choices,
    required this.selected,
    required this.onSelect,
    this.openKofi,
  });

  /// In the order of [sortedChoices].
  final List<PlanChoice> choices;
  final String? selected;
  final ValueChanged<PlanChoice> onSelect;

  /// Gives Ko-fi a box with a way to its page when none of [choices] is its,
  /// for a server that doesn't say what it sells.
  final VoidCallback? openKofi;

  /// The narrowest a box beside another gets, at the default text size.
  static const _minBox = 156.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showPlan = {for (final c in choices) c.planName}.length > 1;
    final paypal = [...choices.where((c) => c.provider == PlanProvider.paypal)];
    final kofi = [...choices.where((c) => c.provider == PlanProvider.kofi)];
    final two = paypal.isNotEmpty && (kofi.isNotEmpty || openKofi != null);
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return LayoutBuilder(
      builder: (context, constraints) {
        final beside = two && constraints.maxWidth >= 2 * _minBox * scale + BSpace.s8;
        Widget box(String title, List<PlanChoice> own, {VoidCallback? open}) {
          // Said once for the box when all its choices are charged alike.
          final notes = {for (final c in own) c.note};
          final shared = notes.length == 1 ? notes.single : null;
          return _ProviderBox(
            title: title,
            description: shared,
            // Both boxes' choices line up, however long their descriptions.
            alignEnd: beside && paypal.length == kofi.length,
            children: [
              for (final choice in own)
                PlanChoiceCard(
                  choice: choice,
                  selected: choice.id == selected,
                  showPlan: showPlan,
                  showNote: shared == null,
                  narrow: beside,
                  inBox: true,
                  onTap: () => onSelect(choice),
                ),
              if (own.isEmpty && open != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: BSpace.s8),
                  child: OutlinedButton(onPressed: open, child: Text(l10n.planKofiBuy, textAlign: TextAlign.center)),
                ),
            ],
          );
        }

        final boxes = [
          if (paypal.isNotEmpty) box('PayPal', paypal),
          if (kofi.isNotEmpty || openKofi != null)
            box(l10n.planKofi, kofi, open: openKofi),
        ];
        return Padding(
          padding: const EdgeInsets.only(bottom: BSpace.s8),
          child: beside
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: boxes.first),
                      const SizedBox(width: BSpace.s8),
                      Expanded(child: boxes.last),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: BSpace.s8,
                  children: boxes,
                ),
        );
      },
    );
  }
}

class _ProviderBox extends StatelessWidget {
  const _ProviderBox({
    required this.title,
    required this.description,
    required this.alignEnd,
    required this.children,
  });

  final String title;
  final String? description;

  /// Puts [children] at the bottom of a box stretched taller than they need.
  final bool alignEnd;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final small = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: const BorderRadius.all(BShape.rLg),
      ),
      child: Padding(
        // The cards bring their own space below.
        padding: const EdgeInsets.fromLTRB(BSpace.s8, BSpace.s12, BSpace.s8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BSpace.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  if (description case final description?) ...[
                    const SizedBox(height: BSpace.s4),
                    Text(description, style: small),
                  ],
                ],
              ),
            ),
            const SizedBox(height: BSpace.s12),
            if (alignEnd) const Spacer(),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A [PlanChoice] to pick, with its price at the end, or under its name when
/// [narrow].
class PlanChoiceCard extends StatelessWidget {
  const PlanChoiceCard({
    super.key,
    required this.choice,
    required this.selected,
    required this.onTap,
    this.showPlan = false,
    this.narrow = false,
    this.showNote = true,
    this.inBox = false,
  });

  final PlanChoice choice;
  final bool selected;
  final VoidCallback onTap;

  /// Whether the plan's name tells the choices apart.
  final bool showPlan;
  final bool narrow;

  /// Off where the box around it says how it is charged.
  final bool showNote;

  /// Whether it sits on a [PlanProviderBoxes] box, and has to stand out.
  final bool inBox;

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
    final mark = Icon(
      selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      color: selected ? scheme.primary : scheme.onSurfaceVariant,
    );
    final name = Text(title, style: theme.textTheme.titleMedium?.copyWith(color: color));
    final small = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final note = switch (choice.note) {
      final note? when showNote => Text(note, style: small),
      _ => null,
    };
    final Widget? price = switch (choice.price) {
      // Smaller rather than broken in two.
      final price? => FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          price,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
      null => null,
    };
    // Under the name, being longer than a price.
    final priceNote = price == null && choice.priceNote != null ? Text(choice.priceNote!, style: small) : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: BSpace.s8),
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: selected,
        child: Material(
          color: selected
              ? scheme.secondaryContainer
              : inBox
              ? scheme.surface
              : scheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: selected ? scheme.primary : Colors.transparent, width: 2),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsets.all(narrow ? BSpace.s12 : BSpace.s16),
              child: narrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            mark,
                            const SizedBox(width: BSpace.s8),
                            Expanded(child: name),
                          ],
                        ),
                        if (price != null) ...[const SizedBox(height: BSpace.s8), price],
                        if (priceNote != null) ...[const SizedBox(height: BSpace.s8), priceNote],
                        if (note != null) ...[const SizedBox(height: BSpace.s4), note],
                      ],
                    )
                  : Row(
                      children: [
                        mark,
                        const SizedBox(width: BSpace.s16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [name, ?priceNote, ?note],
                          ),
                        ),
                        if (price != null) ...[
                          const SizedBox(width: BSpace.s12),
                          // Leaves the name room on a narrow screen.
                          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 150), child: price),
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
