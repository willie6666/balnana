import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;

import '../data/api.dart';
import 'push.dart';
import 'settings.dart';

/// The browser's push service, or null in a browser without one: Safari on
/// a phone has it only for an app added to the home screen, and no browser
/// has it for a page not served over https.
PushService? webPushService(SharedPreferences prefs) {
  if (!web.window.isSecureContext ||
      !globalContext.has('PushManager') ||
      !globalContext.has('Notification') ||
      !web.window.navigator.has('serviceWorker')) {
    return null;
  }
  return _WebPush(prefs);
}

/// Push through the browser's own push service. web/push_sw.js receives the
/// messages, words them and shows them, also while no tab of the app is
/// open; a tap opens the group in a tab that is, or in a new one.
class _WebPush implements PushService {
  _WebPush(this._prefs) {
    web.window.navigator.serviceWorker.addEventListener('message', _message.toJS);
    unawaited(_watchPermission());
  }

  final SharedPreferences _prefs;
  final _changes = StreamController<void>.broadcast();
  final _opened = StreamController<PushTarget>.broadcast();

  void _message(web.MessageEvent event) {
    if (event.data.dartify() case {'balnanaOpen': {'server': final String server, 'token': final String token}}) {
      _opened.add((server: server, token: token));
    }
  }

  /// Notifications allowed or blocked in the browser's site settings.
  Future<void> _watchPermission() async {
    try {
      final status = await web.window.navigator.permissions.query({'name': 'notifications'}.jsify()! as JSObject).toDart;
      status.onchange = ((web.Event _) => _changes.add(null)).toJS;
    } on Object catch (e) {
      debugPrint('notification permission: $e');
    }
  }

  static bool get _granted => web.Notification.permission == 'granted';

  @override
  Future<PushSubscription?> subscribe(String server, String vapid) async {
    // Subscribing would ask, and browsers want that asked from a tap.
    if (!_granted) return null;
    final script = Uri(
      path: 'push_sw.js',
      queryParameters: {
        'server': server,
        if (SettingsNotifier.savedLocale(_prefs) case final locale?) 'lang': locale.toLanguageTag(),
      },
    );
    // Its own scope, so Flutter's service worker, which removes itself, and
    // this one leave each other be. A new query updates this one in place.
    final registration = await web.window.navigator.serviceWorker
        .register(script.toString().toJS, web.RegistrationOptions(scope: 'push/'))
        .toDart;
    await _activated(registration);
    final key = base64Url.decode(base64Url.normalize(vapid));
    final manager = registration.pushManager;
    var sub = await manager.getSubscription().toDart;
    if (sub != null && !listEquals(sub.options.applicationServerKey?.toDart.asUint8List(), key)) {
      // Subscribed for another server's key.
      await sub.unsubscribe().toDart;
      sub = null;
    }
    sub ??= await manager
        .subscribe(web.PushSubscriptionOptionsInit(userVisibleOnly: true, applicationServerKey: key.toJS))
        .toDart;
    final p256dh = sub.getKey('p256dh');
    final auth = sub.getKey('auth');
    if (p256dh == null || auth == null) return null;
    return (endpoint: sub.endpoint, p256dh: _encode(p256dh), auth: _encode(auth));
  }

  /// Waits for the worker's first install: a registration without an active
  /// worker cannot subscribe.
  static Future<void> _activated(web.ServiceWorkerRegistration registration) async {
    if (registration.active != null) return;
    final worker = registration.installing ?? registration.waiting;
    if (worker == null) return;
    final done = Completer<void>();
    void check() {
      if (done.isCompleted) return;
      if (worker.state == 'activated') done.complete();
      if (worker.state == 'redundant') done.completeError(StateError('the push worker failed to install'));
    }

    worker.addEventListener('statechange', ((web.Event _) => check()).toJS);
    check();
    await done.future.timeout(const Duration(seconds: 30));
  }

  static String _encode(JSArrayBuffer bytes) => base64Url.encode(bytes.toDart.asUint8List()).replaceAll('=', '');

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<bool> requestPermission({bool tapped = false}) async {
    if (!tapped || web.Notification.permission != 'default') return _granted;
    // Called straight from the tap: the browser asks only then.
    final answer = (await web.Notification.requestPermission().toDart).toDart;
    if (answer == 'granted') _changes.add(null);
    return answer == 'granted';
  }

  @override
  Stream<PushTarget> get openedGroups => _opened.stream;
}
