part of 'expense_editor_page.dart';

/// Where it was, a note and the photo of the receipt.
class _DetailsFields extends StatelessWidget {
  const _DetailsFields({required this.state});

  final _EditorState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = state;
    final features = s._group.features;
    // Switched off for the group, what the expense has stays, to keep or remove.
    final saved = s.widget.expense?.location ?? s.widget.recurring?.location;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (features.places || saved != null) ...[
          FormSection(l10n.expenseLocation),
          LocationField(
            name: s._place,
            point: s._point,
            onPoint: (p) => s._update(() => s._point = p),
            around: s._around,
          ),
        ],

        FormSection(l10n.expenseNote),
        TextFormField(
          controller: s._note,
          minLines: 2,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [LengthLimitingTextInputFormatter(2000)],
          decoration: InputDecoration(hintText: l10n.expenseNoteHint),
        ),

        // Each occurrence is its own expense, with its own receipt.
        // Switched off, a saved photo can still be looked at or removed.
        if (s._unit == null && (features.receipts || (s.widget.hasReceipt && !s._dropReceipt))) ...[
          FormSection(l10n.expenseReceipt),
          ReceiptField(
            token: s._group.token,
            expenseId: s.widget.expense?.id,
            saved: s.widget.hasReceipt && !s._dropReceipt,
            picked: s._receipt,
            onPicked: (r) => s._update(() => s._receipt = r),
            onRemoved: () => s._update(() {
              s._receipt = null;
              s._dropReceipt = s.widget.hasReceipt;
            }),
          ),
        ],
      ],
    );
  }
}
