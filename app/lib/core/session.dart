import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offline_cache.dart';
import 'prefs.dart';
import 'server.dart';

/// How this app is signed in to the current server.
///
/// On Android the server hands out a bearer token, kept on the device per
/// server, in shared preferences. The same-origin web app uses an HttpOnly
/// cookie and [token] stays null; a cross-origin web app keeps a bearer token.
/// [generation] marks a sign-in or sign-out even when the cookie is unseen.
@immutable
class SessionKey {
  const SessionKey(this.token, this.generation, {this.userId});

  final String? token;
  final int generation;
  final String? userId;

  /// Pending writes belong to an account across renewed sessions.
  String get pendingAccount => userId == null ? cacheAccount(token) : 'user:$userId';
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionKey>(SessionNotifier.new);

/// Whom the app talks to the server as: the server, and the session on it.
typedef Identity = ({String? server, String? token, int generation});

/// What was loaded as one [Identity] is never shown as another's: see
/// `current` in data/providers.dart.
final identityProvider = Provider<Identity>((ref) {
  final (token, generation) = ref.watch(sessionProvider.select((s) => (s.token, s.generation)));
  return (server: ref.watch(serverUrlProvider), token: token, generation: generation);
});

class SessionNotifier extends Notifier<SessionKey> {
  static const _key = 'session.tokens';
  static const _usersKey = 'session.users';

  String? _server;

  @override
  SessionKey build() {
    _server = ref.watch(serverUrlProvider);
    final token = _tokens()[_server];
    return SessionKey(token, 0, userId: token == null ? null : _tokens(_usersKey)[_userKey(_server!, token)]);
  }

  Map<String, String> _tokens([String key = _key]) {
    final raw = ref.read(prefsProvider).getString(key);
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
  bool set(String? token, {required Identity from, String? userId}) {
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
    if (token != null && userId != null) _rememberUser(server, token, userId);
    state = SessionKey(
      token,
      state.generation + 1,
      userId: token == null ? null : userId ?? _tokens(_usersKey)[_userKey(server, token)],
    );
    return true;
  }

  static String _userKey(String server, String token) => jsonEncode([server, cacheAccount(token)]);

  void _rememberUser(String server, String token, String userId) {
    final users = _tokens(_usersKey)..[_userKey(server, token)] = userId;
    ref.read(prefsProvider).setString(_usersKey, jsonEncode(users));
  }

  /// Remembers a verified account so its offline work survives signing in again.
  void identify(Identity from, String userId) {
    if (_server != from.server ||
        state.token != from.token ||
        state.generation != from.generation ||
        from.token == null ||
        state.userId == userId) {
      return;
    }
    _rememberUser(from.server!, from.token!, userId);
    state = SessionKey(state.token, state.generation, userId: userId);
  }

  /// The server said a call made as [from] needs signing in. A token it
  /// answered that to is gone, so it is dropped. A cookie is unseen here:
  /// while the app still shows someone [signedIn], everything reloads once
  /// as a new session, and the account turns out signed out.
  void lost(Identity from, {required bool signedIn}) {
    if (from.token != null) {
      set(null, from: from);
    } else if (signedIn && from.server == _server && from.generation == state.generation) {
      state = SessionKey(null, state.generation + 1);
    }
  }
}
