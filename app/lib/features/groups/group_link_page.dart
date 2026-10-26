import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/page.dart';

/// Where a private group link (`/g/<token>`) lands. Groups arrive in M1.
class GroupLinkPage extends StatelessWidget {
  const GroupLinkPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BPage(
      title: l10n.groupLinkTitle,
      fillRemaining: true,
      children: [
        EmptyState(
          icon: Icons.link,
          title: l10n.groupLinkTitle,
          body: l10n.groupLinkBody,
          action: FilledButton.tonal(
            onPressed: () => context.go('/groups'),
            child: Text(l10n.notFoundAction),
          ),
        ),
      ],
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BPage(
      title: l10n.appTitle,
      fillRemaining: true,
      children: [
        EmptyState(
          icon: Icons.explore_off_outlined,
          title: l10n.notFoundTitle,
          body: l10n.notFoundBody,
          action: FilledButton(onPressed: () => context.go('/groups'), child: Text(l10n.notFoundAction)),
        ),
      ],
    );
  }
}
