import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/known_groups.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/colors.dart';
import '../../ui/money.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/page.dart';
import 'open_link.dart';

class GroupsPage extends ConsumerWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final server = ref.watch(serverUrlProvider);
    final info = server == null ? null : ref.watch(serverInfoProvider);

    if (info == null) {
      return _empty(
        context,
        EmptyState(
          icon: Icons.dns_outlined,
          title: l10n.groupsNoServerTitle,
          body: l10n.groupsNoServerBody,
          action: FilledButton(
            onPressed: () => context.go('/settings/server'),
            child: Text(l10n.groupsNoServerAction),
          ),
        ),
      );
    }

    final known = ref.watch(knownGroupsProvider);
    final summaries = ref.watch(summariesProvider);
    final unreachable = (info.hasError && !info.isLoading) || (summaries.hasError && !summaries.isLoading);
    if (unreachable) {
      return _empty(
        context,
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: l10n.groupsUnreachableTitle,
          body: l10n.groupsUnreachableBody,
          action: FilledButton.tonal(
            onPressed: () {
              ref.invalidate(serverInfoProvider);
              ref.invalidate(summariesProvider);
            },
            child: Text(l10n.commonRetry),
          ),
        ),
      );
    }

    final actions = [
      IconButton(
        tooltip: l10n.openLinkTitle,
        icon: const Icon(Icons.link),
        onPressed: () => showOpenLinkDialog(context),
      ),
    ];
    final fab = FloatingActionButton.extended(
      onPressed: () => context.push('/groups/new'),
      icon: const Icon(Icons.add),
      label: Text(l10n.groupNew),
    );

    if (known.isEmpty) {
      return _empty(
        context,
        EmptyState(
          icon: Icons.receipt_long_outlined,
          title: l10n.groupsEmptyTitle,
          body: l10n.groupsEmptyBody,
          action: Wrap(
            spacing: BSpace.s8,
            runSpacing: BSpace.s8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(onPressed: () => context.push('/groups/new'), child: Text(l10n.groupNew)),
              OutlinedButton(onPressed: () => showOpenLinkDialog(context), child: Text(l10n.openLinkTitle)),
            ],
          ),
        ),
        actions: actions,
      );
    }

    final data = summaries.value;
    if (data == null) return _empty(context, const CircularProgressIndicator(), actions: actions);

    return BPage(
      title: l10n.navGroups,
      actions: actions,
      floatingActionButton: fab,
      children: [
        _Totals(groups: data.groups),
        for (final g in data.groups) ...[
          GroupCard(summary: g, onTap: () => context.push('/g/${g.token}')),
          const SizedBox(height: BSpace.s12),
        ],
        for (final token in data.missing) ...[
          _MissingGroupCard(onRemove: () => ref.read(knownGroupsProvider.notifier).remove(token)),
          const SizedBox(height: BSpace.s12),
        ],
        // Room for the floating button.
        const SizedBox(height: BSpace.s48),
      ],
    );
  }

  Widget _empty(BuildContext context, Widget child, {List<Widget>? actions}) =>
      BPage(title: context.l10n.navGroups, actions: actions, fillRemaining: true, children: [child]);
}

/// "You're owed" and "You owe" across groups, when every group uses the same
/// currency; amounts in different currencies don't add up.
class _Totals extends StatelessWidget {
  const _Totals({required this.groups});

  final List<GroupSummary> groups;

  @override
  Widget build(BuildContext context) {
    final withBalance = groups.where((g) => g.balance != null).toList();
    if (withBalance.isEmpty) return const SizedBox.shrink();
    final currency = withBalance.first.currency, digits = withBalance.first.minorDigits;
    if (withBalance.any((g) => g.currency != currency || g.minorDigits != digits)) return const SizedBox.shrink();

    var owed = BigInt.zero, owe = BigInt.zero;
    for (final g in withBalance) {
      if (g.balance! > BigInt.zero) owed += g.balance!;
      if (g.balance! < BigInt.zero) owe -= g.balance!;
    }
    final l10n = context.l10n;
    final c = context.bColors;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: BSpace.s16),
      child: Row(
        children: [
          Expanded(
            child: _TotalPill(
              label: l10n.totalOwed,
              amount: formatMoney(context, owed, digits, currency),
              background: owed == BigInt.zero ? scheme.surfaceContainerHigh : c.owedContainer,
              foreground: owed == BigInt.zero ? scheme.onSurfaceVariant : c.onOwedContainer,
            ),
          ),
          const SizedBox(width: BSpace.s12),
          Expanded(
            child: _TotalPill(
              label: l10n.totalOwe,
              amount: formatMoney(context, owe, digits, currency),
              background: owe == BigInt.zero ? scheme.surfaceContainerHigh : c.oweContainer,
              foreground: owe == BigInt.zero ? scheme.onSurfaceVariant : c.onOweContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalPill extends StatelessWidget {
  const _TotalPill({required this.label, required this.amount, required this.background, required this.foreground});

  final String label;
  final String amount;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BSpace.s20, vertical: BSpace.s12),
      decoration: BoxDecoration(color: background, borderRadius: const BorderRadius.all(BShape.rLg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelMedium?.copyWith(color: foreground)),
          Text(amount, style: text.moneyRow.copyWith(color: foreground), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.summary, required this.onTap});

  final GroupSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final balance = summary.balance;
    return Material(
      color: scheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(BShape.rLg)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(BSpace.s16),
          child: Row(
            children: [
              GroupBadge(token: summary.token, name: summary.name, emoji: summary.emoji, color: summary.color),
              const SizedBox(width: BSpace.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.name, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      l10n.groupMemberCount(summary.memberCount),
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (balance != null) ...[
                const SizedBox(width: BSpace.s8),
                BalancePill(amount: balance, digits: summary.minorDigits, currency: summary.currency),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "you're owed $12", "you owe $5" or "settled up" in a soft colored pill.
class BalancePill extends StatelessWidget {
  const BalancePill({super.key, required this.amount, required this.digits, required this.currency});

  final BigInt amount;
  final int digits;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.bColors;
    final scheme = Theme.of(context).colorScheme;
    final money = formatMoney(context, amount.abs(), digits, currency);
    final (label, background, foreground) = switch (amount.sign) {
      1 => (l10n.pillOwed(money), c.owedContainer, c.onOwedContainer),
      -1 => (l10n.pillOwe(money), c.oweContainer, c.onOweContainer),
      _ => (l10n.pillSettled, scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: BSpace.s12, vertical: BSpace.s4),
      decoration: ShapeDecoration(color: background, shape: const StadiumBorder()),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: foreground)),
    );
  }
}

class _MissingGroupCard extends StatelessWidget {
  const _MissingGroupCard({required this.onRemove});

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(BShape.rLg)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: BSpace.s16, vertical: BSpace.s4),
        leading: Icon(Icons.link_off, color: scheme.onSurfaceVariant),
        title: Text(l10n.groupMissingTitle),
        subtitle: Text(l10n.groupMissingBody),
        trailing: TextButton(onPressed: onRemove, child: Text(l10n.commonRemove)),
      ),
    );
  }
}
