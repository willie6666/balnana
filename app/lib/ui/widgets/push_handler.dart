import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/push.dart';
import '../../core/router.dart';

/// Keeps push registration current and opens the group of a tapped
/// notification. Builds [child] unchanged.
class PushHandler extends ConsumerStatefulWidget {
  const PushHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushHandler> createState() => _PushHandlerState();
}

class _PushHandlerState extends ConsumerState<PushHandler> {
  StreamSubscription<String>? _opened;

  @override
  void initState() {
    super.initState();
    final push = ref.read(pushServiceProvider);
    if (push == null) return;
    _opened = push.openedGroups.listen(_open);
    push.initialGroup().then((token) {
      if (token != null) _open(token);
    }, onError: (Object _) {});
  }

  void _open(String token) {
    if (mounted) ref.read(routerProvider).go('/g/$token');
  }

  @override
  void dispose() {
    _opened?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(pushSyncProvider);
    return widget.child;
  }
}
