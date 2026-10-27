import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/push.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/core/session.dart';
import 'package:balnana/core/settings.dart';
import 'package:balnana/data/api.dart';
import 'package:balnana/data/known_groups.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = 'https://split.example.com';

class _FakePush implements PushService {
  /// Where the push service delivers; null when the phone has none.
  String? address = 'https://push.example.com/1';
  final refreshes = StreamController<void>.broadcast();
  var asked = 0;
  final keys = <String>[];

  /// While set, asking for permission waits for it.
  Future<void>? hold;

  @override
  Future<PushSubscription?> subscribe(String vapid) async {
    keys.add(vapid);
    return switch (address) {
      final a? => (endpoint: a, p256dh: 'pub', auth: 'auth'),
      null => null,
    };
  }

  @override
  Stream<void> get changes => refreshes.stream;

  @override
  Future<void> requestPermission() async {
    asked++;
    await hold;
  }

  @override
  Future<String?> initialGroup() async => null;

  @override
  Stream<String> get openedGroups => const Stream.empty();
}

/// Writes down every request and answers 204, after [hold] if set.
class _Recorder implements HttpClientAdapter {
  final requests = <String>[];
  Future<void>? hold;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = options.data == null ? '' : ' ${jsonEncode(options.data)}';
    final who = options.headers['Authorization'] == null ? '' : ' as ${options.headers['Authorization']}';
    requests.add('${options.method} ${options.uri.path}$body$who');
    await hold;
    return ResponseBody.fromString('', 204);
  }

  @override
  void close({bool force = false}) {}
}

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 600));

void main() {
  late _FakePush push;
  late _Recorder server;
  late ProviderContainer container;

  Future<void> boot({
    bool serverPush = true,
    Future<void>? hold,
    Future<void>? permission,
    String? device = 'device-1',
    String? address = 'https://push.example.com/1',
  }) async {
    SharedPreferences.setMockInitialValues({
      'settings.server': _server,
      'push.device': ?device,
      'groups.known': jsonEncode([
        {'server': _server, 'token': 'tok', 'memberId': 'a', 'addedAt': '2026-01-01T00:00:00Z'},
        {'server': _server, 'token': 'unpicked', 'addedAt': '2026-01-01T00:00:00Z'},
      ]),
    });
    final prefs = await SharedPreferences.getInstance();
    push = _FakePush()
      ..hold = permission
      ..address = address;
    server = _Recorder()..hold = hold;
    final info = ServerInfo(
      version: '1.0.0',
      authMode: AuthMode.link,
      push: serverPush,
      vapidPublicKey: serverPush ? 'vapid-key' : null,
      publicUrl: _server,
    );
    container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        cacheDbProvider.overrideWithValue(null),
        pushServiceProvider.overrideWithValue(push),
        serverInfoProvider.overrideWithValue(AsyncValue.data(info)),
        apiProvider.overrideWith((ref) {
          final token = ref.watch(sessionProvider).token;
          return Dio(BaseOptions(baseUrl: '$_server/api/v1', headers: {'Authorization': ?token}))
            ..httpClientAdapter = server;
        }),
      ],
    );
    addTearDown(container.dispose);
    container.listen(pushSyncProvider, (_, _) {});
    await _settle();
  }

  test('registers the groups with a member picked, once things settle', () async {
    await boot();
    expect(server.requests, [
      'PUT /api/v1/push/devices/device-1 {"endpoint":"https://push.example.com/1","p256dh":"pub","auth":"auth",'
          '"groups":[{"token":"tok","memberId":"a"}]}',
    ]);
    expect(push.asked, 1);
    expect(push.keys, ['vapid-key']);

    container.read(knownGroupsProvider.notifier).setMember('unpicked', 'b');
    await _settle();
    expect(
      server.requests.last,
      contains('{"token":"tok","memberId":"a"},{"token":"unpicked","memberId":"b"}'),
    );

    push.address = 'https://push.example.com/2';
    push.refreshes.add(null);
    await _settle();
    expect(
      server.requests.last,
      startsWith('PUT /api/v1/push/devices/device-1 {"endpoint":"https://push.example.com/2"'),
    );
  });

  test('a device makes up its own ID and keeps it', () async {
    await boot(device: null);
    final id = container.read(prefsProvider).getString('push.device');
    expect(id, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
    expect(server.requests, [startsWith('PUT /api/v1/push/devices/$id ')]);
  });

  test('a phone without a push service registers nothing, and can still be forgotten', () async {
    await boot(address: null);
    expect(server.requests, isEmpty);
    expect(push.keys, ['vapid-key']);

    // Registered before, when the phone had a push service.
    await container.read(prefsProvider).setString('push.server', _server);
    container.read(settingsProvider.notifier).setNotifications(false);
    await _settle();
    expect(server.requests, ['DELETE /api/v1/push/devices/device-1']);
  });

  test('turning notifications off tells the server to forget the device', () async {
    await boot();
    server.requests.clear();
    container.read(settingsProvider.notifier).setNotifications(false);
    await _settle();
    expect(server.requests, ['DELETE /api/v1/push/devices/device-1']);

    // Nothing more to forget.
    container.read(knownGroupsProvider.notifier).setMember('unpicked', 'b');
    await _settle();
    expect(server.requests, hasLength(1));
  });

  test('a server without push is left alone', () async {
    await boot(serverPush: false);
    expect(server.requests, isEmpty);
    expect(push.asked, 0);
    expect(push.keys, isEmpty);
    expect(container.read(pushAvailableProvider), isFalse);
  });

  // Whatever order the work finishes in, the server ends up told the latest.
  test('turning notifications off during a registration undoes it', () async {
    final put = Completer<void>();
    await boot(hold: put.future);
    expect(server.requests, hasLength(1));
    container.read(settingsProvider.notifier).setNotifications(false);
    await _settle();
    expect(server.requests, hasLength(1));
    put.complete();
    await _settle();
    expect(server.requests, [startsWith('PUT '), 'DELETE /api/v1/push/devices/device-1']);
    expect(container.read(prefsProvider).getString('push.server'), isNull);
  });

  test('turning notifications off while permission is asked registers nothing', () async {
    final asked = Completer<void>();
    await boot(permission: asked.future);
    container.read(settingsProvider.notifier).setNotifications(false);
    await _settle();
    asked.complete();
    await _settle();
    expect(server.requests, isEmpty);
    expect(container.read(prefsProvider).getString('push.server'), isNull);
  });

  test('signing in during a registration registers again as the account', () async {
    final put = Completer<void>();
    await boot(hold: put.future);
    container.read(sessionProvider.notifier).set('b');
    await _settle();
    server.hold = null;
    put.complete();
    await _settle();
    expect(server.requests, hasLength(2));
    expect(server.requests.last, endsWith(' as b'));
  });
}
