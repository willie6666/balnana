import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offline_cache_open.dart' if (dart.library.js_interop) 'offline_cache_open_web.dart';

part 'offline_cache.g.dart';

/// The last answer the server gave to a request this app may repeat offline.
@DataClassName('CachedResponse')
class CachedResponses extends Table {
  TextColumn get server => text()();

  /// The method, path and query, plus the body for the few cached POSTs.
  TextColumn get request => text()();
  TextColumn get body => text()();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {server, request};
}

/// What this device remembers of each server, to show while it is out of
/// reach. Only the Android app keeps one: the web app comes from the server
/// itself, so it cannot load without it anyway.
@DriftDatabase(tables: [CachedResponses])
class CacheDb extends _$CacheDb {
  CacheDb(super.executor);

  /// How long an answer is kept after it was last saved.
  static const keep = Duration(days: 90);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      final cutoff = DateTime.now().subtract(keep);
      await (delete(cachedResponses)..where((r) => r.savedAt.isSmallerThanValue(cutoff))).go();
    },
  );

  Future<void> save(String server, String request, String body) => into(cachedResponses).insertOnConflictUpdate(
    CachedResponsesCompanion.insert(server: server, request: request, body: body, savedAt: DateTime.now()),
  );

  Future<CachedResponse?> find(String server, String request) => (select(
    cachedResponses,
  )..where((r) => r.server.equals(server) & r.request.equals(request))).getSingleOrNull();

  /// Forgets everything saved from [server], such as when signing out.
  Future<void> forget(String server) => (delete(cachedResponses)..where((r) => r.server.equals(server))).go();
}

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
class OfflineCache extends Interceptor {
  OfflineCache(this._db, this._server, this._offline);

  final CacheDb _db;
  final String _server;
  final void Function(bool offline) _offline;

  /// POSTs that only read, and so may be answered from the cache.
  static const _readingPosts = {'/groups/summaries'};

  /// The cache key for [options], or null when its answer is not kept.
  String? _key(RequestOptions options) {
    if (options.responseType != ResponseType.json) return null;
    final path = options.path;
    final query = options.uri.query;
    final request = '${options.method} $path${query.isEmpty ? '' : '?$query'}';
    if (options.method == 'GET') return request;
    if (options.method == 'POST' && _readingPosts.contains(path)) return '$request ${jsonEncode(options.data)}';
    return null;
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _offline(false);
    final key = _key(response.requestOptions);
    if (key != null && response.statusCode == 200 && response.data != null) {
      unawaited(_db.save(_server, key, jsonEncode(response.data)).catchError((Object _) {}));
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
    CachedResponse? saved;
    try {
      saved = await _db.find(_server, key);
    } on Object {
      saved = null;
    }
    if (saved == null) return handler.next(err);
    _offline(true);
    handler.resolve(
      Response<dynamic>(
        requestOptions: err.requestOptions,
        data: jsonDecode(saved.body),
        statusCode: 200,
        extra: {'savedAt': saved.savedAt},
      ),
    );
  }
}
