import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/google_play.dart';
import '../../data/api.dart';
import '../../data/providers.dart';

/// How long a check of what Google Play holds lasts: coming back to the app
/// happens often, and each token costs the server a call to Google.
const playCheckEvery = Duration(hours: 1);

/// Tells the server about each of [tokens], and returns whether any gave a
/// plan. One failing doesn't stop the rest; it throws only when all of them do.
Future<bool> reportPlayPurchases(BalnanaApi api, List<String> tokens) async {
  var paid = false, reached = false;
  ApiException? failure;
  for (final token in tokens) {
    try {
      paid = (await api.reportPlayPurchase(token)).paid || paid;
      reached = true;
    } on ApiException catch (e) {
      failure ??= e;
    }
  }
  if (!reached && failure != null) throw failure;
  return paid;
}

/// Reports purchases away from the plan page: Google refunds a purchase the
/// server doesn't confirm within 3 days, and one may be paid for while the
/// app was killed, offline or on another page.
class PlayPurchases extends ConsumerStatefulWidget {
  const PlayPurchases({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PlayPurchases> createState() => _PlayPurchasesState();
}

class _PlayPurchasesState extends ConsumerState<PlayPurchases> {
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<List<String>>? _bought;
  DateTime? _checked;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onShow: _check);
    _bought = ref.read(googlePlayProvider).bought.listen(_report);
    ref.listenManual(signedInProvider, fireImmediately: true, (_, signedIn) {
      // Purchases go to whoever is signed in now.
      _checked = null;
      if (signedIn) _check();
    });
  }

  @override
  void dispose() {
    unawaited(_bought?.cancel());
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final last = _checked;
    if (last != null && DateTime.now().difference(last) < playCheckEvery) return;
    try {
      final held = await ref.read(googlePlayProvider).purchases();
      if (mounted && await _report(held)) _checked = DateTime.now();
    } on PlayException catch (e) {
      debugPrint('play purchases: $e');
    }
  }

  /// Returns whether the server had its say, or there was nothing to tell it.
  Future<bool> _report(List<String> tokens) async {
    final api = ref.read(balnanaApiProvider);
    if (tokens.isEmpty) return true;
    if (api == null || !ref.read(signedInProvider)) return false;
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      // A server that doesn't sell through Play has nothing to do with them.
      if ((await api.myPlan()).play == null) return true;
      await reportPlayPurchases(api, tokens);
      container.invalidate(myPlanProvider);
      return true;
    } on ApiException catch (e) {
      debugPrint('play purchases: ${e.code}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
