import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The app's binding: [WidgetsFlutterBinding] with mouse-wheel steps eased by [WheelGlide].
class SmoothWheelBinding extends WidgetsFlutterBinding {
  late final _glide = WheelGlide(this);

  @override
  void handlePointerEvent(PointerEvent event) {
    if (!_glide.handle(event)) super.handlePointerEvent(event);
  }
}

/// Spreads each mouse-wheel step over a few frames, for every scroll view at once.
///
/// Flutter moves a scroll view by a wheel tick's whole delta in one frame, so a mouse
/// wheel scrolls in visible jumps. Here each tick only moves a target, and the scroll
/// follows it on a critically damped spring: its speed carries over from tick to tick,
/// so a spinning wheel scrolls in one continuous motion, as browsers do for HTML pages.
///
/// Each frame's step goes out as an ordinary scroll event to whatever was under the
/// pointer at the last tick, so nested and tabbed scroll views need no changes. The
/// glide stops once nothing takes a step (an edge was reached) or a pointer goes down.
/// Trackpads already send fine-grained deltas and keep the default, as do ctrl, alt or
/// meta with the wheel (zooming, for instance) and reduced motion.
class WheelGlide {
  WheelGlide(this._binding);

  final WidgetsBinding _binding;

  /// Spring stiffness: settles within about a quarter second after the last tick.
  static const _omega = 26.0;

  PointerScrollEvent? _tick;
  HitTestResult? _path;
  Offset _remaining = Offset.zero;
  Offset _velocity = Offset.zero;
  Duration? _lastFrame;
  int? _frameCallback;

  /// Takes over [event] when it is a mouse-wheel step to ease; false lets it through.
  bool handle(PointerEvent event) {
    if (event is PointerDownEvent) _stop();
    if (event is! PointerScrollEvent) return false;
    final keys = HardwareKeyboard.instance;
    if (event.kind != PointerDeviceKind.mouse ||
        event.scrollDelta == Offset.zero ||
        keys.isControlPressed ||
        keys.isAltPressed ||
        keys.isMetaPressed ||
        _binding.platformDispatcher.accessibilityFeatures.disableAnimations) {
      _stop();
      return false;
    }
    final path = HitTestResult();
    _binding.hitTestInView(path, event.position, event.viewId);
    _path = path;
    _remaining += event.scrollDelta;
    _tick = event;
    _frameCallback ??= _binding.scheduleFrameCallback(_frame);
    return true;
  }

  void _frame(Duration timeStamp) {
    _frameCallback = null;
    // The first frame has no previous one to measure from; count it as one frame.
    final dt = _lastFrame == null ? 1 / 60 : (timeStamp - _lastFrame!).inMicroseconds / 1e6;
    _lastFrame = timeStamp;
    if (dt > 0) {
      // Exact step of x'' = -ω²x - 2ωx' with x the distance past the target, so any
      // frame time stays stable.
      final offset = -_remaining;
      final decay = math.exp(-_omega * dt);
      final next = (offset + (_velocity + offset * _omega) * dt) * decay;
      _velocity = (_velocity - (_velocity + offset * _omega) * (_omega * dt)) * decay;
      final settled = next.distance < .5 && _velocity.distance < 20;
      final step = settled ? _remaining : next - offset;
      _remaining = settled ? Offset.zero : -next;
      if (!_send(step) || settled) {
        _stop();
        return;
      }
    }
    _frameCallback = _binding.scheduleFrameCallback(_frame);
  }

  /// Sends [delta] to the scroll views under the last tick; false when none moved.
  bool _send(Offset delta) {
    final tick = _tick!;
    // A page may have closed since the tick; its scroll views are gone with it.
    final gone = _path!.path.any(
      (entry) => entry.target is RenderObject && !(entry.target as RenderObject).attached,
    );
    if (gone) return false;
    var moved = false;
    final event = PointerScrollEvent(
      viewId: tick.viewId,
      kind: tick.kind,
      device: tick.device,
      position: tick.position,
      scrollDelta: delta,
      // A scroll view that moves answers false; with no taker the resolver answers true.
      onRespond: ({required allowPlatformDefault}) => moved = !allowPlatformDefault,
    );
    _binding.dispatchEvent(event, _path);
    return moved;
  }

  void _stop() {
    if (_frameCallback != null) _binding.cancelFrameCallbackWithId(_frameCallback!);
    _frameCallback = null;
    _lastFrame = null;
    _tick = null;
    _path = null;
    _remaining = Offset.zero;
    _velocity = Offset.zero;
  }
}
