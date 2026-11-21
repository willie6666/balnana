import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/app_store.dart';
import '../../data/api.dart';
import '../../data/providers.dart';
import 'play_purchases.dart' show playCheckEvery;

/// Tells the server about each of [signed], and returns whether any gave a
/// plan. One failing doesn't stop the rest; it throws only when all of them do.
Future<bool> reportAppStorePurchases(BalnanaApi api, List<String> signed) async {
  var paid = false, reached = false;
  ApiException? failure;
  for (final transaction in signed) {
    try {
      paid = (await api.reportAppStorePurchase(transaction)).paid || paid;
      reached = true;
    } on ApiException catch (e) {
      failure ??= e;
    }
  }
  if (!reached && failure != null) throw failure;
  return paid;
}

/// Reports App Store transactions away from the plan page: renewals on a
/// server without Apple's notifications, Ask to Buy approvals, and purchases
/// made while the app was killed, offline or on another page.
class AppStorePurchases extends ConsumerStatefulWidget {
  const AppStorePurchases({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppStorePurchases> createState() => _AppStorePurchasesState();
}

class _AppStorePurchasesState extends ConsumerState<AppStorePurchases> {
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<List<String>>? _bought;
  DateTime? _checked;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onShow: _check);
    _bought = ref.read(appStoreProvider).bought.listen(_report);
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
      final held = await ref.read(appStoreProvider).purchases();
      if (mounted && await _report(held)) _checked = DateTime.now();
    } on AppStoreException catch (e) {
      debugPrint('app store purchases: $e');
    }
  }

  /// Returns whether the server had its say, or there was nothing to tell it.
  Future<bool> _report(List<String> signed) async {
    final api = ref.read(balnanaApiProvider);
    if (signed.isEmpty) return true;
    if (api == null || !ref.read(signedInProvider)) return false;
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      // A server that doesn't sell in the App Store has nothing to do with them.
      if ((await api.myPlan()).appStore == null) return true;
      await reportAppStorePurchases(api, signed);
      container.invalidate(myPlanProvider);
      return true;
    } on ApiException catch (e) {
      // Another account's subscription on this Apple ID is no news to retry.
      debugPrint('app store purchases: ${e.code}');
      return e.code == 'appstore_other_account';
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
