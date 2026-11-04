import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../data/models.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/grouped_list.dart';

/// What a group can add to expenses, each with its switch.
class FeatureSwitches extends StatelessWidget {
  const FeatureSwitches({super.key, required this.features, required this.onChanged});

  final GroupFeatures features;
  final ValueChanged<GroupFeatures> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final f = features;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GroupedList(
          title: l10n.groupFeatures,
          children: [
            GroupedSwitchTile(
              icon: Icons.currency_exchange,
              title: l10n.groupFeatureForeign,
              subtitle: l10n.groupFeatureForeignHelp,
              value: f.foreignCurrency,
              onChanged: (on) => onChanged(f.copyWith(foreignCurrency: on)),
            ),
            GroupedSwitchTile(
              icon: Icons.repeat,
              title: l10n.groupFeatureRecurring,
              subtitle: l10n.groupFeatureRecurringHelp,
              value: f.recurring,
              onChanged: (on) => onChanged(f.copyWith(recurring: on)),
            ),
            GroupedSwitchTile(
              icon: Icons.place_outlined,
              title: l10n.groupFeaturePlaces,
              subtitle: l10n.groupFeaturePlacesHelp,
              value: f.places,
              onChanged: (on) => onChanged(f.copyWith(places: on)),
            ),
            GroupedSwitchTile(
              icon: Icons.receipt_long_outlined,
              title: l10n.groupFeatureReceipts,
              subtitle: l10n.groupFeatureReceiptsHelp,
              value: f.receipts,
              onChanged: (on) => onChanged(f.copyWith(receipts: on)),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(BSpace.s16, 0, BSpace.s16, BSpace.s24),
          child: Text(
            l10n.groupFeaturesHelp,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
