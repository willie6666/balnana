import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// A friendly placeholder: icon in a soft circle, a title, a line of help and
/// an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.body, this.action});

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
            child: Icon(icon, size: 44, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: BSpace.s24),
          Text(title, style: text.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: BSpace.s8),
          Text(
            body,
            style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: BSpace.s24), action!],
        ],
      ),
    );
  }
}
