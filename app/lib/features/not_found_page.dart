import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/l10n.dart';
import '../ui/widgets/empty_state.dart';
import '../ui/widgets/page.dart';

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
