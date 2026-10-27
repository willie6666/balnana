import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../data/home_group.dart';
import '../data/providers.dart';
import '../features/account/email_pages.dart';
import '../features/account/oauth.dart';
import '../features/account/sign_in_page.dart';
import '../features/activity/activity_page.dart';
import '../features/admin/admin_page.dart';
import '../features/expense/expense_editor_page.dart';
import '../features/group/categories_page.dart';
import '../features/group/group_page.dart';
import '../features/group/group_settings_page.dart';
import '../features/group/join_page.dart';
import '../features/groups/create_group_page.dart';
import '../features/groups/groups_page.dart';
import '../features/groups/import_group_page.dart';
import '../features/groups/link_page.dart';
import '../features/not_found_page.dart';
import '../features/settings/privacy_page.dart';
import '../features/settings/server_page.dart';
import '../features/settings/settings_page.dart';
import '../features/shell/shell.dart';
import 'push.dart';
import 'server.dart';

final _root = GlobalKey<NavigatorState>();

/// A new server sends everyone to /admin until its administrator password
/// is set. In accounts mode, signed-out people only see signing in, settings
/// and groups opened by link (which ask them to sign in unless open to
/// anyone). Home is a group: the one opened last, when there is one.
String? _redirect(Ref ref, GoRouterState state) {
  final path = state.matchedLocation;
  if (ref.read(setupRequiredProvider)) return path == '/admin' ? null : '/admin';
  if (ref.read(accountsModeProvider)) {
    final account = ref.read(currentAccountProvider);
    if (account.isLoading || account.hasError) return null;
    final signedIn = account.value != null;
    if (path == '/sign-in') return signedIn ? safeNext(state.uri.queryParameters['next']) ?? '/groups' : null;
    final public =
        path.startsWith('/settings') ||
        (path.startsWith('/g/') && !path.endsWith('/join')) ||
        _publicLinks.any(path.startsWith);
    if (!signedIn && !public) return signInPath(state.uri.toString());
  }
  if (path == '/groups') {
    final home = homeGroup(ref);
    if (home != null) return '/g/$home';
  }
  return null;
}

/// Pages opened from emails or coming back from a sign-in provider, which
/// work signed out.
const _publicLinks = [
  '/verify-email',
  '/reset-password',
  '/invite/',
  '/oauth-done',
  '/admin',
  '/link',
  '/privacy',
];

final routerProvider = Provider<GoRouter>((ref) {
  // Signing in or out moves people on without rebuilding the router.
  final refresh = ValueNotifier(0);
  void bump(Object? _, Object? _) => refresh.value++;
  ref.listen(currentAccountProvider, bump);
  ref.listen(accountsModeProvider, bump);
  ref.listen(setupRequiredProvider, bump);
  ref.onDispose(refresh.dispose);

  // Opened by a notification of this server: start at its group, not at home.
  final launched = ref.read(launchTargetProvider);
  final router = GoRouter(
    navigatorKey: _root,
    initialLocation: launched != null && launched.server == ref.read(serverUrlProvider)
        ? '/g/${launched.token}'
        : '/groups',
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state),
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/groups'),
      // Server administration. Nothing links here; the operator knows it.
      GoRoute(path: '/admin', builder: (context, state) => const AdminPage()),
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
      // A link to the server, opened in the Android app.
      GoRoute(path: '/link', builder: (context, state) => LinkPage(url: state.uri.queryParameters['url'])),
      GoRoute(
        path: '/invite/:token',
        builder: (context, state) => InvitePage(token: state.pathParameters['token']!),
      ),
      GoRoute(path: '/privacy', builder: (context, state) => const PrivacyPage()),
      // For app stores, which ask for a web page where accounts can be deleted.
      GoRoute(path: '/delete-account', builder: (context, state) => const DeleteAccountPage()),
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
              // A private group link; the token never leaves this device except to the server.
              GoRoute(
                path: '/g/:token',
                // Keyed, since switching groups keeps the page and only changes the token.
                builder: (context, state) {
                  final token = state.pathParameters['token']!;
                  return GroupPage(key: ValueKey(token), token: token);
                },
                routes: [
                  GoRoute(
                    path: 'expenses/new',
                    parentNavigatorKey: _root,
                    pageBuilder: (context, state) => MaterialPage(
                      fullscreenDialog: true,
                      child: ExpenseEditorPage(token: state.pathParameters['token']!),
                    ),
                  ),
                  GoRoute(
                    path: 'expenses/:id',
                    parentNavigatorKey: _root,
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
                    routes: [
                      GoRoute(
                        path: 'categories',
                        builder: (context, state) => CategoriesPage(token: state.pathParameters['token']!),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'join',
                    builder: (context, state) => JoinPage(token: state.pathParameters['token']!),
                  ),
                ],
              ),
              // Under the navigation, which stays put while signing in.
              GoRoute(
                path: '/sign-in',
                builder: (context, state) => SignInPage(
                  next: state.uri.queryParameters['next'],
                  prefill: state.extra is SignInPrefill ? state.extra as SignInPrefill : null,
                ),
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
