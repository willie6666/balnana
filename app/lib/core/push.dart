import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  /// This device's address for the server to send to, its Firebase
  /// installation ID, or null when there is none (no Google Play services,
  /// say).
  Future<String?> device();

  /// A new address, after the old one stopped working.
  Stream<String> get deviceChanges;

  /// Asks to show notifications, where the system wants that asked.
  Future<void> requestPermission();

  /// The group of the notification that opened the app, if one did.
  Future<String?> initialGroup();

  /// The group of each notification tapped while the app runs.
  Stream<String> get openedGroups;
}

class _FirebasePush implements PushService {
  _FirebasePush(FirebaseOptions options)
    : _messaging = Firebase.initializeApp(options: options).then((_) => FirebaseMessaging.instance) {
    _messaging.then((m) => m.onRegistered.listen(_registered)).ignore();
  }

  final Future<FirebaseMessaging> _messaging;
  final _changes = StreamController<String>.broadcast();
  String? _id;

  void _registered(String id) {
    if (id == _id) return;
    _id = id;
    _changes.add(id);
  }

  @override
  Future<String?> device() async {
    final m = await _messaging;
    final next = m.onRegistered.first;
    await m.register();
    if (_id case final id?) {
      next.ignore();
      return id;
    }
    return next.timeout(const Duration(seconds: 30));
  }

  @override
  Stream<String> get deviceChanges => _changes.stream;

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
  final sync = ref.watch(_pushReconcilerProvider);
  final want = _PushWant(
    push: push,
    on: ref.watch(settingsProvider.select((s) => s.notifications)),
    server: ref.watch(serverUrlProvider),
    available: ref.watch(pushAvailableProvider),
    api: ref.watch(balnanaApiProvider),
    signedIn: ref.watch(sessionProvider).token != null,
    groups: [
      for (final g in ref.watch(knownGroupsProvider))
        if (g.memberId case final member?) (token: g.token, memberId: member),
    ],
  );

  final changes = push.deviceChanges.listen((_) => ref.invalidateSelf());
  ref.onDispose(changes.cancel);

  // Settle first: at start several of the above change one after another.
  final timer = Timer(const Duration(milliseconds: 500), () => sync.want(want));
  ref.onDispose(timer.cancel);
});

final _pushReconcilerProvider = Provider<_PushReconciler>((ref) => _PushReconciler(ref.watch(prefsProvider)));

/// What the server should know about this device, as of one change.
class _PushWant {
  const _PushWant({
    required this.push,
    required this.on,
    required this.server,
    required this.available,
    required this.api,
    required this.signedIn,
    required this.groups,
  });

  final PushService push;
  final bool on;
  final String? server;
  final bool available;
  final BalnanaApi? api;
  final bool signedIn;
  final List<({String token, String memberId})> groups;

  bool get register => on && available && api != null && server != null && (groups.isNotEmpty || signedIn);
}

/// Tells the server one thing at a time, always ending with the latest
/// [_PushWant]: a registration still on its way when notifications are
/// turned off is followed by a removal, not left standing.
class _PushReconciler {
  _PushReconciler(this._prefs);

  final SharedPreferences _prefs;
  _PushWant? _latest;
  bool _running = false;

  void want(_PushWant want) {
    _latest = want;
    if (!_running) unawaited(_run());
  }

  Future<void> _run() async {
    _running = true;
    try {
      for (var want = _latest; want != null; want = identical(want, _latest) ? null : _latest) {
        try {
          await _apply(want);
        } on Object catch (e) {
          debugPrint('push registration failed: $e');
        }
      }
    } finally {
      _running = false;
    }
  }

  /// Whether [want] has been overtaken, so what is left of it is not done.
  bool _stale(_PushWant want) => !identical(want, _latest);

  Future<void> _apply(_PushWant want) async {
    final device = await want.push.device();
    if (device == null || _stale(want)) return;
    final server = want.server;
    final before = _prefs.getString(_registeredOn);
    if (before != null && (before != server || !want.on)) {
      // A server left behind is let go even when it cannot be reached.
      final api = want.api;
      final forgotten = before == server && api != null ? await _forget(api, device) : await _forgetOn(before, device);
      if (forgotten || before != server) await _prefs.remove(_registeredOn);
    }
    if (!want.register || _stale(want)) return;
    await want.push.requestPermission();
    if (_stale(want)) return;
    await want.api!.registerPushDevice(device, want.groups.take(maxPushGroups).toList());
    // Saved even when overtaken meanwhile: the next run may need to undo it.
    await _prefs.setString(_registeredOn, server!);
  }
}

/// The most groups one registration may name, as the server allows.
const maxPushGroups = 200;

/// The server this device last registered with.
const _registeredOn = 'push.server';

/// Tells the server behind [api] to stop sending to [device], and whether it
/// heard. Needs no session: the device's address itself is the secret.
Future<bool> _forget(BalnanaApi api, String device) async {
  try {
    await api.removePushDevice(device);
    return true;
  } on ApiException catch (e) {
    // An answer of any kind will do: a server with push off keeps no devices.
    return e.code != ApiException.network;
  }
}

/// [_forget] on [server], which this app no longer talks to.
Future<bool> _forgetOn(String server, String device) async {
  final dio = Dio(BaseOptions(baseUrl: '$server$apiBasePath', connectTimeout: const Duration(seconds: 10)));
  try {
    return await _forget(BalnanaApi(dio), device);
  } finally {
    dio.close();
  }
}
