import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/core/session.dart';
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
      jsonEncode(
        status >= 400
            ? {
                'code': status == 401
                    ? 'sign_in_required'
                    : status >= 500
                    ? 'busy'
                    : 'validation_failed',
              }
            : {'id': 'e1'},
      ),
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
  late String chosenServer;

  setUp(() async {
    chosenServer = _server;
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = CacheDb(NativeDatabase.memory());
    addTearDown(db.close);
    server = _Server();
    container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        serverUrlProvider.overrideWith((ref) => chosenServer),
        cacheDbProvider.overrideWithValue(db),
        apiProvider.overrideWithValue(
          Dio(BaseOptions(baseUrl: '$_server/api/v1'))..httpClientAdapter = server,
        ),
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

  PendingTarget target() => (
    identity: container.read(identityProvider),
    account: container.read(sessionProvider).pendingAccount,
    member: 'ana',
  );

  PendingSender sender() => container.read(pendingSenderProvider.notifier);
  Future<List<PendingWrite>> rows() => db.select(db.pendingWrites).get();
  Future<bool> queue(String title, String key) =>
      sender().queue('tok', PendingPath.expenses, {'title': title}, key, target: target());

  test('keeps a write on the device and says the app is offline', () async {
    expect(await queue('Sushi', 'k1'), isTrue);

    final row = (await rows()).single;
    expect(
      (row.server, row.account, row.groupToken, row.path, row.key),
      (_server, '', 'tok', '/expenses', 'k1'),
    );
    expect(jsonDecode(row.body), {'title': 'Sushi'});
    expect(row.error, isNull);
    expect(container.read(offlineProvider), isTrue);
    expect(server.sent, isEmpty);
  });

  test('sends what waits in order with its key, then forgets it', () async {
    await queue('Sushi', 'k1');
    await queue('Ramen', 'k2');

    await sender().send();

    expect(server.sent.map((s) => (s.path, s.key)), [
      ('/api/v1/g/tok/expenses', 'k1'),
      ('/api/v1/g/tok/expenses', 'k2'),
    ]);
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
    await sender().queue('tok', PendingPath.payments, {'amount': '1'}, 'k1', target: target());
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

  test('a broken local row does not stop later drafts from sending', () async {
    await queue('Sushi', 'k1');
    await queue('Ramen', 'k2');
    await queue('Udon', 'k3');
    await db.customStatement('update pending_writes set body = ?', ['broken JSON']);
    await db.customStatement('update pending_writes set body = ?, path = ? where "key" = ?', [
      '{}',
      '/other',
      'k2',
    ]);
    await db.customStatement('update pending_writes set body = ? where "key" = ?', ['{}', 'k3']);

    await sender().send();

    expect(server.sent.single.key, 'k3');
    expect((await rows()).map((w) => (w.key, w.error)), [('k1', 'bad_request'), ('k2', 'bad_request')]);
  });

  test('a pending row from the previous account cannot be discarded or retried', () async {
    await queue('Sushi', 'k1');
    final row = (await rows()).single;
    await db.parkPending(row.id, 'validation_failed');
    final who = container.read(identityProvider);
    container.read(sessionProvider.notifier).set('other-account', from: who);

    await sender().discard(row);
    await sender().retry(row);

    expect((await rows()).single.error, 'validation_failed');
    expect(server.sent, isEmpty);
  });

  test('a late failure keeps its original server, account and member', () async {
    final session = container.read(sessionProvider.notifier);
    session.set('a-token', from: container.read(identityProvider), userId: 'ana');
    final original = target();
    chosenServer = 'https://other.example';
    container.invalidate(serverUrlProvider);
    await sender().queue('tok', PendingPath.expenses, {'title': 'Sushi'}, 'original', target: original);
    final row = (await rows()).single;
    expect((row.server, row.account, row.member), (_server, 'user:ana', 'ana'));
    await sender().send();
    expect(server.sent, isEmpty);
    expect(container.read(offlineProvider), isFalse);
  });

  test('expired authentication keeps all drafts until their owner signs in again', () async {
    final session = container.read(sessionProvider.notifier);
    session.set('expired', from: container.read(identityProvider), userId: 'ana');
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await queue('Sushi', 'k1');
    await queue('Ramen', 'k2');
    server.statuses['/api/v1/g/tok/expenses'] = 401;
    await sender().send();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(container.read(sessionProvider).token, isNull);
    expect(await rows(), hasLength(2));
    expect((await rows()).every((w) => w.error == null && w.account == 'user:ana'), isTrue);

    session.set('ben-token', from: container.read(identityProvider), userId: 'ben');
    await sender().send();
    expect(await rows(), hasLength(2));
    server.statuses.clear();
    server.sent.clear();
    session.set('renewed', from: container.read(identityProvider), userId: 'ana');
    await sender().send();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(await rows(), isEmpty);
    expect(server.sent.map((s) => s.key), ['k1', 'k2']);
  });

  test('session-keyed drafts migrate only when their account is identified', () async {
    final session = container.read(sessionProvider.notifier);
    session.set('legacy', from: container.read(identityProvider));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await queue('Sushi', 'legacy-key');
    expect((await rows()).single.account, cacheAccount('legacy'));
    server.down = true;
    session.identify(container.read(identityProvider), 'ana');
    await sender().send();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect((await rows()).single.account, 'user:ana');
    // The association is persisted across application restarts.
    final prefs = container.read(prefsProvider);
    final reopened = ProviderContainer(
      overrides: [prefsProvider.overrideWithValue(prefs), serverUrlProvider.overrideWithValue(_server)],
    );
    addTearDown(reopened.dispose);
    expect(reopened.read(sessionProvider).pendingAccount, 'user:ana');
  });

  test('429 and 503 retry automatically without changing keys or order', () async {
    for (final status in [429, 503]) {
      server.sent.clear();
      await queue('Sushi', 'k1');
      await queue('Ramen', 'k2');
      server.statuses['/api/v1/g/tok/expenses'] = status;
      await sender().send();
      expect(server.sent.map((s) => s.key), ['k1']);
      server.statuses.clear();
      final deadline = DateTime.now().add(const Duration(seconds: 4));
      while ((await rows()).isNotEmpty && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      expect(await rows(), isEmpty);
      expect(server.sent.map((s) => s.key), ['k1', 'k1', 'k2']);
    }
  });
}
