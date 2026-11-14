import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offline_cache_open.dart' if (dart.library.js_interop) 'offline_cache_open_web.dart';

part 'offline_cache.g.dart';

/// The last answer the server gave to a request this app may repeat offline.
@DataClassName('CachedResponse')
class CachedResponses extends Table {
  TextColumn get server => text()();

  /// Whose answer it is: see [cacheAccount] and [CacheDb.public].
  TextColumn get account => text()();

  /// The method, path and query, plus the body for the few cached POSTs.
  TextColumn get request => text()();
  TextColumn get body => text()();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {server, account, request};
}

/// A new expense or payment made while the server was out of reach, sent
/// once it is back. Only adding waits here: a change to something already
/// on the server could clash with someone else's.
@DataClassName('PendingWrite')
class PendingWrites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get server => text()();

  /// Whose it is, as in [CachedResponses.account].
  TextColumn get account => text()();
  TextColumn get groupToken => text()();

  /// The member it is sent as.
  TextColumn get member => text().nullable()();

  /// Where in the group it goes: [PendingPath].
  TextColumn get path => text()();

  /// The JSON sent.
  TextColumn get body => text()();

  /// The Idempotency-Key it is sent with, so sending it twice adds it once.
  TextColumn get key => text()();
  DateTimeColumn get createdAt => dateTime()();

  /// The error code the server refused it with. It waits for the person
  /// to try again or let it go.
  TextColumn get error => text().nullable()();
}

/// Where a [PendingWrite] is sent, after the group's path.
abstract final class PendingPath {
  static const expenses = '/expenses';
  static const payments = '/payments';

  static bool supports(String path) => path == expenses || path == payments;
}

typedef _CacheKey = ({String server, String account, String request});
typedef _CacheScope = (String server, String? path);

/// What this device remembers of each server, to show while it is out of
/// reach. Only the Android app keeps one: the web app comes from the server
/// itself, so it cannot load without it anyway.
@DriftDatabase(tables: [CachedResponses, PendingWrites])
class CacheDb extends _$CacheDb {
  CacheDb(super.executor);

  /// How long an answer is kept after it was last saved.
  static const keep = Duration(days: 90);

  /// The account of answers that are the same for everyone, such as the
  /// server's info.
  static const public = '*';

  /// The account signed in to each server, once that has changed while the
  /// app runs. Answers for any other account are no longer saved.
  final _accounts = <String, String>{};

  int get generation => _generation;
  var _generation = 0;

  /// Generations are local to this process. Rows from earlier runs have
  /// generation zero until they are fetched again.
  final _forgotten = <(String, String, String), int>{};
  final _accountChanged = <String, int>{};
  final _expired = <_CacheScope, int>{};
  final _recheckFrom = <_CacheScope, int>{};

  /// The last response kept for a cache-first request, including removals.
  final _answered = <_CacheKey, int>{};
  final _rechecking = <(_CacheKey, int)>{};

  Future<void>? _cacheWrites;

  /// Serialize writes and check generations when each write reaches the queue.
  Future<T> _writeCache<T>(Future<T> Function() write) async {
    final previous = _cacheWrites;
    final done = Completer<void>();
    _cacheWrites = done.future;
    try {
      if (previous != null) await previous;
      return await write();
    } finally {
      if (identical(_cacheWrites, done.future)) _cacheWrites = null;
      done.complete();
    }
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // Version 1 did not say whose answers it kept; they are let go.
      if (from < 2) {
        await m.deleteTable(cachedResponses.actualTableName);
        await m.createTable(cachedResponses);
      }
      if (from < 3) await m.createTable(pendingWrites);
    },
    beforeOpen: (details) async {
      final cutoff = DateTime.now().subtract(keep);
      await (delete(cachedResponses)..where((r) => r.savedAt.isSmallerThanValue(cutoff))).go();
    },
  );

  /// Keeps [body] if the request is still current. [asked] is its generation
  /// when sent. A direct save gets a new generation.
  Future<bool> save(String server, String account, String request, String body, {int? asked}) {
    final key = (server: server, account: account, request: request);
    return _keepAnswer(key, asked ?? ++_generation, () async {
      await into(cachedResponses).insertOnConflictUpdate(
        CachedResponsesCompanion.insert(
          server: server,
          account: account,
          request: request,
          body: body,
          savedAt: DateTime.now(),
        ),
      );
    });
  }

  /// Forgets an answer after the server confirms it is no longer available.
  Future<bool> _forgetAnswer(_CacheKey key, int asked) => _keepAnswer(key, asked, () async {
    await (delete(cachedResponses)..where(
          (r) => r.server.equals(key.server) & r.account.equals(key.account) & r.request.equals(key.request),
        ))
        .go();
  });

  Future<bool> _keepAnswer(_CacheKey key, int asked, Future<void> Function() write) => _writeCache(() async {
    if (!_canKeep(key, asked)) return false;
    await write();
    if (OfflineCache.showsFirst(key.request)) _answered[key] = asked;
    return _canKeep(key, asked);
  });

  bool _canKeep(_CacheKey key, int asked) {
    final (server, account, request) = (key.server, key.account, key.request);
    final current = _accounts[server];
    if (account != public &&
        ((current != null && current != account) || asked < (_accountChanged[server] ?? 0))) {
      return false;
    }
    final scope = _requestScope(request);
    return asked >= (_answered[key] ?? 0) &&
        asked >= _scopeGeneration(_expired, server, scope) &&
        (!OfflineCache.showsFirst(request) || asked >= _scopeGeneration(_recheckFrom, server, scope)) &&
        (scope == null ||
            (asked >= (_forgotten[(server, account, scope)] ?? 0) &&
                asked >= (_forgotten[(server, public, scope)] ?? 0)));
  }

  /// Requires a server read after a change or a manual refresh. Old rows
  /// remain available for offline use.
  void expire(String server, {String? group}) {
    final generation = ++_generation;
    _expired[(server, group == null ? null : '/g/${Uri.encodeComponent(group)}')] = generation;
    if (group != null) _expired[(server, _lists)] = generation;
  }

  void _expireGroupLists(String server) => _expired[(server, _lists)] = ++_generation;

  /// On reconnect, shows cached data and checks it even if saved recently.
  void recheckGroup(String server, String group) {
    final generation = ++_generation;
    _recheckFrom[(server, '/g/${Uri.encodeComponent(group)}')] = generation;
    _recheckFrom[(server, _lists)] = generation;
  }

  int _expiry(_CacheKey key) => _scopeGeneration(_expired, key.server, _requestScope(key.request));

  int _recheckGeneration(_CacheKey key) =>
      _scopeGeneration(_recheckFrom, key.server, _requestScope(key.request));

  static int _scopeGeneration(Map<_CacheScope, int> generations, String server, String? scope) {
    final all = generations[(server, null)] ?? 0;
    final specific = generations[(server, scope)] ?? 0;
    return specific > all ? specific : all;
  }

  static String? _requestScope(String request) =>
      _groupPath(request) ?? (_isGroupList(request) ? _lists : null);
  static final _groupRequest = RegExp(r'^GET (/g/[^/?]+)');
  static String? _groupPath(String request) => _groupRequest.firstMatch(request)?.group(1);
  static const _lists = 'lists';
  static bool _isGroupList(String request) =>
      request == 'GET /me/groups' || request.startsWith('POST /groups/summaries ');

  Future<CachedResponse?> find(String server, String account, String request) async {
    if (_cacheWrites case final writes?) await writes;
    final cutoff = DateTime.now().subtract(keep);
    final query = select(cachedResponses)
      ..where(
        (r) =>
            r.server.equals(server) &
            r.account.equals(account) &
            r.request.equals(request) &
            r.savedAt.isBiggerOrEqualValue(cutoff),
      );
    return query.getSingleOrNull();
  }

  /// Forgets what [account] was told about [group] on [server], and the
  /// lists of groups that sum it up, once it has changed there. Were the
  /// reload after a change to fail, they would show it as it was before.
  Future<void> forgetGroup(String server, String account, String group) =>
      _forgetGroup(server, group, account: account);

  /// Deletion applies to every account. Late answers must not restore it.
  Future<void> forgetDeletedGroup(String server, String group) => _forgetGroup(server, group);

  Future<void> _forgetGroup(String server, String group, {String? account}) {
    final generation = ++_generation;
    _forgotten[(server, account ?? public, '/g/$group')] = generation;
    _forgotten[(server, account ?? public, _lists)] = generation;
    final groupRequest = 'GET /g/$group';
    return _writeCache(() async {
      await (delete(cachedResponses)..where((r) {
            final sameServer = r.server.equals(server);
            final scope = account == null ? sameServer : sameServer & r.account.equals(account);
            // Tokens are case-sensitive and may contain underscores.
            final prefix = r.request.substr(1, groupRequest.length + 1);
            return scope &
                (r.request.equals(groupRequest) |
                    prefix.equals('$groupRequest/') |
                    prefix.equals('$groupRequest?') |
                    r.request.equals('GET /me/groups') |
                    r.request.like('POST /groups/summaries %'));
          }))
          .go();
    });
  }

  /// Makes [account] the one signed in to [server], forgetting what any
  /// other account saw and saving nothing more for them. Unsent writes stay
  /// with their owner until that account returns or discards them.
  Future<void> switchAccount(String server, String account) {
    _accounts[server] = account;
    _accountChanged[server] = ++_generation;
    return _writeCache(() async {
      await (delete(
        cachedResponses,
      )..where((r) => r.server.equals(server) & r.account.isNotIn([account, public]))).go();
    });
  }

  /// Moves session-keyed writes to their verified account, for older caches.
  Future<void> identifyPending(String server, String session, String account) =>
      (update(pendingWrites)..where((w) => w.server.equals(server) & w.account.equals(session))).write(
        PendingWritesCompanion(account: Value(account)),
      );

  /// What [account] has left to send to [server], oldest first.
  Stream<List<PendingWrite>> watchPending(String server, String account) => _pending(server, account).watch();

  /// What [account] has left to send to [server] now, oldest first.
  Future<List<PendingWrite>> pending(String server, String account) => _pending(server, account).get();

  SimpleSelectStatement<$PendingWritesTable, PendingWrite> _pending(String server, String account) =>
      select(pendingWrites)
        ..where((w) => w.server.equals(server) & w.account.equals(account))
        ..orderBy([(w) => OrderingTerm.asc(w.id)]);

  Future<void> addPending({
    required String server,
    required String account,
    required String group,
    required String? member,
    required String path,
    required Map<String, Object?> body,
    required String key,
  }) => into(pendingWrites).insert(
    PendingWritesCompanion.insert(
      server: server,
      account: account,
      groupToken: group,
      member: Value(member),
      path: path,
      body: jsonEncode(body),
      key: key,
      createdAt: DateTime.now(),
    ),
  );

  Future<void> removePending(int id) => (delete(pendingWrites)..where((w) => w.id.equals(id))).go();

  /// Keeps [id] from being sent again until [retryPending].
  Future<void> parkPending(int id, String error) => (update(
    pendingWrites,
  )..where((w) => w.id.equals(id))).write(PendingWritesCompanion(error: Value(error)));

  Future<void> retryPending(int id) => (update(
    pendingWrites,
  )..where((w) => w.id.equals(id))).write(const PendingWritesCompanion(error: Value(null)));
}

/// The cache account of a session: a hash of its [token], so the token
/// itself is kept only once, or '' when signed out.
String cacheAccount(String? token) =>
    token == null ? '' : sha256.convert(utf8.encode(token)).toString().substring(0, 32);

/// The cache on this device, or null where there is none.
final cacheDbProvider = Provider<CacheDb?>((ref) {
  final executor = openCacheExecutor();
  if (executor == null) return null;
  final db = CacheDb(executor);
  ref.onDispose(db.close);
  return db;
});

/// Whether the server is out of reach and what is shown came from the cache.
final offlineProvider = NotifierProvider<OfflineNotifier, bool>(OfflineNotifier.new);

class OfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool offline) {
    if (state != offline) state = offline;
  }
}

/// Answers that were shown from the cache and then came back different
/// from the server: what showed them is to load again (see OfflineBar).
final freshAnswersProvider = NotifierProvider<FreshAnswers, FreshAnswer?>(FreshAnswers.new);

class FreshAnswer {
  FreshAnswer(this.request);

  /// The request as [OfflineCache] keeps it, such as `GET /g/abc/balances`.
  final String request;
}

class FreshAnswers extends Notifier<FreshAnswer?> {
  @override
  FreshAnswer? build() => null;

  void add(String request) => state = FreshAnswer(request);
}

/// Whether the app has just opened and not yet heard whether the server is
/// there. Meanwhile what was saved is shown at once, as while offline but
/// without the bar. The startup probe in OfflineBar ends it and reloads
/// what was shown from the cache.
///
/// Off unless the app turns it on as it starts (see main.dart).
final warmStartProvider = NotifierProvider<WarmStartNotifier, bool>(() => WarmStartNotifier());

class WarmStartNotifier extends Notifier<bool> {
  WarmStartNotifier({this.on = false});

  final bool on;
  var _served = false;

  @override
  bool build() => on;

  /// Notes that a request was answered from the cache while starting.
  void served() => _served = true;

  /// Ends the start, and returns whether anything shown came from the cache.
  bool end() {
    final served = _served;
    _served = false;
    state = false;
    return served;
  }
}

/// Saves the server's answers and gives them back when it cannot be reached.
///
/// Answers are kept per [_account] (see [cacheAccount]), so no account ever
/// sees what another one saw.
///
/// Once [isOffline] says the server is out of reach, saved answers are given
/// back at once instead of after each request times out. A [probe] client
/// still asks the server every time, so it can tell when it is back. While
/// [isWarm] says the app has just started, every client is answered from
/// what was saved, and [onWarm] hears of it.
///
/// Given a [client], the one this is added to, what a group shows and the
/// lists of groups ([showsFirst]) are answered from what was saved even
/// while online, so they show at once. [client] then asks the server again,
/// and [onFresh] hears of each answer that came back different.
class OfflineCache extends Interceptor {
  OfflineCache(
    this._db,
    this._server,
    this._account,
    this._offline, {
    bool Function()? isOffline,
    bool Function()? isWarm,
    void Function()? onWarm,
    this.probe = false,
    this.client,
    this.onFresh,
  }) : _isOffline = isOffline ?? (() => false),
       _isWarm = isWarm ?? (() => false),
       _onWarm = onWarm ?? (() {});

  final CacheDb _db;
  final String _server;
  final String _account;
  final void Function(bool offline) _offline;
  final bool Function() _isOffline;
  final bool Function() _isWarm;
  final void Function() _onWarm;
  final bool probe;
  final Dio? client;
  final void Function(String request)? onFresh;

  /// An answer saved this recently is shown without asking again.
  static const recheckAfter = Duration(seconds: 5);

  /// What may be shown from the cache before the server is asked: a group,
  /// its balances, the first page of its expenses and changes, what it
  /// spent and its recurring expenses, and the lists of groups. Not one
  /// expense or plan, which editing or paying needs as the server has it,
  /// nor a later page, which follows on from what the server said.
  static bool showsFirst(String request) =>
      _showsFirst.hasMatch(request) && !RegExp(r'[?&]cursor=').hasMatch(request);

  static final _showsFirst = RegExp(
    r'^(GET /g/[^/?]+(/(balances|expenses|stats|activity|recurring))?(\?.*)?|GET /me/groups|POST /groups/summaries .*)$',
  );

  /// Set on a request asking the server again, to the body that was shown.
  static const _recheckKey = 'offlineCacheShown';

  /// POSTs that only read, and so may be answered from the cache.
  static const _readingPosts = {'/groups/summaries'};

  static const _askedKey = 'offlineCacheAsked';

  /// The cache key for [options], or null when its answer is not kept.
  String? _key(RequestOptions options) {
    if (options.responseType != ResponseType.json) return null;
    final path = options.path;
    final query = options.uri.query;
    final request = '${options.method} $path${query.isEmpty ? '' : '?$query'}';
    if (options.method == 'GET') return request;
    if (options.method == 'POST' && _readingPosts.contains(path)) {
      return '$request ${jsonEncode(options.data)}';
    }
    return null;
  }

  Future<CachedResponse?> _find(String key) async {
    try {
      return await _db.find(_server, _account, key);
    } on Object {
      return null;
    }
  }

  static Response<dynamic> _answer(RequestOptions options, CachedResponse saved) => Response<dynamic>(
    requestOptions: options,
    data: jsonDecode(saved.body),
    statusCode: 200,
    extra: {'savedAt': saved.savedAt},
  );

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra.containsKey(_recheckKey)) return handler.next(options);
    final key = _key(options);
    if (key == null) return handler.next(options);
    if (!_isWarm() && (probe || !_isOffline())) return _showFirst(options, handler, key);
    final saved = await _find(key);
    if (saved == null) return _ask(options, handler);
    // The startup probe or a live request may have finished during the lookup.
    final warm = _isWarm();
    if (!warm && (probe || !_isOffline())) return _ask(options, handler);
    if (warm) _onWarm();
    handler.resolve(_answer(options, saved));
  }

  void _ask(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_askedKey] = ++_db._generation;
    handler.next(options);
  }

  /// Answers what [showsFirst] from what was saved, then asks the server
  /// again; anything else, or what has nothing saved, goes to the server.
  Future<void> _showFirst(RequestOptions options, RequestInterceptorHandler handler, String key) async {
    final client = this.client;
    if (client == null || probe || !showsFirst(key)) return _ask(options, handler);
    final cacheKey = (server: _server, account: _account, request: key);
    final beforeLookup = _db._answered[cacheKey] ?? 0;
    final saved = await _find(key);
    // A write may have completed during the lookup. Use the generation
    // observed before it so an older snapshot cannot pass a later expiry.
    if (saved == null || beforeLookup < _db._expiry(cacheKey)) return _ask(options, handler);
    handler.resolve(_answer(options, saved));
    final recheckFrom = _db._recheckGeneration(cacheKey);
    if (beforeLookup < recheckFrom || DateTime.now().difference(saved.savedAt) >= recheckAfter) {
      unawaited(_recheck(client, options, cacheKey, saved, recheckFrom));
    }
  }

  /// Asks the server again for what [saved] answered: see [onResponse].
  Future<void> _recheck(
    Dio client,
    RequestOptions options,
    _CacheKey key,
    CachedResponse saved,
    int recheckFrom,
  ) async {
    final asking = (key, recheckFrom);
    if (!_db._rechecking.add(asking)) return;
    try {
      await client.fetch<Object?>(
        options.copyWith(extra: {...options.extra, _recheckKey: saved.body, _askedKey: ++_db._generation}),
      );
    } on Object {
      // What was shown stays; onError has told whether the server is there.
    } finally {
      _db._rechecking.remove(asking);
    }
  }

  @override
  Future<void> onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {
    _offline(false);
    final options = response.requestOptions;
    final key = _key(options);
    final data = response.data;
    if (key != null && response.statusCode == 200 && (data is Map || data is List)) {
      final body = jsonEncode(data);
      final save = _db.save(_server, _account, key, body, asked: options.extra[_askedKey] as int?);
      if (options.extra[_recheckKey] case final String shown) {
        try {
          // Kept before anyone hears of it, so the reload shows it.
          if (await save && body != shown) onFresh?.call(key);
        } on Object {
          // The cache only helps.
        }
      } else {
        unawaited(save.catchError((Object _) => false));
      }
    } else if (options.method == 'POST' &&
        response.statusCode == 201 &&
        (options.path == '/groups' || options.path == '/groups/import')) {
      _db._expireGroupLists(_server);
    } else if (key == null && options.method != 'GET') {
      // A change to a group: what was saved of it is out of date. This is
      // done before the caller hears back, and so before it reloads.
      final group = RegExp(r'^/g/([^/?]+)').firstMatch(options.path)?.group(1);
      if (group != null) {
        try {
          await _db.forgetGroup(_server, _account, group);
        } on Object {
          // The cache only helps; a change is not undone for it.
        }
      }
    }
    handler.next(response);
  }

  /// Whether [response] is a proxy in front of the server saying it cannot
  /// reach it. The server's own errors always carry a code.
  static bool isGatewayError(Response<dynamic> response) {
    final data = response.data;
    return const {502, 503, 504}.contains(response.statusCode) && !(data is Map && data['code'] is String);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response != null && !isGatewayError(response)) {
      _offline(false);
      // Only authoritative removals or access denials evict saved answers.
      final key = _key(err.requestOptions);
      final extra = err.requestOptions.extra;
      final asked = extra[_askedKey];
      if (key != null && asked is int && showsFirst(key) && _answerUnavailable(response)) {
        try {
          final removed = await _db._forgetAnswer((server: _server, account: _account, request: key), asked);
          if (removed && extra.containsKey(_recheckKey)) onFresh?.call(key);
        } on Object {
          // The cache only helps.
        }
      }
      return handler.next(err);
    }
    final key = _key(err.requestOptions);
    final unreachable = switch (err.type) {
      _ when response != null => true,
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.unknown => true,
      _ => false,
    };
    if (key == null || !unreachable) return handler.next(err);
    final saved = await _find(key);
    if (saved == null) return handler.next(err);
    _offline(true);
    handler.resolve(_answer(err.requestOptions, saved));
  }

  static bool _answerUnavailable(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map) return false;
    return switch ((response.statusCode, data['code'])) {
      (401, 'sign_in_required') || (403, 'not_a_member' || 'email_unverified') || (404, 'not_found') => true,
      _ => false,
    };
  }
}
