import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable, ProviderOrFamily;

import '../core/server.dart';
import '../core/session.dart';
import '../core/settings.dart';
import 'api.dart';
import 'home_group.dart';
import 'known_groups.dart';
import 'models.dart';

class _NoServer implements Exception {
  const _NoServer();
}

BalnanaApi _api(Ref ref) => ref.watch(balnanaApiProvider) ?? (throw const _NoServer());

/// Whom each value was loaded as.
final _loadedAs = Expando<Identity>('loadedAs');

/// Whether [value] can be marked in [_loadedAs].
bool _markable(Object? value) =>
    value != null && value is! Record && value is! String && value is! num && value is! bool;

/// Runs [load] with the server's API and marks what it gives as loaded as
/// whom the app is now.
Future<T> _load<T>(Ref ref, Future<T> Function(BalnanaApi api) load) async {
  final who = ref.watch(identityProvider);
  return _mark(who, await load(_api(ref)));
}

T _mark<T>(Identity who, T value) {
  if (_markable(value)) _loadedAs[value!] = who;
  return value;
}

extension CurrentValue<T> on AsyncValue<T> {
  /// This, without a value [who] may not see that is kept from before.
  ///
  /// A provider loading or failing anew keeps its last value. That is kept
  /// through a refresh, but not when it was loaded as someone else (on
  /// another server, or before signing in or out), nor once the server
  /// says [who] may not see it.
  AsyncValue<T> current(Identity who) {
    if (this is AsyncData<T> || !hasValue) return this;
    final denied = switch (error) {
      ApiException(status: 401 || 403 || 404) => true,
      _ => false,
    };
    final value = this.value;
    if (!denied && _markable(value) && _loadedAs[value!] == who) return this;
    return unwrapPrevious();
  }
}

extension WatchCurrent on WidgetRef {
  /// Watches [provider] for what is [CurrentValue.current] of it.
  AsyncValue<T> watchCurrent<T>(ProviderListenable<AsyncValue<T>> provider) =>
      watch(provider).current(watch(identityProvider));
}

class _OtherServer implements Exception {
  const _OtherServer();
}

/// The server each group was opened on, by token. A group's token is its
/// secret: it goes to that server alone, whichever server is chosen since.
final groupServersProvider = Provider<Map<String, String?>>((ref) => {});

/// Opens [token] as a group of the server chosen now, as a page showing it
/// opens, and returns that server.
String? openGroup(WidgetRef ref, String token) {
  final server = ref.read(serverUrlProvider);
  ref.read(groupServersProvider)[token] = server;
  return server;
}

/// Refuses [token] unless its group is on [server]. A group not opened yet is
/// taken to be on [server].
void _checkServer(Map<String, String?> servers, String token, String? server) {
  if (servers.putIfAbsent(token, () => server) != server) throw const _OtherServer();
}

/// The API for the group of [token], unless it was opened on another server
/// than the one chosen now.
GroupApi groupApi(Ref ref, String token) {
  final api = _api(ref);
  _checkServer(ref.read(groupServersProvider), token, ref.watch(serverUrlProvider));
  return api.group(token);
}

/// The API for one group, acting as this device's member in it.
GroupApi groupApiOf(WidgetRef ref, String token) {
  final api = ref.read(balnanaApiProvider) ?? (throw const _NoServer());
  _checkServer(ref.read(groupServersProvider), token, ref.read(serverUrlProvider));
  return api.group(token, memberId: ref.read(knownGroupsProvider.notifier).byToken(token)?.memberId);
}

/// The signed-in account, or null when signed out or the server has no
/// accounts.
final accountProvider = FutureProvider<User?>((ref) async {
  final who = ref.watch(identityProvider);
  final info = await ref.watch(serverInfoProvider.future);
  if (info.authMode != AuthMode.accounts) return null;
  try {
    final user = await _load(ref, (api) => api.me());
    if (ref.mounted && ref.read(identityProvider) == who) {
      ref.read(settingsProvider.notifier).applyAccountLocale(user.locale);
    }
    return user;
  } on ApiException catch (e) {
    if (e.status == 401) return null;
    rethrow;
  }
});

/// Ids of the providers the signed-in account signs in with.
final myOAuthProvider = FutureProvider<List<String>>((ref) => _load(ref, (api) => api.myOAuth()));

/// [accountProvider], without an account signed in before the session changed.
final currentAccountProvider = Provider<AsyncValue<User?>>(
  (ref) => ref.watch(accountProvider).current(ref.watch(identityProvider)),
);

/// Whether an account is signed in, as far as is known yet.
final signedInProvider = Provider<bool>(
  (ref) => ref.watch(currentAccountProvider.select((a) => a.value != null)),
);

/// Keeps a new session and reloads everything as that account, unless the
/// app is no longer [from], whom it was when it asked for the session: see
/// [SessionNotifier.set]. Returns whether it did.
bool startSession(WidgetRef ref, String? token, {required Identity from}) =>
    ref.read(sessionProvider.notifier).set(token, from: from);

/// Ends the session here and on the server.
Future<void> signOut(WidgetRef ref) async {
  final who = ref.read(identityProvider);
  try {
    await ref.read(balnanaApiProvider)?.logout();
  } on ApiException {
    // Forget the session here all the same.
  }
  ref.read(sessionProvider.notifier).set(null, from: who);
}

class Summaries {
  const Summaries({required this.groups, required this.missing, this.locked = const []});

  final List<GroupSummary> groups;

  /// The tokens of groups on this device the server no longer has.
  final List<String> missing;

  /// The tokens of groups on this device the server has, but that need
  /// signing in, or another account, to open.
  final List<String> locked;
}

/// The groups to show at home: the account's groups when signed in, else the
/// groups on this device, as the server sees them now.
final summariesProvider = FutureProvider<Summaries>((ref) async {
  final who = ref.watch(identityProvider);
  final api = _api(ref);
  if (await ref.watch(accountProvider.future) != null) {
    final order = ref.watch(groupOrderProvider);
    return _mark(who, Summaries(groups: inChosenOrder(await api.myGroups(), order), missing: []));
  }
  final known = ref.watch(knownGroupsProvider);
  if (known.isEmpty) return _mark(who, Summaries(groups: [], missing: []));
  final (:groups, :missing, :locked) = await api.summaries({for (final g in known) g.token: g.memberId});
  // Keep this device's order.
  final order = {for (final (i, g) in known.indexed) g.token: i};
  groups.sort((a, b) => (order[a.token] ?? 0).compareTo(order[b.token] ?? 0));
  return _mark(who, Summaries(groups: groups, missing: missing, locked: locked));
});

final groupProvider = FutureProvider.family<Group, String>(
  (ref, token) => _load(ref, (_) => groupApi(ref, token).get()),
);

final balancesProvider = FutureProvider.family<Balances, String>((ref, token) async {
  final group = await ref.watch(groupProvider(token).future);
  return _load(ref, (_) => groupApi(ref, token).balances(group.minorDigits));
});

/// A group's expenses, newest first, loaded a page at a time.
class ExpenseList {
  const ExpenseList(
    this.items,
    this.nextCursor, {
    this.filter = const ExpenseFilter(),
    this.loadingMore = false,
    this.moreError,
  });

  final List<Expense> items;

  /// What [items] were narrowed to.
  final ExpenseFilter filter;
  final String? nextCursor;
  final bool loadingMore;

  /// Why the next page did not load. It is not asked for again until retried.
  final Exception? moreError;

  bool get hasMore => nextCursor != null;
}

/// What the expenses of a group are narrowed to, while the app runs.
final expenseFilterProvider = NotifierProvider.family<ExpenseFilterNotifier, ExpenseFilter, String>(
  ExpenseFilterNotifier.new,
);

class ExpenseFilterNotifier extends Notifier<ExpenseFilter> {
  ExpenseFilterNotifier(this.token);

  final String token;

  @override
  ExpenseFilter build() => const ExpenseFilter();

  void set(ExpenseFilter filter) => state = filter;
}

final expensesProvider = AsyncNotifierProvider.family<ExpensesNotifier, ExpenseList, String>(
  ExpensesNotifier.new,
);

class ExpensesNotifier extends AsyncNotifier<ExpenseList> {
  ExpensesNotifier(this.token);

  final String token;
  int _digits = 2;
  late Identity _who;

  /// Counts builds, so a page asked for before one is not added after it.
  var _build = 0;

  @override
  Future<ExpenseList> build() async {
    _build++;
    _who = ref.watch(identityProvider);
    final filter = ref.watch(expenseFilterProvider(token));
    final group = await ref.watch(groupProvider(token).future);
    _digits = group.minorDigits;
    final page = await groupApi(ref, token).expenses(_digits, filter: filter);
    return _mark(_who, ExpenseList(page.items, page.nextCursor, filter: filter));
  }

  /// Loads the next page, unless the last try failed and this is no [retry].
  Future<void> loadMore({bool retry = false}) async {
    // While reloading, state still holds the old first page, and its cursor
    // would add a page after it over the new one.
    if (state.isLoading) return;
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    if (current.moreError != null && !retry) return;
    final build = _build, filter = current.filter;
    state = AsyncData(
      _mark(_who, ExpenseList(current.items, current.nextCursor, filter: filter, loadingMore: true)),
    );
    try {
      final page = await groupApi(ref, token).expenses(_digits, cursor: current.nextCursor, filter: filter);
      if (!ref.mounted || build != _build || state.isLoading) return;
      state = AsyncData(
        _mark(_who, ExpenseList([...current.items, ...page.items], page.nextCursor, filter: filter)),
      );
    } on Exception catch (e) {
      if (!ref.mounted || build != _build || state.isLoading) return;
      state = AsyncData(
        _mark(_who, ExpenseList(current.items, current.nextCursor, filter: filter, moreError: e)),
      );
    }
  }
}

/// One entry of the activity feed across all groups on this device.
typedef FeedItem = ({Activity activity, Group group});

/// The latest changes in every group at home, newest first.
/// What changed lately in the groups on this device, newest first.
class ActivityFeed {
  const ActivityFeed({required this.items, this.failed = 0});

  final List<FeedItem> items;

  /// How many groups could not be loaded, whose changes are missing.
  final int failed;
}

final activityFeedProvider = FutureProvider<ActivityFeed>((ref) async {
  final who = ref.watch(identityProvider);
  final api = _api(ref);
  final home = await ref.watch(summariesProvider.future);
  Object? error;
  var failed = 0, gone = false;
  final perGroup = await Future.wait(
    home.groups.map((g) async {
      try {
        final group = await ref.watch(groupProvider(g.token).future);
        final page = await api.group(g.token).activity(limit: 30);
        return [for (final a in page.items) (activity: a, group: group)];
      } on ApiException catch (e) {
        if (e.isNotFound || e.code == 'not_a_member') {
          gone = true;
          return <FeedItem>[];
        }
        failed++;
        error ??= e;
      } on Exception catch (e) {
        failed++;
        error ??= e;
      }
      return <FeedItem>[];
    }),
  );
  // The list of groups is out of date, so it is loaded again, and this
  // with it.
  if (gone && ref.mounted) ref.invalidate(summariesProvider);
  // With nothing to show, why is worth more than an empty page.
  if (failed > 0 && failed == home.groups.length) throw error!;
  return _mark(
    who,
    ActivityFeed(
      items: perGroup.expand((items) => items).toList()
        ..sort((a, b) => b.activity.createdAt.compareTo(a.activity.createdAt)),
      failed: failed,
    ),
  );
});

/// Reloads everything that shows [token]'s data after a change.
void refreshGroup(WidgetRef ref, String token) => _refresh(ref.invalidate, token);

/// [refreshGroup] for callbacks that may outlive the widget, such as undo.
void refreshGroupIn(ProviderContainer container, String token) => _refresh(container.invalidate, token);

void _refresh(void Function(ProviderOrFamily) invalidate, String token) {
  invalidate(groupProvider(token));
  invalidate(balancesProvider(token));
  invalidate(expensesProvider(token));
  invalidate(statsProvider);
  invalidate(summariesProvider);
  invalidate(activityFeedProvider);
  invalidate(receiptProvider);
  invalidate(recurringProvider(token));
}

/// One expense, for the editor.
final expenseProvider = FutureProvider.autoDispose.family<Expense, ({String token, String id})>((
  ref,
  key,
) async {
  final group = await ref.watch(groupProvider(key.token).future);
  return _load(ref, (_) => groupApi(ref, key.token).expense(key.id, group.minorDigits));
});

/// A group's recurring expenses, the next one due first.
final recurringProvider = FutureProvider.family<List<RecurringExpense>, String>((ref, token) async {
  final group = await ref.watch(groupProvider(token).future);
  return _load(ref, (_) => groupApi(ref, token).recurringExpenses(group.minorDigits));
});

/// One recurring expense, for the editor.
final recurringOneProvider = FutureProvider.autoDispose.family<RecurringExpense, ({String token, String id})>((
  ref,
  key,
) async {
  final group = await ref.watch(groupProvider(key.token).future);
  return _load(ref, (_) => groupApi(ref, key.token).recurringExpense(key.id, group.minorDigits));
});

/// The photo of an expense's receipt.
final receiptProvider = FutureProvider.autoDispose.family<Uint8List, ({String token, String id})>(
  (ref, key) => _load(ref, (_) => groupApi(ref, key.token).receipt(key.id)),
);

/// What a group spent in a period, or all time when it is null.
final statsProvider = FutureProvider.autoDispose.family<GroupStats, ({String token, Period? period})>((
  ref,
  key,
) async {
  final group = await ref.watch(groupProvider(key.token).future);
  return _load(ref, (_) => groupApi(ref, key.token).stats(group.minorDigits, period: key.period));
});
