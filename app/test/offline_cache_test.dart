import 'dart:convert';
import 'dart:typed_data';

import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/core/session.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:balnana/ui/widgets/offline_bar.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = 'https://split.example.com';

/// Answers with [status] and a body naming the request, or throws a
/// connection error while [down].
class _Server implements HttpClientAdapter {
  var down = false;
  var status = 200;
  var calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (down) throw DioException.connectionError(requestOptions: options, reason: 'down');
    return ResponseBody.fromString(
      jsonEncode({'path': options.uri.path, 'call': calls}),
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
      ..interceptors.add(OfflineCache(db, _server, offline.add));
  });

  tearDown(() => db.close());

  Future<void> saved() => Future<void>.delayed(const Duration(milliseconds: 20));

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

  test('keeps reading POSTs by body, and nothing else that writes', () async {
    await dio.post<Object?>('/groups/summaries', data: {'tokens': ['a']});
    await dio.post<Object?>('/g/tok/expenses', data: {'title': 'x'});
    await saved();
    server.down = true;
    final summaries = await dio.post<Object?>('/groups/summaries', data: {'tokens': ['a']});
    expect((summaries.data as Map)['path'], '/api/v1/groups/summaries');
    await expectLater(
      dio.post<Object?>('/groups/summaries', data: {'tokens': ['b']}),
      throwsA(isA<DioException>()),
    );
    await expectLater(dio.post<Object?>('/g/tok/expenses', data: {'title': 'x'}), throwsA(isA<DioException>()));
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

  test('signing in or out forgets what the last account saw', () async {
    await db.save(_server, 'GET /me', '{}');
    await db.save('https://other.example.com', 'GET /me', '{}');
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(await SharedPreferences.getInstance()),
        serverUrlProvider.overrideWithValue(_server),
        cacheDbProvider.overrideWithValue(db),
      ],
    );
    addTearDown(container.dispose);
    container.read(sessionProvider.notifier).set('token');
    await saved();
    expect(await db.find(_server, 'GET /me'), isNull);
    expect(await db.find('https://other.example.com', 'GET /me'), isNotNull);
  });

  testWidgets('a bar says the app is offline until the server answers again', (tester) async {
    var infoLoads = 0;
    final container = ProviderContainer(
      overrides: [
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => OfflineBar(child: child!),
          home: Consumer(builder: (context, ref, _) => Text('${ref.watch(serverInfoProvider).value?.version}')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
    expect(infoLoads, 1);

    container.read(offlineProvider.notifier).set(true);
    await tester.pump();
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(infoLoads, 2);

    container.read(offlineProvider.notifier).set(false);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
    expect(infoLoads, 3);
  });
}
