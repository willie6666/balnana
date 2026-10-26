import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/categories.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/colors.dart';
import '../../ui/money.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import 'group_page.dart';

class ExpensesTab extends ConsumerWidget {
  const ExpensesTab({super.key, required this.group, required this.sidePadding});

  final Group group;
  final double sidePadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(expensesProvider(group.token));
    final list = async.value;
    final me = myMemberId(ref, group.token);

    final List<Widget> slivers;
    if (list == null) {
      slivers = [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: async.hasError && !async.isLoading
                ? EmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: l10n.groupsUnreachableTitle,
                    body: errorMessage(l10n, async.error!),
                    action: FilledButton.tonal(
                      onPressed: () => ref.invalidate(expensesProvider(group.token)),
                      child: Text(l10n.commonRetry),
                    ),
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      ];
    } else if (list.items.isEmpty) {
      slivers = [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(BSpace.s16),
            child: Center(
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.expensesEmptyTitle,
                body: l10n.expensesEmptyBody,
              ),
            ),
          ),
        ),
      ];
    } else {
      final rows = _rows(list.items);
      slivers = [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(sidePadding, BSpace.s8, sidePadding, BSpace.s8),
          sliver: SliverList.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              if (list.hasMore && i >= rows.length - 5) {
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
  const CategoryIcon({super.key, required this.expense, this.size = 44});

  final Expense expense;
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
    final category = Category.byId(expense.categoryId) ?? Category.other;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.alphaBlend(category.color.withValues(alpha: 0.25), scheme.surface),
        shape: BoxShape.circle,
      ),
      child: Text(category.emoji, style: TextStyle(fontSize: size * 0.48)),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense, required this.group, required this.me, this.onTap});

  final Expense expense;
  final Group group;
  final String? me;
  final VoidCallback? onTap;

  String _name(AppLocalizations l10n, String id) => group.member(id)?.name ?? l10n.someone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final c = context.bColors;
    String money(BigInt v) => formatMoney(context, v, group.minorDigits, group.currency);

    final e = expense;
    final String title, subtitle;
    if (e.isPayment) {
      final from = _name(l10n, e.payers.first.memberId), to = _name(l10n, e.splits.first.memberId);
      title = l10n.paymentTitle(from, to);
      subtitle = money(e.amount);
    } else {
      title = e.title;
      subtitle = e.payers.length == 1
          ? l10n.expensePaidBy(_name(l10n, e.payers.first.memberId), money(e.amount))
          : l10n.expensePaidByMany(e.payers.length, money(e.amount));
    }

    // What it means for this device's member.
    String? effect;
    Color? effectColor;
    if (me != null) {
      final paid = e.paidBy(me!), owed = e.owedBy(me!), net = paid - owed;
      if (e.isPayment) {
        if (paid > BigInt.zero) (effect, effectColor) = (l10n.effectYouPaid(money(paid)), c.owed);
        if (owed > BigInt.zero) (effect, effectColor) = (l10n.effectYouReceived(money(owed)), c.owe);
      } else if (net > BigInt.zero) {
        (effect, effectColor) = (l10n.effectYouLent(money(net)), c.owed);
      } else if (net < BigInt.zero) {
        (effect, effectColor) = (l10n.effectYouBorrowed(money(-net)), c.owe);
      } else {
        (effect, effectColor) = (paid > BigInt.zero ? l10n.effectEven : l10n.effectNotInvolved, c.settled);
      }
    }

    return Material(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.md))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: BSpace.s12, vertical: BSpace.s8),
          child: Row(
            children: [
              CategoryIcon(expense: e),
              const SizedBox(width: BSpace.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      subtitle,
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: BSpace.s8),
              if (effect != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    effect,
                    textAlign: TextAlign.end,
                    style: text.labelLarge?.copyWith(color: effectColor),
                  ),
                )
              else
                Text(money(e.amount), style: text.moneyRow),
            ],
          ),
        ),
      ),
    );
  }
}

/// Details of a recorded payment, with a way to delete it.
Future<void> showPaymentSheet(BuildContext context, Group group, Expense payment) => showModalBottomSheet<void>(
  context: context,
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
            CategoryIcon(expense: payment, size: 56),
            const SizedBox(height: BSpace.s16),
            Text(l10n.paymentTitle(from, to), style: text.titleLarge, textAlign: TextAlign.center),
            Text(
              formatMoney(context, payment.amount, group.minorDigits, group.currency),
              style: text.moneyHero.copyWith(fontSize: 36),
            ),
            Text(DateFormat.yMMMEd(locale).format(payment.occurredAt.toLocal()), style: text.bodyMedium),
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

/// Deletes [expense] and offers to bring it back.
Future<void> deleteExpenseWithUndo(BuildContext context, WidgetRef ref, Group group, Expense expense) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  // The page that asked may be gone by the time someone taps Undo.
  final container = ProviderScope.containerOf(context, listen: false);
  final api = groupApiOf(ref, group.token);
  try {
    await api.deleteExpense(expense.id);
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
    return;
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
}
