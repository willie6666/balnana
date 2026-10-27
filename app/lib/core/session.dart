import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offline_cache.dart';
import 'prefs.dart';
import 'server.dart';

/// How this app is signed in to the current server.
///
/// On Android the server hands out a bearer token, kept on the device per
/// server. On the web the session is an HttpOnly cookie the app never sees,
/// so [token] stays null there and [generation] alone marks a change.
@immutable
class SessionKey {
  const SessionKey(this.token, this.generation);

  final String? token;
  final int generation;
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionKey>(SessionNotifier.new);

/// Whom the app talks to the server as: the server, and the session on it.
typedef Identity = ({String? server, String? token, int generation});

/// What was loaded as one [Identity] is never shown as another's: see
/// `current` in data/providers.dart.
final identityProvider = Provider<Identity>((ref) {
  final session = ref.watch(sessionProvider);
  return (server: ref.watch(serverUrlProvider), token: session.token, generation: session.generation);
});

class SessionNotifier extends Notifier<SessionKey> {
  static const _key = 'session.tokens';

  String? _server;

  @override
  SessionKey build() {
    _server = ref.watch(serverUrlProvider);
    return SessionKey(_tokens()[_server], 0);
  }

  Map<String, String> _tokens() {
    final raw = ref.read(prefsProvider).getString(_key);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, Object?>) return {};
      return {
        for (final MapEntry(:key, :value) in map.entries)
          if (value is String) key: value,
      };
    } on FormatException {
      return {};
    }
  }

  /// Uses [token] from now on (null to sign out), and reloads everything.
  ///
  /// [from] is whom the app was when it asked for [token]. A session is for
  /// the server that gave it, and an answer that comes after another server
  /// was chosen, or another session started, is not for now: nothing changes
  /// and false is returned.
  bool set(String? token, {required Identity from}) {
    final server = _server;
    if (server == null || from.server != server || from.generation != state.generation) return false;
    final tokens = _tokens();
    if (token == null) {
      tokens.remove(server);
    } else {
      tokens[server] = token;
    }
    ref.read(prefsProvider).setString(_key, jsonEncode(tokens));
    // What the last account saw is not for the next one.
    ref.read(cacheDbProvider)?.switchAccount(server, cacheAccount(token)).ignore();
    state = SessionKey(token, state.generation + 1);
    return true;
  }
}
