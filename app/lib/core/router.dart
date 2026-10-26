import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/providers.dart';
import '../features/account/email_pages.dart';
import '../features/account/oauth.dart';
import '../features/account/sign_in_page.dart';
import '../features/activity/activity_page.dart';
import '../features/expense/expense_editor_page.dart';
import '../features/group/group_page.dart';
import '../features/group/group_settings_page.dart';
import '../features/group/join_page.dart';
import '../features/group/stats_page.dart';
import '../features/groups/create_group_page.dart';
import '../features/groups/groups_page.dart';
import '../features/groups/import_group_page.dart';
import '../features/not_found_page.dart';
import '../features/settings/server_page.dart';
import '../features/settings/settings_page.dart';
import '../features/shell/shell.dart';
import 'server.dart';

final _root = GlobalKey<NavigatorState>();

/// In accounts mode, signed-out people only see signing in, settings and
/// groups opened by link (which ask them to sign in unless open to anyone).
String? _accountsRedirect(Ref ref, GoRouterState state) {
  if (!ref.read(accountsModeProvider)) return null;
  final account = ref.read(accountProvider);
  if (account.isLoading || account.hasError) return null;
  final signedIn = account.value != null;
  final path = state.matchedLocation;
  if (path == '/sign-in') return signedIn ? safeNext(state.uri.queryParameters['next']) ?? '/groups' : null;
  final public =
      path.startsWith('/settings') ||
      (path.startsWith('/g/') && !path.endsWith('/join')) ||
      _publicLinks.any(path.startsWith);
  if (!signedIn && !public) return signInPath(state.uri.toString());
  return null;
}

/// Pages opened from emails or coming back from a sign-in provider, which
/// work signed out.
const _publicLinks = ['/verify-email', '/reset-password', '/invite/', '/oauth-done'];

final routerProvider = Provider<GoRouter>((ref) {
  // Signing in or out moves people on without rebuilding the router.
  final refresh = ValueNotifier(0);
  void bump(Object? _, Object? _) => refresh.value++;
  ref.listen(accountProvider, bump);
  ref.listen(accountsModeProvider, bump);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: _root,
    initialLocation: '/groups',
    refreshListenable: refresh,
    redirect: (context, state) => _accountsRedirect(ref, state),
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/groups'),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => SignInPage(
          next: state.uri.queryParameters['next'],
          prefill: state.extra is SignInPrefill ? state.extra as SignInPrefill : null,
        ),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => VerifyEmailPage(token: state.uri.queryParameters['token'] ?? ''),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => ResetPasswordPage(token: state.uri.queryParameters['token'] ?? ''),
      ),
      GoRoute(
        path: '/oauth-done',
        builder: (context, state) => OAuthDonePage(
          code: state.uri.queryParameters['code'],
          error: state.uri.queryParameters['error'],
          next: state.uri.queryParameters['next'],
        ),
      ),
      GoRoute(
        path: '/invite/:token',
        builder: (context, state) => InvitePage(token: state.pathParameters['token']!),
      ),
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
              child: ExpenseEditorPage(
                token: state.pathParameters['token']!,
                expenseId: state.pathParameters['id'],
              ),
            ),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => GroupSettingsPage(token: state.pathParameters['token']!),
          ),
          GoRoute(
            path: 'stats',
            builder: (context, state) => StatsPage(token: state.pathParameters['token']!),
          ),
          GoRoute(
            path: 'join',
            builder: (context, state) => JoinPage(token: state.pathParameters['token']!),
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
                  GoRoute(
                    path: 'import',
                    parentNavigatorKey: _root,
                    pageBuilder: (context, state) =>
                        const MaterialPage(fullscreenDialog: true, child: ImportGroupPage()),
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
