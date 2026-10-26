import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderOrFamily;

import '../core/server.dart';
import '../core/session.dart';
import 'api.dart';
import 'known_groups.dart';
import 'models.dart';

class _NoServer implements Exception {
  const _NoServer();
}

BalnanaApi _api(Ref ref) => ref.watch(balnanaApiProvider) ?? (throw const _NoServer());

/// The API for one group, acting as this device's member in it.
GroupApi groupApiOf(WidgetRef ref, String token) {
  final api = ref.read(balnanaApiProvider) ?? (throw const _NoServer());
  return api.group(token, memberId: ref.read(knownGroupsProvider.notifier).byToken(token)?.memberId);
}

/// The signed-in account, or null when signed out or the server has no
/// accounts.
final accountProvider = FutureProvider<User?>((ref) async {
  final info = await ref.watch(serverInfoProvider.future);
  if (info.authMode != AuthMode.accounts) return null;
  try {
    return await _api(ref).me();
  } on ApiException catch (e) {
    if (e.status == 401) return null;
    rethrow;
  }
});

/// Whether an account is signed in, as far as is known yet.
final signedInProvider = Provider<bool>((ref) => ref.watch(accountProvider.select((a) => a.value != null)));

/// Keeps a new session and reloads everything as that account.
void startSession(WidgetRef ref, String? token) => ref.read(sessionProvider.notifier).set(token);

/// Ends the session here and on the server.
Future<void> signOut(WidgetRef ref) async {
  try {
    await ref.read(balnanaApiProvider)?.logout();
  } on ApiException {
    // Forget the session here all the same.
  }
  ref.read(sessionProvider.notifier).set(null);
}

typedef Summaries = ({List<GroupSummary> groups, List<String> missing});

/// The groups to show at home: the account's groups when signed in, else the
/// groups on this device, as the server sees them now.
final summariesProvider = FutureProvider<Summaries>((ref) async {
  final api = _api(ref);
  if (await ref.watch(accountProvider.future) != null) {
    return (groups: await api.myGroups(), missing: <String>[]);
  }
  final known = ref.watch(knownGroupsProvider);
  if (known.isEmpty) return (groups: <GroupSummary>[], missing: <String>[]);
  final (groups, missing) = await api.summaries({for (final g in known) g.token: g.memberId});
  // Keep this device's order: most recently added first.
  final order = {for (final (i, g) in known.indexed) g.token: i};
  groups.sort((a, b) => (order[a.token] ?? 0).compareTo(order[b.token] ?? 0));
  return (groups: groups, missing: missing);
});

final groupProvider = FutureProvider.family<Group, String>((ref, token) => _api(ref).group(token).get());

final balancesProvider = FutureProvider.family<Balances, String>((ref, token) async {
  final group = await ref.watch(groupProvider(token).future);
  return _api(ref).group(token).balances(group.minorDigits);
});

/// A group's expenses, newest first, loaded a page at a time.
class ExpenseList {
  const ExpenseList(this.items, this.nextCursor, {this.loadingMore = false, this.moreError});

  final List<Expense> items;
  final String? nextCursor;
  final bool loadingMore;

  /// Why the next page did not load. It is not asked for again until retried.
  final Exception? moreError;

  bool get hasMore => nextCursor != null;
}

final expensesProvider = AsyncNotifierProvider.family<ExpensesNotifier, ExpenseList, String>(
  ExpensesNotifier.new,
);

class ExpensesNotifier extends AsyncNotifier<ExpenseList> {
  ExpensesNotifier(this.token);

  final String token;
  int _digits = 2;

  @override
  Future<ExpenseList> build() async {
    final group = await ref.watch(groupProvider(token).future);
    _digits = group.minorDigits;
    final page = await _api(ref).group(token).expenses(_digits);
    return ExpenseList(page.items, page.nextCursor);
  }

  /// Loads the next page, unless the last try failed and this is no [retry].
  Future<void> loadMore({bool retry = false}) async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    if (current.moreError != null && !retry) return;
    state = AsyncData(ExpenseList(current.items, current.nextCursor, loadingMore: true));
    try {
      final page = await _api(ref).group(token).expenses(_digits, cursor: current.nextCursor);
      state = AsyncData(ExpenseList([...current.items, ...page.items], page.nextCursor));
    } on Exception catch (e) {
      state = AsyncData(ExpenseList(current.items, current.nextCursor, moreError: e));
    }
  }
}

/// One entry of the activity feed across all groups on this device.
typedef FeedItem = ({Activity activity, Group group});

/// The latest changes in every group at home, newest first.
final activityFeedProvider = FutureProvider<List<FeedItem>>((ref) async {
  final api = _api(ref);
  final home = await ref.watch(summariesProvider.future);
  final perGroup = await Future.wait(
    home.groups.map((g) async {
      try {
        final group = await ref.watch(groupProvider(g.token).future);
        final page = await api.group(g.token).activity(limit: 30);
        return [for (final a in page.items) (activity: a, group: group)];
      } on ApiException catch (e) {
        if (e.isNotFound) return <FeedItem>[];
        rethrow;
      }
    }),
  );
  return perGroup.expand((items) => items).toList()
    ..sort((a, b) => b.activity.createdAt.compareTo(a.activity.createdAt));
});

/// Reloads everything that shows [token]'s data after a change.
void refreshGroup(WidgetRef ref, String token) => _refresh(ref.invalidate, token);

/// [refreshGroup] for callbacks that may outlive the widget, such as undo.
void refreshGroupIn(ProviderContainer container, String token) => _refresh(container.invalidate, token);

void _refresh(void Function(ProviderOrFamily) invalidate, String token) {
  invalidate(groupProvider(token));
  invalidate(balancesProvider(token));
  invalidate(expensesProvider(token));
  invalidate(summariesProvider);
  invalidate(activityFeedProvider);
}

/// One expense, for the editor.
final expenseProvider = FutureProvider.autoDispose.family<Expense, ({String token, String id})>((
  ref,
  key,
) async {
  final group = await ref.watch(groupProvider(key.token).future);
  return _api(ref).group(key.token).expense(key.id, group.minorDigits);
});
