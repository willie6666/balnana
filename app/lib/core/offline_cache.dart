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

/// What this device remembers of each server, to show while it is out of
/// reach. Only the Android app keeps one: the web app comes from the server
/// itself, so it cannot load without it anyway.
@DriftDatabase(tables: [CachedResponses])
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

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // Version 1 did not say whose answers it kept; they are let go.
      if (from < 2) {
        await m.deleteTable(cachedResponses.actualTableName);
        await m.createTable(cachedResponses);
      }
    },
    beforeOpen: (details) async {
      final cutoff = DateTime.now().subtract(keep);
      await (delete(cachedResponses)..where((r) => r.savedAt.isSmallerThanValue(cutoff))).go();
    },
  );

  Future<void> save(String server, String account, String request, String body) async {
    // An answer still on its way when its account signed out stays unsaved.
    final current = _accounts[server];
    if (account != public && current != null && current != account) return;
    await into(cachedResponses).insertOnConflictUpdate(
      CachedResponsesCompanion.insert(
        server: server,
        account: account,
        request: request,
        body: body,
        savedAt: DateTime.now(),
      ),
    );
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
  Future<void> forgetGroup(String server, String account, String group) {
    final stale = delete(cachedResponses)
      ..where(
        (r) =>
            r.server.equals(server) &
            r.account.equals(account) &
            (r.request.equals('GET /g/$group') |
                r.request.like('GET /g/$group/%') |
                r.request.like('GET /g/$group?%') |
                r.request.equals('GET /me/groups') |
                r.request.like('POST /groups/summaries %')),
      );
    return stale.go();
  }

  /// Makes [account] the one signed in to [server], forgetting what any
  /// other account saw there and saving nothing more for them.
  Future<void> switchAccount(String server, String account) {
    _accounts[server] = account;
    final others = delete(cachedResponses)
      ..where((r) => r.server.equals(server) & r.account.isNotIn([account, public]));
    return others.go();
  }
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

/// Saves the server's answers and gives them back when it cannot be reached.
///
/// Answers are kept per [_account] (see [cacheAccount]), so no account ever
/// sees what another one saw.
///
/// Once [isOffline] says the server is out of reach, saved answers are given
/// back at once instead of after each request times out. A [probe] client
/// still asks the server every time, so it can tell when it is back.
class OfflineCache extends Interceptor {
  OfflineCache(
    this._db,
    this._server,
    this._account,
    this._offline, {
    bool Function()? isOffline,
    this.probe = false,
  }) : _isOffline = isOffline ?? (() => false);

  final CacheDb _db;
  final String _server;
  final String _account;
  final void Function(bool offline) _offline;
  final bool Function() _isOffline;
  final bool probe;

  /// POSTs that only read, and so may be answered from the cache.
  static const _readingPosts = {'/groups/summaries'};

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
    final key = probe || !_isOffline() ? null : _key(options);
    final saved = key == null ? null : await _find(key);
    if (saved == null) return handler.next(options);
    handler.resolve(_answer(options, saved));
  }

  @override
  Future<void> onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {
    _offline(false);
    final options = response.requestOptions;
    final key = _key(options);
    if (key != null && response.statusCode == 200 && response.data != null) {
      unawaited(_db.save(_server, _account, key, jsonEncode(response.data)).catchError((Object _) {}));
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

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response != null) {
      _offline(false);
      return handler.next(err);
    }
    final key = _key(err.requestOptions);
    final unreachable = switch (err.type) {
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
