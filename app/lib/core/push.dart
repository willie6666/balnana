import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api.dart';
import '../data/known_groups.dart';
import 'prefs.dart';
import 'server.dart';
import 'session.dart';
import 'settings.dart';

/// The Firebase project this build gets notifications through, or null.
///
/// Push is optional: a build gets it with the four
/// `--dart-define=BALNANA_FIREBASE_...` values of an Android app in the same
/// Firebase project as the server's `BALNANA_FCM_CREDENTIALS`. Only Android
/// has it; the web app is open only while someone looks at it.
FirebaseOptions? get firebaseOptions {
  const apiKey = String.fromEnvironment('BALNANA_FIREBASE_API_KEY');
  const appId = String.fromEnvironment('BALNANA_FIREBASE_APP_ID');
  const senderId = String.fromEnvironment('BALNANA_FIREBASE_SENDER_ID');
  const projectId = String.fromEnvironment('BALNANA_FIREBASE_PROJECT_ID');
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
  if (apiKey.isEmpty || appId.isEmpty || senderId.isEmpty || projectId.isEmpty) return null;
  return const FirebaseOptions(apiKey: apiKey, appId: appId, messagingSenderId: senderId, projectId: projectId);
}

/// What the app needs from the phone's push service.
abstract interface class PushService {
  /// This device's address for the server to send to, or null when there is
  /// none (no Google Play services, say).
  Future<String?> token();

  /// A new address, after the old one stopped working.
  Stream<String> get tokenRefresh;

  /// Asks to show notifications, where the system wants that asked.
  Future<void> requestPermission();

  /// The group of the notification that opened the app, if one did.
  Future<String?> initialGroup();

  /// The group of each notification tapped while the app runs.
  Stream<String> get openedGroups;
}

class _FirebasePush implements PushService {
  _FirebasePush(FirebaseOptions options)
    : _messaging = Firebase.initializeApp(options: options).then((_) => FirebaseMessaging.instance);

  final Future<FirebaseMessaging> _messaging;

  // The server sends to registration tokens through the FCM HTTP v1 API, so
  // these stay until it moves to installation IDs (`register`, `onRegistered`).
  @override
  // ignore: deprecated_member_use
  Future<String?> token() async => (await _messaging).getToken();

  @override
  // ignore: deprecated_member_use
  Stream<String> get tokenRefresh => Stream.fromFuture(_messaging).asyncExpand((m) => m.onTokenRefresh);

  @override
  Future<void> requestPermission() async => (await _messaging).requestPermission();

  @override
  Future<String?> initialGroup() async => _group(await (await _messaging).getInitialMessage());

  @override
  Stream<String> get openedGroups => Stream.fromFuture(
    _messaging,
  ).asyncExpand((_) => FirebaseMessaging.onMessageOpenedApp).expand((m) => [?_group(m)]);

  static String? _group(RemoteMessage? message) => switch (message?.data['group']) {
    final String token when token.isNotEmpty => token,
    _ => null,
  };
}

/// The push service of this build, or null when it has none.
final pushServiceProvider = Provider<PushService?>((ref) {
  final options = firebaseOptions;
  return options == null ? null : _FirebasePush(options);
});

/// Whether this build and the chosen server can send notifications.
final pushAvailableProvider = Provider<bool>(
  (ref) =>
      ref.watch(pushServiceProvider) != null && ref.watch(serverInfoProvider.select((i) => i.value?.push == true)),
);

/// Keeps the server told which groups this device wants to hear about.
///
/// Watched for as long as the app runs. It tells the server again whenever
/// the groups, the member picked in one, the session or the setting change,
/// and when the push service hands out a new address. Failures are left for
/// the next change: a missed registration only means a missed notification.
final pushSyncProvider = Provider<void>((ref) {
  final push = ref.watch(pushServiceProvider);
  if (push == null) return;
  final on = ref.watch(settingsProvider.select((s) => s.notifications));
  final server = ref.watch(serverUrlProvider);
  final available = ref.watch(pushAvailableProvider);
  final api = ref.watch(balnanaApiProvider);
  final signedIn = ref.watch(sessionProvider).token != null;
  final groups = [
    for (final g in ref.watch(knownGroupsProvider))
      if (g.memberId case final member?) (token: g.token, memberId: member),
  ];
  final prefs = ref.read(prefsProvider);

  final refresh = push.tokenRefresh.listen((_) => ref.invalidateSelf());
  ref.onDispose(refresh.cancel);

  // Settle first: at start several of the above change one after another.
  final timer = Timer(const Duration(milliseconds: 500), () async {
    try {
      final token = await push.token();
      if (token == null || !ref.mounted) return;
      final before = prefs.getString(_registeredOn);
      if (before != null && (before != server || !on)) {
        // A server left behind is let go even when it cannot be reached.
        final forgotten = before == server && api != null ? await _forget(api, token) : await _forgetOn(before, token);
        if (forgotten || before != server) await prefs.remove(_registeredOn);
      }
      if (!on || !available || api == null || server == null || (groups.isEmpty && !signedIn)) return;
      await push.requestPermission();
      await api.registerPushDevice(token, groups.take(maxPushGroups).toList());
      await prefs.setString(_registeredOn, server);
    } on Object catch (e) {
      debugPrint('push registration failed: $e');
    }
  });
  ref.onDispose(timer.cancel);
});

/// The most groups one registration may name, as the server allows.
const maxPushGroups = 200;

/// The server this device last registered with.
const _registeredOn = 'push.server';

/// Tells the server behind [api] to stop sending to [token], and whether it
/// heard. Needs no session: the token itself is the secret.
Future<bool> _forget(BalnanaApi api, String token) async {
  try {
    await api.removePushDevice(token);
    return true;
  } on ApiException catch (e) {
    // An answer of any kind will do: a server with push off keeps no devices.
    return e.code != ApiException.network;
  }
}

/// [_forget] on [server], which this app no longer talks to.
Future<bool> _forgetOn(String server, String token) async {
  final dio = Dio(BaseOptions(baseUrl: '$server$apiBasePath', connectTimeout: const Duration(seconds: 10)));
  try {
    return await _forget(BalnanaApi(dio), token);
  } finally {
    dio.close();
  }
}
