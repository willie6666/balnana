import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'prefs.dart';
import 'server.dart';

/// The header a group's key goes in; see "Group passwords" in api/openapi.yaml.
const groupKeyHeader = 'X-Balnana-Group-Key';

/// The keys this device was given for groups with a password, by token, on
/// the current server. A member needs none, so most groups have no entry.
final groupKeysProvider = NotifierProvider<GroupKeysNotifier, Map<String, String>>(GroupKeysNotifier.new);

class GroupKeysNotifier extends Notifier<Map<String, String>> {
  static const _key = 'groups.keys';

  String? _server;

  @override
  Map<String, String> build() {
    _server = ref.watch(serverUrlProvider);
    return {...?_all()[_server]};
  }

  /// Every server's keys: server, then token, then key.
  Map<String, Map<String, String>> _all() {
    final raw = ref.read(prefsProvider).getString(_key);
    if (raw == null) return {};
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, Object?>) return {};
      return {
        for (final MapEntry(key: server, value: keys) in json.entries)
          if (keys is Map<String, Object?>)
            server: {
              for (final MapEntry(key: token, value: key) in keys.entries)
                if (key is String) token: key,
            },
      };
    } on FormatException {
      return {};
    }
  }

  void _update(Map<String, String> Function(Map<String, String> mine) change) {
    final server = _server;
    if (server == null) return;
    final all = _all();
    final mine = change({...state});
    state = mine;
    if (mine.isEmpty) {
      all.remove(server);
    } else {
      all[server] = mine;
    }
    ref.read(prefsProvider).setString(_key, jsonEncode(all));
  }

  void set(String token, String key) => _update((mine) => mine..[token] = key);

  void remove(String token) {
    if (state.containsKey(token)) _update((mine) => mine..remove(token));
  }

  /// After the link was reset, the key goes with the group to [newToken].
  void replaceToken(String oldToken, String newToken) {
    final key = state[oldToken];
    if (key == null) return;
    _update(
      (mine) => mine
        ..remove(oldToken)
        ..[newToken] = key,
    );
  }
}

/// Sends the key this device has for the group a request is about.
class GroupKeyInterceptor extends Interceptor {
  GroupKeyInterceptor(this.keyFor);

  /// The key for the group with this token, if this device has one.
  final String? Function(String token) keyFor;

  static final _groupPath = RegExp(r'^/g/([^/?]+)');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_groupPath.firstMatch(options.path)?.group(1) case final encoded?) {
      if (keyFor(Uri.decodeComponent(encoded)) case final key?) options.headers[groupKeyHeader] = key;
    }
    handler.next(options);
  }

  /// The key [dio] sends for [token], for requests that do not go through
  /// it, like the browser's event stream.
  static String? of(Dio dio, String token) {
    for (final i in dio.interceptors) {
      if (i is GroupKeyInterceptor) return i.keyFor(token);
    }
    return null;
  }
}
