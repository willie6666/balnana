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

  /// Counts [forgetGroup] calls. A request notes it when asked, so its
  /// answer can tell whether a change came after it.
  int get forgets => _forgets;
  var _forgets = 0;

  /// When each group, and any group's lists, were last forgotten: the
  /// [forgets] count just after, keyed by server, account and group.
  final _forgotten = <String, int>{};

  /// When what was saved of each group, of the lists of groups, or of a
  /// whole server, stopped being shown before the server is asked: see
  /// [expire]. Keyed as in [_expiryKeys].
  final _expired = <String, DateTime>{};

  /// Requests being asked again behind an answer shown from the cache, by
  /// server, account and request, so each is asked once at a time.
  final rechecking = <String>{};

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

  /// Keeps [body] as the answer to [request]. [asked] is [forgets] when the
  /// request was sent: an answer asked before its group changed may show it
  /// as it was, and is not kept.
  /// Returns whether it was kept.
  Future<bool> save(String server, String account, String request, String body, {int? asked}) async {
    // An answer still on its way when its account signed out stays unsaved.
    final current = _accounts[server];
    if (account != public && current != null && current != account) return false;
    if (asked != null &&
        (asked < (_forgotten[_forgetKey(server, account, request)] ?? 0) ||
            asked < (_forgotten[_forgetKey(server, public, request)] ?? 0))) {
      return false;
    }
    await into(cachedResponses).insertOnConflictUpdate(
      CachedResponsesCompanion.insert(
        server: server,
        account: account,
        request: request,
        body: body,
        savedAt: DateTime.now(),
      ),
    );
    return true;
  }

  /// Forgets the answer to [request], which the server no longer gives.
  Future<void> forget(String server, String account, String request) => (delete(
    cachedResponses,
  )..where((r) => r.server.equals(server) & r.account.equals(account) & r.request.equals(request))).go();

  /// Has the server asked first, rather than [OfflineCache] showing what was
  /// saved meanwhile, for what is shown of [group] on [server] and the lists
  /// of groups, or for everything there when [group] is null. For when what
  /// was saved is known to be out of date, as after a change someone else
  /// made, or when the person asks to see it as it is now. Applies to what
  /// was saved until now; what the server answers next is shown first again.
  void expire(String server, {String? group}) {
    // Saved times keep whole seconds, so an answer saved in the same second
    // counts as new; the reload that follows saves over it anyway.
    final now = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch ~/ 1000 * 1000);
    if (group == null) {
      _expired[server] = now;
    } else {
      _expired['$server /g/${Uri.encodeComponent(group)}'] = now;
      _expired['$server lists'] = now;
    }
  }

  /// Whether the answer to [request] saved at [savedAt] has expired: see [expire].
  bool isExpired(String server, String request, DateTime savedAt) => _expiryKeys(server, request).any((key) {
    final at = _expired[key];
    return at != null && savedAt.isBefore(at);
  });

  static List<String> _expiryKeys(String server, String request) {
    final group = RegExp(r'^GET (/g/[^/?]+)').firstMatch(request)?.group(1);
    final lists = request == 'GET /me/groups' || request.startsWith('POST /groups/summaries ');
    return [server, if (group != null) '$server $group', if (lists) '$server lists'];
  }

  Future<CachedResponse?> find(String server, String account, String request) {
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
    _forgets++;
    final accountKey = '$server ${account ?? public}';
    _forgotten['$accountKey /g/$group'] = _forgets;
    _forgotten[accountKey] = _forgets;
    final groupRequest = 'GET /g/$group';
    return (delete(cachedResponses)..where((r) {
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
  }

  /// Where [save] finds when what [request] asks for was last forgotten:
  /// its group, or for the lists of groups, any group.
  static String _forgetKey(String server, String account, String request) {
    final group = RegExp(r'^GET (/g/[^/?]+)').firstMatch(request)?.group(1);
    if (group != null) return '$server $account $group';
    final lists = request == 'GET /me/groups' || request.startsWith('POST /groups/summaries ');
    return lists ? '$server $account' : '';
  }

  /// Makes [account] the one signed in to [server], forgetting what any
  /// other account saw and saving nothing more for them. Unsent writes stay
  /// with their owner until that account returns or discards them.
  Future<void> switchAccount(String server, String account) async {
    _accounts[server] = account;
    final others = delete(cachedResponses)
      ..where((r) => r.server.equals(server) & r.account.isNotIn([account, public]));
    await others.go();
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
    options.extra[_askedKey] = _db.forgets;
    if (options.extra.containsKey(_recheckKey)) return handler.next(options);
    if (!_isWarm() && (probe || !_isOffline())) return _showFirst(options, handler);
    final key = _key(options);
    if (key == null) return handler.next(options);
    final saved = await _find(key);
    if (saved == null) return handler.next(options);
    // The startup probe or a live request may have finished during the lookup.
    final warm = _isWarm();
    if (!warm && (probe || !_isOffline())) return handler.next(options);
    if (warm) _onWarm();
    handler.resolve(_answer(options, saved));
  }

  /// Answers what [showsFirst] from what was saved, then asks the server
  /// again; anything else, or what has nothing saved, goes to the server.
  Future<void> _showFirst(RequestOptions options, RequestInterceptorHandler handler) async {
    final key = _key(options);
    final client = this.client;
    if (client == null || probe || key == null || !showsFirst(key)) return handler.next(options);
    final saved = await _find(key);
    if (saved == null || _db.isExpired(_server, key, saved.savedAt)) return handler.next(options);
    handler.resolve(_answer(options, saved));
    if (DateTime.now().difference(saved.savedAt) >= recheckAfter) unawaited(_recheck(client, options, key, saved));
  }

  /// Asks the server again for what [saved] answered: see [onResponse].
  Future<void> _recheck(Dio client, RequestOptions options, String key, CachedResponse saved) async {
    final asking = '$_server $_account $key';
    if (!_db.rechecking.add(asking)) return;
    try {
      await client.fetch<Object?>(options.copyWith(extra: {...options.extra, _recheckKey: saved.body}));
    } on Object {
      // What was shown stays; onError has told whether the server is there.
    } finally {
      _db.rechecking.remove(asking);
    }
  }

  @override
  Future<void> onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {
    _offline(false);
    final options = response.requestOptions;
    final key = _key(options);
    if (options.extra[_recheckKey] case final String shown when key != null) {
      final data = response.data;
      if (response.statusCode == 200 && (data is Map || data is List)) {
        final body = jsonEncode(data);
        try {
          // Kept before anyone hears of it, so the reload shows it.
          final kept = await _db.save(_server, _account, key, body, asked: options.extra[_askedKey] as int?);
          if (kept && body != shown) onFresh?.call(key);
        } on Object {
          // The cache only helps.
        }
      }
    } else if (key != null && response.statusCode == 200 && response.data != null) {
      // Anything else is not this API: a captive portal's page, answered 200.
      if (response.data is Map || response.data is List) {
        unawaited(
          _db
              .save(
                _server,
                _account,
                key,
                jsonEncode(response.data),
                asked: options.extra[_askedKey] as int?,
              )
              .catchError((Object _) => false),
        );
      }
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
      // Asked again behind what was shown, the server now refuses it, as
      // for a group that is gone: the reload shows why.
      final key = _key(err.requestOptions);
      if (key != null && err.requestOptions.extra.containsKey(_recheckKey)) {
        try {
          await _db.forget(_server, _account, key);
          onFresh?.call(key);
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
}
