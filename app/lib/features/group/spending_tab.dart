import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/categories.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/money.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/menu_chip.dart';

/// What a group spent: in total, by category, per person and by month.
class SpendingTab extends ConsumerStatefulWidget {
  const SpendingTab({super.key, required this.group, required this.sidePadding});

  final Group group;
  final double sidePadding;

  @override
  ConsumerState<SpendingTab> createState() => _SpendingTabState();
}

class _SpendingTabState extends ConsumerState<SpendingTab> {
  Period? _period;

  /// The last stats shown, kept on screen while another period loads.
  GroupStats? _shown;

  /// Shows the expenses behind a row of the stats in the expenses tab.
  void _showExpenses(ExpenseFilter filter) {
    ref.read(expenseFilterProvider(widget.group.token).notifier).set(filter.copyWith(period: () => _period));
    DefaultTabController.of(context).animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final group = widget.group;
    final side = widget.sidePadding;
    final async = ref.watchCurrent(statsProvider((token: group.token, period: _period)));
    if (async.value case final stats?) _shown = stats;
    final stats = _shown;

    final Widget body;
    if (stats == null) {
      body = Padding(
        padding: const EdgeInsets.only(top: BSpace.s48),
        child: Center(
          child: async.hasError && !async.isLoading
              ? EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.groupsUnreachableTitle,
                  body: errorMessage(l10n, async.error!),
                  action: FilledButton.tonal(
                    onPressed: () => ref.invalidate(statsProvider),
                    child: Text(l10n.commonRetry),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      );
    } else {
      body = AnimatedOpacity(
        // The last period's numbers, faded, until this one's arrive.
        opacity: async.value == null ? 0.5 : 1,
        duration: BMotion.short,
        child: _StatsBody(group: group, stats: stats, onShow: _showExpenses),
      );
    }

    return Builder(
      builder: (context) => CustomScrollView(
        key: const PageStorageKey('spending'),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            // Room at the end for the floating button.
            padding: EdgeInsets.fromLTRB(side, BSpace.s16, side, 88),
            sliver: SliverList.list(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: PeriodChip(period: _period, onChanged: (p) => setState(() => _period = p)),
                ),
                if (stats != null && async.hasError && !async.isLoading) ...[
                  const SizedBox(height: BSpace.s8),
                  Row(
                    children: [
                      Expanded(child: Text(errorMessage(l10n, async.error!))),
                      TextButton(onPressed: () => ref.invalidate(statsProvider), child: Text(l10n.commonRetry)),
                    ],
                  ),
                ],
                const SizedBox(height: BSpace.s16),
                body,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.group, required this.stats, required this.onShow});

  final Group group;
  final GroupStats stats;
  final ValueChanged<ExpenseFilter> onShow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    String money(BigInt v) => formatMoney(context, v, group.minorDigits, group.currency, symbol: group.symbol);

    final hero = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.statsTotal, style: text.titleMedium?.copyWith(color: scheme.onSurfaceVariant)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(money(stats.total), style: text.displayMedium?.copyWith(fontWeight: FontWeight.w800)),
        ),
        Text(l10n.statsCount(stats.count), style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
      ],
    );
    if (stats.count == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          hero,
          const SizedBox(height: BSpace.s32),
          EmptyState(icon: Icons.insights_outlined, title: l10n.statsEmptyTitle, body: l10n.statsEmptyBody),
        ],
      );
    }

    final biggestCategory = stats.categories.map((c) => c.amount).fold(BigInt.zero, _max);
    final memberAmounts = stats.members.expand((m) => [m.paid, m.share]);
    final biggestMember = memberAmounts.fold(BigInt.zero, _max);
    // One width for every amount, so all the bars share one scale.
    final amountWidth = memberAmounts
        .map((v) => _textWidth(context, money(v), _MemberRow.amountStyle(context)))
        .fold(0.0, math.max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        hero,
        if (stats.months.length > 1) ...[
          const SizedBox(height: BSpace.s24),
          _Section(
            title: l10n.statsByMonth,
            child: _MonthChart(months: stats.months, money: money),
          ),
        ],
        const SizedBox(height: BSpace.s24),
        _Section(
          title: l10n.statsByCategory,
          child: Column(
            children: [
              for (final c in stats.categories)
                _CategoryRow(
                  category: group.category(c.category),
                  amount: money(c.amount),
                  count: c.count,
                  fraction: _fraction(c.amount, biggestCategory),
                  // Expenses without a category cannot be listed on their own.
                  onTap: c.category == null ? null : () => onShow(ExpenseFilter(category: c.category)),
                ),
            ],
          ),
        ),
        const SizedBox(height: BSpace.s24),
        _Section(
          title: l10n.statsByMember,
          trailing: Wrap(
            spacing: BSpace.s12,
            children: [
              _Key(color: scheme.primary, label: l10n.statsPaid),
              _Key(color: scheme.tertiary, label: l10n.statsShare),
            ],
          ),
          child: Column(
            children: [
              for (final m in stats.members)
                if (group.member(m.member) case final member?)
                  _MemberRow(
                    member: member,
                    paid: (money(m.paid), _fraction(m.paid, biggestMember)),
                    share: (money(m.share), _fraction(m.share, biggestMember)),
                    amountWidth: amountWidth,
                    onTap: () => onShow(ExpenseFilter(member: member.id)),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  static BigInt _max(BigInt a, BigInt b) => a > b ? a : b;

  static double _textWidth(BuildContext context, String s, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width.ceilToDouble();
    painter.dispose();
    return width;
  }

  static double _fraction(BigInt v, BigInt max) => max <= BigInt.zero ? 0 : (v / max).clamp(0, 1).toDouble();
}

/// A titled card around one chart.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s16, BSpace.s16, BSpace.s8),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(BShape.rLg)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: BSpace.s12,
            runSpacing: BSpace.s4,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              ?trailing,
            ],
          ),
          const SizedBox(height: BSpace.s12),
          child,
        ],
      ),
    );
  }
}

/// A legend entry: a swatch beside its name.
class _Key extends StatelessWidget {
  const _Key({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(BShape.rXs)),
      ),
      const SizedBox(width: BSpace.s4),
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}

/// A thin bar growing from the start edge, square there and rounded at its end.
class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 8,
    child: FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      // A sliver of a bar still shows that there is something.
      widthFactor: fraction == 0 ? 0 : math.max(fraction, 0.01),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadiusDirectional.horizontal(end: BShape.rXs).resolve(Directionality.of(context)),
        ),
      ),
    ),
  );
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.count,
    required this.fraction,
    this.onTap,
  });

  /// Null for expenses without a category.
  final GroupCategory? category;
  final String amount;
  final int count;
  final double fraction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final c = category;
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(BShape.md)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: BSpace.s8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c == null
                    ? scheme.surfaceContainerHighest
                    : Color.alphaBlend(c.color.withValues(alpha: 0.25), scheme.surface),
                shape: BoxShape.circle,
              ),
              child: c == null
                  ? Icon(Icons.label_off_outlined, size: 18, color: scheme.onSurfaceVariant)
                  : Text(c.emoji, style: const TextStyle(fontSize: 17)),
            ),
            const SizedBox(width: BSpace.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c?.label(l10n) ?? l10n.statsNoCategory,
                          style: text.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: BSpace.s8),
                      Text(amount, style: text.moneySmall),
                    ],
                  ),
                  const SizedBox(height: BSpace.s4),
                  _Bar(fraction: fraction, color: scheme.primary),
                  const SizedBox(height: BSpace.s4),
                  Text(l10n.statsCount(count), style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.paid,
    required this.share,
    required this.amountWidth,
    required this.onTap,
  });

  static TextStyle? amountStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  final Member member;

  /// The amount as shown, and how long its bar is.
  final (String, double) paid, share;
  final double amountWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget line(String label, (String, double) value, Color color) => Padding(
      padding: const EdgeInsets.only(top: BSpace.s4),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(label, style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          Expanded(child: _Bar(fraction: value.$2, color: color)),
          const SizedBox(width: BSpace.s8),
          SizedBox(
            width: amountWidth,
            child: Text(value.$1, style: amountStyle(context), textAlign: TextAlign.end, maxLines: 1),
          ),
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(BShape.md)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: BSpace.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MemberAvatar(member: member, size: 24),
                const SizedBox(width: BSpace.s8),
                Expanded(child: Text(member.name, style: text.titleSmall, overflow: TextOverflow.ellipsis)),
              ],
            ),
            line(l10n.statsPaid, paid, scheme.primary),
            line(l10n.statsShare, share, scheme.tertiary),
          ],
        ),
      ),
    );
  }
}

/// Columns of spending per month. Tapping or hovering a column reads it out
/// above the chart; the latest month is read out at first.
class _MonthChart extends StatefulWidget {
  const _MonthChart({required this.months, required this.money});

  final List<({DateTime month, BigInt amount})> months;
  final String Function(BigInt) money;

  @override
  State<_MonthChart> createState() => _MonthChartState();
}

class _MonthChartState extends State<_MonthChart> {
  DateTime? _picked;

  static const _plotHeight = 140.0;
  static const _slot = 40.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final months = widget.months;
    final picked = months.firstWhere((m) => m.month == _picked, orElse: () => months.last);
    final biggest = months.map((m) => m.amount).fold(BigInt.zero, _StatsBody._max);
    final manyYears = months.first.month.year != months.last.month.year;

    String name(DateTime month, {bool long = false}) {
      if (long) return DateFormat.yMMMM(locale).format(month);
      // Mark where each year starts when the chart spans more than one.
      final first = month.month == 1 || month == months.first.month;
      return manyYears && first ? DateFormat.yMMM(locale).format(month) : DateFormat.MMM(locale).format(month);
    }

    final columns = [
      for (final m in months)
        Semantics(
          button: true,
          selected: m.month == picked.month,
          label: '${name(m.month, long: true)}, ${widget.money(m.amount)}',
          excludeSemantics: true,
          onTap: () => setState(() => _picked = m.month),
          child: InkWell(
            // Hovering picks a month too, so a pointer can sweep across the chart.
            onHover: (hovering) {
              if (hovering) setState(() => _picked = m.month);
            },
            onTap: () => setState(() => _picked = m.month),
            borderRadius: const BorderRadius.all(BShape.rXs),
            child: SizedBox(
              width: _slot,
              child: Column(
                children: [
                  SizedBox(
                    height: _plotHeight,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: BMotion.short,
                        width: 20,
                        height: biggest <= BigInt.zero
                            ? 0
                            : math.max(2, _plotHeight * (m.amount / biggest).clamp(0, 1).toDouble()),
                        decoration: BoxDecoration(
                          color: m.month == picked.month
                              ? scheme.primary
                              : scheme.primary.withValues(alpha: 0.4),
                          borderRadius: const BorderRadius.vertical(top: BShape.rXs),
                        ),
                      ),
                    ),
                  ),
                  // Room for the baseline, drawn once under every column.
                  const SizedBox(height: 1),
                  const SizedBox(height: BSpace.s4),
                  Text(
                    name(m.month),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: text.labelSmall?.copyWith(
                      color: m.month == picked.month ? scheme.onSurface : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name(picked.month, long: true), style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
        Text(widget.money(picked.amount), style: text.moneyRow),
        const SizedBox(height: BSpace.s12),
        LayoutBuilder(
          builder: (context, constraints) {
            Widget withBaseline(Widget row) => Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: _plotHeight,
                  height: 1,
                  child: ColoredBox(color: scheme.outlineVariant),
                ),
                row,
              ],
            );
            if (months.length * _slot <= constraints.maxWidth) {
              return withBaseline(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: columns));
            }
            // Newest at the end, in view first.
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: withBaseline(Row(mainAxisSize: MainAxisSize.min, children: columns)),
            );
          },
        ),
        const SizedBox(height: BSpace.s8),
      ],
    );
  }
}
