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
import 'package:balnana/data/providers.dart';
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

  /// What asking for permission answers; null throws.
  bool? allowed = true;

  @override
  Future<PushSubscription?> subscribe(String server, String vapid) async {
    keys.add(vapid);
    return switch (address) {
      final a? => (endpoint: a, p256dh: 'pub', auth: 'auth'),
      null => null,
    };
  }

  @override
  Stream<void> get changes => refreshes.stream;

  @override
  Future<bool> requestPermission({bool tapped = false}) async {
    asked++;
    await hold;
    return allowed ?? (throw StateError('no activity'));
  }

  @override
  Stream<PushTarget> get openedGroups => const Stream.empty();
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

Future<void> _settle(WidgetTester tester) async {
  // Deliver provider/stream changes before advancing the debounce timer.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump();
}

void main() {
  late _FakePush push;
  late _Recorder server;
  late ProviderContainer container;

  Future<void> boot(
    WidgetTester tester, {
    bool serverPush = true,
    Future<void>? hold,
    Future<void>? permission,
    String? device = 'device-1',
    String? address = 'https://push.example.com/1',
    bool groups = true,
    bool cookie = false,
  }) async {
    SharedPreferences.setMockInitialValues({
      'settings.server': _server,
      'push.device': ?device,
      'groups.known': jsonEncode([
        if (groups) ...[
          {'server': _server, 'token': 'tok', 'memberId': 'a', 'addedAt': '2026-01-01T00:00:00Z'},
          {'server': _server, 'token': 'unpicked', 'addedAt': '2026-01-01T00:00:00Z'},
        ],
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
        signedInProvider.overrideWith((ref) => cookie && ref.watch(sessionProvider).generation == 0),
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
    await _settle(tester);
  }

  testWidgets('registers the groups with a member picked, once things settle', (tester) async {
    await boot(tester);
    expect(server.requests, [
      'PUT /api/v1/push/devices/device-1 {"endpoint":"https://push.example.com/1","p256dh":"pub","auth":"auth",'
          '"groups":[{"token":"tok","memberId":"a"}]}',
    ]);
    expect(push.asked, 1);
    expect(push.keys, ['vapid-key']);

    container.read(knownGroupsProvider.notifier).setMember('unpicked', 'b');
    await _settle(tester);
    expect(
      server.requests.last,
      contains('{"token":"tok","memberId":"a"},{"token":"unpicked","memberId":"b"}'),
    );

    push.address = 'https://push.example.com/2';
    push.refreshes.add(null);
    await _settle(tester);
    expect(
      server.requests.last,
      startsWith('PUT /api/v1/push/devices/device-1 {"endpoint":"https://push.example.com/2"'),
    );
  });

  testWidgets('a refused or failed permission request still registers, and is shown', (tester) async {
    await boot(tester);
    expect(container.read(pushBlockedProvider), isFalse);

    push.allowed = false;
    container.read(knownGroupsProvider.notifier).setMember('unpicked', 'b');
    await _settle(tester);
    expect(server.requests, hasLength(2));
    expect(container.read(pushBlockedProvider), isTrue);

    push.allowed = null;
    push.address = 'https://push.example.com/2';
    push.refreshes.add(null);
    await _settle(tester);
    expect(server.requests.last, contains('push.example.com/2'));
  });

  testWidgets('a device makes up its own ID and keeps it', (tester) async {
    await boot(tester, device: null);
    final id = container.read(prefsProvider).getString('push.device');
    expect(id, matches(RegExp(r'^[A-Za-z0-9_-]{43}$')));
    expect(server.requests, [startsWith('PUT /api/v1/push/devices/$id ')]);
  });

  testWidgets('a phone without a push service registers nothing, and can still be forgotten', (tester) async {
    await boot(tester, address: null);
    expect(server.requests, isEmpty);
    expect(push.keys, ['vapid-key']);

    // Registered before, when the phone had a push service.
    await container.read(prefsProvider).setString('push.server', _server);
    container.read(settingsProvider.notifier).setNotifications(false);
    await _settle(tester);
    expect(server.requests, ['DELETE /api/v1/push/devices/device-1']);
  });

  testWidgets('turning notifications off tells the server to forget the device', (tester) async {
    await boot(tester);
    server.requests.clear();
    container.read(settingsProvider.notifier).setNotifications(false);
    await _settle(tester);
    expect(server.requests, ['DELETE /api/v1/push/devices/device-1']);

    // Nothing more to forget.
    container.read(knownGroupsProvider.notifier).setMember('unpicked', 'b');
    await _settle(tester);
    expect(server.requests, hasLength(1));
  });

  testWidgets('signing out with no groups left tells the server to forget the device', (tester) async {
    await boot(tester, groups: false);
    container.read(sessionProvider.notifier).set('b', from: container.read(identityProvider));
    await _settle(tester);
    expect(server.requests.single, startsWith('PUT '));

    server.requests.clear();
    container.read(sessionProvider.notifier).set(null, from: container.read(identityProvider));
    await _settle(tester);
    expect(server.requests, ['DELETE /api/v1/push/devices/device-1']);
  });

  testWidgets('a server without push is left alone', (tester) async {
    await boot(tester, serverPush: false);
    expect(server.requests, isEmpty);
    expect(push.asked, 0);
    expect(push.keys, isEmpty);
    expect(container.read(pushAvailableProvider), isFalse);
  });

  // Whatever order the work finishes in, the server ends up told the latest.
  testWidgets('turning notifications off during a registration undoes it', (tester) async {
    final put = Completer<void>();
    await boot(tester, hold: put.future);
    expect(server.requests, hasLength(1));
    container.read(settingsProvider.notifier).setNotifications(false);
    await _settle(tester);
    expect(server.requests, hasLength(1));
    put.complete();
    await _settle(tester);
    expect(server.requests, [startsWith('PUT '), 'DELETE /api/v1/push/devices/device-1']);
    expect(container.read(prefsProvider).getString('push.server'), isNull);
  });

  testWidgets('turning notifications off while permission is asked registers nothing', (tester) async {
    final asked = Completer<void>();
    await boot(tester, permission: asked.future);
    container.read(settingsProvider.notifier).setNotifications(false);
    await _settle(tester);
    asked.complete();
    await _settle(tester);
    expect(server.requests, isEmpty);
    expect(container.read(prefsProvider).getString('push.server'), isNull);
  });

  testWidgets('signing in during a registration registers again as the account', (tester) async {
    final put = Completer<void>();
    await boot(tester, hold: put.future);
    container.read(sessionProvider.notifier).set('b', from: container.read(identityProvider));
    await _settle(tester);
    server.hold = null;
    put.complete();
    await _settle(tester);
    expect(server.requests, hasLength(2));
    expect(server.requests.last, endsWith(' as b'));
  });

  test('each expense has a notification ID of its own', () {
    const a = '0b9f6c1e-3d2a-4c8e-9a51-6f2d7e4b1c03';
    const b = '5e7a2d90-81c4-4f3b-b6e2-0c9d1a8f3e57';
    expect(notificationId(a), notificationId(a));
    expect(notificationId(a), isNot(notificationId(b)));
    // Positive and within 32 bits, as Android wants.
    for (final id in [notificationId(a), notificationId(b), notificationId('')]) {
      expect(id, inInclusiveRange(0, 0x7fffffff));
    }
  });
  testWidgets('cookie accounts register without known links and unregister on sign-out', (tester) async {
    await boot(tester, groups: false, cookie: true);
    expect(container.read(sessionProvider).token, isNull);
    expect(server.requests.single, startsWith('PUT /api/v1/push/devices/device-1 '));
    expect(push.keys, ['vapid-key']);
    server.requests.clear();
    container.read(sessionProvider.notifier).set(null, from: container.read(identityProvider));
    await _settle(tester);
    expect(server.requests, ['DELETE /api/v1/push/devices/device-1']);
  });
}
