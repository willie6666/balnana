import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/activity/activity_page.dart';
import '../features/expense/expense_editor_page.dart';
import '../features/group/group_page.dart';
import '../features/group/group_settings_page.dart';
import '../features/groups/create_group_page.dart';
import '../features/groups/groups_page.dart';
import '../features/not_found_page.dart';
import '../features/settings/server_page.dart';
import '../features/settings/settings_page.dart';
import '../features/shell/shell.dart';
import 'server.dart';

final _root = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _root,
    initialLocation: '/groups',
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/groups'),
      // A private group link; the token never leaves this device except to the server.
      GoRoute(
        path: '/g/:token',
        builder: (context, state) => GroupPage(token: state.pathParameters['token']!),
        routes: [
          GoRoute(
            path: 'expenses/new',
            pageBuilder: (context, state) => MaterialPage(
              fullscreenDialog: true,
              child: ExpenseEditorPage(token: state.pathParameters['token']!),
            ),
          ),
          GoRoute(
            path: 'expenses/:id',
            pageBuilder: (context, state) => MaterialPage(
              fullscreenDialog: true,
              child: ExpenseEditorPage(token: state.pathParameters['token']!, expenseId: state.pathParameters['id']),
            ),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => GroupSettingsPage(token: state.pathParameters['token']!),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/groups',
                builder: (context, state) => const GroupsPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _root,
                    pageBuilder: (context, state) =>
                        const MaterialPage(fullscreenDialog: true, child: CreateGroupPage()),
                  ),
                ],
              ),
            ],
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
