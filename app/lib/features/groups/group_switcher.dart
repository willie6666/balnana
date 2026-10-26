import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/home_group.dart';
import '../../data/known_groups.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/colors.dart';
import '../../ui/money.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/member_avatar.dart';
import 'open_link.dart';

/// The title of a group page: the group's badge and name, which opens the
/// list of groups to switch to.
class GroupSwitcher extends StatelessWidget {
  const GroupSwitcher({super.key, this.group});

  /// Null while the group loads or cannot be shown.
  final Group? group;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final g = group;
    return Tooltip(
      message: l10n.groupSwitch,
      child: InkWell(
        onTap: () => showGroupsSheet(context, current: g?.token),
        borderRadius: const BorderRadius.all(Radius.circular(BShape.md)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: BSpace.s8, vertical: BSpace.s4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (g != null) ...[
                GroupBadge(token: g.token, name: g.name, emoji: g.emoji, color: g.color, size: 36),
                const SizedBox(width: BSpace.s12),
              ],
              Flexible(child: Text(g?.name ?? l10n.navGroups, overflow: TextOverflow.ellipsis)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lists the groups to switch between, to reorder, or to add one.
Future<void> showGroupsSheet(BuildContext context, {String? current}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  useSafeArea: true,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _GroupsSheet(current: current, home: context),
);

class _GroupsSheet extends ConsumerWidget {
  const _GroupsSheet({required this.current, required this.home});

  final String? current;

  /// Where the sheet was opened, which outlives the sheet.
  final BuildContext home;

  void _then(BuildContext context, void Function(BuildContext home) action) {
    Navigator.of(context).pop();
    if (home.mounted) action(home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final summaries = ref.watch(summariesProvider);
    final data = summaries.value;

    final Widget list;
    if (data == null) {
      list = Padding(
        padding: const EdgeInsets.all(BSpace.s24),
        child: Center(
          child: summaries.hasError && !summaries.isLoading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(errorMessage(l10n, summaries.error!), textAlign: TextAlign.center),
                    const SizedBox(height: BSpace.s8),
                    TextButton(onPressed: () => ref.invalidate(summariesProvider), child: Text(l10n.commonRetry)),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      );
    } else {
      final groups = data.groups;
      list = ReorderableListView.builder(
        shrinkWrap: true,
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.symmetric(horizontal: BSpace.s8),
        itemCount: groups.length,
        onReorderItem: (from, to) => reorderGroups(ref, groups, from, to),
        itemBuilder: (context, i) => _GroupTile(
          key: ValueKey(groups[i].token),
          index: i,
          summary: groups[i],
          selected: groups[i].token == current,
          onTap: () => _then(context, (home) => home.go('/g/${groups[i].token}')),
        ),
        footer: Column(
          children: [
            for (final token in data.missing)
              ListTile(
                leading: const Icon(Icons.link_off),
                title: Text(l10n.groupMissingTitle),
                subtitle: Text(l10n.groupMissingBody),
                trailing: TextButton(
                  onPressed: () => ref.read(knownGroupsProvider.notifier).remove(token),
                  child: Text(l10n.commonRemove),
                ),
              ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(BSpace.s24, 0, BSpace.s16, BSpace.s8),
            child: Row(
              children: [
                Expanded(child: Text(l10n.navGroups, style: text.titleLarge)),
                IconButton(
                  tooltip: l10n.openLinkTitle,
                  icon: const Icon(Icons.link),
                  onPressed: () => _then(context, showOpenLinkDialog),
                ),
                IconButton.filledTonal(
                  tooltip: l10n.groupNew,
                  icon: const Icon(Icons.add),
                  onPressed: () => _then(context, (home) => home.push('/groups/new')),
                ),
              ],
            ),
          ),
          Flexible(child: list),
          const SizedBox(height: BSpace.s16),
        ],
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    super.key,
    required this.index,
    required this.summary,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final GroupSummary summary;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final balance = summary.balance;
    return Padding(
      padding: const EdgeInsets.only(bottom: BSpace.tileGap * 2),
      child: Material(
        color: selected ? scheme.secondaryContainer : Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.md))),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          selected: selected,
          contentPadding: const EdgeInsetsDirectional.only(start: BSpace.s16, end: BSpace.s4),
          leading: GroupBadge(token: summary.token, name: summary.name, emoji: summary.emoji, color: summary.color),
          title: Text(summary.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: balance == null
              ? Text(l10n.groupMemberCount(summary.memberCount))
              : Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: BalancePill(amount: balance, digits: summary.minorDigits, currency: summary.currency),
                ),
          trailing: ReorderableDragStartListener(
            index: index,
            child: Tooltip(
              message: l10n.groupReorder,
              child: const Padding(padding: EdgeInsets.all(BSpace.s12), child: Icon(Icons.drag_handle)),
            ),
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
      margin: const EdgeInsets.only(top: BSpace.s4),
      padding: const EdgeInsets.symmetric(horizontal: BSpace.s8, vertical: 2),
      decoration: ShapeDecoration(color: background, shape: const StadiumBorder()),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: foreground)),
    );
  }
}
