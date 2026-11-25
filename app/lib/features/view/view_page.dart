import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/layout.dart';
import '../../ui/money.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/menu_chip.dart';
import '../expense/expense_detail_page.dart';
import '../group/balances.dart';
import '../group/expenses_tab.dart';
import '../group/group_page.dart';
import '../group/spending_tab.dart';

/// A group as its view-only link shows it, to anyone with the link: no
/// account, member or way to change anything.
class ViewPage extends ConsumerWidget {
  const ViewPage({super.key, required this.token});

  /// The link's own token, not the group's.
  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watchCurrent(viewProvider(token));
    final view = async.value;
    if (view == null) {
      final Widget body;
      if (async.hasError && !async.isLoading) {
        final error = async.error!;
        final code = error is ApiException ? error.code : null;
        body = switch (code) {
          // The server's own answer: a 404 from a proxy says nothing of the link.
          'not_found' => EmptyState(
            icon: Icons.link_off,
            title: l10n.viewMissingTitle,
            body: l10n.viewMissingBody,
          ),
          'view_link_expired' => EmptyState(
            icon: Icons.timer_off_outlined,
            title: l10n.viewExpiredTitle,
            body: l10n.viewExpiredBody,
          ),
          'view_link_paused' => EmptyState(
            icon: Icons.pause_circle_outline,
            title: l10n.viewPausedTitle,
            body: l10n.viewPausedBody,
          ),
          _ => EmptyState(
            icon: Icons.cloud_off_outlined,
            title: l10n.groupsUnreachableTitle,
            body: errorMessage(l10n, error),
            action: FilledButton.tonal(
              onPressed: () => ref.invalidate(viewProvider(token)),
              child: Text(l10n.commonRetry),
            ),
          ),
        };
      } else {
        body = const CircularProgressIndicator();
      }
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(padding: const EdgeInsets.all(BSpace.s16), child: body),
        ),
      );
    }
    final group = view.asGroup(token);
    return GroupTheme(
      group: group,
      child: _View(token: token, view: view, group: group),
    );
  }
}

class _View extends ConsumerWidget {
  const _View({required this.token, required this.view, required this.group});

  final String token;
  final ViewGroup view;

  /// [view] in the shape the group's own widgets take.
  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final show = view.show;
    final tabs = [
      if (show.expenses) (label: l10n.tabExpenses, key: 'expenses'),
      if (show.spending) (label: l10n.statsTitle, key: 'spending'),
    ];
    final title = [?view.emoji, view.name].join(' ');

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            // Pulling down needs a touch screen.
            IconButton(
              tooltip: l10n.viewRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(viewProvider(token)),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final side = math.max(BSpace.s16, (constraints.maxWidth - contentMaxWidth) / 2);
            final header = <Widget>[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(side, BSpace.s4, side, BSpace.s8),
                sliver: SliverToBoxAdapter(child: _Banner(view: view)),
              ),
              if (show.balances)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(side, 0, side, BSpace.s8),
                  sliver: SliverToBoxAdapter(
                    child: _Balances(view: view, group: group),
                  ),
                ),
            ];
            Widget tab(String key) => switch (key) {
              'expenses' => _Expenses(token: token, group: group, sidePadding: side),
              _ => _Spending(token: token, group: group, sidePadding: side, canShow: show.expenses),
            };

            if (tabs.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => ref.refresh(viewProvider(token).future),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    ...header,
                    const SliverToBoxAdapter(child: SizedBox(height: BSpace.s32)),
                  ],
                ),
              );
            }
            return NestedScrollView(
              headerSliverBuilder: (context, _) => [
                ...header,
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  // The tabs' content looks for what this takes up, even when nothing.
                  sliver: tabs.length < 2
                      ? const SliverToBoxAdapter(child: SizedBox.shrink())
                      : SliverPersistentHeader(
                          pinned: true,
                          delegate: TabsHeader(
                            color: Theme.of(context).colorScheme.surface,
                            padding: side,
                            tabs: TabBar(tabs: [for (final t in tabs) Tab(text: t.label)]),
                          ),
                        ),
                ),
              ],
              body: tabs.length < 2
                  ? tab(tabs.single.key)
                  : TabBarView(children: [for (final t in tabs) tab(t.key)]),
            );
          },
        ),
      ),
    );
  }
}

/// Says the page only shows the group, and whether it is kept up to date.
class _Banner extends StatelessWidget {
  const _Banner({required this.view});

  final ViewGroup view;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = switch (view.asOf) {
      final at? when !view.live => l10n.viewOnlyAsOf(DateFormat.yMMMd(locale).add_jm().format(at.toLocal())),
      _ => l10n.viewOnlyLive,
    };
    return Row(
      children: [
        Icon(view.live ? Icons.visibility_outlined : Icons.history, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: BSpace.s8),
        Expanded(
          child: Text(label, style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
        ),
      ],
    );
  }
}

/// Everyone's balance and the payments that would settle them, to read only.
class _Balances extends StatelessWidget {
  const _Balances({required this.view, required this.group});

  final ViewGroup view;
  final Group group;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    String money(BigInt v, {bool signed = false}) =>
        formatMoney(context, v, group.minorDigits, group.currency, signed: signed, symbol: group.symbol);
    // Members who left stay while they still owe or are owed something.
    final members = [
      for (final m in group.members)
        if (!m.left || m.balance != BigInt.zero) m,
    ];
    final largest = members.fold(BigInt.zero, (a, m) => m.balance.abs() > a ? m.balance.abs() : a);

    return Material(
      color: scheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.xl))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s12, BSpace.s16, BSpace.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BSpace.s4),
              child: Text(l10n.viewBalances, style: text.labelLarge?.copyWith(color: scheme.primary)),
            ),
            for (final m in members)
              BalanceBeam(
                member: m,
                isMe: false,
                net: m.balance,
                largest: largest,
                amount: money(m.balance, signed: true),
              ),
            if (view.transfers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(BSpace.s4, BSpace.s12, BSpace.s4, BSpace.s8),
                child: Text(l10n.suggestedPayments, style: text.labelLarge?.copyWith(color: scheme.primary)),
              ),
              for (final t in view.transfers)
                if ((group.member(t.from), group.member(t.to)) case (final from?, final to?))
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: BSpace.s4),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MemberAvatar(member: from, size: 32),
                        Icon(Icons.arrow_forward, size: 18, color: scheme.onSurfaceVariant),
                        MemberAvatar(member: to, size: 32),
                      ],
                    ),
                    title: Text(
                      l10n.transferPays(from.name, to.name),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(money(t.amount), style: text.moneyRow),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The expenses the link shows, newest first, with the group's own filters.
class _Expenses extends ConsumerWidget {
  const _Expenses({required this.token, required this.group, required this.sidePadding});

  final String token;
  final Group group;
  final double sidePadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final side = sidePadding;
    final provider = viewExpensesProvider(token);
    final async = ref.watchCurrent(provider);
    final filterKey = viewFilterKey(token);
    final filter = ref.watch(expenseFilterProvider(filterKey));
    final list = async.value;
    // Shown while the list for a new filter loads, or failed to.
    final stale = list != null && list.filter != filter;

    Widget retry(Object error) => EmptyState(
      icon: Icons.cloud_off_outlined,
      title: l10n.groupsUnreachableTitle,
      body: errorMessage(l10n, error),
      action: FilledButton.tonal(onPressed: () => ref.invalidate(provider), child: Text(l10n.commonRetry)),
    );
    Widget fill(Widget child) => SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s48, BSpace.s16, BSpace.s16),
        child: Center(child: child),
      ),
    );

    final List<Widget> slivers;
    if (list == null) {
      slivers = [
        fill(async.hasError && !async.isLoading ? retry(async.error!) : const CircularProgressIndicator()),
      ];
    } else if (list.items.isEmpty && list.filter.isEmpty && filter.isEmpty) {
      slivers = [
        fill(
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: l10n.expensesEmptyTitle,
            body: l10n.viewEmptyBody,
          ),
        ),
      ];
    } else {
      final rows = ExpensesTab.withDays(list.items);
      slivers = [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(side, BSpace.s12, side, 0),
          sliver: SliverToBoxAdapter(child: ExpenseFilterBar(group: group)),
        ),
        if (stale && async.isLoading)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(side, BSpace.s8, side, 0),
            sliver: const SliverToBoxAdapter(child: LinearProgressIndicator()),
          ),
        if (stale && async.hasError && !async.isLoading)
          fill(retry(async.error!))
        else if (list.items.isEmpty)
          fill(
            EmptyState(
              icon: Icons.search_off,
              title: l10n.expensesNoMatchTitle,
              body: l10n.expensesNoMatchBody,
              action: FilledButton.tonal(
                onPressed: () =>
                    ref.read(expenseFilterProvider(filterKey).notifier).set(const ExpenseFilter()),
                child: Text(l10n.filterClear),
              ),
            ),
          )
        else ...[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(side, 0, side, BSpace.s8),
            sliver: SliverList.builder(
              itemCount: rows.length,
              itemBuilder: (context, i) {
                if (list.hasMore && !stale && !async.isLoading && i >= rows.length - 5) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(provider.notifier).loadMore());
                }
                return switch (rows[i]) {
                  final DateTime day => DateHeader(day: day),
                  final Expense e => ExpenseTile(
                    expense: e,
                    group: group,
                    me: null,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => _ExpensePage(token: token, group: group, expense: e),
                      ),
                    ),
                  ),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
          ),
          if (list.loadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(BSpace.s16),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (list.moreError case final error?)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(BSpace.s16),
                child: Column(
                  children: [
                    Text(errorMessage(l10n, error), textAlign: TextAlign.center),
                    const SizedBox(height: BSpace.s8),
                    FilledButton.tonal(
                      onPressed: () => ref.read(provider.notifier).loadMore(retry: true),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: BSpace.s32)),
        ],
      ];
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(viewProvider(token).future),
      child: Builder(
        builder: (context) => CustomScrollView(
          key: const PageStorageKey('expenses'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            ...slivers,
          ],
        ),
      ),
    );
  }
}

/// What the group spent, as on its own spending tab.
class _Spending extends ConsumerStatefulWidget {
  const _Spending({
    required this.token,
    required this.group,
    required this.sidePadding,
    required this.canShow,
  });

  final String token;
  final Group group;
  final double sidePadding;

  /// Whether the link shows expenses, so a row can list those behind it.
  final bool canShow;

  @override
  ConsumerState<_Spending> createState() => _SpendingState();
}

class _SpendingState extends ConsumerState<_Spending> {
  Period? _period;

  /// The last stats shown, kept on screen while another period loads.
  GroupStats? _shown;

  void _showExpenses(ExpenseFilter filter) {
    ref
        .read(expenseFilterProvider(viewFilterKey(widget.token)).notifier)
        .set(filter.copyWith(period: () => _period));
    DefaultTabController.of(context).animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final side = widget.sidePadding;
    final provider = viewStatsProvider((token: widget.token, period: _period));
    final async = ref.watchCurrent(provider);
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
                    onPressed: () => ref.invalidate(provider),
                    child: Text(l10n.commonRetry),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      );
    } else {
      body = AnimatedOpacity(
        opacity: async.value == null ? 0.5 : 1,
        duration: BMotion.short,
        child: StatsBody(group: widget.group, stats: stats, onShow: widget.canShow ? _showExpenses : null),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(viewProvider(widget.token).future),
      child: Builder(
        builder: (context) => CustomScrollView(
          key: const PageStorageKey('spending'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(side, BSpace.s16, side, BSpace.s32),
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
                        TextButton(onPressed: () => ref.invalidate(provider), child: Text(l10n.commonRetry)),
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
      ),
    );
  }
}

/// One expense of the link, to read only.
class _ExpensePage extends ConsumerWidget {
  const _ExpensePage({required this.token, required this.group, required this.expense});

  final String token;
  final Group group;
  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) => GroupTheme(
    group: group,
    child: Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = math.max(BSpace.s16, (constraints.maxWidth - contentMaxWidth) / 2);
          return ListView(
            padding: EdgeInsets.fromLTRB(side, BSpace.s8, side, BSpace.s32),
            children: [
              ExpenseDetails(
                group: group,
                expense: expense,
                me: null,
                receipt: expense.hasReceipt
                    ? ref.watchCurrent(viewReceiptProvider((token: token, id: expense.id)))
                    : null,
              ),
            ],
          );
        },
      ),
    ),
  );
}
