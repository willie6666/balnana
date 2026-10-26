import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/page.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BPage(
      title: l10n.navActivity,
      fillRemaining: true,
      children: [
        EmptyState(icon: Icons.history, title: l10n.activityEmptyTitle, body: l10n.activityEmptyBody),
      ],
    );
  }
}
