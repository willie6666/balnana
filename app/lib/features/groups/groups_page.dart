import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/page.dart';

class GroupsPage extends ConsumerWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final server = ref.watch(serverUrlProvider);
    final info = server == null ? null : ref.watch(serverInfoProvider);

    final Widget body;
    if (info == null) {
      body = EmptyState(
        icon: Icons.dns_outlined,
        title: l10n.groupsNoServerTitle,
        body: l10n.groupsNoServerBody,
        action: FilledButton(
          onPressed: () => context.go('/settings/server'),
          child: Text(l10n.groupsNoServerAction),
        ),
      );
    } else if (info.hasError && !info.isLoading) {
      body = EmptyState(
        icon: Icons.cloud_off_outlined,
        title: l10n.groupsUnreachableTitle,
        body: l10n.groupsUnreachableBody,
        action: FilledButton.tonal(
          onPressed: () => ref.invalidate(serverInfoProvider),
          child: Text(l10n.commonRetry),
        ),
      );
    } else if (!info.hasValue) {
      body = const CircularProgressIndicator();
    } else {
      body = EmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.groupsEmptyTitle,
        body: l10n.groupsEmptyBody,
      );
    }

    return BPage(title: l10n.navGroups, fillRemaining: true, children: [body]);
  }
}
