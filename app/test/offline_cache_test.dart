import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:balnana/app.dart';
import 'package:balnana/core/l10n.dart';
import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/push.dart';
import 'package:balnana/core/router.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/core/session.dart';
import 'package:balnana/core/settings.dart';
import 'package:balnana/data/api.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/ui/widgets/offline_bar.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = 'https://split.example.com';
const _info = ServerInfo(version: '1', authMode: AuthMode.link, publicUrl: _server);

class _HeldCache extends CacheDb {
  _HeldCache() : super(NativeDatabase.memory());

  final reading = Completer<void>();
  final release = Completer<void>();

  @override
  Future<CachedResponse?> find(String server, String account, String request) async {
    reading.complete();
    await release.future;
    return CachedResponse(
      server: server,
      account: account,
      request: request,
      body: '{}',
      savedAt: DateTime.now(),
    );
  }
}

/// Answers with [status] and a body naming the request and who asked, or
/// throws a connection error while [down]. Answers wait for [hold] if set.
class _Server implements HttpClientAdapter {
  var down = false;
  var status = 200;
  var calls = 0;
  var plain = false;
  Future<void>? hold;
  Completer<void>? started;
  RequestOptions? firstRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final call = ++calls;
    firstRequest ??= options;
    final hold = this.hold;
    final status = this.status;
    if (started case final signal? when !signal.isCompleted) signal.complete();
    if (down) throw DioException.connectionError(requestOptions: options, reason: 'down');
    final who = options.headers['Authorization'];
    await hold;
    if (plain) {
      return ResponseBody.fromString(
        '<html>',
        status,
        headers: {
          'content-type': ['text/html'],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode(switch (status) {
        401 => {'code': 'sign_in_required'},
        403 => {'code': 'not_a_member'},
        404 => {'code': 'not_found'},
        >= 400 => {'code': 'busy'},
        _ => {'path': options.uri.path, 'call': call, 'who': who},
      }),
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
  late Dio dio;
  late List<bool> offline;

  setUp(() {
    db = CacheDb(NativeDatabase.memory());
    server = _Server();
    offline = [];
    dio = Dio(BaseOptions(baseUrl: '$_server/api/v1'))
      ..httpClientAdapter = server
      ..interceptors.add(OfflineCache(db, _server, '', offline.add));
  });

  tearDown(() => db.close());

  Future<void> saved() => Future<void>.delayed(const Duration(milliseconds: 20));

  test('a rejected session can be cleared while the account loads', () async {
    SharedPreferences.setMockInitialValues({});
    server.status = 401;
    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(await SharedPreferences.getInstance()),
        serverUrlProvider.overrideWithValue(_server),
        cacheDbProvider.overrideWithValue(db),
        apiProvider.overrideWithValue(dio),
        serverInfoProvider.overrideWithValue(
          const AsyncData(ServerInfo(version: 'test', authMode: AuthMode.accounts, publicUrl: _server)),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(sessionProvider.notifier).set('expired', from: container.read(identityProvider));
    expect(await container.read(accountProvider.future), isNull);
    await saved();
    expect(container.read(sessionProvider).token, isNull);
  });

  test('shows the last answer while the server is out of reach', () async {
    final first = await dio.get<Object?>('/g/tok', queryParameters: {'a': '1'});
    await saved();
    server.down = true;
    final again = await dio.get<Object?>('/g/tok', queryParameters: {'a': '1'});
    expect(again.data, first.data);
    expect(again.extra['savedAt'], isA<DateTime>());
    expect(offline, [false, true]);

    // Another query was never saved.
    await expectLater(dio.get<Object?>('/g/tok', queryParameters: {'a': '2'}), throwsA(isA<DioException>()));

    server.down = false;
    await dio.get<Object?>('/g/tok');
    expect(offline.last, isFalse);
  });

  test('once offline, saved answers come back without asking the server', () async {
    var known = false;
    Dio client({bool probe = false}) => Dio(BaseOptions(baseUrl: '$_server/api/v1'))
      ..httpClientAdapter = server
      ..interceptors.add(OfflineCache(db, _server, '', offline.add, isOffline: () => known, probe: probe));

    final first = await client().get<Object?>('/g/tok');
    await saved();
    known = true;
    final calls = server.calls;
    final again = await client().get<Object?>('/g/tok');
    expect(again.data, first.data);
    expect(again.extra['savedAt'], isA<DateTime>());
    expect(server.calls, calls);

    // What was never saved, writes, and the probe still go to the server.
    await client().get<Object?>('/g/other');
    await client().post<Object?>('/g/tok/expenses', data: {'title': 'x'});
    await client(probe: true).get<Object?>('/g/other');
    expect(server.calls, calls + 3);
  });

  test('while the app starts, every client answers from what was saved', () async {
    var warm = false, served = 0;
    Dio client({bool probe = false}) => Dio(BaseOptions(baseUrl: '$_server/api/v1'))
      ..httpClientAdapter = server
      ..interceptors.add(
        OfflineCache(db, _server, '', offline.add, isWarm: () => warm, onWarm: () => served++, probe: probe),
      );

    final first = await client().get<Object?>('/me');
    await client(probe: true).get<Object?>('/server-info');
    await saved();
    warm = true;
    final calls = server.calls;
    expect((await client().get<Object?>('/me')).data, first.data);
    await client(probe: true).get<Object?>('/server-info');
    expect(server.calls, calls);
    expect(served, 2);
    // Without the bar: the server was not found out of reach.
    expect(offline, [false, false]);

    // What was never saved still goes to the server, unremarked.
    await client().get<Object?>('/g/other');
    expect(server.calls, calls + 1);
    expect(served, 2);
  });

  test('a cache lookup finishing after warm start goes to the server', () async {
    final cache = _HeldCache();
    addTearDown(cache.close);
    var warm = true;
    var served = false;
    final client = Dio(BaseOptions(baseUrl: '$_server/api/v1'))
      ..httpClientAdapter = server
      ..interceptors.add(
        OfflineCache(
          cache,
          _server,
          CacheDb.public,
          (_) {},
          probe: true,
          isWarm: () => warm,
          onWarm: () => served = true,
        ),
      );
    addTearDown(client.close);

    final response = client.get<Object?>('/server-info');
    await cache.reading.future;
    warm = false;
    cache.release.complete();

    expect((await response).extra, isNot(contains('savedAt')));
    expect(server.calls, 1);
    expect(served, isFalse);
  });

  test('keeps reading POSTs by body, and nothing else that writes', () async {
    await dio.post<Object?>('/g/tok/expenses', data: {'title': 'x'});
    await dio.post<Object?>(
      '/groups/summaries',
      data: {
        'tokens': ['a'],
      },
    );
    await saved();
    server.down = true;
    final summaries = await dio.post<Object?>(
      '/groups/summaries',
      data: {
        'tokens': ['a'],
      },
    );
    expect((summaries.data as Map)['path'], '/api/v1/groups/summaries');
    await expectLater(
      dio.post<Object?>(
        '/groups/summaries',
        data: {
          'tokens': ['b'],
        },
      ),
      throwsA(isA<DioException>()),
    );
    await expectLater(
      dio.post<Object?>('/g/tok/expenses', data: {'title': 'x'}),
      throwsA(isA<DioException>()),
    );
  });

  test('a change to a group forgets what was saved of it', () async {
    await dio.get<Object?>('/g/tok');
    await dio.get<Object?>('/g/tok/expenses', queryParameters: {'limit': '50'});
    await dio.get<Object?>('/g/other');
    await dio.post<Object?>(
      '/groups/summaries',
      data: {
        'tokens': ['tok'],
      },
    );
    await saved();
    await dio.post<Object?>('/g/tok/expenses', data: {'title': 'x'});
    server.down = true;
    await expectLater(dio.get<Object?>('/g/tok'), throwsA(isA<DioException>()));
    await expectLater(
      dio.get<Object?>('/g/tok/expenses', queryParameters: {'limit': '50'}),
      throwsA(isA<DioException>()),
    );
    await expectLater(
      dio.post<Object?>(
        '/groups/summaries',
        data: {
          'tokens': ['tok'],
        },
      ),
      throwsA(isA<DioException>()),
    );
    // Other groups keep theirs.
    await dio.get<Object?>('/g/other');
  });

  test('a page from a proxy is not saved as an answer', () async {
    server.plain = true;
    await dio.get<Object?>('/g/tok');
    await saved();
    server.down = true;
    await expectLater(dio.get<Object?>('/g/tok'), throwsA(isA<DioException>()));
  });

  test('an error from the server is not covered up', () async {
    await dio.get<Object?>('/g/tok');
    await saved();
    server.status = 404;
    await expectLater(
      dio.get<Object?>('/g/tok'),
      throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 404)),
    );
    expect(offline, everyElement(isFalse));
  });

  test('a proxy that cannot reach the server shows the last answer', () async {
    final first = await dio.get<Object?>('/g/tok');
    await saved();
    server
      ..status = 502
      ..plain = true;
    expect((await dio.get<Object?>('/g/tok')).data, first.data);
    expect(offline.last, isTrue);
  });

  test("the server's own busy answer is not covered up", () async {
    await dio.get<Object?>('/g/tok');
    await saved();
    server.status = 503;
    await expectLater(
      dio.get<Object?>('/g/tok'),
      throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 503)),
    );
    expect(offline, everyElement(isFalse));
  });

  test('an answer asked before a change to its group is not kept', () async {
    final release = Completer<void>();
    server.hold = release.future;
    final before = dio.get<Object?>('/g/tok');
    final lists = dio.get<Object?>('/me/groups');
    final other = dio.get<Object?>('/g/other');
    await saved();
    server.hold = null;
    await dio.post<Object?>('/g/tok/expenses', data: {'title': 'x'});
    release.complete();
    await (before, lists, other).wait;
    await saved();
    server.down = true;
    await expectLater(dio.get<Object?>('/g/tok'), throwsA(isA<DioException>()));
    await expectLater(dio.get<Object?>('/me/groups'), throwsA(isA<DioException>()));
    await dio.get<Object?>('/g/other');
  });

  test('invalidating one group preserves groups with similar tokens', () async {
    const requests = ['GET /g/A_B/expenses', 'GET /g/A-B/expenses', 'GET /g/a_b/expenses'];
    for (final request in requests) {
      await db.save(_server, '', request, '{}');
    }

    await db.forgetGroup(_server, '', 'A_B');

    expect(await db.find(_server, '', requests[0]), isNull);
    expect(await db.find(_server, '', requests[1]), isNotNull);
    expect(await db.find(_server, '', requests[2]), isNotNull);
  });

  test('an answer expires while the database stays open', () async {
    await dio.get<Object?>('/g/tok');
    await saved();
    // Opening already ran its cleanup. Age the response without reopening.
    await db.customStatement('update cached_responses set saved_at = ?', [
      DateTime.now().subtract(CacheDb.keep + const Duration(seconds: 1)).millisecondsSinceEpoch ~/ 1000,
    ]);
    server.down = true;
    await expectLater(dio.get<Object?>('/g/tok'), throwsA(isA<DioException>()));
    expect(offline, everyElement(isFalse));
    // A new network answer can refresh the same key normally.
    server.down = false;
    await dio.get<Object?>('/g/tok');
    await saved();
    server.down = true;
    expect((await dio.get<Object?>('/g/tok')).extra['savedAt'], isA<DateTime>());
  });

  group('shown first while online', () {
    late List<String> fresh;
    late Dio showing;
    late Completer<String> changed;

    // Register after OfflineCache so the signal arrives after it has saved
    // or rejected the recheck's response.
    Future<void> observeRecheck() {
      final done = Completer<void>();
      showing.interceptors.add(
        InterceptorsWrapper(
          onResponse: (response, handler) {
            if (identical(response.requestOptions, server.firstRequest)) done.complete();
            handler.next(response);
          },
          onError: (error, handler) {
            if (identical(error.requestOptions, server.firstRequest)) done.complete();
            handler.next(error);
          },
        ),
      );
      return done.future;
    }

    setUp(() {
      fresh = [];
      changed = Completer<String>();
      showing = Dio(BaseOptions(baseUrl: '$_server/api/v1'))..httpClientAdapter = server;
      showing.interceptors.add(
        OfflineCache(
          db,
          _server,
          '',
          offline.add,
          client: showing,
          onFresh: (request) {
            fresh.add(request);
            if (!changed.isCompleted) changed.complete(request);
          },
        ),
      );
      addTearDown(showing.close);
    });

    /// Saves [body] as the answer to [request], [age] ago.
    Future<void> keep(String request, Object body, {Duration age = const Duration(minutes: 1)}) => db
        .into(db.cachedResponses)
        .insertOnConflictUpdate(
          CachedResponsesCompanion.insert(
            server: _server,
            account: '',
            request: request,
            body: jsonEncode(body),
            savedAt: DateTime.now().subtract(age),
          ),
        );

    test('what was saved shows at once, and the server is asked again', () async {
      await keep('GET /g/tok/balances', {'old': true});
      final shown = await showing.get<Object?>('/g/tok/balances');
      expect(shown.data, {'old': true});
      expect(shown.extra['savedAt'], isA<DateTime>());
      expect(await changed.future, 'GET /g/tok/balances');
      expect(server.calls, 1);
      expect(fresh, ['GET /g/tok/balances']);

      // The reload it calls for shows the server's answer, without asking again.
      final again = await showing.get<Object?>('/g/tok/balances');
      expect((again.data as Map)['call'], 1);
      await saved();
      expect(server.calls, 1);
    });

    test('an answer that did not change reloads nothing', () async {
      await keep('GET /g/tok', {'path': '/api/v1/g/tok', 'call': 1, 'who': null});
      final checked = observeRecheck();
      await showing.get<Object?>('/g/tok');
      await checked;
      expect(server.calls, 1);
      expect(fresh, isEmpty);
    });

    test('the lists of groups show first too, asked once at a time', () async {
      await keep('GET /me/groups', []);
      final release = Completer<void>();
      final started = server.started = Completer<void>();
      server.hold = release.future;
      final cached = await Future.wait([
        showing.get<Object?>('/me/groups'),
        showing.get<Object?>('/me/groups'),
      ]);
      expect(cached.map((r) => r.data), [[], []]);
      await started.future;
      release.complete();
      expect(await changed.future, 'GET /me/groups');
      expect(server.calls, 1);
      expect(fresh, ['GET /me/groups']);
    });

    test('one expense, a later page and the account ask the server first', () async {
      for (final request in ['GET /g/tok/expenses/e1', 'GET /g/tok/expenses?cursor=c', 'GET /me', 'GET /g/tok/plan']) {
        await keep(request, {'old': true});
      }
      for (final (path, query) in [
        ('/g/tok/expenses/e1', <String, Object?>{}),
        ('/g/tok/expenses', {'cursor': 'c'}),
        ('/me', <String, Object?>{}),
        ('/g/tok/plan', <String, Object?>{}),
      ]) {
        final res = await showing.get<Object?>(path, queryParameters: query);
        expect(res.data, isNot({'old': true}), reason: path);
      }
      expect(server.calls, 4);
    });

    test('an answer saved moments ago is not asked for again', () async {
      await keep('GET /g/tok/stats', {'old': true}, age: Duration.zero);
      expect((await showing.get<Object?>('/g/tok/stats')).data, {'old': true});
      await saved();
      expect(server.calls, 0);
    });

    test('after expire the server is asked first, for that group and the lists', () async {
      const old = '{"old":true}';
      await db.save(_server, '', 'GET /g/tok/activity?limit=30', old);
      await db.save(_server, '', 'GET /g/other', old);
      await db.save(_server, '', 'GET /me/groups', old);
      db.expire(_server, group: 'tok');
      expect((await showing.get<Object?>('/g/tok/activity', queryParameters: {'limit': 30})).data, isNot({'old': true}));
      expect((await showing.get<Object?>('/me/groups')).data, isNot({'old': true}));
      expect((await showing.get<Object?>('/g/other')).data, {'old': true});

      // What the server answered since shows first again.
      final calls = server.calls;
      expect((await showing.get<Object?>('/me/groups')).extra['savedAt'], isA<DateTime>());
      expect(server.calls, calls);

      db.expire(_server);
      expect((await showing.get<Object?>('/g/other')).data, isNot({'old': true}));
    });

    test('a refusal on asking again forgets the answer and reloads', () async {
      await keep('GET /g/gone', {'old': true});
      server.status = 404;
      expect((await showing.get<Object?>('/g/gone')).data, {'old': true});
      expect(await changed.future, 'GET /g/gone');
      expect(fresh, ['GET /g/gone']);
      expect(await db.find(_server, '', 'GET /g/gone'), isNull);
    });

    for (final status in [429, 500, 503]) {
      test('a temporary HTTP $status keeps the offline answer', () async {
        await keep('GET /g/tok', {'old': true});
        final checked = observeRecheck();
        server.status = status;
        expect((await showing.get<Object?>('/g/tok')).data, {'old': true});
        await checked;
        expect(fresh, isEmpty);
        expect(server.calls, 1);
        server.down = true;
        expect((await dio.get<Object?>('/g/tok')).data, {'old': true});
      });
    }

    for (final (action, status) in [('refresh', 200), ('join', 403), ('a newer read', 200)]) {
      test('a late recheck HTTP $status cannot roll back data after $action', () async {
        const request = 'GET /g/tok';
        await keep(request, {'old': true});
        final checked = observeRecheck();
        final release = Completer<void>();
        final started = server.started = Completer<void>();
        server
          ..status = status
          ..hold = release.future;
        expect((await showing.get<Object?>('/g/tok')).data, {'old': true});
        await started.future;
        server
          ..status = 200
          ..hold = null;
        if (action == 'join') {
          await showing.post<Object?>('/g/tok/join');
        } else if (action == 'refresh') {
          db.expire(_server, group: 'tok');
        }
        final latest = (await (action == 'a newer read' ? dio : showing).get<Object?>('/g/tok')).data;
        expect(latest, isNot({'old': true}));
        release.complete();
        await checked;
        expect(fresh, isEmpty);
        final cached = await db.find(_server, '', request);
        expect(jsonDecode(cached!.body), latest);
      });
    }

    for (final (path, status) in [('/groups', 201), ('/groups/import', 201), ('/groups/import', 200)]) {
      test('POST $path with HTTP $status only expires the list when it creates a group', () async {
        await db.save(_server, '', 'GET /me/groups', '[]');
        await db.save(_server, '', 'GET /g/tok', '{"old":true}');
        server.status = status;
        await showing.post<Object?>(path);
        server.status = 200;
        final list = await showing.get<Object?>('/me/groups');
        expect(list.extra['savedAt'], status == 201 ? isNull : isA<DateTime>());
        expect((await showing.get<Object?>('/g/tok')).data, {'old': true});
      });
    }

    test('out of reach on asking again, the bar shows and nothing reloads', () async {
      await keep('GET /g/tok', {'old': true});
      server.down = true;
      expect((await showing.get<Object?>('/g/tok')).data, {'old': true});
      await saved();
      expect(offline, [true]);
      expect(fresh, isEmpty);
    });

    test('a fresh answer reloads what showed it', () {
      final reloaded = <Object>[];
      for (final request in [
        'GET /g/tok',
        'GET /g/tok/balances',
        'GET /g/tok/expenses?limit=50',
        'GET /g/tok/stats?tz=UTC',
        'GET /g/tok/activity?limit=30',
        'GET /g/tok/recurring',
        'GET /me/groups',
      ]) {
        reloadFresh(reloaded.add, request);
      }
      expect(reloaded, [
        groupProvider('tok'),
        balancesProvider('tok'),
        expensesProvider('tok'),
        statsProvider,
        activityFeedProvider,
        recurringProvider('tok'),
        summariesProvider,
      ]);
    });
  });

  test('signing in or out forgets what the last account saw', () async {
    await db.save(_server, cacheAccount('a'), 'GET /me', '{}');
    await db.save(_server, CacheDb.public, 'GET /server-info', '{}');
    await db.save('https://other.example.com', cacheAccount('a'), 'GET /me', '{}');
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(await SharedPreferences.getInstance()),
        serverUrlProvider.overrideWithValue(_server),
        cacheDbProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);
    container.read(sessionProvider.notifier).set('b', from: container.read(identityProvider));
    await saved();
    expect(await db.find(_server, cacheAccount('a'), 'GET /me'), isNull);
    expect(await db.find(_server, CacheDb.public, 'GET /server-info'), isNotNull);
    expect(await db.find('https://other.example.com', cacheAccount('a'), 'GET /me'), isNotNull);
  });

  // An answer for the last account that arrives after the switch must not
  // be shown to the next one, offline or not.
  for (final (name, steps) in [
    ('signing out', <String?>[null]),
    ('switching accounts', <String?>['b']),
    ('signing out and in again', <String?>[null, 'c']),
  ]) {
    test('a late answer is not kept after $name', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(await SharedPreferences.getInstance()),
          serverUrlProvider.overrideWithValue(_server),
          cacheDbProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);
      final session = container.read(sessionProvider.notifier)
        ..set('a', from: container.read(identityProvider));
      Dio client(String? token) => Dio(BaseOptions(baseUrl: '$_server/api/v1'))
        ..httpClientAdapter = server
        ..options.headers['Authorization'] = token
        ..interceptors.add(OfflineCache(db, _server, cacheAccount(token), offline.add));

      final release = Completer<void>();
      server.hold = release.future;
      final pending = client('a').get<Object?>('/me');
      await saved();
      for (final token in steps) {
        session.set(token, from: container.read(identityProvider));
      }
      await saved();
      release.complete();
      await pending;
      await saved();

      server.down = true;
      await expectLater(client(steps.last).get<Object?>('/me'), throwsA(isA<DioException>()));
      final rows = await db.select(db.cachedResponses).get();
      expect(rows.where((r) => r.account == cacheAccount('a')), isEmpty);
    });
  }

  testWidgets('while offline the bar keeps checking whether the server is back', (tester) async {
    var probes = 0;
    var up = false;
    final container = ProviderContainer(
      overrides: [
        cacheDbProvider.overrideWithValue(null),
        serverUrlProvider.overrideWithValue(_server),
        serverInfoProvider.overrideWith(
          (ref) async => const ServerInfo(version: '1', authMode: AuthMode.link, publicUrl: _server),
        ),
        serverProbeProvider.overrideWithValue((url) async {
          probes++;
          if (!up) throw const ProbeException(ProbeError.unreachable);
          return const ServerInfo(version: '1', authMode: AuthMode.link, publicUrl: _server);
        }),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: l10nDelegates,
          builder: (context, child) => OfflineBar(child: child!),
          home: const SizedBox(),
        ),
      ),
    );
    container.read(offlineProvider.notifier).set(true);
    await tester.pump();
    await tester.pump(OfflineBar.checkEvery);
    expect(probes, 1);
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

    up = true;
    await tester.pump(OfflineBar.checkEvery);
    await tester.pumpAndSettle();
    expect(probes, 2);
    expect(container.read(offlineProvider), isFalse);
    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);

    // Online again, so no more checks.
    await tester.pump(OfflineBar.checkEvery * 2);
    expect(probes, 2);
  });

  testWidgets('connection changes keep the current form and its draft', (tester) async {
    final container = ProviderContainer(overrides: [cacheDbProvider.overrideWithValue(null)]);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: l10nDelegates,
          home: const OfflineBar(child: Scaffold(body: TextField())),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'unsaved draft');
    container.read(offlineProvider.notifier).set(true);
    await tester.pump();
    expect(find.text('unsaved draft'), findsOneWidget);
    container.read(offlineProvider.notifier).set(false);
    await tester.pump();
    expect(find.text('unsaved draft'), findsOneWidget);
  });

  testWidgets('a fresh install can start without a server', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          serverUrlProvider.overrideWithValue(null),
          cacheDbProvider.overrideWithValue(null),
          pushServiceProvider.overrideWithValue(null),
          warmStartProvider.overrideWith(() => WarmStartNotifier(on: true)),
        ],
        child: const BalnanaApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Connect to a server'), findsOneWidget);
  });

  testWidgets('a bar says the app is offline until the server answers again', (tester) async {
    var infoLoads = 0;
    final container = ProviderContainer(
      overrides: [
        cacheDbProvider.overrideWithValue(null),
        serverInfoProvider.overrideWith((ref) async {
          infoLoads++;
          return const ServerInfo(version: '1', authMode: AuthMode.link, publicUrl: _server);
        }),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: l10nDelegates,
          builder: (context, child) => OfflineBar(child: child!),
          home: Consumer(
            builder: (context, ref, _) => Text('${ref.watch(serverInfoProvider).value?.version}'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
    expect(infoLoads, 1);

    container.read(offlineProvider.notifier).set(true);
    await tester.pump();
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    expect(find.textContaining('new expenses and payments upload when you reconnect'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(infoLoads, 2);

    container.read(offlineProvider.notifier).set(false);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
    expect(infoLoads, 3);
  });

  Future<ProviderContainer> warmStart(
    WidgetTester tester, {
    required Future<ServerInfo> Function(String) probe,
    required void Function() onInfo,
  }) async {
    SharedPreferences.setMockInitialValues({'settings.server': _server});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        cacheDbProvider.overrideWithValue(null),
        warmStartProvider.overrideWith(() => WarmStartNotifier(on: true)),
        serverInfoProvider.overrideWith((ref) async {
          onInfo();
          // As if answered from the cache while starting.
          if (ref.read(warmStartProvider)) ref.read(warmStartProvider.notifier).served();
          return _info;
        }),
        serverProbeProvider.overrideWithValue(probe),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: l10nDelegates,
          builder: (context, child) => OfflineBar(child: child!),
          home: Consumer(
            builder: (context, ref, _) => Text('${ref.watch(serverInfoProvider).value?.version}'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('what was saved shows at start, and reloads once the server answers', (tester) async {
    var infoLoads = 0;
    final container = await warmStart(tester, probe: (_) async => _info, onInfo: () => infoLoads++);
    expect(container.read(warmStartProvider), isFalse);
    expect(infoLoads, 2);
    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
  });

  testWidgets('what was saved shows at start, with the bar if the server is out of reach', (tester) async {
    var infoLoads = 0;
    final container = await warmStart(
      tester,
      probe: (_) async => throw const ProbeException(ProbeError.unreachable),
      onInfo: () => infoLoads++,
    );
    expect(container.read(warmStartProvider), isFalse);
    expect(infoLoads, 1);
    expect(container.read(offlineProvider), isTrue);
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
  });

  testWidgets('a failed startup probe is ignored after changing servers', (tester) async {
    final probe = Completer<ServerInfo>();
    final container = await warmStart(tester, probe: (_) => probe.future, onInfo: () {});
    expect(container.read(warmStartProvider), isTrue);

    container.read(settingsProvider.notifier).setServerUrl('https://other.example.com');
    probe.completeError(const ProbeException(ProbeError.unreachable));
    await tester.pumpAndSettle();

    expect(container.read(warmStartProvider), isFalse);
    expect(container.read(offlineProvider), isFalse);
    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
  });

  testWidgets('switching away and back still discards the startup probe', (tester) async {
    final probe = Completer<ServerInfo>();
    final container = await warmStart(tester, probe: (_) => probe.future, onInfo: () {});
    final settings = container.read(settingsProvider.notifier);
    settings.setServerUrl('https://other.example.com');
    await tester.pumpAndSettle();
    expect(container.read(warmStartProvider), isFalse);
    settings.setServerUrl(_server);
    probe.completeError(const ProbeException(ProbeError.unreachable));
    await tester.pumpAndSettle();

    expect(container.read(offlineProvider), isFalse);
    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
  });

  testWidgets('startup refresh reloads readers without closing a client saving an expense', (tester) async {
    final probe = Completer<ServerInfo>();
    var infoLoads = 0;
    final container = await warmStart(tester, probe: (_) => probe.future, onInfo: () => infoLoads++);
    final reads = container.listen(balnanaApiProvider, (_, _) {});
    final api = reads.read();
    final client = container.read(apiProvider)!..httpClientAdapter = server;
    final release = Completer<void>();
    server.hold = release.future;
    final expense = client.post<Object?>('/g/tok/expenses', data: {'title': 'Groceries'});
    await tester.pump(const Duration(milliseconds: 100));
    expect(server.calls, 1);

    probe.complete(_info);
    await tester.pumpAndSettle();
    expect(infoLoads, 2);
    expect(reads.read(), isNot(same(api)));
    expect(container.read(apiProvider), same(client));

    release.complete();
    await tester.pump(const Duration(milliseconds: 100));
    expect((await expense).statusCode, 200);
    final receipt = client.put<Object?>('/g/tok/expenses/123/receipt');
    await tester.pump(const Duration(milliseconds: 100));
    expect((await receipt).statusCode, 200);
  });

  test('a delayed authentication failure still clears the session after an API refresh', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer.test(
      overrides: [
        prefsProvider.overrideWithValue(await SharedPreferences.getInstance()),
        serverUrlProvider.overrideWithValue(_server),
        cacheDbProvider.overrideWithValue(null),
        serverInfoProvider.overrideWithValue(const AsyncData(_info)),
      ],
    );
    container.read(sessionProvider.notifier).set('expired', from: container.read(identityProvider));
    final api = container.read(balnanaApiProvider)!;
    container.read(apiProvider)!.httpClientAdapter = server;
    final release = Completer<void>();
    server
      ..status = 401
      ..hold = release.future;
    final request = expectLater(api.me(), throwsA(isA<ApiException>()));
    container.invalidate(balnanaApiProvider);
    expect(container.read(balnanaApiProvider), isNot(same(api)));
    release.complete();
    await request;
    // The transport handles the rejection in a microtask.
    await Future<void>.delayed(Duration.zero);
    expect(container.read(sessionProvider).token, isNull);
  });

  for (final up in [true, false]) {
    testWidgets('cached setup status waits for the startup probe (reachable: $up)', (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({'settings.server': _server});
      final prefs = await SharedPreferences.getInstance();
      final probe = Completer<ServerInfo>();
      final reload = Completer<ServerInfo>();
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          cacheDbProvider.overrideWithValue(null),
          pushServiceProvider.overrideWithValue(null),
          warmStartProvider.overrideWith(() => WarmStartNotifier(on: true)),
          serverInfoProvider.overrideWith((ref) async {
            if (!ref.read(warmStartProvider)) return reload.future;
            ref.read(warmStartProvider.notifier).served();
            return const ServerInfo(
              version: '1',
              authMode: AuthMode.link,
              publicUrl: _server,
              setupRequired: true,
            );
          }),
          serverProbeProvider.overrideWithValue((_) => probe.future),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const BalnanaApp()));
      await tester.pumpAndSettle();
      final router = container.read(routerProvider);
      expect(router.state.matchedLocation, '/groups');

      if (up) {
        probe.complete(_info);
        await tester.pumpAndSettle();
        expect(router.state.matchedLocation, '/groups');
        reload.complete(_info);
      } else {
        probe.completeError(const ProbeException(ProbeError.unreachable));
      }
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, up ? '/groups' : '/admin');
    });
  }
}
