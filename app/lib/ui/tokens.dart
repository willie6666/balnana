import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Corner radii.
abstract final class BShape {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;

  static const rXs = Radius.circular(xs);
  static const rLg = Radius.circular(lg);
}

/// Spacing scale. Layouts use these values only.
abstract final class BSpace {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s48 = 48.0;

  /// Gap between tiles of one group in a grouped list.
  static const tileGap = 2.0;
}

abstract final class BMotion {
  static const short = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 300);
  static const long = Duration(milliseconds: 450);

  static const standard = Cubic(0.2, 0, 0, 1);
  static const emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);
  static const emphasizedAccelerate = Cubic(0.3, 0, 0.8, 0.15);
}
