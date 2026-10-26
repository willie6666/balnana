import 'package:flutter/widgets.dart';

/// Window size classes.
enum WindowSize {
  compact, // phones
  medium, // small tablets, phones in landscape
  expanded, // tablets, small desktop windows
  large; // desktop

  static WindowSize of(BuildContext context) => fromWidth(MediaQuery.sizeOf(context).width);

  static WindowSize fromWidth(double width) {
    if (width < 600) return compact;
    if (width < 840) return medium;
    if (width < 1200) return expanded;
    return large;
  }
}

/// Widest a column of reading content gets.
const contentMaxWidth = 720.0;
