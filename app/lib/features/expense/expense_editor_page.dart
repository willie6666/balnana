import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/money.dart';
import '../../core/session.dart';
import '../../data/api.dart';
import '../../data/categories.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/money.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/amount_field.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/form_page.dart';
import '../../ui/widgets/member_avatar.dart';
import '../group/expenses_tab.dart';
import '../group/group_page.dart';
import 'receipt.dart';

/// Adds an expense to a group, or edits one when [expenseId] is set.
class ExpenseEditorPage extends ConsumerStatefulWidget {
  const ExpenseEditorPage({super.key, required this.token, this.expenseId});

  final String token;
  final String? expenseId;

  @override
  ConsumerState<ExpenseEditorPage> createState() => _ExpenseEditorPageState();
}

class _ExpenseEditorPageState extends ConsumerState<ExpenseEditorPage> {
  /// The version the form started from. Live updates bring newer ones, which
  /// replace it only when nothing was changed here or when asked to.
  Expense? _base;

  void _adopt(Expense expense) => setState(() => _base = expense);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final token = widget.token, expenseId = widget.expenseId;
    final group = ref.watchCurrent(groupProvider(token));
    final expense = expenseId == null ? null : ref.watchCurrent(expenseProvider((token: token, id: expenseId)));
    final error = group.error ?? expense?.error;
    // A row of the list holds the whole expense, so the form opens from it at
    // once while the latest version loads.
    final listed = expense == null || expense.hasValue || expense.hasError
        ? null
        : ref
              .read(expensesProvider(token))
              .current(ref.read(identityProvider))
              .value
              ?.items
              .where((e) => e.id == expenseId)
              .firstOrNull;

    if (group.value case final g? when expense == null || expense.hasValue || listed != null) {
      final latest = expense?.value ?? listed;
      final base = _base ??= latest;
      return GroupTheme(
        group: g,
        child: _Editor(
          key: ValueKey(base?.version),
          group: g,
          expense: base,
          hasReceipt: latest?.hasReceipt ?? false,
          newer: latest != null && latest.version != base?.version ? latest : null,
          onReload: _adopt,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(leading: const CloseButton()),
      body: Center(
        child: error == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(BSpace.s16),
                child: EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.groupsUnreachableTitle,
                  body: errorMessage(l10n, error),
                  action: FilledButton.tonal(
                    onPressed: () {
                      ref.invalidate(groupProvider(token));
                      if (expenseId != null) ref.invalidate(expenseProvider((token: token, id: expenseId)));
                    },
                    child: Text(l10n.commonRetry),
                  ),
                ),
              ),
      ),
    );
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({
    super.key,
    required this.group,
    this.expense,
    required this.hasReceipt,
    this.newer,
    required this.onReload,
  });

  final Group group;
  final Expense? expense;

  /// Live receipt metadata, independent of the financial draft version.
  final bool hasReceipt;

  /// A version of [expense] someone else saved since the form started.
  final Expense? newer;

  /// Starts the form over from another version.
  final ValueChanged<Expense> onReload;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _title = TextEditingController();
  final _note = TextEditingController();
  String? _category;
  late DateTime _date;

  /// The only payer, unless [_multiPay].
  String? _payer;
  bool _multiPay = false;
  final _paid = <String, TextEditingController>{};

  SplitMethod _method = SplitMethod.equal;
  final _included = <String>{};
  final _values = <String, TextEditingController>{};

  /// A new photo of the receipt, and whether the saved one is to go; both
  /// wait for the expense to be saved.
  PickedReceipt? _receipt;
  bool _dropReceipt = false;

  bool _busy = false;
  bool _tried = false;

  Group get _group => widget.group;
  bool get _received => widget.expense?.isReceived ?? false;
  int get _digits => _group.minorDigits;

  /// Current members, plus anyone who left but is part of this expense.
  late final List<Member> _people = [
    for (final m in _group.members)
      if (!m.left ||
          (widget.expense?.payers.any((p) => p.memberId == m.id) ?? false) ||
          (widget.expense?.splits.any((s) => s.memberId == m.id) ?? false))
        m,
  ];

  @override
  void initState() {
    super.initState();
    for (final m in _people) {
      _paid[m.id] = TextEditingController();
      _values[m.id] = TextEditingController();
    }
    final e = widget.expense;
    if (e == null) {
      _date = DateTime.now();
      final me = _group.member(myMemberIdRead(ref, _group.token));
      _payer = (me != null && !me.left) ? me.id : _group.activeMembers.firstOrNull?.id;
      _included.addAll(_group.activeMembers.map((m) => m.id));
    } else {
      _amount.text = formatAmount(e.amount, _digits);
      _title.text = e.title;
      _note.text = e.note ?? '';
      _category = e.categoryId;
      _date = e.occurredAt.toLocal();
      if (e.payers.length == 1) {
        _payer = e.payers.single.memberId;
      } else {
        _multiPay = true;
        for (final p in e.payers) {
          _paid[p.memberId]?.text = formatAmount(p.amount, _digits);
        }
      }
      _method = e.splitMethod;
      for (final s in e.splits) {
        _included.add(s.memberId);
        _values[s.memberId]?.text = switch (_method) {
          SplitMethod.equal => '',
          SplitMethod.exact => formatAmount(s.amount, _digits),
          SplitMethod.percent || SplitMethod.shares => s.share ?? '',
        };
      }
    }
    for (final c in [_amount, ..._paid.values, ..._values.values]) {
      c.addListener(_changed);
    }
    _initial = _snapshot();
  }

  void _changed() => setState(() {});

  /// Everything the form holds, to tell whether it was changed.
  List<Object?> _snapshot() => [
    _amount.text,
    _title.text,
    _note.text,
    _category,
    _date,
    _payer,
    _multiPay,
    _method,
    for (final m in _people) ...[_included.contains(m.id), _paid[m.id]!.text, _values[m.id]!.text],
  ];

  late final List<Object?> _initial;

  bool get _formDirty => !listEquals(_snapshot(), _initial);

  bool get _dirty => _formDirty || _receipt != null || _dropReceipt;

  @override
  void didUpdateWidget(_Editor old) {
    super.didUpdateWidget(old);
    // Nothing to lose here, so show the newer version straight away.
    final newer = widget.newer;
    if (newer != null && newer.version != old.newer?.version && !_dirty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onReload(newer);
      });
    }
  }

  /// [setState] for the row widgets below.
  void _update(VoidCallback fn) => setState(fn);

  @override
  void dispose() {
    for (final c in [_amount, _title, _note, ..._paid.values, ..._values.values]) {
      c.dispose();
    }
    super.dispose();
  }

  BigInt? get _total {
    try {
      final v = parseInput(_amount.text, _digits);
      return v != null && v > BigInt.zero ? v : null;
    } on MoneyException {
      return null;
    }
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
    return out.values.fold(BigInt.zero, (a, b) => a + b) == total ? out : null;
  }

  void _setMethod(SplitMethod method) {
    if (method == _method) return;
    setState(() {
      _method = method;
      for (final c in _values.values) {
        c.text = method == SplitMethod.shares ? '1' : '';
      }
    });
  }

  void _setMultiPay(bool multi) {
    setState(() {
      _multiPay = multi;
      if (multi && _payer != null && _paid.values.every((c) => c.text.isEmpty)) {
        _paid[_payer!]!.text = _amount.text;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return;
    // Keep the time of day, so expenses on one day stay in the order they were added.
    setState(
      () => _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute, _date.second),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
    if (picked == null) return;
    setState(() => _date = DateTime(_date.year, _date.month, _date.day, picked.hour, picked.minute));
  }

  Future<void> _save() async {
    setState(() => _tried = true);
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (!_form.currentState!.validate()) return;
    final total = _total, payers = _payers(), preview = _preview();
    if (total == null || payers == null || preview.shares == null) {
      final message = preview.error != null ? moneyErrorMessage(l10n, preview.error!) : l10n.errorPayersTotal;
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    final draft = ExpenseDraft(
      title: _title.text.trim(),
      categoryId: _category,
      amount: total,
      occurredAt: _date,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      payers: payers,
      splitMethod: _method,
      splits: _parts,
    );
    setState(() => _busy = true);
    final api = groupApiOf(ref, _group.token);
    try {
      final String id;
      if (widget.expense case final e?) {
        id = e.id;
        // A new photo alone leaves the expense as it is.
        if (_formDirty) await api.updateExpense(e.id, draft, _digits, version: e.version);
      } else {
        id = (await api.createExpense(draft, _digits)).id;
      }
      await _saveReceipt(api, id);
      ref.invalidate(expenseProvider((token: _group.token, id: id)));
      refreshGroup(ref, _group.token);
      if (mounted) context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      if (e.code == 'expense_version_conflict') {
        await _conflict();
      } else {
        messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
      }
    }
  }

  /// Uploads or removes the photo once the expense is saved. The expense
  /// stays saved when this fails, so it is only told.
  Future<void> _saveReceipt(GroupApi api, String id) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_receipt case final r?) {
        await api.putReceipt(id, r.bytes, r.type, _digits);
      } else if (_dropReceipt) {
        await api.deleteReceipt(id);
      }
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.receiptNotSaved(errorMessage(l10n, e)))));
    }
  }

  /// Someone else changed the expense while it was open here.
  Future<void> _conflict() async {
    final l10n = context.l10n;
    final reload = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.conflictTitle),
        content: Text(l10n.errorVersionConflict),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.conflictReload)),
        ],
      ),
    );
    if (reload == true && widget.expense != null) await _reload();
  }

  /// Starts the form over from the server's latest version.
  Future<void> _reload() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final latest = await ref.refresh(expenseProvider((token: _group.token, id: widget.expense!.id)).future);
      if (mounted) widget.onReload(latest);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
    }
  }

  Future<void> _delete() async {
    final e = widget.expense!;
    final router = GoRouter.of(context);
    setState(() => _busy = true);
    final deleted = await deleteExpenseWithUndo(context, ref, _group, e);
    // Gone already (the user went back): popping now would close another page.
    if (!mounted) return;
    if (deleted) {
      router.pop();
    } else {
      setState(() => _busy = false);
    }
  }

  /// Asks before leaving with changes that are not saved.
  Future<void> _leave() async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.expenseDiscardTitle),
        content: Text(l10n.expenseDiscardBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.expenseDiscard)),
        ],
      ),
    );
    if (discard == true && mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final symbol = moneySymbol(locale, _group.currency, _group.symbol);
    final preview = _preview();
    final editing = widget.expense != null;

    return PopScope(
      canPop: !_dirty || _busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: FormPage(
        title: editing ? l10n.expenseEdit : l10n.expenseNew,
        submitLabel: l10n.commonSave,
        busy: _busy,
        onSubmit: _save,
        actions: [
          if (editing)
            IconButton(
              tooltip: l10n.expenseDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _busy ? null : _delete,
            ),
        ],
        children: [
          if (widget.newer != null && _dirty) ...[
            Card.filled(
              color: scheme.secondaryContainer,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(BSpace.s16, BSpace.s12, BSpace.s8, BSpace.s8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.expenseChangedElsewhere, style: TextStyle(color: scheme.onSecondaryContainer)),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => widget.onReload(widget.newer!),
                        child: Text(l10n.conflictReload),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: BSpace.s16),
          ],
          Form(
            key: _form,
            autovalidateMode: _tried ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _amount,
                  autofocus: !editing,
                  textAlign: TextAlign.center,
                  style: text.moneyHero,
                  keyboardType: TextInputType.numberWithOptions(decimal: _digits > 0),
                  inputFormatters: [AmountFormatter(_digits)],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                    hintText: formatAmount(BigInt.zero, _digits),
                    prefixIcon: FieldAffix(symbol, style: text.headlineMedium),
                    prefixIconConstraints: const BoxConstraints(),
                  ),
                  validator: (_) {
                    try {
                      return _total == null ? l10n.errorInvalidAmount : null;
                    } on MoneyException catch (e) {
                      return moneyErrorMessage(l10n, e.error);
                    }
                  },
                ),
                const SizedBox(height: BSpace.s8),
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [LengthLimitingTextInputFormatter(200)],
                  decoration: InputDecoration(labelText: l10n.expenseTitle, hintText: l10n.expenseTitleHint),
                  validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
                ),
                const SizedBox(height: BSpace.s12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final c in _group.offeredCategories(_category))
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: BSpace.s8),
                          child: ChoiceChip(
                            avatar: Text(c.emoji),
                            label: Text(c.label(l10n)),
                            showCheckmark: false,
                            selected: _category == c.id,
                            onSelected: (on) => setState(() => _category = on ? c.id : null),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: BSpace.s12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.event_outlined),
                        label: Text(DateFormat.yMMMEd(locale).format(_date)),
                      ),
                    ),
                    const SizedBox(width: BSpace.s8),
                    OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.schedule_outlined),
                      label: Text(DateFormat.jm(locale).format(_date)),
                    ),
                  ],
                ),

                // Money that came in keeps its reversed roles: see Expense.isReceived.
                FormSection(_received ? l10n.expenseReceivedForLabel : l10n.expensePaidByLabel),
                _PaidBy(state: this, symbol: symbol),

                FormSection(_received ? l10n.expenseReceivedByLabel : l10n.expenseSplit),
                SegmentedButton<SplitMethod>(
                  showSelectedIcon: false,
                  // Four segments share a phone's width: tighter padding keeps each label on one line.
                  style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: BSpace.s8)),
                  ),
                  segments: [
                    for (final (method, label) in [
                      (SplitMethod.equal, l10n.splitEqual),
                      (SplitMethod.exact, l10n.splitExact),
                      (SplitMethod.percent, l10n.splitPercent),
                      (SplitMethod.shares, l10n.splitShares),
                    ])
                      ButtonSegment(
                        value: method,
                        label: Text(label, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  selected: {_method},
                  onSelectionChanged: (s) => _setMethod(s.single),
                ),
                const SizedBox(height: BSpace.s12),
                if (preview.shares case final shares?) SplitBar(people: _people, shares: shares),
                for (final m in _people)
                  _SplitRow(state: this, member: m, share: preview.shares?[m.id], symbol: symbol),
                _SplitSummary(state: this, error: preview.error),

                FormSection(l10n.expenseNote),
                TextFormField(
                  controller: _note,
                  minLines: 2,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [LengthLimitingTextInputFormatter(2000)],
                  decoration: InputDecoration(hintText: l10n.expenseNoteHint),
                ),

                FormSection(l10n.expenseReceipt),
                ReceiptField(
                  token: _group.token,
                  expenseId: widget.expense?.id,
                  saved: widget.hasReceipt && !_dropReceipt,
                  picked: _receipt,
                  onPicked: (r) => setState(() => _receipt = r),
                  onRemoved: () => setState(() {
                    _receipt = null;
                    _dropReceipt = widget.hasReceipt;
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: BSpace.s8,
          runSpacing: BSpace.s8,
          children: [
            for (final m in s._people)
              if (!m.left || m.id == s._payer)
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
                        prefixIcon: FieldAffix(symbol),
                        prefixIconConstraints: const BoxConstraints(),
                        hintText: '0',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _Remaining(
            total: s._total,
            sum: s._paid.values.fold(BigInt.zero, (a, c) {
              try {
                return a + (parseInput(c.text, s._digits) ?? BigInt.zero);
              } on MoneyException {
                return a;
              }
            }),
            digits: s._digits,
            currency: s._group.currency,
            symbol: s._group.symbol,
          ),
        ],
      ],
    );
  }
}

/// A currency symbol or unit beside a field, shown even while it is empty.
class FieldAffix extends StatelessWidget {
  const FieldAffix(this.text, {super.key, this.end = false, this.style});

  final String text;
  final bool end;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: end ? 4 : 12, end: end ? 12 : 4),
      child: Text(
        text,
        style: (style ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({required this.state, required this.member, required this.share, required this.symbol});

  final _EditorState state;
  final Member member;
  final BigInt? share;
  final String symbol;

  @override
  Widget build(BuildContext context) {
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
                      ? formatMoney(context, share!, s._digits, s._group.currency, symbol: s._group.symbol)
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
                    hintText: '0',
                    prefixIcon: method == SplitMethod.exact ? FieldAffix(symbol) : null,
                    prefixIconConstraints: const BoxConstraints(),
                    suffixIcon: switch (method) {
                      SplitMethod.percent => const FieldAffix('%', end: true),
                      SplitMethod.shares => const FieldAffix('×', end: true),
                      _ => null,
                    },
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
          currency: s._group.currency,
          symbol: s._group.symbol,
        );
      case SplitMethod.percent:
        var sum = BigInt.zero;
        for (final id in s._included) {
          try {
            sum += parseInput(s._values[id]!.text, 4) ?? BigInt.zero;
          } on MoneyException {
            // Too large to be a percentage; the total below says so.
            sum += maxMinor;
          }
        }
        final left = BigInt.from(1000000) - sum;
        if (left == BigInt.zero) return const SizedBox.shrink();
        final pct = formatAmount(left.abs(), 4).replaceFirst(RegExp(r'\.?0+$'), '');
        return _Note(
          text: left.isNegative ? l10n.splitPercentOver(pct) : l10n.splitPercentLeft(pct),
          error: true,
        );
      case SplitMethod.equal:
      case SplitMethod.shares:
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
