import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Lets a swipe that starts on a list row or a button scroll at once.
///
/// With semantics on, the engine holds back a touch on anything tappable for
/// 200 ms, to learn whether the browser reports a click for it, so a list
/// stays still under the finger and then jumps. It does that only for
/// elements marked `flt-tappable`, so the mark is hidden while the engine
/// looks at the touch. Screen readers' clicks still arrive, and the engine
/// still drops a click that follows a touch it has passed on.
///
/// Only on Android: iOS Safari times its clicks its own way, and this has
/// not been tried there.
void skipSwipeDelay() {
  if (defaultTargetPlatform != TargetPlatform.android) return;
  // Capturing on the window, to come before the engine's own listener.
  web.window.addEventListener('pointerdown', _onPointerDown.toJS, true.toJS);
}

void _onPointerDown(web.PointerEvent event) {
  if (event.pointerType != 'touch') return;
  final path = event.composedPath().toDart;
  if (path.isEmpty || !path.first.isA<web.Element>()) return;
  final target = path.first as web.Element;
  if (!target.hasAttribute('flt-tappable')) return;
  target.removeAttribute('flt-tappable');
  // Back once every listener has had the event.
  Timer.run(() => target.setAttribute('flt-tappable', ''));
}
