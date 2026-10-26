import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/known_groups.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/page.dart';
import 'open_link.dart';

/// Home when no group can be shown yet: no server, no groups, or the server
/// is out of reach. Otherwise it opens the first group.
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

    // A signed-in account's groups live on the server, not on this device.
    final data = summaries.value;
    final empty = ref.watch(signedInProvider) ? data?.groups.isEmpty ?? false : known.isEmpty;
    if (empty) {
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

    // Home shows a group itself. The router opens one directly when it can
    // tell which without the server; otherwise the first group, once known.
    final first = data == null || data.groups.isEmpty ? null : data.groups.first.token;
    if (first != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/g/$first');
      });
    }
    return _empty(context, const CircularProgressIndicator(), actions: actions);
  }

  Widget _empty(BuildContext context, Widget child, {List<Widget>? actions}) =>
      BPage(title: context.l10n.navGroups, actions: actions, fillRemaining: true, children: [child]);
}
