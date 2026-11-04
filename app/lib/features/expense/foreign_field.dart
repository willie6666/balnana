part of 'expense_editor_page.dart';

extension _ForeignLogic on _EditorState {
  BigInt? get _chargedValue {
    try {
      final v = parseInput(_charged.text, _group.minorDigits);
      return v != null && v > BigInt.zero ? v : null;
    } on MoneyException {
      return null;
    }
  }

  /// Keeps what it came to and the rate in step with the amount.
  void _convert() {
    final total = _total;
    if (_foreign == null || total == null) return;
    if (_chargedFixed) {
      if (_chargedValue case final charged?) _rate.text = rateOf(total, _digits, charged, _group.minorDigits);
    } else if (convertAmount(total, _digits, shareValue(_rate.text), _group.minorDigits)
        case final charged?) {
      _charged.text = charged == BigInt.zero ? '' : formatAmount(charged, _group.minorDigits);
    }
  }

  void _rateChanged(String _) => _update(() {
    _chargedFixed = false;
    _convert();
  });

  void _chargedChanged(String _) => _update(() {
    _chargedFixed = true;
    _convert();
  });

  /// Whether it can be in another currency: payments and recurring
  /// expenses stay in the group's.
  /// Switched off for the group, only an expense paid in one already keeps it.
  bool get _canForeign =>
      _unit == null &&
      widget.recurring == null &&
      !(widget.expense?.isPayment ?? false) &&
      (_group.features.foreignCurrency || widget.expense?.foreign != null);

  Future<void> _pickCurrency() async {
    final picked = await showCurrencyPicker(context, current: _currency);
    if (picked == null || picked == _currency || !mounted) return;
    final foreign = picked == _group.currency ? null : picked;
    _update(() {
      _foreign = foreign;
      // What was typed stays where it still is an amount in the new currency,
      // written the way that currency's field accepts it: "12.00" would leave
      // a field without decimals unable to take any further edit.
      final typed = [
        if (!_multiPay) _amount,
        ..._paid.values,
        if (_method == SplitMethod.exact) ..._values.values,
      ];
      for (final c in typed) {
        if (c.text.trim().isEmpty) continue;
        try {
          final parsed = parseInput(c.text, _digits);
          if (parsed == null) {
            c.clear();
          } else {
            c.text = formatAmount(parsed, _digits);
          }
        } on MoneyException {
          c.clear();
        }
      }
      _charged.clear();
      _rate.clear();
      _chargedFixed = false;
      _fetched = null;
      // The rate the group last used for it, to start from.
      final last = ref
          .read(expensesProvider(_group.token))
          .current(ref.read(identityProvider))
          .value
          ?.items
          .where((e) => e.foreign?.currency == foreign)
          .firstOrNull;
      if (foreign != null && last != null) {
        _rate.text = rateOf(last.foreign!.amount, last.foreign!.digits, last.amount, _group.minorDigits);
        _convert();
      }
    });
    if (foreign != null) await _fetchRate(foreign);
  }

  /// Starts [foreign]'s rate from what the server looks up, unless the rate or
  /// what it came to was typed meanwhile. Until then, and when the server has
  /// none, the group's last rate stays.
  Future<void> _fetchRate(String foreign) async {
    final api = ref.read(balnanaApiProvider);
    if (api == null || ref.read(serverInfoProvider).value?.exchangeRates != true) return;
    final before = _rate.text;
    final ExchangeRate fetched;
    try {
      fetched = await api.exchangeRate(foreign, _group.currency);
    } on ApiException {
      return;
    }
    if (!mounted || _foreign != foreign || _chargedFixed || _rate.text != before) return;
    _update(() {
      _fetched = fetched;
      _rate.text = fetched.rate;
      _convert();
    });
  }
}

/// The currency it was paid in and, when that is not the group's, what it
/// came to in the group's.
class _ForeignField extends StatelessWidget {
  const _ForeignField({required this.state, required this.locale});

  final _EditorState state;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final s = state;
    final g = s._group;
    final foreign = s._foreign;
    final button = Center(
      child: TextButton.icon(
        onPressed: s._pickCurrency,
        icon: const Icon(Icons.currency_exchange, size: 18),
        label: Text(l10n.expensePaidIn(s._currency)),
      ),
    );
    if (foreign == null) return button;
    final rate = TextFormField(
      controller: s._rate,
      textAlign: TextAlign.end,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [AmountFormatter(rateDigits)],
      onChanged: s._rateChanged,
      decoration: InputDecoration(labelText: l10n.expenseRate(foreign, g.currency)),
    );
    final charged = TextFormField(
      controller: s._charged,
      textAlign: TextAlign.end,
      keyboardType: TextInputType.numberWithOptions(decimal: g.minorDigits > 0),
      inputFormatters: [AmountFormatter(g.minorDigits)],
      onChanged: s._chargedChanged,
      decoration: InputDecoration(
        labelText: l10n.expenseInGroupCurrency(g.currency),
        prefixIcon: FieldAffix(moneySymbol(locale, g.currency, g.symbol)),
        prefixIconConstraints: const BoxConstraints(),
        errorMaxLines: 3,
      ),
      validator: (_) {
        try {
          final v = parseInput(s._charged.text, g.minorDigits);
          return v != null && v > BigInt.zero ? null : l10n.errorInvalidAmount;
        } on MoneyException catch (e) {
          return moneyErrorMessage(l10n, e.error);
        }
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button,
        const SizedBox(height: BSpace.s8),
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth < 320
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    rate,
                    const SizedBox(height: BSpace.s8),
                    charged,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: rate),
                    const SizedBox(width: BSpace.s8),
                    Expanded(child: charged),
                  ],
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(BSpace.s4, BSpace.s8, BSpace.s4, 0),
          child: Text(
            [
              if (s._fetched case final f? when f.rate == s._rate.text)
                l10n.expenseRateFrom(switch (f.source) {
                  'openexchangerates' => 'Open Exchange Rates',
                  _ => 'Frankfurter',
                }, DateFormat.yMMMd(locale).format(f.updatedAt.toLocal())),
              l10n.expenseForeignHelp(g.currency),
            ].join(' '),
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
