part of 'expense_editor_page.dart';

/// How many likely payers a large group offers before "Someone else".
const _likelyCount = 4;

extension _PaidByLogic on _EditorState {
  /// With several payers, the amount is what they paid together.
  void _paidChanged() {
    if (!_multiPay) return;
    var sum = BigInt.zero;
    for (final c in _paid.values) {
      try {
        sum += parseInput(c.text, _digits) ?? BigInt.zero;
      } on MoneyException {
        // Shown by the field.
      }
    }
    final text = sum == BigInt.zero ? '' : formatAmount(sum, _digits);
    if (_amount.text != text) _amount.text = text;
    _update(() {});
  }

  Map<String, BigInt>? _payers() {
    final total = _total;
    if (total == null) return null;
    if (!_multiPay) return _payer == null ? null : {_payer!: total};
    final out = <String, BigInt>{};
    for (final MapEntry(:key, :value) in _paid.entries) {
      try {
        final v = parseInput(value.text, _digits);
        if (v != null && v > BigInt.zero) out[key] = v;
      } on MoneyException {
        return null;
      }
    }
    // The amount is their sum, unless a part cannot be read.
    return out.values.fold(BigInt.zero, (a, b) => a + b) == total ? out : null;
  }

  void _setMultiPay(bool multi) {
    _update(() {
      _multiPay = multi;
      if (multi && _payer != null && _paid.values.every((c) => c.text.isEmpty)) {
        _paid[_payer!]!.text = _amount.text;
      }
      if (multi && _payer != null) _payersShown.add(_payer!);
    });
    _paidChanged();
  }

  /// This device's member and whoever paid lately, then the payer: the
  /// chips a large group offers.
  List<Member> _likelyPayers() {
    final recent = ref
        .read(expensesProvider(_group.token))
        .current(ref.read(identityProvider))
        .value
        ?.items
        .expand((e) => e.payers.map((p) => p.memberId));
    final out = <Member>[];
    for (final id in [?myMemberIdRead(ref, _group.token), ...?recent]) {
      if (out.length == _likelyCount) break;
      final m = _people.where((m) => m.id == id && !m.left).firstOrNull;
      if (m != null && !out.contains(m)) out.add(m);
    }
    if (_people.where((m) => m.id == _payer).firstOrNull case final payer? when !out.contains(payer)) {
      out.add(payer);
    }
    return out;
  }

  Future<void> _pickPayer(String title) async {
    final picked = await pickMember(
      context,
      title: title,
      members: _people,
      selected: _multiPay ? null : _payer,
    );
    if (picked?.id case final id? when mounted) {
      _update(() {
        _multiPay = false;
        _payer = id;
      });
    }
  }

  /// Who is listed to pay part, in a large group.
  Set<String> get _payersListed => {
    for (final m in _people)
      if (_payersShown.contains(m.id)) m.id,
  };

  Future<void> _pickPayers(String title) async {
    final listed = _payersListed;
    final picked = await pickMembers(context, title: title, members: _people, selected: listed);
    if (picked == null || !mounted) return;
    _update(() {
      _payersShown
        ..clear()
        ..addAll(picked);
      for (final id in listed.difference(picked)) {
        _paid[id]!.clear();
      }
    });
  }
}

class _PaidBy extends StatelessWidget {
  const _PaidBy({required this.state, required this.symbol});

  final _EditorState state;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = state;
    final title = s._received ? l10n.expenseReceivedForLabel : l10n.expensePaidByLabel;
    // A large group offers the likeliest payers and lists only the payers
    // chosen; anyone else is picked from a list.
    final offered = s._crowd ? s._likelyPayers() : s._people;
    final listed = s._crowd ? s._payersListed : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: BSpace.s8,
          runSpacing: BSpace.s8,
          children: [
            for (final m in offered)
              ChoiceChip(
                avatar: MemberAvatar(member: m, size: 24),
                label: Text(m.name),
                showCheckmark: false,
                selected: !s._multiPay && s._payer == m.id,
                onSelected: (_) => s._update(() {
                  s._multiPay = false;
                  s._payer = m.id;
                }),
              ),
            if (s._crowd)
              ActionChip(
                avatar: const Icon(Icons.person_search_outlined, size: 18),
                label: Text(l10n.crowdSomeoneElse),
                onPressed: () => s._pickPayer(title),
              ),
            ChoiceChip(
              avatar: const Icon(Icons.group_outlined, size: 18),
              label: Text(l10n.expenseMultiplePayers),
              showCheckmark: false,
              selected: s._multiPay,
              onSelected: (_) => s._setMultiPay(true),
            ),
          ],
        ),
        if (s._multiPay) ...[
          const SizedBox(height: BSpace.s8),
          for (final m in s._people)
            if (listed == null || listed.contains(m.id))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: BSpace.s4),
                child: Row(
                  children: [
                    MemberAvatar(member: m, size: 32),
                    const SizedBox(width: BSpace.s12),
                    Expanded(child: Text(m.name, overflow: TextOverflow.ellipsis)),
                    SizedBox(
                      width: 132,
                      child: TextField(
                        controller: s._paid[m.id],
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.numberWithOptions(decimal: s._digits > 0),
                        inputFormatters: [AmountFormatter(s._digits)],
                        decoration: InputDecoration(
                          isDense: true,
                          errorText: _inputError(l10n, s._paid[m.id]!.text, s._digits),
                          errorMaxLines: 3,
                          prefixIcon: FieldAffix(symbol),
                          prefixIconConstraints: const BoxConstraints(),
                          hintText: '0',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          if (s._crowd)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => s._pickPayers(title),
                icon: const Icon(Icons.group_add_outlined),
                label: Text(l10n.crowdChoosePayers),
              ),
            ),
        ],
      ],
    );
  }
}
