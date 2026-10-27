import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../layout.dart';
import '../tokens.dart';
import 'member_avatar.dart';

/// A full-screen form: a small app bar with a close button, a centered
/// scrolling column and an optional primary action pinned to the bottom.
class FormPage extends StatelessWidget {
  const FormPage({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.submitLabel,
    this.onSubmit,
    this.busy = false,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final String? submitLabel;

  /// Null disables the button.
  final VoidCallback? onSubmit;

  /// Shows progress in place of the button label.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(title),
        actions: actions,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = math.max(BSpace.s16, (constraints.maxWidth - contentMaxWidth) / 2);
          return ListView(
            padding: EdgeInsets.fromLTRB(side, BSpace.s8, side, BSpace.s32),
            children: children,
          );
        },
      ),
      bottomNavigationBar: submitLabel == null
          ? null
          : SafeArea(
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: contentMaxWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s8, BSpace.s16, BSpace.s16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: busy ? null : onSubmit,
                        child: busy
                            ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(submitLabel!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/// A small heading between parts of a form.
class FormSection extends StatelessWidget {
  const FormSection(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(BSpace.s4, BSpace.s24, BSpace.s4, BSpace.s8),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.primary)),
    );
  }
}

/// A row of palette swatches; tapping one selects it.
class ColorPicker extends StatelessWidget {
  const ColorPicker({super.key, required this.colors, required this.selected, required this.onSelected});

  final List<Color> colors;
  final Color? selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: BSpace.s8,
      runSpacing: BSpace.s8,
      children: [
        for (final (i, color) in colors.indexed)
          Semantics(
            selected: color == selected,
            button: true,
            label: context.l10n.colorSwatch(i + 1, colors.length),
            child: InkResponse(
              onTap: () => onSelected(color),
              radius: 24,
              child: AnimatedContainer(
                duration: BMotion.short,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == selected ? scheme.onSurface : Colors.transparent,
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: color == selected ? Icon(Icons.check, color: onColor(color), size: 20) : null,
              ),
            ),
          ),
      ],
    );
  }
}
