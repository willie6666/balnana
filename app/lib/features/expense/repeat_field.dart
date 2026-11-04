part of 'expense_editor_page.dart';

extension _RepeatLogic on _EditorState {
  /// A new expense can be made to repeat, and a recurring one changed; an
  /// expense already added stays as it is.
  bool get _canRepeat =>
      (widget.expense == null && _sentExpense == null && _group.features.recurring) ||
      widget.recurring != null;

  int? get _everyValue => switch (int.tryParse(_every.text)) {
    final n? when n >= 1 && n <= 999 => n,
    _ => null,
  };

  /// Repeats every [unit]. A picked receipt belongs to one expense, so it is
  /// dropped, once the user agrees.
  Future<void> _repeat(RepeatUnit unit) async {
    if (_receipt != null) {
      final l10n = context.l10n;
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.repeatDropReceiptTitle),
          content: Text(l10n.repeatDropReceiptBody),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.repeatDropReceiptAction),
            ),
          ],
        ),
      );
      if (!(ok ?? false) || !mounted) return;
    }
    _update(() {
      _unit = unit;
      _receipt = null;
    });
  }

  Future<void> _pickEnd() async {
    final start = DateUtils.dateOnly(_date);
    final end = _endsOn;
    final picked = await showDatePicker(
      context: context,
      initialDate: end != null && !end.isBefore(start) ? end : start,
      firstDate: start,
      lastDate: DateTime(2999, 12, 31),
    );
    if (picked != null) _update(() => _endsOn = picked);
  }
}

/// Whether and how often the expense comes back, and until when.
class _RepeatField extends StatelessWidget {
  const _RepeatField({required this.state, required this.locale});

  final _EditorState state;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = state;
    final unit = s._unit, end = s._endsOn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: BSpace.s8,
          runSpacing: BSpace.s8,
          children: [
            // A recurring expense is stopped from its page instead, and one
            // that may have been added can't turn into a single expense.
            if (s.widget.recurring == null && s._sentRecurring == null)
              ChoiceChip(
                label: Text(l10n.repeatNever),
                showCheckmark: false,
                selected: unit == null,
                onSelected: (_) => s._update(() => s._unit = null),
              ),
            for (final (u, label) in [
              (RepeatUnit.day, l10n.repeatDaily),
              (RepeatUnit.week, l10n.repeatWeekly),
              (RepeatUnit.month, l10n.repeatMonthly),
              (RepeatUnit.year, l10n.repeatYearly),
            ])
              ChoiceChip(
                label: Text(label),
                showCheckmark: false,
                selected: unit == u,
                onSelected: (_) => s._repeat(u),
              ),
          ],
        ),
        if (unit != null) ...[
          const SizedBox(height: BSpace.s12),
          Row(
            children: [
              Text(l10n.repeatEvery, style: text.bodyLarge),
              const SizedBox(width: BSpace.s12),
              SizedBox(
                width: 72,
                child: TextFormField(
                  controller: s._every,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(isDense: true),
                  validator: (_) => s._everyValue == null ? l10n.errorInvalidRepeat : null,
                ),
              ),
              const SizedBox(width: BSpace.s12),
              Expanded(child: Text(repeatUnitLabel(l10n, unit, s._everyValue ?? 1), style: text.bodyLarge)),
            ],
          ),
          const SizedBox(height: BSpace.s12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: s._pickEnd,
                  icon: const Icon(Icons.event_available_outlined),
                  label: Text(
                    end == null
                        ? l10n.repeatEndNone
                        : l10n.repeatEndOn(DateFormat.yMMMEd(locale).format(end)),
                  ),
                ),
              ),
              if (end != null)
                IconButton(
                  tooltip: l10n.repeatEndClear,
                  icon: const Icon(Icons.close),
                  onPressed: () => s._update(() => s._endsOn = null),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(BSpace.s4, BSpace.s8, BSpace.s4, 0),
            child: Text(l10n.repeatHelp, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ),
        ],
      ],
    );
  }
}
