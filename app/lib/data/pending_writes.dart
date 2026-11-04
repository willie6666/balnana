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
  return db.watchPending(server, ref.watch(sessionProvider).pendingAccount);
});

/// The original owner of a write, captured before its network request starts.
typedef PendingTarget = ({Identity identity, String account, String? member});

PendingTarget pendingTarget(WidgetRef ref, String token) => (
  identity: ref.read(identityProvider),
  account: ref.read(sessionProvider).pendingAccount,
  member: ref.read(knownGroupsProvider.notifier).byToken(token)?.memberId,
);

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
  Timer? _retry;
  var _failures = 0;

  @override
  void build() {
    // Nothing waits without a cache, as on the web.
    if (ref.watch(cacheDbProvider) == null) return;
    ref.onDispose(() => _retry?.cancel());
    ref.listen(offlineProvider, (was, now) {
      if (was == true && !now) unawaited(send());
    });
    // The rows to send are another account's or server's now.
    ref.listen(sessionProvider, (_, _) {
      _retry?.cancel();
      _failures = 0;
      unawaited(send());
    });
    // Whatever was left the last time the app ran.
    Future.microtask(send);
  }

  /// Keeps [body] to send to [path] in the group of [token] with [key], and
  /// returns whether it was kept: it is not where there is no cache.
  Future<bool> queue(
    String token,
    String path,
    Map<String, Object?> body,
    String key, {
    required PendingTarget target,
  }) async {
    final db = ref.read(cacheDbProvider);
    final server = target.identity.server;
    if (db == null || server == null) return false;
    final current = ref.read(identityProvider) == target.identity;
    await db.addPending(
      server: server,
      account: current ? ref.read(sessionProvider).pendingAccount : target.account,
      group: token,
      member: target.member,
      path: path,
      body: body,
      key: key,
    );
    // The bar shows it waiting and asks until the server is back.
    if (ref.mounted && ref.read(identityProvider) == target.identity) {
      ref.read(offlineProvider.notifier).set(true);
    }
    return true;
  }

  /// Sends what waits. Asked while sending, it goes over the rows again
  /// once done, for any the first pass did not see.
  Future<void> send() async {
    if (_sending) {
      _again = true;
      return;
    }
    _retry?.cancel();
    final db = ref.read(cacheDbProvider);
    final who = ref.read(identityProvider);
    final server = who.server;
    final account = ref.read(sessionProvider).pendingAccount;
    if (db == null || server == null) return;
    _sending = true;
    try {
      if (account.startsWith('user:') && who.token != null) {
        await db.identifyPending(server, cacheAccount(who.token), account);
      }
      for (final w in await db.pending(server, account)) {
        if (w.error != null) continue;
        // Signed in as someone else meanwhile: theirs are sent next.
        if (!ref.mounted || ref.read(identityProvider) != who) return;
        final api = ref.read(balnanaApiProvider);
        if (api == null) return;
        try {
          await api.group(w.groupToken, memberId: w.member).resend(w.path, jsonDecode(w.body), key: w.key);
        } on ApiException catch (e) {
          // Authentication can expire while offline. Keep every draft for
          // its owner to send after signing in again.
          if (e.status == 401) return;
          if (e.unreachable) {
            if (ref.mounted && ref.read(identityProvider) == who) {
              ref.read(offlineProvider.notifier).set(true);
            }
            return;
          }
          if (e.status == 429 || (e.status ?? 0) >= 500) {
            _retryLater(who);
            return;
          }
          await db.parkPending(w.id, e.code);
          continue;
        }
        await db.removePending(w.id);
        _failures = 0;
        if (ref.mounted && ref.read(identityProvider) == who) refreshGroupOf(ref, w.groupToken);
      }
    } finally {
      _sending = false;
      if (_again && ref.mounted && !(_retry?.isActive ?? false)) {
        _again = false;
        unawaited(send());
      }
    }
  }

  void _retryLater(Identity who) {
    if (!ref.mounted || ref.read(identityProvider) != who) return;
    final seconds = 2 << _failures.clamp(0, 5);
    _failures++;
    _retry = Timer(Duration(seconds: seconds.clamp(2, 60)), () {
      if (ref.mounted && ref.read(identityProvider) == who) unawaited(send());
    });
  }

  /// Sends [w] again after the server refused it.
  Future<void> retry(PendingWrite w) async {
    await ref.read(cacheDbProvider)?.retryPending(w.id);
    await send();
  }

  Future<void> discard(PendingWrite w) async => ref.read(cacheDbProvider)?.removePending(w.id);
}
