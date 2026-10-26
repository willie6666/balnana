import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../layout.dart';
import '../tokens.dart';

/// A top-level page: large collapsing title over a scrolling column that is
/// centered and capped at [contentMaxWidth] on wide windows.
class BPage extends StatelessWidget {
  const BPage({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.floatingActionButton,
    this.fillRemaining = false,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  /// Center [children] in the space below the title instead of listing them,
  /// for empty states.
  final bool fillRemaining;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = math.max(BSpace.s16, (constraints.maxWidth - contentMaxWidth) / 2);
          final padding = EdgeInsets.fromLTRB(side, BSpace.s8, side, BSpace.s32);
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                // The bar already insets its title by 16; line it up with the column.
                title: Padding(
                  padding: EdgeInsetsDirectional.only(start: side - BSpace.s16),
                  child: Text(title),
                ),
                actions: actions,
              ),
              if (fillRemaining)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: padding,
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: children),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: padding,
                  sliver: SliverList.list(children: children),
                ),
            ],
          );
        },
      ),
    );
  }
}
