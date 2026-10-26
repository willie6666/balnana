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
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      minVerticalPadding: BSpace.s12,
      contentPadding: const EdgeInsets.symmetric(horizontal: BSpace.s16),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: scheme.secondaryContainer, shape: BoxShape.circle),
        child: Icon(icon, size: 22, color: scheme.onSecondaryContainer),
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing,
    );
  }
}

/// A [GroupedTile] with a switch; the whole row toggles it.
class GroupedSwitchTile extends StatelessWidget {
  const GroupedSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GroupedTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
