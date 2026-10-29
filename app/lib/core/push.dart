import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush/unifiedpush.dart';

import '../data/api.dart';
import '../data/known_groups.dart';
import '../l10n/app_localizations.dart';
import '../ui/colors.dart';
import 'prefs.dart';
import 'server.dart';
import 'session.dart';
import 'settings.dart';

/// What the app needs from the phone's push service.
abstract interface class PushService {
  /// Subscribes this device to Web Push messages from [server], signed with
  /// [vapid], its public key. Null when the phone has no push service to do
  /// it (no Google Play services and no UnifiedPush app, say).
  Future<PushSubscription?> subscribe(String server, String vapid);

  /// The subscription changed or ended, so the server needs telling again.
  Stream<void> get changes;

  /// Asks to show notifications, where the system wants that asked, and
  /// whether they may be shown.
  Future<bool> requestPermission();

  /// The group of each notification tapped while the app runs.
  Stream<PushTarget> get openedGroups;
}

/// A group a notification is about, and the server it came from. The token
/// is a secret of that server's: it is only ever sent back to that server.
typedef PushTarget = ({String server, String token});

/// What a notification carries to open [target] when tapped.
@visibleForTesting
String notificationPayload(PushTarget target) => jsonEncode({'s': target.server, 'g': target.token});

/// The group a notification's [payload] opens, or null for none. A payload
/// from before notifications named their server opens nothing: which server
/// its group is on is not known.
@visibleForTesting
PushTarget? notificationTarget(String? payload) {
  if (payload == null) return null;
  try {
    return switch (jsonDecode(payload)) {
      {'s': final String server, 'g': final String token} when server.isNotEmpty && token.isNotEmpty => (
        server: server,
        token: token,
      ),
      _ => null,
    };
  } on FormatException {
    return null;
  }
}

/// Push through UnifiedPush: a distributor app the user installed, such as
/// ntfy, or else the one built in, which goes through Google's Firebase
/// Cloud Messaging without the Firebase SDK. Messages are Web Push,
/// encrypted for this device, and shown here as notifications.
class _UnifiedPush implements PushService {
  _UnifiedPush(this._prefs);

  final SharedPreferences _prefs;
  Future<void>? _started;

  /// Set up once. A start that failed is tried again the next time.
  Future<void> get _ready => _started ??= _start().catchError((Object e, StackTrace stack) {
    _started = null;
    Error.throwWithStackTrace(e, stack);
  });
  final _changes = StreamController<void>.broadcast();
  final _opened = StreamController<PushTarget>.broadcast();

  /// Registrations waiting for their endpoint, by instance.
  final _waiting = <String, Completer<PushEndpoint?>>{};

  Future<void> _start() async {
    await _notifications.initialize(
      settings: _notificationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (notificationTarget(response.payload) case final target?) _opened.add(target);
      },
    );
    await UnifiedPush.initialize(
      onNewEndpoint: (endpoint, instance) {
        if (_waiting.remove(instance) case final waiter?) {
          waiter.complete(endpoint);
        } else if (instance == _prefs.getString(_instanceKey)) {
          // A new address the push service handed out on its own.
          final before = _savedSubscription(_prefs, instance);
          unawaited(_saveEndpoint(_prefs, instance, endpoint));
          final keys = endpoint.pubKeySet;
          if (before?.endpoint != endpoint.url ||
              before?.p256dh != keys?.pubKey ||
              before?.auth != keys?.auth) {
            _changes.add(null);
          }
        }
      },
      onRegistrationFailed: (reason, instance) {
        debugPrint('push registration failed: $reason');
        _waiting.remove(instance)?.complete(null);
      },
      onUnregistered: (instance) {
        if (instance != _prefs.getString(_instanceKey)) return;
        unawaited(_prefs.remove(_endpointKey));
        _changes.add(null);
      },
      onMessage: (message, instance) => unawaited(_notify(_prefs, message, instance)),
    );
  }

  @override
  Future<PushSubscription?> subscribe(String server, String vapid) async {
    await _ready;
    if (!await UnifiedPush.tryUseCurrentOrDefaultDistributor()) return null;
    // One registration per server: another one gets its own address, and
    // what comes to this one is known to be from this server.
    final instance = 'balnana-${sha256.convert(utf8.encode('$server\n$vapid')).toString().substring(0, 16)}';
    await _prefs.setString(_originKey(instance), server);
    final waiter = _waiting[instance] ??= Completer<PushEndpoint?>();
    await UnifiedPush.register(instance: instance, vapid: vapid);
    final endpoint = await waiter.future.timeout(const Duration(seconds: 30), onTimeout: () => null);
    if (identical(_waiting[instance], waiter)) _waiting.remove(instance);

    if (endpoint != null) {
      // Without keys the server cannot encrypt for this device.
      if (endpoint.pubKeySet == null) return null;
      await _saveEndpoint(_prefs, instance, endpoint);
    } else {
      // The push service may stay quiet about an address it already gave,
      // possibly to the background receiver.
      await _prefs.reload();
    }
    final sub = _savedSubscription(_prefs, instance);
    if (sub == null) return null;
    final before = _prefs.getString(_instanceKey);
    if (before != instance) {
      await _prefs.setString(_instanceKey, instance);
      if (before != null) {
        unawaited(UnifiedPush.unregister(before));
        await _prefs.remove(_originKey(before));
      }
    }
    return sub;
  }

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<bool> requestPermission() async {
    await _ready;
    final allowed = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return allowed ?? true;
  }

  @override
  Stream<PushTarget> get openedGroups {
    _ready.ignore();
    return _opened.stream;
  }
}

/// The group of the notification that opened the app, if one did. It is read
/// before the first screen, so the app opens on that group straight away.
Future<PushTarget?> launchedFromNotification() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
  try {
    await _notifications.initialize(settings: _notificationSettings);
    final launch = await _notifications.getNotificationAppLaunchDetails();
    if (launch == null || !launch.didNotificationLaunchApp) return null;
    return notificationTarget(launch.notificationResponse?.payload);
  } on Exception {
    return null;
  }
}

/// What [launchedFromNotification] found when the app started.
final launchTargetProvider = Provider<PushTarget?>((ref) => null);

/// Receives push messages while the app is closed. The UnifiedPush plugin
/// starts the app's `main` with `--unifiedpush-bg` for that, with no screen
/// to show: this shows the notifications and remembers a new address for
/// the next time the app opens and tells the server.
Future<void> receivePushInBackground() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await _notifications.initialize(settings: _notificationSettings);
  await UnifiedPush.initialize(
    onNewEndpoint: (endpoint, instance) => unawaited(_saveEndpoint(prefs, instance, endpoint)),
    onUnregistered: (instance) {
      if (instance == prefs.getString(_instanceKey)) unawaited(prefs.remove(_endpointKey));
    },
    onMessage: (message, instance) => unawaited(_notify(prefs, message, instance)),
  );
}

final _notifications = FlutterLocalNotificationsPlugin();

const _notificationSettings = InitializationSettings(
  android: AndroidInitializationSettings('ic_notification'),
);

/// The UnifiedPush instance of the current registration.
const _instanceKey = 'push.instance';

/// Its address and keys, as JSON, with the instance they belong to.
const _endpointKey = 'push.endpoint';

/// The server whose messages come to [instance].
String _originKey(String instance) => 'push.origin.$instance';

Future<void> _saveEndpoint(SharedPreferences prefs, String instance, PushEndpoint endpoint) async {
  final keys = endpoint.pubKeySet;
  if (keys == null) return;
  await prefs.setString(
    _endpointKey,
    jsonEncode({'instance': instance, 'url': endpoint.url, 'p256dh': keys.pubKey, 'auth': keys.auth}),
  );
}

PushSubscription? _savedSubscription(SharedPreferences prefs, String instance) {
  final saved = prefs.getString(_endpointKey);
  if (saved == null) return null;
  return switch (jsonDecode(saved)) {
    {
      'instance': final String i,
      'url': final String url,
      'p256dh': final String p256dh,
      'auth': final String auth,
    }
        when i == instance =>
      (endpoint: url, p256dh: p256dh, auth: auth),
    _ => null,
  };
}

/// The notification ID for [expense]: the same in every process, and
/// different for different expenses. Android keys a notification's tap
/// action by this ID alone, not by its tag, so notifications sharing one
/// would all open the group of whichever came last.
@visibleForTesting
int notificationId(String expense) {
  final b = sha256.convert(utf8.encode(expense)).bytes;
  return (b[0] << 24 | b[1] << 16 | b[2] << 8 | b[3]) & 0x7fffffff;
}

/// Shows one push message from the server (see notify in
/// server/internal/api/push.go): the group's name over a line in the
/// phone's language. Tapping it opens the group, if the app still talks to
/// the server it came from.
Future<void> _notify(SharedPreferences prefs, PushMessage message, String instance) async {
  // Turned off since the server was last told: show nothing.
  if (!message.decrypted || !SettingsNotifier.notificationsOn(prefs)) return;
  // From a server this device no longer registers with.
  var server = prefs.getString(_originKey(instance));
  if (server == null) {
    // Perhaps registered by the other process since this one read them.
    await prefs.reload();
    server = prefs.getString(_originKey(instance));
    if (server == null) return;
  }
  final Object? json;
  try {
    json = jsonDecode(utf8.decode(message.content));
  } on FormatException {
    return;
  }
  if (json case {
    'g': final String group,
    'e': final String expense,
    't': final String title,
    'k': final String key,
    'a': final List<Object?> args,
  }) {
    final locale = SettingsNotifier.savedLocale(prefs) ?? PlatformDispatcher.instance.locale;
    final l10n = lookupAppLocalizations(
      AppLocalizations.delegate.isSupported(locale) ? locale : AppLocalizations.supportedLocales.first,
    );
    final a = args.whereType<String>().toList();
    final body = switch ((key, a)) {
      ('push_payment_added', [final payer, final payee, final amount]) => l10n.pushPaymentAdded(
        payer,
        payee,
        amount,
      ),
      ('push_expense_added', [final who, final what, final amount]) => l10n.pushExpenseAdded(
        who,
        what,
        amount,
      ),
      ('push_expense_edited', [final who, final what, final amount]) => l10n.pushExpenseEdited(
        who,
        what,
        amount,
      ),
      ('push_expense_deleted', [final who, final what, final amount]) => l10n.pushExpenseDeleted(
        who,
        what,
        amount,
      ),
      ('push_expense_added_anon', [final what, final amount]) => l10n.pushExpenseAddedAnon(what, amount),
      ('push_expense_edited_anon', [final what, final amount]) => l10n.pushExpenseEditedAnon(what, amount),
      ('push_expense_deleted_anon', [final what, final amount]) => l10n.pushExpenseDeletedAnon(what, amount),
      // From a newer server: say nothing rather than something wrong.
      _ => null,
    };
    if (body == null) return;
    await _notifications.show(
      // One notification per expense: a change replaces the last one.
      id: notificationId(expense),
      title: title,
      body: body,
      payload: notificationPayload((server: server, token: group)),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'expenses',
          l10n.pushChannel,
          channelDescription: l10n.pushChannelDescription,
          icon: 'ic_notification',
          color: brandSeed,
          tag: expense,
          category: AndroidNotificationCategory.social,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
  }
}

/// The push service of this build, or null when it has none. Only Android
/// has one; the web app is open only while someone looks at it.
final pushServiceProvider = Provider<PushService?>((ref) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
  return _UnifiedPush(ref.watch(prefsProvider));
});

/// The chosen server's push key, when this build and the server can send
/// notifications.
final _pushKeyProvider = Provider<String?>((ref) {
  if (ref.watch(pushServiceProvider) == null) return null;
  return ref.watch(serverInfoProvider.select((i) => i.value?.push == true ? i.value?.vapidPublicKey : null));
});

/// Whether this build and the chosen server can send notifications.
final pushAvailableProvider = Provider<bool>((ref) => ref.watch(_pushKeyProvider) != null);

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
    vapid: ref.watch(_pushKeyProvider),
    api: ref.watch(balnanaApiProvider),
    signedIn: ref.watch(sessionProvider).token != null,
    groups: [
      for (final g in ref.watch(knownGroupsProvider))
        if (g.memberId case final member?) (token: g.token, memberId: member),
    ],
  );

  final changes = push.changes.listen((_) => ref.invalidateSelf());
  ref.onDispose(changes.cancel);

  // Settle first: at start several of the above change one after another.
  final timer = Timer(const Duration(milliseconds: 500), () => sync.want(want));
  ref.onDispose(timer.cancel);
});

final _pushReconcilerProvider = Provider<_PushReconciler>(
  (ref) => _PushReconciler(ref.watch(prefsProvider), (blocked) {
    if (ref.mounted) ref.read(pushBlockedProvider.notifier).set(blocked);
  }),
);

/// Whether the system was last found to block this app's notifications, so
/// none show however the setting is.
final pushBlockedProvider = NotifierProvider<PushBlockedNotifier, bool>(PushBlockedNotifier.new);

class PushBlockedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool blocked) {
    if (state != blocked) state = blocked;
  }
}

/// What the server should know about this device, as of one change.
class _PushWant {
  const _PushWant({
    required this.push,
    required this.on,
    required this.server,
    required this.vapid,
    required this.api,
    required this.signedIn,
    required this.groups,
  });

  final PushService push;
  final bool on;
  final String? server;

  /// The server's push key; null when it sends no notifications.
  final String? vapid;
  final BalnanaApi? api;
  final bool signedIn;
  final List<({String token, String memberId})> groups;

  bool get register =>
      on && vapid != null && api != null && server != null && (groups.isNotEmpty || signedIn);
}

/// Tells the server one thing at a time, always ending with the latest
/// [_PushWant]: a registration still on its way when notifications are
/// turned off is followed by a removal, not left standing.
class _PushReconciler {
  _PushReconciler(this._prefs, this._blocked);

  final SharedPreferences _prefs;
  final void Function(bool blocked) _blocked;
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
    final device = await _deviceId(_prefs);
    final server = want.server;
    final before = _prefs.getString(_registeredOn);
    if (before != null && (before != server || !want.on)) {
      // A server left behind is let go even when it cannot be reached.
      final api = want.api;
      final forgotten = before == server && api != null
          ? await _forget(api, device)
          : await _forgetOn(before, device);
      if (forgotten || before != server) await _prefs.remove(_registeredOn);
    }
    if (!want.register || _stale(want)) return;
    try {
      _blocked(!await want.push.requestPermission());
    } on Object catch (e) {
      // The server is told all the same: notifications allowed later, in
      // the system's settings, then show straight away.
      debugPrint('notification permission: $e');
    }
    if (_stale(want)) return;
    final sub = await want.push.subscribe(server!, want.vapid!);
    if (sub == null || _stale(want)) return;
    await want.api!.registerPushDevice(device, sub, want.groups.take(maxPushGroups).toList());
    // Saved even when overtaken meanwhile: the next run may need to undo it.
    await _prefs.setString(_registeredOn, server);
  }
}

/// The most groups one registration may name, as the server allows.
const maxPushGroups = 200;

/// The server this device last registered with.
const _registeredOn = 'push.server';

/// This device's ID on servers, made up here at random. Only this device
/// knows it, so it is also what lets the device unregister.
const _deviceKey = 'push.device';

Future<String> _deviceId(SharedPreferences prefs) async {
  if (prefs.getString(_deviceKey) case final id?) return id;
  final random = Random.secure();
  final id = base64Url.encode([for (var i = 0; i < 32; i++) random.nextInt(256)]).replaceAll('=', '');
  await prefs.setString(_deviceKey, id);
  return id;
}

/// Tells the server behind [api] to stop sending to [device], and whether it
/// heard. Needs no session: the device ID itself is the secret.
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
