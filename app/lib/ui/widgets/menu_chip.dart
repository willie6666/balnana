import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../data/models.dart';

/// A filter chip that opens a menu of choices, or calls [onPressed] (to open
/// a sheet, say) when it is set.
class MenuChip extends StatelessWidget {
  const MenuChip({
    super.key,
    required this.label,
    required this.selected,
    this.items = const [],
    this.avatar,
    this.onPressed,
  });

  final String label;
  final bool selected;
  final Widget? avatar;
  final List<Widget> items;
  final VoidCallback? onPressed;

  Widget _chip(VoidCallback onTap) => FilterChip(
    avatar: avatar,
    showCheckmark: false,
    selected: selected,
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(label, overflow: TextOverflow.ellipsis),
        ),
        const Icon(Icons.arrow_drop_down, size: 18),
      ],
    ),
    onSelected: (_) => onTap(),
  );

  @override
  Widget build(BuildContext context) {
    if (onPressed case final onPressed?) return _chip(onPressed);
    return MenuAnchor(
      menuChildren: items,
      builder: (context, controller, _) => _chip(() => controller.isOpen ? controller.close() : controller.open()),
    );
  }
}

/// Ready-made periods, in local time.
enum PeriodPreset {
  thisMonth,
  lastMonth,
  thisYear;

  Period at(DateTime now) => switch (this) {
    thisMonth => (from: DateTime(now.year, now.month), to: DateTime(now.year, now.month + 1)),
    lastMonth => (from: DateTime(now.year, now.month - 1), to: DateTime(now.year, now.month)),
    thisYear => (from: DateTime(now.year), to: DateTime(now.year + 1)),
  };

  String label(AppLocalizations l10n) => switch (this) {
    thisMonth => l10n.periodThisMonth,
    lastMonth => l10n.periodLastMonth,
    thisYear => l10n.periodThisYear,
  };
}

/// Names [period] by its preset when it is one, else by its first and last day.
String periodLabel(BuildContext context, Period? period) {
  final l10n = context.l10n;
  if (period == null) return l10n.periodAll;
  final now = DateTime.now();
  for (final p in PeriodPreset.values) {
    if (p.at(now) == period) return p.label(l10n);
  }
  final locale = Localizations.localeOf(context).toLanguageTag();
  final first = period.from;
  final last = DateTime(period.to.year, period.to.month, period.to.day - 1);
  final format = first.year == now.year && last.year == now.year ? DateFormat.MMMd(locale) : DateFormat.yMMMd(locale);
  if (first == last) return format.format(first);
  return '${format.format(first)} – ${format.format(last)}';
}

/// A chip to pick a period: all time, a preset, or days from a calendar.
class PeriodChip extends StatelessWidget {
  const PeriodChip({super.key, required this.period, required this.onChanged});

  final Period? period;
  final ValueChanged<Period?> onChanged;

  Future<void> _pickDays(BuildContext context) async {
    final now = DateTime.now();
    final current = period;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5, 12, 31),
      initialDateRange: current == null
          ? null
          : DateTimeRange(start: current.from, end: DateTime(current.to.year, current.to.month, current.to.day - 1)),
    );
    if (range == null) return;
    final end = range.end;
    onChanged((from: range.start, to: DateTime(end.year, end.month, end.day + 1)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    return MenuChip(
      avatar: const Icon(Icons.date_range_outlined),
      label: periodLabel(context, period),
      selected: period != null,
      items: [
        MenuItemButton(onPressed: () => onChanged(null), child: Text(l10n.periodAll)),
        for (final p in PeriodPreset.values)
          MenuItemButton(onPressed: () => onChanged(p.at(now)), child: Text(p.label(l10n))),
        MenuItemButton(onPressed: () => _pickDays(context), child: Text(l10n.periodPickDays)),
      ],
    );
  }
}
