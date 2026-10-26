import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activity/activity_page.dart';
import '../features/groups/group_link_page.dart';
import '../features/groups/groups_page.dart';
import '../features/settings/server_page.dart';
import '../features/settings/settings_page.dart';
import '../features/shell/shell.dart';
import 'server.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/groups',
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/groups'),
      // A private group link; the token never leaves this device except to the server.
      GoRoute(
        path: '/g/:token',
        builder: (context, state) => GroupLinkPage(token: state.pathParameters['token']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/groups', builder: (context, state) => const GroupsPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/activity', builder: (context, state) => const ActivityPage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'server',
                    redirect: (context, state) => canChooseServer ? null : '/settings',
                    builder: (context, state) => const ServerPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
