import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../ui/layout.dart';

/// How often each place in the navigation (Groups, Activity, Settings) was
/// picked. A page that watches its count starts over when it changes: at
/// the top, on its first tab.
final tabResetsProvider = NotifierProvider<TabResets, List<int>>(TabResets.new);

class TabResets extends Notifier<List<int>> {
  @override
  List<int> build() => const [0, 0, 0];

  void bump(int tab) => state = [for (final (i, n) in state.indexed) i == tab ? n + 1 : n];
}

/// [child] made anew each time the place [tab] in the navigation is picked.
class TabRoot extends ConsumerWidget {
  const TabRoot({super.key, required this.tab, required this.child});

  final int tab;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      KeyedSubtree(key: ValueKey(ref.watch(tabResetsProvider.select((resets) => resets[tab]))), child: child);
}

/// The frame around the top-level pages: a bottom bar on phones, a rail on
/// wider windows.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  /// Picking a place always opens its first page as new, whatever was left
  /// open there. Groups opens the group that was open last.
  void _go(WidgetRef ref, int index) {
    ref.read(tabResetsProvider.notifier).bump(index);
    shell.goBranch(index, initialLocation: true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Back from Activity or Settings goes to the groups first, and only then
    // leaves the app.
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(ref, 0);
      },
      child: _frame(context, (index) => _go(ref, index)),
    );
  }

  Widget _frame(BuildContext context, ValueChanged<int> go) {
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
          onDestinationSelected: go,
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
              onDestinationSelected: go,
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
