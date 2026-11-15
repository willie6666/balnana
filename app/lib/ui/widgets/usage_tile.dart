import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// A row in a [GroupedList] for something a plan limits, with [label] at
/// its end. Given how much is [used] of a [limit], a bar fills toward it.
class GroupedLimitTile extends StatelessWidget {
  const GroupedLimitTile({
    super.key,
    required this.icon,
    required this.title,
    required this.label,
    this.used,
    this.limit,
  });

  final IconData icon;
  final String title;

  /// The limit or the usage in words, such as "3 of 20" or "No limit".
  final String label;

  final int? used;

  /// No limit when null.
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (used, limit) = (this.used, this.limit);
    final full = used != null && limit != null && used >= limit;
    final value = used == null || limit == null
        ? null
        : limit == 0
        ? (used > 0 ? 1.0 : 0.0)
        : (used / limit).clamp(0.0, 1.0);
    return MergeSemantics(
      child: ListTile(
        minVerticalPadding: BSpace.s12,
        contentPadding: const EdgeInsets.symmetric(horizontal: BSpace.s16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: scheme.secondaryContainer, shape: BoxShape.circle),
          child: Icon(icon, size: 22, color: scheme.onSecondaryContainer),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: Text(title)),
            const SizedBox(width: BSpace.s12),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: full ? scheme.error : scheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        subtitle: value == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: BSpace.s8),
                child: ExcludeSemantics(
                  child: LinearProgressIndicator(
                    value: value,
                    // The current Material 3 bar, with a gap and a stop at the end.
                    // ignore: deprecated_member_use
                    year2023: false,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                    color: full ? scheme.error : null,
                    backgroundColor: full ? scheme.errorContainer : null,
                  ),
                ),
              ),
      ),
    );
  }
}
