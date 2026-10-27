import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/money.dart';
import '../../core/server.dart';
import '../../data/providers.dart';
import '../../ui/money.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/page.dart';
import '../group/expenses_tab.dart';

/// What changed lately in every group on this device.
class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hasServer = ref.watch(serverUrlProvider) != null;
    final async = hasServer ? ref.watchCurrent(activityFeedProvider) : null;
    final items = async?.value;

    if (items == null || items.isEmpty) {
      final failed = async != null && async.hasError && !async.isLoading;
      return BPage(
        title: l10n.navActivity,
        fillRemaining: true,
        children: [
          if (async != null && async.isLoading && items == null)
            const CircularProgressIndicator()
          else if (failed)
            EmptyState(
              icon: Icons.cloud_off_outlined,
              title: l10n.groupsUnreachableTitle,
              body: errorMessage(l10n, async.error!),
              action: FilledButton.tonal(
                onPressed: () => ref.invalidate(activityFeedProvider),
                child: Text(l10n.commonRetry),
              ),
            )
          else
            EmptyState(icon: Icons.history, title: l10n.activityEmptyTitle, body: l10n.activityEmptyBody),
        ],
      );
    }

    final rows = <Widget>[];
    DateTime? day;
    for (final item in items) {
      final t = item.activity.createdAt.toLocal();
      final d = DateTime(t.year, t.month, t.day);
      if (d != day) {
        day = d;
        rows.add(DateHeader(day: d));
      }
      rows.add(ActivityTile(item: item));
    }
    return RefreshIndicator(
      onRefresh: () => ref.refresh(activityFeedProvider.future),
      child: BPage(title: l10n.navActivity, children: rows),
    );
  }
}

class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final group = item.group;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return ListTile(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.md))),
      contentPadding: const EdgeInsets.symmetric(horizontal: BSpace.s8),
      leading: GroupBadge(
        token: group.token,
        name: group.name,
        emoji: group.emoji,
        color: group.color,
        size: 40,
      ),
      title: Text(activitySentence(context, item), style: text.bodyLarge),
      subtitle: Text(
        '${group.name} · ${DateFormat.jm(locale).format(item.activity.createdAt.toLocal())}',
        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      onTap: () => context.go('/g/${group.token}'),
    );
  }
}

/// One line about what happened, in the reader's language.
String activitySentence(BuildContext context, FeedItem item) {
  final l10n = context.l10n;
  final a = item.activity, g = item.group;
  final who = g.member(a.actorMemberId)?.name ?? l10n.someone;
  final title = a.text('title') ?? '';
  final name = a.text('name') ?? '';
  String amount() {
    final raw = a.text('amount');
    if (raw == null) return '';
    try {
      return formatMoney(context, parseAmount(raw, g.minorDigits), g.minorDigits, g.currency, symbol: g.symbol);
    } on MoneyException {
      return raw;
    }
  }

  final payment = a.text('kind') == 'payment';
  return switch (a.action) {
    'group.created' => l10n.activityGroupCreated(who, name.isEmpty ? g.name : name),
    'group.imported' => l10n.activityGroupImported(who, a.number('count') ?? 0, a.text('from') ?? ''),
    'group.updated' => l10n.activityGroupUpdated(who),
    'group.link_reset' => l10n.activityLinkReset(who),
    'member.added' => l10n.activityMemberAdded(who, name),
    'member.updated' => l10n.activityMemberRenamed(who, a.text('oldName') ?? name, name),
    'member.removed' => l10n.activityMemberRemoved(who, name),
    'member.joined' => l10n.activityMemberJoined(name),
    'category.added' => l10n.activityCategoryAdded(who, name),
    'category.updated' => l10n.activityCategoryUpdated(who),
    'category.deleted' => l10n.activityCategoryDeleted(who, name),
    'expense.created' when payment => l10n.activityPaymentAdded(
      who,
      a.text('from') ?? l10n.someone,
      a.text('to') ?? l10n.someone,
      amount(),
    ),
    'expense.created' => l10n.activityExpenseAdded(who, title, amount()),
    'expense.updated' => l10n.activityExpenseUpdated(who, title, amount()),
    'expense.deleted' when payment => l10n.activityPaymentDeleted(who, amount()),
    'expense.deleted' => l10n.activityExpenseDeleted(who, title),
    'expense.restored' when payment => l10n.activityPaymentRestored(who, amount()),
    'expense.restored' => l10n.activityExpenseRestored(who, title),
    'receipt.added' => l10n.activityReceiptAdded(who, title),
    'receipt.removed' => l10n.activityReceiptRemoved(who, title),
    _ => l10n.activityOther(who),
  };
}
