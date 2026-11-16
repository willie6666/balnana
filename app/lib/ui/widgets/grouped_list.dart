import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// A titled block of tiles that read as one card: large outer corners, small
/// inner corners and hairline gaps between tiles.
class GroupedList extends StatelessWidget {
  const GroupedList({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final last = children.length - 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: BSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(BSpace.s16, 0, BSpace.s16, BSpace.s8),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.primary),
              ),
            ),
          for (final (i, child) in children.indexed) ...[
            if (i > 0) const SizedBox(height: BSpace.tileGap),
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: i == 0 ? BShape.rLg : BShape.rXs,
                bottom: i == last ? BShape.rLg : BShape.rXs,
              ),
              child: Material(color: scheme.surfaceContainer, child: child),
            ),
          ],
        ],
      ),
    );
  }
}

/// A row in a [GroupedList].
class GroupedTile extends StatelessWidget {
  const GroupedTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.leading,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Shown in place of [icon] in its circle.
  final Widget? leading;

  /// False dims the row, for what cannot be changed here.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      enabled: enabled,
      minVerticalPadding: BSpace.s12,
      contentPadding: const EdgeInsets.symmetric(horizontal: BSpace.s16),
      leading: Opacity(
        opacity: enabled ? 1 : 0.5,
        child:
            leading ??
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: scheme.secondaryContainer, shape: BoxShape.circle),
              child: Icon(icon, size: 22, color: scheme.onSecondaryContainer),
            ),
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing,
    );
  }
}

/// A [GroupedTile] with a switch; the whole row toggles it. Without
/// [onChanged] it is dimmed and shows what is, which cannot be changed here.
class GroupedSwitchTile extends StatefulWidget {
  const GroupedSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.leading,
  }) : onSave = null;

  /// A switch whose change [onSave] sends somewhere slow, such as the server.
  /// It moves at once and stays there while that runs, then shows [value]
  /// again: the saved state, or the old one if saving failed.
  const GroupedSwitchTile.saving({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onSave,
    this.leading,
  }) : onChanged = null;

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Future<void> Function(bool)? onSave;

  /// Shown in place of [icon] in its circle.
  final Widget? leading;

  @override
  State<GroupedSwitchTile> createState() => _GroupedSwitchTileState();
}

class _GroupedSwitchTileState extends State<GroupedSwitchTile> {
  /// What it was switched to while that is saving.
  bool? _saving;

  Future<void> _save(Future<void> Function(bool) save, bool value) async {
    setState(() => _saving = value);
    try {
      await save(value);
    } finally {
      if (mounted) setState(() => _saving = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = _saving ?? widget.value;
    final save = widget.onSave;
    final ValueChanged<bool>? onChanged = save != null
        // One change at a time.
        ? (on) => _saving == null ? _save(save, on) : null
        : widget.onChanged;
    // One node for the row and its switch, so a screen reader reads the title with the state.
    return MergeSemantics(
      child: GroupedTile(
        icon: widget.icon,
        leading: widget.leading,
        title: widget.title,
        subtitle: widget.subtitle,
        enabled: onChanged != null,
        onTap: onChanged == null ? null : () => onChanged(!value),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
