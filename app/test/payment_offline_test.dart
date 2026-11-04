import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:balnana/core/money.dart';
import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/pending_writes.dart';
import 'package:balnana/features/group/balances.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Server implements HttpClientAdapter {
  final fail = Completer<void>();
  final requests = <RequestOptions>[];
  var down = true;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (down) {
      await fail.future;
      throw DioException.connectionError(requestOptions: options, reason: 'offline');
    }
    return ResponseBody.fromString('', 201);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  testWidgets('a late payment keeps its server and original time through reconnect', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = CacheDb(NativeDatabase.memory());
    addTearDown(db.close);
    final remote = _Server();
    var server = 'https://old.example';
    late ProviderContainer container;
    final group = Group(
      token: 'A' * 22,
      name: 'Trip',
      currency: 'USD',
      minorDigits: 2,
      createdAt: DateTime.utc(2026),
      members: [
        Member(id: 'a', name: 'Ana', balance: BigInt.zero),
        Member(id: 'b', name: 'Ben', balance: BigInt.zero),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          serverUrlProvider.overrideWith((ref) => server),
          cacheDbProvider.overrideWithValue(db),
          apiProvider.overrideWith(
            (ref) =>
                Dio(BaseOptions(baseUrl: '${ref.watch(serverUrlProvider)}/api/v1'))
                  ..httpClientAdapter = remote,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                container = ProviderScope.containerOf(context);
                return TextButton(
                  onPressed: () => recordPayment(context, ref, group, Transfer('a', 'b', BigInt.from(100))),
                  child: const Text('Begin'),
                );
              },
            ),
          ),
        ),
      ),
    );
    final before = DateTime.now();
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Record'));
    await tester.pumpAndSettle();
    final original = remote.requests.single.data as Map<String, Object?>;
    final occurredAt = DateTime.parse(original['occurredAt']! as String);
    expect(occurredAt.isBefore(before), isFalse);
    expect(occurredAt.isAfter(DateTime.now()), isFalse);

    server = 'https://new.example';
    container.invalidate(serverUrlProvider);
    await tester.pump();
    remote.fail.complete();
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final row =
          (await db
                  .watchPending('https://old.example', '')
                  .firstWhere((rows) => rows.isNotEmpty)
                  .timeout(const Duration(seconds: 3)))
              .single;
      expect(row.groupToken, group.token);
      expect(jsonDecode(row.body), original);
      expect(await db.pending(server, ''), isEmpty);
    });
    expect(remote.requests, hasLength(1));

    remote.down = false;
    server = 'https://old.example';
    container.invalidate(serverUrlProvider);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await container.read(pendingSenderProvider.notifier).send();
      expect(
        await db
            .watchPending(server, '')
            .firstWhere((rows) => rows.isEmpty)
            .timeout(const Duration(seconds: 3)),
        isEmpty,
      );
    });
    expect(remote.requests.last.uri.host, 'old.example');
    expect(remote.requests.last.data, original);
    expect(remote.requests.last.headers['Idempotency-Key'], remote.requests.first.headers['Idempotency-Key']);
    await tester.pumpAndSettle();
  });
}
