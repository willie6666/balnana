import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/money.dart';
import '../../core/server.dart';
import '../../core/session.dart';
import '../../data/categories.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/layout.dart';
import '../../ui/money.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/form_page.dart';
import '../../ui/widgets/member_avatar.dart';
import '../group/expenses_tab.dart';
import '../group/group_page.dart';
import 'expense_editor_page.dart';
import 'location.dart';
import 'receipt.dart';

/// An expense to read, always its latest version. Changing it is a tap on
/// the edit button away, so a look cannot change it by accident.
class ExpenseDetailPage extends ConsumerStatefulWidget {
  const ExpenseDetailPage({super.key, required this.token, required this.expenseId});

  final String token;
  final String expenseId;

  @override
  ConsumerState<ExpenseDetailPage> createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends ConsumerState<ExpenseDetailPage> {
  bool _busy = false;

  Future<void> _delete(Group group, Expense expense) async {
    final router = GoRouter.of(context);
    setState(() => _busy = true);
    final deleted = await deleteExpenseWithUndo(context, ref, group, expense);
    // Gone already (the user went back): popping now would close another page.
    if (!mounted) return;
    if (deleted) {
      router.pop();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final token = widget.token, id = widget.expenseId;
    final group = ref.watchCurrent(groupProvider(token));
    final expense = ref.watchCurrent(expenseProvider((token: token, id: id)));
    // A row of the list holds the whole expense, so the page shows it at once
    // while the latest version loads.
    final listed = expense.hasValue || expense.hasError
        ? null
        : ref
              .read(expensesProvider(token))
              .current(ref.read(identityProvider))
              .value
              ?.items
              .where((e) => e.id == id)
              .firstOrNull;

    if ((group.value, expense.value ?? listed) case (final g?, final e?)) {
      return GroupTheme(
        group: g,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              if (!e.isPayment && e.editable)
                IconButton(
                  tooltip: l10n.expenseEdit,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: _busy ? null : () => context.push('/g/$token/expenses/$id/edit'),
                ),
              IconButton(
                tooltip: l10n.expenseDelete,
                icon: const Icon(Icons.delete_outline),
                onPressed: _busy ? null : () => _delete(g, e),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => ref.refresh(expenseProvider((token: token, id: id)).future),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final side = math.max(BSpace.s16, (constraints.maxWidth - contentMaxWidth) / 2);
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(side, BSpace.s8, side, BSpace.s32),
                  children: [_Details(group: g, expense: e)],
                );
              },
            ),
          ),
        ),
      );
    }

    final error = group.error ?? expense.error;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: error == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(BSpace.s16),
                child: EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.groupsUnreachableTitle,
                  body: errorMessage(l10n, error),
                  action: FilledButton.tonal(
                    onPressed: () {
                      ref.invalidate(groupProvider(token));
                      ref.invalidate(expenseProvider((token: token, id: id)));
                    },
                    child: Text(l10n.commonRetry),
                  ),
                ),
              ),
      ),
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.group, required this.expense});

  final Group group;
  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final muted = text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    final e = expense, f = e.foreign;
    final me = myMemberId(ref, group.token);
    String money(BigInt v) => formatMoney(context, v, group.minorDigits, group.currency, symbol: group.symbol);
    String name(String id) => group.member(id)?.name ?? l10n.someone;

    final String title;
    if (e.isPayment) {
      title = l10n.paymentTitle(name(e.payers.first.memberId), name(e.splits.first.memberId));
    } else {
      title = e.title;
    }
    final category = e.isPayment ? null : group.category(e.categoryId);
    final type = !e.isReceived
        ? null
        : e.transactionType == 'income'
        ? l10n.transactionIncome
        : l10n.transactionRefund;

    // Money received keeps its reversed roles: see Expense.isReceived.
    final (byLabel, toLabel) = e.isReceived
        ? (l10n.expenseReceivedForLabel, l10n.expenseReceivedByLabel)
        : (l10n.expensePaidByLabel, l10n.expenseSplit);
    final method = switch (e.splitMethod) {
      SplitMethod.equal => l10n.splitEqual,
      SplitMethod.exact => l10n.splitExact,
      SplitMethod.shares => l10n.splitShares,
      SplitMethod.unknown => null,
    };
    final people = [
      for (final m in group.members)
        if (e.splits.any((s) => s.memberId == m.id)) m,
    ];
    final place = e.location;
    final maps = ref.watch(serverInfoProvider.select((i) => i.value?.maps ?? false));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: CategoryIcon(expense: e, group: group, size: 56)),
        const SizedBox(height: BSpace.s12),
        Text(title, style: text.titleLarge, textAlign: TextAlign.center),
        if (category != null || type != null)
          Text(
            [?category?.label(l10n), ?type].join(' · '),
            style: muted,
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: BSpace.s8),
        Text(
          f == null ? money(e.amount) : formatMoney(context, f.amount, f.digits, f.currency),
          style: text.moneyLarge,
          textAlign: TextAlign.center,
        ),
        // What it came to in the group's currency, which the balances use.
        if (f != null) Text(money(e.amount), style: muted, textAlign: TextAlign.center),
        const SizedBox(height: BSpace.s4),
        Text(
          DateFormat.yMMMEd(locale).add_jm().format(e.occurredAt.toLocal()),
          style: muted,
          textAlign: TextAlign.center,
        ),

        if (e.recurringId case final id?) ...[
          const SizedBox(height: BSpace.s16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.repeat),
            title: Text(l10n.recurringFromSchedule),
            subtitle: Text(l10n.recurringOpen),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/g/${group.token}/recurring/$id'),
          ),
        ],

        FormSection(byLabel),
        for (final p in e.payers) _PartRow(group: group, part: p, foreign: f, me: me),

        FormSection(toLabel),
        if (method != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(BSpace.s4, 0, BSpace.s4, BSpace.s8),
            child: Text(method, style: muted),
          ),
        SplitBar(people: people, shares: {for (final s in e.splits) s.memberId: s.amount}),
        for (final s in e.splits) _PartRow(group: group, part: s, foreign: f, me: me),

        if (place != null) ...[
          FormSection(l10n.expenseLocation),
          if (place.name case final name?)
            Row(
              children: [
                Icon(Icons.place_outlined, color: scheme.onSurfaceVariant),
                const SizedBox(width: BSpace.s8),
                Expanded(child: Text(name, style: text.bodyLarge)),
              ],
            ),
          if (place.point case final point?) ...[
            const SizedBox(height: BSpace.s12),
            if (maps)
              ClipRRect(
                borderRadius: BorderRadius.circular(BShape.md),
                child: SizedBox(
                  height: 160,
                  child: LocationMap(key: ValueKey(point), center: point, pin: point, interactive: false),
                ),
              )
            else
              Text('${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}', style: muted),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => openInMaps(context, point, place.name),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.locationOpenInMaps),
              ),
            ),
          ],
        ],

        if (e.note case final note? when note.trim().isNotEmpty) ...[
          FormSection(l10n.expenseNote),
          SelectableText(note, style: text.bodyLarge),
        ],

        if (e.hasReceipt) ...[
          FormSection(l10n.expenseReceipt),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ReceiptThumbnail(photo: ref.watchCurrent(receiptProvider((token: group.token, id: e.id)))),
          ),
        ],
      ],
    );
  }
}

/// A member's part of what was paid or split, in the currency it was paid in.
class _PartRow extends StatelessWidget {
  const _PartRow({required this.group, required this.part, required this.foreign, required this.me});

  final Group group;
  final ExpensePart part;
  final ForeignMoney? foreign;
  final String? me;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final member = group.member(part.memberId);
    final name = member?.name ?? l10n.someone;
    final inGroup = formatMoney(context, part.amount, group.minorDigits, group.currency, symbol: group.symbol);
    final f = foreign, typed = part.foreignAmount;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BSpace.s4),
      child: Row(
        children: [
          if (member != null) MemberAvatar(member: member, size: 32) else const SizedBox(width: 32),
          const SizedBox(width: BSpace.s12),
          Expanded(
            child: Text(
              part.memberId == me ? l10n.memberYou(name) : name,
              style: text.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: BSpace.s8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                f == null || typed == null ? inGroup : formatMoney(context, typed, f.digits, f.currency),
                style: text.moneyRow,
              ),
              if (f != null && typed != null)
                Text(inGroup, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
