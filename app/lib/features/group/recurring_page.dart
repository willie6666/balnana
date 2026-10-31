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
import '../../ui/money.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/grouped_list.dart';
import '../../ui/widgets/page.dart';
import 'categories_page.dart';
import 'group_page.dart';

/// "day" or "days", after a number field.
String repeatUnitLabel(AppLocalizations l10n, RepeatUnit unit, int count) => switch (unit) {
  RepeatUnit.day => l10n.repeatUnitDay(count),
  RepeatUnit.week => l10n.repeatUnitWeek(count),
  RepeatUnit.month => l10n.repeatUnitMonth(count),
  RepeatUnit.year => l10n.repeatUnitYear(count),
  RepeatUnit.unknown => '',
};

/// "Every 2 weeks".
String repeatLabel(AppLocalizations l10n, Repeat repeat) => switch (repeat.unit) {
  RepeatUnit.day => l10n.repeatIntervalDay(repeat.every),
  RepeatUnit.week => l10n.repeatIntervalWeek(repeat.every),
  RepeatUnit.month => l10n.repeatIntervalMonth(repeat.every),
  RepeatUnit.year => l10n.repeatIntervalYear(repeat.every),
  RepeatUnit.unknown => l10n.repeatCustom,
};

/// Asks, then deletes [recurring]; the expenses it added stay. Returns
/// whether it was deleted.
Future<bool> deleteRecurring(BuildContext context, WidgetRef ref, Group group, RecurringExpense recurring) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final sure = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.recurringDeleteTitle),
      content: Text(l10n.recurringDeleteBody(recurring.title)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.recurringDelete)),
      ],
    ),
  );
  if (sure != true) return false;
  try {
    await groupApiOf(ref, group.token).deleteRecurring(recurring.id);
  } on ApiException catch (e) {
    // Someone else deleted it first: it is gone either way.
    if (e.status != 404) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
      return false;
    }
  }
  refreshGroup(ref, group.token);
  messenger.showSnackBar(SnackBar(content: Text(l10n.recurringDeleted)));
  return true;
}

/// A group's recurring expenses: when each comes back, and controls to
/// change, pause or delete them.
class RecurringPage extends ConsumerWidget {
  const RecurringPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final group = ref.watchCurrent(groupProvider(token));
    final list = ref.watchCurrent(recurringProvider(token));
    if (group.value case final g? when list.hasValue) {
      return GroupTheme(
        group: g,
        child: _Recurring(group: g, items: list.requireValue),
      );
    }
    final error = group.error ?? list.error;
    return BPage(
      title: l10n.recurringTitle,
      fillRemaining: true,
      children: [
        if (error != null && !group.isLoading && !list.isLoading)
          EmptyState(
            icon: Icons.cloud_off_outlined,
            title: l10n.groupsUnreachableTitle,
            body: errorMessage(l10n, error),
            action: FilledButton.tonal(
              onPressed: () {
                ref.invalidate(groupProvider(token));
                ref.invalidate(recurringProvider(token));
              },
              child: Text(l10n.commonRetry),
            ),
          )
        else
          const CircularProgressIndicator(),
      ],
    );
  }
}

class _Recurring extends ConsumerWidget {
  const _Recurring({required this.group, required this.items});

  final Group group;
  final List<RecurringExpense> items;

  void _add(BuildContext context) => context.push('/g/${group.token}/expenses/new?repeat=1');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (items.isEmpty) {
      return BPage(
        title: l10n.recurringTitle,
        fillRemaining: true,
        children: [
          EmptyState(
            icon: Icons.repeat,
            title: l10n.recurringEmptyTitle,
            body: l10n.recurringEmptyBody,
            action: FilledButton.icon(
              onPressed: () => _add(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.recurringAdd),
            ),
          ),
        ],
      );
    }
    return BPage(
      title: l10n.recurringTitle,
      children: [
        GroupedList(
          children: [
            for (final r in items) _RecurringTile(group: group, recurring: r),
            GroupedTile(icon: Icons.add, title: l10n.recurringAdd, onTap: () => _add(context)),
          ],
        ),
      ],
    );
  }
}

enum _Action { edit, pause, resume, delete }

class _RecurringTile extends ConsumerWidget {
  const _RecurringTile({required this.group, required this.recurring});

  final Group group;
  final RecurringExpense recurring;

  Future<void> _setPaused(BuildContext context, WidgetRef ref, bool paused) async {
    final l10n = context.l10n;
    try {
      await groupApiOf(ref, group.token).pauseRecurring(recurring.id, paused: paused, digits: group.minorDigits);
      refreshGroup(ref, group.token);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final r = recurring;
    final next = r.nextAt;
    final String status;
    if (next == null) {
      status = l10n.recurringEnded;
    } else if (r.paused) {
      status = l10n.recurringPaused;
    } else {
      status = l10n.recurringNext(DateFormat.yMMMEd(locale).format(next.toLocal()));
    }
    final dim = r.paused || r.ended;
    final edit = '/g/${group.token}/recurring/${r.id}';
    return ListTile(
      minVerticalPadding: BSpace.s12,
      contentPadding: const EdgeInsets.only(left: BSpace.s16, right: BSpace.s4),
      leading: Opacity(
        opacity: dim ? 0.5 : 1,
        child: CategoryBubble(category: group.category(r.categoryId) ?? Category.other.asGroupCategory),
      ),
      title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${repeatLabel(l10n, r.repeat)} · $status',
        style: TextStyle(color: dim ? scheme.onSurfaceVariant : null),
      ),
      onTap: () => context.push(edit),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatMoney(context, r.amount, group.minorDigits, group.currency, symbol: group.symbol),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: dim ? scheme.onSurfaceVariant : null),
          ),
          PopupMenuButton<_Action>(
            onSelected: (a) async {
              switch (a) {
                case _Action.edit:
                  await context.push(edit);
                case _Action.pause:
                  await _setPaused(context, ref, true);
                case _Action.resume:
                  await _setPaused(context, ref, false);
                case _Action.delete:
                  await deleteRecurring(context, ref, group, r);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _Action.edit,
                child: ListTile(leading: const Icon(Icons.edit_outlined), title: Text(l10n.recurringEdit)),
              ),
              if (!r.ended)
                r.paused
                    ? PopupMenuItem(
                        value: _Action.resume,
                        child: ListTile(
                          leading: const Icon(Icons.play_arrow_outlined),
                          title: Text(l10n.recurringResume),
                        ),
                      )
                    : PopupMenuItem(
                        value: _Action.pause,
                        child: ListTile(leading: const Icon(Icons.pause_outlined), title: Text(l10n.recurringPause)),
                      ),
              PopupMenuItem(
                value: _Action.delete,
                child: ListTile(leading: const Icon(Icons.delete_outline), title: Text(l10n.recurringDelete)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
