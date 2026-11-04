import 'dart:async';
import 'dart:convert';

import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/api.dart';
import 'package:balnana/data/home_group.dart';
import 'package:balnana/data/known_groups.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = 'https://split.example';
const _other = 'https://other.example';
const _user = User(id: 'ana', name: 'Ana', hasPassword: true);

Map<String, Object?> _summary(String token) => {
  'token': token,
  'name': token,
  'currency': 'USD',
  'minorDigits': 2,
  'memberCount': 2,
  'updatedAt': '2026-11-04T00:00:00Z',
};

void main() {
  test('deleted groups stay out of stale lists and every local account history', () async {
    SharedPreferences.setMockInitialValues({
      'groups.known': jsonEncode([
        {'server': _server, 'token': 'deleted'},
        {'server': _server, 'token': 'kept'},
        {'server': _other, 'token': 'deleted'},
      ]),
      'groups.current': jsonEncode({
        '$_server ana': 'deleted',
        '$_server ben': 'deleted',
        '$_server cy': 'kept',
        '$_other ana': 'deleted',
      }),
      'groups.order': jsonEncode({
        '$_server ana': ['deleted', 'kept'],
        '$_server ben': ['deleted'],
        '$_other ana': ['deleted'],
      }),
    });
    final prefs = await SharedPreferences.getInstance();
    Completer<void>? hold;
    var fail = false;
    final dio = Dio(BaseOptions(baseUrl: '$_server/api/v1'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) async {
            await hold?.future;
            if (fail) {
              h.reject(DioException.connectionError(requestOptions: o, reason: 'offline'));
            } else {
              h.resolve(
                Response(
                  requestOptions: o,
                  data: {
                    'groups': [_summary('deleted'), _summary('kept')],
                  },
                ),
              );
            }
          },
        ),
      );
    final c = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        serverUrlProvider.overrideWithValue(_server),
        cacheDbProvider.overrideWithValue(null),
        accountProvider.overrideWithValue(const AsyncData(_user)),
        apiProvider.overrideWithValue(dio),
      ],
    );
    addTearDown(c.dispose);
    c.listen(visibleSummariesProvider, (_, _) {});
    await c.read(summariesProvider.future);
    expect(c.read(currentGroupProvider), 'deleted');
    expect(c.read(visibleSummariesProvider).value!.groups.map((g) => g.token), ['deleted', 'kept']);
    hold = Completer<void>();
    removeDeletedGroup(c, _server, 'deleted');
    expect(c.read(visibleSummariesProvider).value?.groups.any((g) => g.token == 'deleted') ?? false, isFalse);
    expect(c.read(currentGroupProvider), isNull);
    expect(c.read(knownGroupsProvider).map((g) => g.token), ['kept']);
    final current = jsonDecode(prefs.getString('groups.current')!) as Map;
    expect(current, {'$_server cy': 'kept', '$_other ana': 'deleted'});
    final order = jsonDecode(prefs.getString('groups.order')!) as Map;
    expect(order['$_server ana'], ['kept']);
    expect(order['$_server ben'], isEmpty);
    expect(order['$_other ana'], ['deleted']);
    expect(
      (jsonDecode(prefs.getString('groups.known')!) as List).any((g) => (g as Map)['server'] == _other),
      isTrue,
    );
    await expectLater(c.read(groupProvider('deleted').future), throwsA(isA<ApiException>()));
    hold.complete();
    await c.read(summariesProvider.future);
    expect(c.read(visibleSummariesProvider).value!.groups.map((g) => g.token), ['kept']);
    hold = Completer<void>();
    c.invalidate(summariesProvider);
    final refresh = c.read(summariesProvider.future);
    fail = true;
    hold.complete();
    await expectLater(refresh, throwsA(isA<ApiException>()));
    expect(c.read(visibleSummariesProvider).value!.groups.map((g) => g.token), ['kept']);
  });

  test('a missing link is pruned automatically while locked links are retained', () async {
    SharedPreferences.setMockInitialValues({
      'groups.known': jsonEncode([
        {'server': _server, 'token': 'missing'},
        {'server': _server, 'token': 'locked'},
      ]),
    });
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio(BaseOptions(baseUrl: '$_server/api/v1'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) {
            h.resolve(
              Response(
                requestOptions: o,
                data: {
                  'groups': [],
                  'missing': ['missing'],
                  'locked': ['locked'],
                },
              ),
            );
          },
        ),
      );
    final c = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        serverUrlProvider.overrideWithValue(_server),
        cacheDbProvider.overrideWithValue(null),
        accountProvider.overrideWithValue(const AsyncData(null)),
        apiProvider.overrideWithValue(dio),
      ],
    );
    addTearDown(c.dispose);
    c.listen(visibleSummariesProvider, (_, _) {});
    await c.read(summariesProvider.future);
    // Deletion cleanup runs after the summary has been delivered.
    await Future<void>.delayed(Duration.zero);
    expect(c.read(knownGroupsProvider).map((g) => g.token), ['locked']);
    expect(c.read(visibleSummariesProvider).value?.missing ?? [], isEmpty);
    expect(c.read(removedGroupsProvider(_server)), {'missing'});
  });

  test('deletion purges every account cache and rejects late saved answers', () async {
    final db = CacheDb(NativeDatabase.memory());
    addTearDown(db.close);
    final asked = db.forgets;
    for (final account in ['ana', 'ben']) {
      for (final request in [
        'GET /g/deleted',
        'GET /g/deleted/expenses',
        'GET /me/groups',
        'POST /groups/summaries {}',
        'GET /g/kept',
      ]) {
        await db.save(_server, account, request, '{}');
      }
    }
    await db.save(_other, 'ana', 'GET /g/deleted', '{}');
    await db.forgetDeletedGroup(_server, 'deleted');
    for (final account in ['ana', 'ben']) {
      for (final request in [
        'GET /g/deleted',
        'GET /g/deleted/expenses',
        'GET /me/groups',
        'POST /groups/summaries {}',
      ]) {
        expect(await db.find(_server, account, request), isNull);
        await db.save(_server, account, request, '{}', asked: asked);
        expect(await db.find(_server, account, request), isNull);
      }
      expect(await db.find(_server, account, 'GET /g/kept'), isNotNull);
    }
    expect(await db.find(_other, 'ana', 'GET /g/deleted'), isNotNull);
  });
}
