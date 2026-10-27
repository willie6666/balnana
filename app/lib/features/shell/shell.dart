import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../ui/layout.dart';

/// The frame around the top-level pages: a bottom bar on phones, a rail on
/// wider windows.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _go(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    // Back from Activity or Settings goes to the groups first, and only then
    // leaves the app.
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(0);
      },
      child: _frame(context),
    );
  }

  Widget _frame(BuildContext context) {
    final l10n = context.l10n;
    final destinations = [
      (Icons.groups_outlined, Icons.groups, l10n.navGroups),
      (Icons.history_outlined, Icons.history, l10n.navActivity),
      (Icons.settings_outlined, Icons.settings, l10n.navSettings),
    ];

    if (WindowSize.of(context) == WindowSize.compact) {
      return Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _go,
          destinations: [
            for (final (icon, selected, label) in destinations)
              NavigationDestination(icon: Icon(icon), selectedIcon: Icon(selected), label: label),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            right: false,
            child: NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _go,
              labelType: NavigationRailLabelType.all,
              groupAlignment: -0.85,
              destinations: [
                for (final (icon, selected, label) in destinations)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selected),
                    label: Text(label),
                  ),
              ],
            ),
          ),
          Expanded(child: shell),
        ],
      ),
    );
  }
}
