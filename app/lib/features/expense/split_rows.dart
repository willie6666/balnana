part of 'expense_editor_page.dart';

extension _SplitLogic on _EditorState {
  /// Why an amount typed for a payer or a share is not one, if any is not.
  MoneyError? get _typedError {
    final typed = [
      if (_multiPay)
        for (final c in _paid.values) (c.text, _digits),
      if (_method != SplitMethod.equal)
        for (final id in _included) (_values[id]!.text, _method == SplitMethod.shares ? 4 : _digits),
    ];
    for (final (text, digits) in typed) {
      try {
        parseInput(text, digits);
      } on MoneyException catch (e) {
        return e.error;
      }
    }
    return null;
  }

  List<SplitPart> get _parts => [
    for (final m in _people)
      if (_included.contains(m.id))
        SplitPart(m.id, _method == SplitMethod.equal ? '' : shareValue(_values[m.id]!.text)),
  ];

  /// Each person's share of the current total, or the reason there is none.
  ({Map<String, BigInt>? shares, MoneyError? error}) _preview() {
    final total = _total;
    if (total == null) return (shares: null, error: null);
    try {
      return (shares: split(total, _digits, _method, _parts), error: null);
    } on MoneyException catch (e) {
      return (shares: null, error: e.error);
    }
  }

  void _setMethod(SplitMethod method) {
    if (method == _method) return;
    _update(() {
      _method = method;
      for (final c in _values.values) {
        c.text = method == SplitMethod.shares ? '1' : '';
      }
    });
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    super.key,
    required this.state,
    required this.member,
    required this.share,
    required this.symbol,
  });

  final _EditorState state;
  final Member member;
  final BigInt? share;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = state;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final included = s._included.contains(member.id);
    final method = s._method;

    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(BShape.sm)),
      onTap: () => s._update(() => included ? s._included.remove(member.id) : s._included.add(member.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: BSpace.s4),
        child: Row(
          children: [
            Checkbox(
              value: included,
              onChanged: (on) =>
                  s._update(() => on! ? s._included.add(member.id) : s._included.remove(member.id)),
            ),
            MemberAvatar(member: member, size: 32),
            const SizedBox(width: BSpace.s12),
            Expanded(
              child: Text(
                member.name,
                style: text.bodyLarge?.copyWith(color: included ? null : scheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (method != SplitMethod.exact)
              SizedBox(
                width: 96,
                child: Text(
                  included && share != null
                      ? formatMoney(context, share!, s._digits, s._currency, symbol: s._symbol)
                      : '',
                  textAlign: TextAlign.end,
                  style: text.moneySmall.copyWith(color: scheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (method != SplitMethod.equal && included) ...[
              const SizedBox(width: BSpace.s8),
              SizedBox(
                width: method == SplitMethod.exact ? 120 : 92,
                child: TextField(
                  controller: s._values[member.id],
                  textAlign: TextAlign.end,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [AmountFormatter(method == SplitMethod.exact ? s._digits : 4)],
                  decoration: InputDecoration(
                    isDense: true,
                    errorText: _inputError(
                      l10n,
                      s._values[member.id]!.text,
                      method == SplitMethod.exact ? s._digits : 4,
                    ),
                    errorMaxLines: 3,
                    hintText: '0',
                    prefixIcon: method == SplitMethod.exact ? FieldAffix(symbol) : null,
                    prefixIconConstraints: const BoxConstraints(),
                    suffixIcon: method == SplitMethod.shares ? const FieldAffix('×', end: true) : null,
                    suffixIconConstraints: const BoxConstraints(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Why [text] is not an amount with [digits] decimals, or null when it is
/// one or blank.
String? _inputError(AppLocalizations l10n, String text, int digits) {
  try {
    parseInput(text, digits);
    return null;
  } on MoneyException catch (e) {
    return moneyErrorMessage(l10n, e.error);
  }
}

/// How many of the split's people a large group lists before "Show more".
const _splitLimit = 6;

/// The split's people in a large group: a search, a sort that brings who is
/// included and the largest shares to the top, All and None, and the rows
/// that match.
class _CrowdSplit extends StatelessWidget {
  const _CrowdSplit({required this.state, required this.shares, required this.symbol});

  final _EditorState state;
  final Map<String, BigInt>? shares;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = state;
    // Sorted only when asked, so a row does not move away as it is ticked.
    final order = s._splitOrder;
    final people = order == null ? s._people : [for (final id in order) ?s._group.member(id)];
    final matching = [
      for (final m in people)
        if (nameMatches(m.name, s._splitQuery.text)) m,
    ];
    // Who is in first, then by what was typed for them: computed shares
    // differ by a cent between equals, which would shuffle them. Equals keep
    // the group's order.
    BigInt typed(Member m) {
      if (!s._included.contains(m.id)) return BigInt.from(-1);
      if (s._method == SplitMethod.equal) return BigInt.zero;
      try {
        return parseInput(s._values[m.id]!.text, s._method == SplitMethod.shares ? 4 : s._digits) ??
            BigInt.zero;
      } on MoneyException {
        return BigInt.zero;
      }
    }

    final at = {for (final (i, m) in s._people.indexed) m.id: i};
    final sorted = [
      for (final m
          in [...s._people]..sort((a, b) {
            final bySize = typed(b).compareTo(typed(a));
            return bySize != 0 ? bySize : at[a.id]!.compareTo(at[b.id]!);
          }))
        m.id,
    ];
    // Lit once ticks or shares have put the list out of order.
    final stale = !listEquals(sorted, [for (final m in people) m.id]);
    void sort() => s._update(() => s._splitOrder = sorted);
    // Both act on the people the search shows; ticking everyone means everyone still here.
    void tickAll(bool on) => s._update(() {
      for (final m in matching) {
        if (!on) {
          s._included.remove(m.id);
        } else if (!m.left) {
          s._included.add(m.id);
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MemberSearchField(controller: s._splitQuery, onChanged: () => s._update(() {})),
        const SizedBox(height: BSpace.s8),
        Row(
          children: [
            if (stale)
              FilledButton.tonalIcon(
                onPressed: sort,
                icon: const Icon(Icons.sort),
                label: Text(l10n.crowdSort),
              )
            else
              TextButton.icon(onPressed: null, icon: const Icon(Icons.sort), label: Text(l10n.crowdSort)),
            const Spacer(),
            TextButton(onPressed: () => tickAll(true), child: Text(l10n.crowdAll)),
            TextButton(onPressed: () => tickAll(false), child: Text(l10n.crowdNone)),
          ],
        ),
        if (matching.isEmpty)
          Padding(
            padding: const EdgeInsets.all(BSpace.s24),
            child: Text(l10n.crowdNoMatch, textAlign: TextAlign.center),
          )
        else
          ShowMore(
            limit: _splitLimit,
            children: [
              for (final m in matching)
                _SplitRow(key: ValueKey(m.id), state: s, member: m, share: shares?[m.id], symbol: symbol),
            ],
          ),
      ],
    );
  }
}

/// What is still missing for the split to add up, or why it cannot.
class _SplitSummary extends StatelessWidget {
  const _SplitSummary({required this.state, required this.error});

  final _EditorState state;
  final MoneyError? error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = state;
    if (s._total == null) return const SizedBox.shrink();
    switch (s._method) {
      case SplitMethod.exact:
        var sum = BigInt.zero;
        for (final id in s._included) {
          try {
            sum += parseInput(s._values[id]!.text, s._digits) ?? BigInt.zero;
          } on MoneyException {
            // Shown by the field.
          }
        }
        return _Remaining(
          total: s._total,
          sum: sum,
          digits: s._digits,
          currency: s._currency,
          symbol: s._symbol,
        );
      case SplitMethod.equal:
      case SplitMethod.shares:
      case SplitMethod.unknown:
        if (error == null) return const SizedBox.shrink();
        return _Note(text: moneyErrorMessage(l10n, error!), error: true);
    }
  }
}

class _Remaining extends StatelessWidget {
  const _Remaining({
    required this.total,
    required this.sum,
    required this.digits,
    required this.currency,
    this.symbol,
  });

  final BigInt? total;
  final BigInt sum;
  final int digits;
  final String currency;
  final String? symbol;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (total == null) return const SizedBox.shrink();
    final left = total! - sum;
    if (left == BigInt.zero) return const SizedBox.shrink();
    final money = formatMoney(context, left.abs(), digits, currency, symbol: symbol);
    return _Note(text: left.isNegative ? l10n.splitOver(money) : l10n.splitLeft(money), error: true);
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text, this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(BSpace.s4, BSpace.s8, BSpace.s4, 0),
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: error ? scheme.error : scheme.onSurfaceVariant),
      ),
    );
  }
}

/// Everyone's share as one bar of member colors.
class SplitBar extends StatelessWidget {
  const SplitBar({super.key, required this.people, required this.shares});

  final List<Member> people;
  final Map<String, BigInt> shares;

  @override
  Widget build(BuildContext context) {
    final total = shares.values.fold(BigInt.zero, (a, b) => a + b);
    if (total == BigInt.zero) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: BSpace.s8),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(BShape.sm)),
        child: SizedBox(
          height: 12,
          child: Row(
            children: [
              for (final m in people)
                if ((shares[m.id] ?? BigInt.zero) > BigInt.zero)
                  Expanded(
                    flex: (shares[m.id]! * BigInt.from(1000) ~/ total).toInt().clamp(1, 1000),
                    child: Container(
                      margin: const EdgeInsetsDirectional.only(end: 2),
                      color: paletteColor(m.color, m.id),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
