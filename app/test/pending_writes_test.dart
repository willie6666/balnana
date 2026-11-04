import 'dart:convert';
import 'dart:typed_data';

import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/pending_writes.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = 'https://split.example.com';

/// Keeps what was sent and answers with [statuses] by path, 201 otherwise,
/// or throws a connection error while [down].
class _Server implements HttpClientAdapter {
  var down = false;
  final statuses = <String, int>{};
  final sent = <({String path, String? key, String? member, Object? body})>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (down) throw DioException.connectionError(requestOptions: options, reason: 'down');
    final path = options.uri.path;
    sent.add((
      path: path,
      key: options.headers['Idempotency-Key'] as String?,
      member: options.headers['X-Balnana-Member'] as String?,
      body: options.data,
    ));
    final status = statuses[path] ?? 201;
    return ResponseBody.fromString(
      jsonEncode(status >= 400 ? {'code': status >= 500 ? 'busy' : 'validation_failed'} : {'id': 'e1'}),
      status,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late CacheDb db;
  late _Server server;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = CacheDb(NativeDatabase.memory());
    addTearDown(db.close);
    server = _Server();
    container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        serverUrlProvider.overrideWithValue(_server),
        cacheDbProvider.overrideWithValue(db),
        apiProvider.overrideWithValue(Dio(BaseOptions(baseUrl: '$_server/api/v1'))..httpClientAdapter = server),
        serverInfoProvider.overrideWithValue(
          const AsyncData(ServerInfo(version: 'test', authMode: AuthMode.link, publicUrl: _server)),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(pendingSenderProvider, (_, _) {});
    // What the sender looks for when it starts.
    await Future<void>.delayed(const Duration(milliseconds: 20));
  });

  PendingSender sender() => container.read(pendingSenderProvider.notifier);
  Future<List<PendingWrite>> rows() => db.select(db.pendingWrites).get();
  Future<bool> queue(String title, String key) =>
      sender().queue('tok', PendingPath.expenses, {'title': title}, key);

  test('keeps a write on the device and says the app is offline', () async {
    expect(await queue('Sushi', 'k1'), isTrue);

    final row = (await rows()).single;
    expect((row.server, row.account, row.groupToken, row.path, row.key), (_server, '', 'tok', '/expenses', 'k1'));
    expect(jsonDecode(row.body), {'title': 'Sushi'});
    expect(row.error, isNull);
    expect(container.read(offlineProvider), isTrue);
    expect(server.sent, isEmpty);
  });

  test('sends what waits in order with its key, then forgets it', () async {
    await queue('Sushi', 'k1');
    await queue('Ramen', 'k2');

    await sender().send();

    expect(server.sent.map((s) => (s.path, s.key)), [('/api/v1/g/tok/expenses', 'k1'), ('/api/v1/g/tok/expenses', 'k2')]);
    expect(server.sent.map((s) => s.body), [
      {'title': 'Sushi'},
      {'title': 'Ramen'},
    ]);
    expect(await rows(), isEmpty);
  });

  test('sends once the server is back', () async {
    await queue('Sushi', 'k1');

    container.read(offlineProvider.notifier).set(false);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(server.sent.single.key, 'k1');
    expect(await rows(), isEmpty);
  });

  test('keeps one the server refuses with why, and still sends the rest', () async {
    await sender().queue('tok', PendingPath.payments, {'amount': '1'}, 'k1');
    await queue('Ramen', 'k2');
    server.statuses['/api/v1/g/tok/payments'] = 422;

    await sender().send();

    expect(server.sent.map((s) => s.key), ['k1', 'k2']);
    final parked = (await rows()).single;
    expect((parked.key, parked.error), ('k1', 'validation_failed'));

    // Not sent again until asked.
    await sender().send();
    expect(server.sent, hasLength(2));

    server.statuses.clear();
    await sender().retry(parked);
    expect(server.sent.last.key, 'k1');
    expect(await rows(), isEmpty);
  });

  test('stops while the server is out of reach, so the order stays', () async {
    await queue('Sushi', 'k1');
    await queue('Ramen', 'k2');
    server.down = true;

    // Thought back, but still out of reach.
    container.read(offlineProvider.notifier).set(false);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(await rows(), hasLength(2));
    expect((await rows()).every((w) => w.error == null), isTrue);
    expect(container.read(offlineProvider), isTrue);
  });

  test('stops while the server is busy, without keeping an error', () async {
    await queue('Sushi', 'k1');
    await queue('Ramen', 'k2');
    server.statuses['/api/v1/g/tok/expenses'] = 503;

    await sender().send();

    expect(server.sent, hasLength(1));
    expect((await rows()).map((w) => w.error), [null, null]);
  });

  test('sends nothing kept for another account', () async {
    await db.addPending(
      server: _server,
      account: cacheAccount('someone else'),
      group: 'tok',
      member: null,
      path: PendingPath.expenses,
      body: {'title': 'Theirs'},
      key: 'k1',
    );

    await sender().send();

    expect(server.sent, isEmpty);
    expect(await rows(), hasLength(1));
  });

  test('can be thrown away', () async {
    await queue('Sushi', 'k1');

    await sender().discard((await rows()).single);

    expect(await rows(), isEmpty);
  });
}
