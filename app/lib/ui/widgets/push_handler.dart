import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/push.dart';
import '../../core/router.dart';
import '../../core/server.dart';

/// Keeps push registration current and opens the group of a tapped
/// notification, when it came from the server the app now talks to. Builds
/// [child] unchanged.
class PushHandler extends ConsumerStatefulWidget {
  const PushHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushHandler> createState() => _PushHandlerState();
}

class _PushHandlerState extends ConsumerState<PushHandler> {
  StreamSubscription<PushTarget>? _opened;

  @override
  void initState() {
    super.initState();
    final push = ref.read(pushServiceProvider);
    if (push == null) return;
    _opened = push.openedGroups.listen(_open);
    push.initialGroup().then((target) {
      if (target != null) _open(target);
    }, onError: (Object _) {});
  }

  void _open(PushTarget target) {
    if (!mounted) return;
    // A group of another server: its token is not this server's to see.
    if (target.server != ref.read(serverUrlProvider)) return;
    ref.read(routerProvider).go('/g/${target.token}');
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
