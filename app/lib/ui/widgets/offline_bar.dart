import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/offline_cache.dart';
import '../../core/server.dart';
import '../tokens.dart';

/// Puts a bar above [child] while the server is out of reach and what is
/// shown was saved on this device, and reloads everything once it is back.
///
/// While offline, requests are answered from what was saved without asking
/// the server, so the bar asks every [checkEvery] whether it is back.
class OfflineBar extends ConsumerStatefulWidget {
  const OfflineBar({super.key, required this.child});

  final Widget child;

  static const checkEvery = Duration(seconds: 15);

  @override
  ConsumerState<OfflineBar> createState() => _OfflineBarState();
}

class _OfflineBarState extends ConsumerState<OfflineBar> {
  late final AppLifecycleListener _lifecycle;
  Timer? _checks;
  var _checking = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onShow: () {
        if (ref.read(offlineProvider)) _retry();
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _checks?.cancel();
    super.dispose();
  }

  void _keepChecking(bool offline) {
    if (!offline) {
      _checks?.cancel();
      _checks = null;
    } else {
      _checks ??= Timer.periodic(OfflineBar.checkEvery, (_) => _check());
    }
  }

  /// Marks the app online if the server answers, which reloads everything.
  Future<void> _check() async {
    final url = ref.read(serverUrlProvider);
    if (_checking || url == null) return;
    _checking = true;
    try {
      await ref.read(serverProbeProvider)(url);
      if (mounted) ref.read(offlineProvider.notifier).set(false);
    } on Object {
      // Still out of reach.
    } finally {
      _checking = false;
    }
  }

  void _retry() {
    ref.invalidate(serverInfoProvider);
    ref.invalidate(apiProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Back online: what is shown may be old, so load it all again.
    ref.listen(offlineProvider, (was, now) {
      if (was == true && !now) _retry();
      _keepChecking(now);
    });
    final offline = ref.watch(offlineProvider);

    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    return Column(
      children: [
        if (offline)
          Material(
            color: scheme.surfaceContainerHighest,
            child: Padding(
              padding: EdgeInsets.only(
                top: media.padding.top,
                left: media.padding.left,
                right: media.padding.right,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(BSpace.s16, BSpace.s4, BSpace.s8, BSpace.s4),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 20, color: scheme.onSurfaceVariant),
                    const SizedBox(width: BSpace.s12),
                    Expanded(
                      child: Text(
                        l10n.offlineBar,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    TextButton(onPressed: _retry, child: Text(l10n.commonRetry)),
                  ],
                ),
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        Expanded(
          // Keep the child in the same place when the bar appears or goes
          // away, so an open form and an in-flight save are not disposed.
          child: MediaQuery(
            data: offline ? media.removePadding(removeTop: true) : media,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
