import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/settings.dart';
import '../../data/api.dart';
import '../../data/categories.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/colors.dart';
import '../../ui/layout.dart';
import '../../ui/money.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/member_picker.dart';
import '../../ui/widgets/menu_chip.dart';
import 'categories_page.dart';
import 'group_page.dart';

class ExpensesTab extends ConsumerWidget {
  const ExpensesTab({super.key, required this.group, required this.sidePadding});

  final Group group;
  final double sidePadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watchCurrent(expensesProvider(group.token));
    final filter = ref.watch(expenseFilterProvider(group.token));
    final list = async.value;
    final me = myMemberId(ref, group.token);
    // Shown while the list for a new filter loads, or failed to.
    final stale = list != null && list.filter != filter;

    Widget retry(Object error) => EmptyState(
      icon: Icons.cloud_off_outlined,
      title: l10n.groupsUnreachableTitle,
      body: errorMessage(l10n, error),
      action: FilledButton.tonal(
        onPressed: () => ref.invalidate(expensesProvider(group.token)),
        child: Text(l10n.commonRetry),
      ),
    );

    // Fills the rest of the view, or grows past it. Not SliverFillRemaining:
    // it sizes its child by intrinsic height, which EmptyState's width cap
    // throws off, so a long message overflowed.
    Widget fill(Widget child) => SliverLayoutBuilder(
      builder: (context, constraints) => SliverToBoxAdapter(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.max(0, constraints.viewportMainAxisExtent - constraints.precedingScrollExtent),
          ),
          child: Padding(
            padding: const EdgeInsets.all(BSpace.s16),
            child: Center(child: child),
          ),
        ),
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
            body: l10n.expensesEmptyBody,
          ),
        ),
      ];
    } else {
      final bar = SliverPadding(
        padding: EdgeInsets.fromLTRB(sidePadding, BSpace.s12, sidePadding, 0),
        sliver: SliverToBoxAdapter(child: ExpenseFilterBar(group: group)),
      );
      final rows = _rows(list.items);
      slivers = [
        bar,
        if (stale && async.isLoading)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(sidePadding, BSpace.s8, sidePadding, 0),
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
                onPressed: () => ref.read(expenseFilterProvider(group.token).notifier).set(const ExpenseFilter()),
                child: Text(l10n.filterClear),
              ),
            ),
          )
        else ...[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(sidePadding, 0, sidePadding, BSpace.s8),
            sliver: SliverList.builder(
              itemCount: rows.length,
              itemBuilder: (context, i) {
                if (list.hasMore && !stale && !async.isLoading && i >= rows.length - 5) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => ref.read(expensesProvider(group.token).notifier).loadMore(),
                  );
                }
                return switch (rows[i]) {
                  final DateTime day => DateHeader(day: day),
                  final Expense e => ExpenseTile(
                    expense: e,
                    group: group,
                    me: me,
                    onTap: () => e.isPayment
                        ? showPaymentSheet(context, group, e)
                        : context.push('/g/${group.token}/expenses/${e.id}'),
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
                      onPressed: () => ref.read(expensesProvider(group.token).notifier).loadMore(retry: true),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
            ),
          // Room for the floating button.
          const SliverToBoxAdapter(child: SizedBox(height: 88)),
        ],
      ];
    }

    return Builder(
      builder: (context) => CustomScrollView(
        key: const PageStorageKey('expenses'),
        slivers: [SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)), ...slivers],
      ),
    );
  }

  /// Expenses with a date header before each new local day.
  static List<Object> _rows(List<Expense> items) {
    final rows = <Object>[];
    DateTime? day;
    for (final e in items) {
      final local = e.occurredAt.toLocal();
      final d = DateTime(local.year, local.month, local.day);
      if (d != day) rows.add(day = d);
      rows.add(e);
    }
    return rows;
  }
}

/// A search field and chips that narrow the expenses shown.
class ExpenseFilterBar extends ConsumerStatefulWidget {
  const ExpenseFilterBar({super.key, required this.group});

  final Group group;

  @override
  ConsumerState<ExpenseFilterBar> createState() => _ExpenseFilterBarState();
}

class _ExpenseFilterBarState extends ConsumerState<ExpenseFilterBar> {
  late final _search = TextEditingController(text: ref.read(expenseFilterProvider(widget.group.token)).text);
  Timer? _typing;

  @override
  void dispose() {
    _typing?.cancel();
    _search.dispose();
    super.dispose();
  }

  ExpenseFilterNotifier get _notifier => ref.read(expenseFilterProvider(widget.group.token).notifier);

  ExpenseFilter get _filter => ref.read(expenseFilterProvider(widget.group.token));

  /// Searches once typing pauses, rather than for every letter.
  void _typed(String text) {
    _typing?.cancel();
    _typing = Timer(const Duration(milliseconds: 400), () => _notifier.set(_filter.copyWith(text: text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final group = widget.group;
    final filter = ref.watch(expenseFilterProvider(group.token));
    ref.listen(expenseFilterProvider(group.token), (_, next) {
      if (next.text != _search.text) _search.text = next.text;
    });

    final member = group.member(filter.member);
    final category = group.category(filter.category);
    void set(ExpenseFilter f) => _notifier.set(f);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchBar(
          controller: _search,
          hintText: l10n.expensesSearchHint,
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
          leading: const Icon(Icons.search),
          trailing: [
            ListenableBuilder(
              listenable: _search,
              builder: (context, _) => _search.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: l10n.searchClear,
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _typing?.cancel();
                        _search.clear();
                        set(_filter.copyWith(text: ''));
                      },
                    ),
            ),
          ],
          onChanged: _typed,
          onSubmitted: (text) {
            _typing?.cancel();
            set(_filter.copyWith(text: text));
          },
        ),
        const SizedBox(height: BSpace.s8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: BSpace.s8,
            children: [
              MenuChip(
                avatar: member == null ? const Icon(Icons.person_outline) : MemberAvatar(member: member, size: 18),
                label: member?.name ?? l10n.filterAnyone,
                selected: member != null,
                // Too many for a menu: a sheet to search instead.
                onPressed: isCrowd(group.members.length)
                    ? () async {
                        final picked = await pickMember(
                          context,
                          title: l10n.crowdFilterTitle,
                          members: group.members,
                          selected: filter.member,
                          anyone: l10n.filterAnyone,
                        );
                        if (picked != null) set(_filter.copyWith(member: () => picked.id));
                      }
                    : null,
                items: [
                  MenuItemButton(
                    onPressed: () => set(filter.copyWith(member: () => null)),
                    child: Text(l10n.filterAnyone),
                  ),
                  for (final m in group.members)
                    MenuItemButton(
                      leadingIcon: MemberAvatar(member: m, size: 24),
                      onPressed: () => set(filter.copyWith(member: () => m.id)),
                      child: Text(m.name),
                    ),
                ],
              ),
              MenuChip(
                avatar: category != null
                    ? Text(category.emoji)
                    : Icon(filter.payments ? Icons.payments_outlined : Icons.category_outlined),
                label: category?.label(l10n) ?? (filter.payments ? l10n.filterPayments : l10n.filterAnyCategory),
                selected: category != null || filter.payments,
                items: [
                  MenuItemButton(
                    onPressed: () => set(filter.copyWith(category: () => null, payments: false)),
                    child: Text(l10n.filterAnyCategory),
                  ),
                  for (final c in group.offeredCategories(filter.category))
                    MenuItemButton(
                      leadingIcon: Text(c.emoji),
                      onPressed: () => set(filter.copyWith(category: () => c.id, payments: false)),
                      child: Text(c.label(l10n)),
                    ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.payments_outlined),
                    onPressed: () => set(filter.copyWith(category: () => null, payments: true)),
                    child: Text(l10n.filterPayments),
                  ),
                ],
              ),
              PeriodChip(period: filter.period, onChanged: (p) => set(filter.copyWith(period: () => p))),
              if (!filter.isEmpty)
                TextButton(
                  onPressed: () {
                    _typing?.cancel();
                    set(const ExpenseFilter());
                  },
                  child: Text(l10n.filterClear),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class DateHeader extends StatelessWidget {
  const DateHeader({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = switch (today.difference(day).inDays) {
      0 => l10n.dateToday,
      1 => l10n.dateYesterday,
      _ when day.year == today.year => DateFormat.MMMEd(locale).format(day),
      _ => DateFormat.yMMMEd(locale).format(day),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s16, BSpace.s16, BSpace.s8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// A category emoji in a soft circle of the category color, or a payment icon.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.expense, required this.group, this.size = 44});

  final Expense expense;
  final Group group;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (expense.isPayment) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: scheme.tertiaryContainer, shape: BoxShape.circle),
        child: Icon(Icons.payments_outlined, color: scheme.onTertiaryContainer, size: size * 0.5),
      );
    }
    return CategoryBubble(
      category: group.category(expense.categoryId) ?? Category.other.asGroupCategory,
      size: size,
    );
  }
}

class ExpenseTile extends ConsumerWidget {
  const ExpenseTile({super.key, required this.expense, required this.group, required this.me, this.onTap});

  final Expense expense;
  final Group group;
  final String? me;
  final VoidCallback? onTap;

  String _name(AppLocalizations l10n, String id) => group.member(id)?.name ?? l10n.someone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final myShare = ref.watch(settingsProvider.select((s) => s.myShare));
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final c = context.bColors;
    String money(BigInt v) => formatMoney(context, v, group.minorDigits, group.currency, symbol: group.symbol);

    final e = expense;
    final time = DateFormat.jm(Localizations.localeOf(context).toLanguageTag()).format(e.occurredAt.toLocal());
    final paid = me == null ? BigInt.zero : e.paidBy(me!), owed = me == null ? BigInt.zero : e.owedBy(me!);
    final net = paid - owed;
    // Whether the row shows this member's part rather than the whole amount.
    // A payment is all theirs when they are in it.
    final part = myShare && !e.isPayment && net != BigInt.zero;

    // Who paid or received goes on a line of its own, so a phone does not cut
    // it off after the time. Beside the whole amount it needs no amount.
    final String title;
    String? who;
    if (e.isPayment) {
      final from = _name(l10n, e.payers.first.memberId), to = _name(l10n, e.splits.first.memberId);
      title = l10n.paymentTitle(from, to);
    } else if (e.isReceived) {
      title = e.title;
      final type = e.transactionType == 'income' ? l10n.transactionIncome : l10n.transactionRefund;
      final receiver = _name(l10n, e.splits.first.memberId), receivers = e.splits.length;
      final by = switch ((part, receivers)) {
        (true, 1) => l10n.expenseReceivedBy(receiver, money(e.amount)),
        (true, _) => l10n.expenseReceivedByMany(receivers, money(e.amount)),
        (false, 1) => l10n.expenseReceivedByName(receiver),
        (false, _) => l10n.expenseReceivedByManyNames(receivers),
      };
      // Not beside the time, which shares its line with the faces.
      who = '$by · $type';
    } else {
      title = e.title;
      final payer = _name(l10n, e.payers.first.memberId), payers = e.payers.length;
      who = switch ((part, payers)) {
        (true, 1) => l10n.expensePaidBy(payer, money(e.amount)),
        (true, _) => l10n.expensePaidByMany(payers, money(e.amount)),
        (false, 1) => l10n.expensePaidByName(payer),
        (false, _) => l10n.expensePaidByManyNames(payers),
      };
    }

    // Every row shows who paid or received and everyone it was for, under the
    // whole amount or, as settings choose, this member's part of it: green
    // when they lent or paid, red when they borrowed or were paid, gray when
    // they are even or not in it.
    final color = me == null
        ? scheme.onSurface
        : net > BigInt.zero
        ? c.owed
        : net < BigInt.zero
        ? c.owe
        : c.settled;
    final amount = Text(money(part ? net.abs() : e.amount), style: text.moneyRow.copyWith(color: color));

    final muted = text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    Text line(String s) => Text(s, style: muted, maxLines: 1, overflow: TextOverflow.ellipsis);
    final place = e.location;
    // The place comes first and gives way to the time when space runs out.
    final when = Row(
      children: [
        if (place != null) ...[
          Icon(Icons.place_outlined, size: 16, color: scheme.onSurfaceVariant, semanticLabel: l10n.expenseHasLocation),
          const SizedBox(width: BSpace.s4),
          if (place.name case final name?) ...[Flexible(child: line(name)), Text(' · ', style: muted)],
        ],
        Text(time, style: muted, maxLines: 1),
      ],
    );

    return Material(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.md))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: BSpace.s8, vertical: BSpace.s8),
          child: Row(
            children: [
              CategoryIcon(expense: e, group: group),
              const SizedBox(width: BSpace.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The amount shares only the title's line, so the title
                    // keeps most of the row.
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: text.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (e.recurringId != null) ...[
                                const SizedBox(width: BSpace.s4),
                                Icon(
                                  Icons.repeat,
                                  size: 16,
                                  color: scheme.onSurfaceVariant,
                                  semanticLabel: l10n.expenseRecurring,
                                ),
                              ],
                              if (e.hasReceipt) ...[
                                const SizedBox(width: BSpace.s4),
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 16,
                                  color: scheme.onSurfaceVariant,
                                  semanticLabel: l10n.expenseHasReceipt,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: BSpace.s8),
                        amount,
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: when),
                        const SizedBox(width: BSpace.s8),
                        // Shrinks rather than pushing the row past the screen
                        // with many people or large text.
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: WindowSize.of(context) == WindowSize.compact ? 168 : 240,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerEnd,
                            child: _Lending(group, e),
                          ),
                        ),
                      ],
                    ),
                    // Under the faces, so it has the row's whole width.
                    if (who != null) line(who),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Who paid or received and everyone it was for.
class _Lending extends StatelessWidget {
  const _Lending(this.group, this.expense);

  final Group group;
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final e = expense;
    // Money received is the other way round in the ledger: whom it is for
    // "paid" it.
    final (by, to) = e.isReceived ? (e.splits, e.payers) : (e.payers, e.splits);
    final ids = {...by, ...to}.map((p) => p.memberId).toSet();
    List<Member> where(List<ExpensePart> parts) {
      final some = {for (final p in parts) if (p.amount > BigInt.zero) p.memberId};
      return [
        for (final id in ids)
          if (some.contains(id)) ?group.member(id),
      ];
    }

    final lenders = where(by), borrowers = where(to);
    return Semantics(
      label: '${lenders.map((m) => m.name).join(', ')} → ${borrowers.map((m) => m.name).join(', ')}',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Faces(lenders),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BSpace.s4),
              child: Icon(Icons.arrow_forward, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            _Faces(borrowers),
          ],
        ),
      ),
    );
  }
}

/// Up to four people's avatars overlapping, the last one counting the rest.
class _Faces extends StatelessWidget {
  const _Faces(this.members);

  final List<Member> members;

  static const _size = 24.0, _step = 16.0, _most = 4;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shown = members.length > _most ? _most - 1 : members.length;
    final rest = members.length - shown;
    final count = shown + (rest > 0 ? 1 : 0);
    Widget ring(Widget child) => Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(color: scheme.surface, shape: BoxShape.circle),
      child: child,
    );
    return SizedBox(
      width: count == 0 ? 0 : _size + 3 + (count - 1) * _step,
      height: _size + 3,
      child: Stack(
        children: [
          for (var i = 0; i < shown; i++)
            PositionedDirectional(start: i * _step, child: ring(MemberAvatar(member: members[i], size: _size))),
          if (rest > 0)
            PositionedDirectional(
              start: shown * _step,
              child: ring(
                Container(
                  width: _size,
                  height: _size,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: scheme.secondaryContainer, shape: BoxShape.circle),
                  child: Text(
                    '+$rest',
                    style: TextStyle(color: scheme.onSecondaryContainer, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Details of a recorded payment, with a way to delete it.
Future<void> showPaymentSheet(BuildContext context, Group group, Expense payment) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  showDragHandle: true,
  builder: (context) => _PaymentSheet(group: group, payment: payment),
);

class _PaymentSheet extends ConsumerWidget {
  const _PaymentSheet({required this.group, required this.payment});

  final Group group;
  final Expense payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final from = group.member(payment.payers.first.memberId)?.name ?? l10n.someone;
    final to = group.member(payment.splits.first.memberId)?.name ?? l10n.someone;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(BSpace.s24, 0, BSpace.s24, BSpace.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryIcon(expense: payment, group: group, size: 56),
            const SizedBox(height: BSpace.s16),
            Text(l10n.paymentTitle(from, to), style: text.titleLarge, textAlign: TextAlign.center),
            Text(
              formatMoney(context, payment.amount, group.minorDigits, group.currency, symbol: group.symbol),
              style: text.moneyLarge,
            ),
            Text(DateFormat.yMMMEd(locale).add_jm().format(payment.occurredAt.toLocal()), style: text.bodyMedium),
            const SizedBox(height: BSpace.s24),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                deleteExpenseWithUndo(context, ref, group, payment);
              },
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.paymentDelete),
            ),
          ],
        ),
      ),
    );
  }
}

/// Deletes [expense] and offers to bring it back; false when it could not.
Future<bool> deleteExpenseWithUndo(BuildContext context, WidgetRef ref, Group group, Expense expense) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  // The page that asked may be gone by the time someone taps Undo.
  final container = ProviderScope.containerOf(context, listen: false);
  final api = groupApiOf(ref, group.token);
  try {
    await api.deleteExpense(expense.id);
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
    return false;
  }
  refreshGroupIn(container, group.token);
  messenger.showSnackBar(
    SnackBar(
      content: Text(expense.isPayment ? l10n.paymentDeleted : l10n.expenseDeleted(expense.title)),
      action: SnackBarAction(
        label: l10n.commonUndo,
        onPressed: () async {
          try {
            await api.restoreExpense(expense.id, group.minorDigits);
            refreshGroupIn(container, group.token);
          } on ApiException catch (e) {
            messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
          }
        },
      ),
    ),
  );
  return true;
}
