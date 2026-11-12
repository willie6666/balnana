import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/grouped_list.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/page.dart';
import 'plan_page.dart';

/// The account's groups, each with a switch that shares the account's plan
/// with it.
class SharePlanPage extends ConsumerStatefulWidget {
  const SharePlanPage({super.key});

  @override
  ConsumerState<SharePlanPage> createState() => _SharePlanPageState();
}

class _SharePlanPageState extends ConsumerState<SharePlanPage> {
  /// What was switched here, by group, until the list says the same.
  final _switched = <String, bool>{};
  final _busy = <String>{};

  Future<void> _share(GroupSummary group, bool on) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy.add(group.token));
    try {
      final api = groupApiOf(ref, group.token);
      await (on ? api.sponsor() : api.unsponsor());
      if (mounted) setState(() => _switched[group.token] = on);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
    }
    if (!mounted) return;
    setState(() => _busy.remove(group.token));
    ref.invalidate(summariesProvider);
    ref.invalidate(myPlanProvider);
    ref.invalidate(groupPlanProvider(group.token));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // A fresh list says what the server holds: the switches follow it again.
    ref.listen(summariesProvider, (_, next) {
      if (next.hasValue && !next.isLoading && _switched.isNotEmpty) setState(_switched.clear);
    });
    final plan = ref.watch(myPlanProvider);
    final summaries = ref.watch(visibleSummariesProvider);
    final groups = summaries.value?.groups;
    final mine = plan.value;
    if (groups == null || mine == null) {
      final error = plan.hasError && !plan.isLoading
          ? plan.error
          : summaries.state.hasError && !summaries.state.isLoading
          ? summaries.state.error
          : null;
      return BPage(
        title: l10n.sharePlanTitle,
        fillRemaining: true,
        children: [
          if (error != null)
            EmptyState(
              icon: Icons.cloud_off_outlined,
              title: l10n.sharePlanTitle,
              body: errorMessage(l10n, error),
              action: FilledButton.tonal(
                onPressed: () {
                  ref.invalidate(myPlanProvider);
                  ref.invalidate(summariesProvider);
                },
                child: Text(l10n.commonRetry),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
        ],
      );
    }
    bool shared(GroupSummary g) => _switched[g.token] ?? g.sharedPlan == SharedPlan.mine;
    final limit = mine.sponsoredGroups.limit;
    // Counted from the list, so it follows the switches at once.
    final used = groups.where(shared).length;
    final full = limit != null && used >= limit;
    return BPage(
      title: l10n.sharePlanTitle,
      children: [
        GroupedList(
          children: [
            GroupedTile(
              icon: Icons.volunteer_activism_outlined,
              title: mine.planName,
              subtitle:
                  '${l10n.sharePlanHelp}\n'
                  '${l10n.sharePlanUsage(planUsage(l10n, PlanUsage(used: used, limit: limit)))}',
            ),
          ],
        ),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.groupsEmptyTitle, textAlign: TextAlign.center),
          )
        else
          GroupedList(
            title: l10n.navGroups,
            children: [
              for (final g in groups)
                GroupedSwitchTile(
                  icon: Icons.groups_outlined,
                  leading: GroupBadge(token: g.token, name: g.name, emoji: g.emoji, color: g.color, size: 40),
                  title: g.name,
                  subtitle: !shared(g) && g.sharedPlan == SharedPlan.other
                      ? l10n.errorAlreadySponsored
                      : !shared(g) && full
                      ? l10n.errorLimitSponsored(limit)
                      : null,
                  value: shared(g),
                  // A group another member's plan covers has no use for this
                  // one, and a plan shares with only so many.
                  onChanged: _busy.contains(g.token) || !shared(g) && (g.sharedPlan == SharedPlan.other || full)
                      ? null
                      : (on) => _share(g, on),
                ),
            ],
          ),
      ],
    );
  }
}
