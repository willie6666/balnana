import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/prefs.dart';
import '../core/server.dart';

/// A group this device has opened, and who this device is in it.
///
/// In link mode the token is the only key to a group, so this list is what
/// "my groups" means. It never leaves the device except to the server.
@immutable
class KnownGroup {
  const KnownGroup({required this.server, required this.token, this.memberId, required this.addedAt});

  static KnownGroup? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final server = json['server'], token = json['token'], member = json['memberId'], added = json['addedAt'];
    if (server is! String || token is! String) return null;
    return KnownGroup(
      server: server,
      token: token,
      memberId: member is String ? member : null,
      addedAt: (added is String ? DateTime.tryParse(added) : null) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, Object?> toJson() => {
    'server': server,
    'token': token,
    'memberId': ?memberId,
    'addedAt': addedAt.toUtc().toIso8601String(),
  };

  final String server;
  final String token;

  /// The member this device acts as; null until the person picks one.
  final String? memberId;
  final DateTime addedAt;

  KnownGroup copyWith({String? token, String? Function()? memberId}) => KnownGroup(
    server: server,
    token: token ?? this.token,
    memberId: memberId != null ? memberId() : this.memberId,
    addedAt: addedAt,
  );
}

/// The groups this device knows on the current server, in the order the
/// person arranged them; a newly added group comes first.
final knownGroupsProvider = NotifierProvider<KnownGroupsNotifier, List<KnownGroup>>(KnownGroupsNotifier.new);

class KnownGroupsNotifier extends Notifier<List<KnownGroup>> {
  static const _key = 'groups.known';

  String? _server;

  @override
  List<KnownGroup> build() {
    _server = ref.watch(serverUrlProvider);
    return [for (final g in _all()) if (g.server == _server) g];
  }

  List<KnownGroup> _all() {
    final raw = ref.read(prefsProvider).getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw);
      if (list is! List<Object?>) return [];
      return list.map(KnownGroup.fromJson).nonNulls.toList();
    } on FormatException {
      return [];
    }
  }

  /// Applies [change] to this server's entries and saves them alongside the
  /// other servers' entries.
  void _update(List<KnownGroup> Function(List<KnownGroup> mine) change) {
    final server = _server;
    if (server == null) return;
    final others = [for (final g in _all()) if (g.server != server) g];
    final mine = change(state);
    state = mine;
    ref.read(prefsProvider).setString(_key, jsonEncode([...mine, ...others].map((g) => g.toJson()).toList()));
  }

  KnownGroup? byToken(String token) {
    for (final g in state) {
      if (g.token == token) return g;
    }
    return null;
  }

  /// Remembers [token]; does nothing when it is already known.
  void add(String token, {String? memberId}) {
    if (_server == null || byToken(token) != null) return;
    _update(
      (mine) => [
        KnownGroup(server: _server!, token: token, memberId: memberId, addedAt: DateTime.now()),
        ...mine,
      ],
    );
  }

  /// Remembers [token] for [server], the one it was created on, even when
  /// another server has been chosen since: the token goes to its own server
  /// alone. A link only the answer to a request carried is lost otherwise.
  ///
  /// It never goes through [state], which belongs to whichever server is
  /// chosen when it is next read.
  void addOn(String server, String token, {String? memberId}) {
    final all = _all();
    if (all.any((g) => g.server == server && g.token == token)) return;
    final entry = KnownGroup(server: server, token: token, memberId: memberId, addedAt: DateTime.now());
    ref.read(prefsProvider).setString(_key, jsonEncode([entry, ...all].map((g) => g.toJson()).toList()));
    ref.invalidateSelf();
  }

  void setMember(String token, String? memberId) =>
      _update((mine) => [for (final g in mine) g.token == token ? g.copyWith(memberId: () => memberId) : g]);

  /// After the link was reset, the group lives on under [newToken].
  void replaceToken(String oldToken, String newToken) =>
      _update((mine) => [for (final g in mine) g.token == oldToken ? g.copyWith(token: newToken) : g]);

  void remove(String token) => _update((mine) => [for (final g in mine) if (g.token != token) g]);

  /// Puts the groups in the order of [tokens]; others keep their place at the end.
  void reorder(List<String> tokens) => _update((mine) {
    final index = {for (final (i, t) in tokens.indexed) t: i};
    return [
      for (final t in tokens) ?byToken(t),
      for (final g in mine) if (!index.containsKey(g.token)) g,
    ];
  });
}
