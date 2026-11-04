import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/offline_cache.dart';
import '../core/server.dart';
import '../core/session.dart';
import 'api.dart';
import 'known_groups.dart';
import 'providers.dart';

/// What the signed-in account has left to send to the chosen server, oldest
/// first. Nothing waits where the device keeps no cache, as on the web.
final pendingWritesProvider = StreamProvider<List<PendingWrite>>((ref) {
  final db = ref.watch(cacheDbProvider);
  final server = ref.watch(serverUrlProvider);
  if (db == null || server == null) return Stream.value(const []);
  return db.watchPending(server, cacheAccount(ref.watch(sessionProvider).token));
});

/// Keeps new expenses and payments made while the server is out of reach,
/// and sends them in order once it is back: when the app comes online, is
/// opened again, or [send] is asked for.
///
/// One the server refuses is kept with its error, and the rest still go.
/// One that cannot get through stops the rest, so they keep their order.
final pendingSenderProvider = NotifierProvider<PendingSender, void>(PendingSender.new);

class PendingSender extends Notifier<void> {
  var _sending = false;
  var _again = false;

  @override
  void build() {
    // Nothing waits without a cache, as on the web.
    if (ref.watch(cacheDbProvider) == null) return;
    ref.listen(offlineProvider, (was, now) {
      if (was == true && !now) unawaited(send());
    });
    // The rows to send are another account's or server's now.
    ref.listen(identityProvider, (_, _) => unawaited(send()));
    // Whatever was left the last time the app ran.
    Future.microtask(send);
  }

  /// Keeps [body] to send to [path] in the group of [token] with [key], and
  /// returns whether it was kept: it is not where there is no cache.
  Future<bool> queue(String token, String path, Map<String, Object?> body, String key) async {
    final db = ref.read(cacheDbProvider);
    final server = ref.read(serverUrlProvider);
    if (db == null || server == null) return false;
    await db.addPending(
      server: server,
      account: cacheAccount(ref.read(sessionProvider).token),
      group: token,
      member: ref.read(knownGroupsProvider.notifier).byToken(token)?.memberId,
      path: path,
      body: body,
      key: key,
    );
    // The bar shows it waiting and asks until the server is back.
    if (ref.mounted) ref.read(offlineProvider.notifier).set(true);
    return true;
  }

  /// Sends what waits. Asked while sending, it goes over the rows again
  /// once done, for any the first pass did not see.
  Future<void> send() async {
    if (_sending) {
      _again = true;
      return;
    }
    final db = ref.read(cacheDbProvider);
    final who = ref.read(identityProvider);
    final server = who.server;
    if (db == null || server == null) return;
    _sending = true;
    try {
      for (final w in await db.pending(server, cacheAccount(who.token))) {
        if (w.error != null) continue;
        // Signed in as someone else meanwhile: theirs are sent next.
        if (!ref.mounted || ref.read(identityProvider) != who) return;
        final api = ref.read(balnanaApiProvider);
        if (api == null) return;
        try {
          await api.group(w.groupToken, memberId: w.member).resend(w.path, jsonDecode(w.body), key: w.key);
        } on ApiException catch (e) {
          if (e.unreachable) {
            if (ref.mounted) ref.read(offlineProvider.notifier).set(true);
            return;
          }
          // Busy: tried again with everything else.
          if (e.status == 429 || (e.status ?? 0) >= 500) return;
          await db.parkPending(w.id, e.code);
          continue;
        }
        await db.removePending(w.id);
        if (ref.mounted) refreshGroupOf(ref, w.groupToken);
      }
    } finally {
      _sending = false;
      if (_again && ref.mounted) {
        _again = false;
        unawaited(send());
      }
    }
  }

  /// Sends [w] again after the server refused it.
  Future<void> retry(PendingWrite w) async {
    await ref.read(cacheDbProvider)?.retryPending(w.id);
    await send();
  }

  Future<void> discard(PendingWrite w) async => ref.read(cacheDbProvider)?.removePending(w.id);
}
