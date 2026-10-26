import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/prefs.dart';
import '../core/server.dart';
import 'known_groups.dart';
import 'models.dart';
import 'providers.dart';

/// Whose groups these are: the server, and the account when signed in.
String? _owner(Ref ref) {
  final server = ref.watch(serverUrlProvider);
  if (server == null) return null;
  return '$server ${ref.watch(accountProvider.select((a) => a.value?.id)) ?? ''}';
}

/// The group shown at home: the one opened last.
final currentGroupProvider = NotifierProvider<CurrentGroupNotifier, String?>(CurrentGroupNotifier.new);

class CurrentGroupNotifier extends Notifier<String?> {
  static const _key = 'groups.current';

  String? _for;

  @override
  String? build() {
    _for = _owner(ref);
    if (_for == null) return null;
    final token = _read()[_for];
    return token is String ? token : null;
  }

  Map<String, Object?> _read() {
    try {
      final map = jsonDecode(ref.read(prefsProvider).getString(_key) ?? '{}');
      return map is Map<String, Object?> ? map : {};
    } on FormatException {
      return {};
    }
  }

  void set(String? token) {
    final owner = _for;
    if (owner == null || token == state) return;
    state = token;
    final map = _read();
    if (token == null) {
      map.remove(owner);
    } else {
      map[owner] = token;
    }
    ref.read(prefsProvider).setString(_key, jsonEncode(map));
  }
}

/// The order a signed-in account put its groups in on this device, by token.
/// Signed out, the list of groups on this device keeps its own order.
final groupOrderProvider = NotifierProvider<GroupOrderNotifier, List<String>>(GroupOrderNotifier.new);

class GroupOrderNotifier extends Notifier<List<String>> {
  static const _key = 'groups.order';

  String? _for;

  @override
  List<String> build() {
    _for = _owner(ref);
    final list = _read()[_for];
    return list is List ? list.whereType<String>().toList() : [];
  }

  Map<String, Object?> _read() {
    try {
      final map = jsonDecode(ref.read(prefsProvider).getString(_key) ?? '{}');
      return map is Map<String, Object?> ? map : {};
    } on FormatException {
      return {};
    }
  }

  void set(List<String> tokens) {
    final owner = _for;
    if (owner == null) return;
    state = tokens;
    ref.read(prefsProvider).setString(_key, jsonEncode({..._read(), owner: tokens}));
  }
}

/// Groups in the order chosen with [groupOrderProvider]; groups it does not
/// know yet come first, in the order given.
List<GroupSummary> inChosenOrder(List<GroupSummary> groups, List<String> order) {
  final index = {for (final (i, t) in order.indexed) t: i};
  final fresh = [for (final g in groups) if (!index.containsKey(g.token)) g];
  final placed = [for (final g in groups) if (index.containsKey(g.token)) g]
    ..sort((a, b) => index[a.token]!.compareTo(index[b.token]!));
  return [...fresh, ...placed];
}

/// Moves the group at [from] to [to] among [groups] and keeps that order.
void reorderGroups(WidgetRef ref, List<GroupSummary> groups, int from, int to) {
  final tokens = [for (final g in groups) g.token];
  final moved = tokens.removeAt(from);
  tokens.insert(to, moved);
  if (ref.read(signedInProvider)) {
    ref.read(groupOrderProvider.notifier).set(tokens);
  } else {
    ref.read(knownGroupsProvider.notifier).reorder(tokens);
  }
}

/// Where home opens without asking the server, if it can tell: the group
/// opened last, or else the first group on this device.
String? homeGroup(Ref ref) {
  final current = ref.read(currentGroupProvider);
  if (ref.read(signedInProvider)) return current;
  final known = ref.read(knownGroupsProvider);
  if (current != null && known.any((g) => g.token == current)) return current;
  return known.isEmpty ? null : known.first.token;
}
