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
import '../../ui/widgets/member_picker.dart';
import '../group/expenses_tab.dart';
import '../group/group_page.dart';
import '../group/recurring_page.dart';
import 'location.dart';
import 'receipt.dart';

/// Adds an expense to a group, or edits one when [expenseId] is set, or
/// edits a recurring expense when [recurringId] is.
class ExpenseEditorPage extends ConsumerStatefulWidget {
  const ExpenseEditorPage({super.key, required this.token, this.expenseId, this.recurringId, this.repeat = false});

  final String token;
  final String? expenseId;
  final String? recurringId;

  /// Starts a new expense repeating every month.
  final bool repeat;

  @override
  ConsumerState<ExpenseEditorPage> createState() => _ExpenseEditorPageState();
}

class _ExpenseEditorPageState extends ConsumerState<ExpenseEditorPage> {
  /// The version the form started from. Live updates bring newer ones, which
  /// replace it only when nothing was changed here or when asked to.
  Expense? _base;

  void _adopt(Expense expense) => setState(() => _base = expense);

  /// The recurring expense the form started from.
  RecurringExpense? _recurringBase;

  @override
  Widget build(BuildContext context) {
    final token = widget.token, expenseId = widget.expenseId;
    if (widget.recurringId case final id?) return _buildRecurring(id);
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
          repeat: widget.repeat,
        ),
      );
    }
    return _waiting(error, () {
      ref.invalidate(groupProvider(token));
      if (expenseId != null) ref.invalidate(expenseProvider((token: token, id: expenseId)));
    });
  }

  Widget _buildRecurring(String id) {
    final token = widget.token;
    final group = ref.watchCurrent(groupProvider(token));
    final recurring = ref.watchCurrent(recurringOneProvider((token: token, id: id)));
    if (group.value case final g? when recurring.hasValue) {
      final base = _recurringBase ??= recurring.requireValue;
      return GroupTheme(
        group: g,
        child: _Editor(
          key: ValueKey(('recurring', base.version)),
          group: g,
          expense: base.asExpense,
          recurring: base,
          hasReceipt: false,
          onReload: (_) {},
          onReloadRecurring: (r) => setState(() => _recurringBase = r),
        ),
      );
    }
    return _waiting(group.error ?? recurring.error, () {
      ref.invalidate(groupProvider(token));
      ref.invalidate(recurringOneProvider((token: token, id: id)));
    });
  }

  /// A spinner while loading, or what went wrong.
  Widget _waiting(Object? error, VoidCallback retry) {
    final l10n = context.l10n;
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
                  body: error is ApiException && error.isNotFound && widget.recurringId != null
                      ? l10n.recurringMissing
                      : errorMessage(l10n, error),
                  action: FilledButton.tonal(onPressed: retry, child: Text(l10n.commonRetry)),
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
    this.recurring,
    this.onReloadRecurring,
    this.repeat = false,
  });

  final Group group;

  /// The expense being edited; for a recurring one, what it adds.
  final Expense? expense;

  /// Live receipt metadata, independent of the financial draft version.
  final bool hasReceipt;

  /// A version of [expense] someone else saved since the form started.
  final Expense? newer;

  /// Starts the form over from another version.
  final ValueChanged<Expense> onReload;

  /// The recurring expense being edited.
  final RecurringExpense? recurring;
  final ValueChanged<RecurringExpense>? onReloadRecurring;

  /// Starts a new expense repeating every month.
  final bool repeat;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _place = TextEditingController();
  GeoPoint? _point;
  String? _category;
  late DateTime _date;

  /// The only payer, unless [_multiPay].
  String? _payer;
  bool _multiPay = false;
  final _paid = <String, TextEditingController>{};

  /// In a large group, the payers listed while [_multiPay].
  final _payersShown = <String>{};

  SplitMethod _method = SplitMethod.equal;
  final _included = <String>{};
  final _values = <String, TextEditingController>{};

  /// In a large group, what narrows the split's list, and the order it was
  /// last sorted in.
  final _splitQuery = TextEditingController();
  List<String>? _splitOrder;

  /// A new photo of the receipt, and whether the saved one is to go; both
  /// wait for the expense to be saved.
  PickedReceipt? _receipt;
  bool _dropReceipt = false;

  /// How often the expense comes back, or null when it is added once.
  RepeatUnit? _unit;
  final _every = TextEditingController(text: '1');
  DateTime? _endsOn;

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

  /// Whether the group is too large to list every payer at once.
  bool get _crowd => isCrowd(_people.length);

  /// Whether the group is too large to list the whole split at once.
  bool get _crowdSplit => isCrowd(_people.length, _splitLimit);

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
      _place.text = e.location?.name ?? '';
      _point = e.location?.point;
      _category = e.categoryId;
      _date = e.occurredAt.toLocal();
      if (e.payers.length == 1) {
        _payer = e.payers.single.memberId;
      } else {
        _multiPay = true;
        for (final p in e.payers) {
          _paid[p.memberId]?.text = formatAmount(p.amount, _digits);
          _payersShown.add(p.memberId);
        }
      }
      _method = e.splitMethod;
      for (final s in e.splits) {
        _included.add(s.memberId);
        _values[s.memberId]?.text = switch (_method) {
          SplitMethod.equal => '',
          SplitMethod.exact => formatAmount(s.amount, _digits),
          SplitMethod.shares => s.share ?? '',
        };
      }
    }
    if (widget.recurring case final r?) {
      _unit = r.repeat.unit;
      _every.text = '${r.repeat.every}';
      _endsOn = r.endsOn;
    } else if (widget.repeat) {
      _unit = RepeatUnit.month;
    }
    for (final c in [_amount, _every, ..._values.values]) {
      c.addListener(_changed);
    }
    for (final c in _paid.values) {
      c.addListener(_paidChanged);
    }
    _initial = _snapshot();
  }

  void _changed() => setState(() {});

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
    setState(() {});
  }

  /// Everything the form holds, to tell whether it was changed.
  List<Object?> _snapshot() => [
    _amount.text,
    _title.text,
    _note.text,
    _place.text,
    _point,
    _category,
    _date,
    _payer,
    _multiPay,
    _method,
    _unit,
    _every.text,
    _endsOn,
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
    for (final c in [_amount, _title, _note, _place, _splitQuery, _every, ..._paid.values, ..._values.values]) {
      c.dispose();
    }
    super.dispose();
  }

  /// The pin of the group's latest expense that has one, to start the map at.
  GeoPoint? get _around => ref
      .read(expensesProvider(_group.token))
      .current(ref.read(identityProvider))
      .value
      ?.items
      .map((e) => e.location?.point)
      .nonNulls
      .firstOrNull;

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
    // The amount is their sum, unless a part cannot be read.
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
      if (multi && _payer != null) _payersShown.add(_payer!);
    });
    _paidChanged();
  }

  /// How many likely payers a large group offers before "Someone else".
  static const _likelyCount = 4;

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
      members: [
        for (final m in _people)
          if (!m.left) m,
      ],
      selected: _multiPay ? null : _payer,
    );
    if (picked?.id case final id? when mounted) {
      setState(() {
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
    final picked = await pickMembers(
      context,
      title: title,
      members: [
        for (final m in _people)
          if (!m.left || listed.contains(m.id)) m,
      ],
      selected: listed,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _payersShown
        ..clear()
        ..addAll(picked);
      for (final id in listed.difference(picked)) {
        _paid[id]!.clear();
      }
    });
  }

  Future<void> _pickDate() async {
    // Wide enough for the date the expense has, which an import or another
    // app may have set outside the usual range.
    final first = DateTime(2000), last = DateTime.now().add(const Duration(days: 365 * 5));
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: _date.isBefore(first) ? _date : first,
      lastDate: _date.isAfter(last) ? _date : last,
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

  /// A new expense can be made to repeat, and a recurring one changed; an
  /// expense already added stays as it is.
  bool get _canRepeat => widget.expense == null || widget.recurring != null;

  int? get _everyValue => switch (int.tryParse(_every.text)) {
    final n? when n >= 1 && n <= 999 => n,
    _ => null,
  };

  Future<void> _pickEnd() async {
    final start = DateUtils.dateOnly(_date);
    final end = _endsOn;
    final picked = await showDatePicker(
      context: context,
      initialDate: end != null && !end.isBefore(start) ? end : start,
      firstDate: start,
      lastDate: DateTime(2999, 12, 31),
    );
    if (picked != null) setState(() => _endsOn = picked);
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
      location: _place.text.trim().isEmpty && _point == null
          ? null
          : ExpenseLocation(name: _place.text.trim().isEmpty ? null : _place.text.trim(), point: _point),
      payers: payers,
      splitMethod: _method,
      splits: _parts,
    );
    if (_endsOn case final end? when _unit != null && end.isBefore(DateUtils.dateOnly(_date))) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorInvalidEnd)));
      return;
    }
    setState(() => _busy = true);
    final api = groupApiOf(ref, _group.token);
    try {
      if (_unit case final unit?) {
        final recurring = RecurringDraft(
          expense: draft,
          repeat: (unit: unit, every: _everyValue!),
          endsOn: _endsOn,
          timeZone: widget.recurring?.timeZone,
        );
        if (widget.recurring case final r?) {
          await api.updateRecurring(r.id, recurring, _digits, version: r.version);
          ref.invalidate(recurringOneProvider((token: _group.token, id: r.id)));
        } else {
          await api.createRecurring(recurring, _digits);
        }
        refreshGroup(ref, _group.token);
        if (mounted) context.pop();
        return;
      }
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
      if (e.code == 'expense_version_conflict' || e.code == 'recurring_version_conflict') {
        await _conflict(errorMessage(l10n, e));
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
  Future<void> _conflict(String message) async {
    final l10n = context.l10n;
    final reload = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.conflictTitle),
        content: Text(message),
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
      if (widget.recurring case final r?) {
        final latest = await ref.refresh(recurringOneProvider((token: _group.token, id: r.id)).future);
        if (mounted) widget.onReloadRecurring?.call(latest);
        return;
      }
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

  Future<void> _deleteRecurring() async {
    final router = GoRouter.of(context);
    setState(() => _busy = true);
    final deleted = await deleteRecurring(context, ref, _group, widget.recurring!);
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
        title: widget.recurring != null
            ? l10n.recurringEdit
            : editing
            ? l10n.expenseEdit
            : l10n.expenseNew,
        submitLabel: l10n.commonSave,
        busy: _busy,
        onSubmit: _save,
        actions: [
          if (editing)
            IconButton(
              tooltip: l10n.expenseDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _busy
                  ? null
                  : widget.recurring != null
                  ? _deleteRecurring
                  : _delete,
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
                  // Several payers' parts add up to it instead.
                  readOnly: _multiPay,
                  textAlign: TextAlign.center,
                  style: text.moneyHero,
                  keyboardType: TextInputType.numberWithOptions(decimal: _digits > 0),
                  inputFormatters: [AmountFormatter(_digits)],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                    hintText: formatAmount(BigInt.zero, _digits),
                    helperText: _multiPay ? l10n.expenseAmountFromPayers : null,
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

                if (_canRepeat) ...[
                  FormSection(l10n.repeatSection),
                  _RepeatField(state: this, locale: locale),
                ] else if (widget.expense?.recurringId case final id?) ...[
                  FormSection(l10n.repeatSection),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.repeat),
                    title: Text(l10n.recurringFromSchedule),
                    subtitle: Text(l10n.recurringOpen),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/g/${_group.token}/recurring/$id'),
                  ),
                ],

                // Money that came in keeps its reversed roles: see Expense.isReceived.
                FormSection(_received ? l10n.expenseReceivedForLabel : l10n.expensePaidByLabel),
                _PaidBy(state: this, symbol: symbol),

                FormSection(_received ? l10n.expenseReceivedByLabel : l10n.expenseSplit),
                SegmentedButton<SplitMethod>(
                  showSelectedIcon: false,
                  segments: [
                    for (final (method, label) in [
                      (SplitMethod.equal, l10n.splitEqual),
                      (SplitMethod.exact, l10n.splitExact),
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
                if (_crowdSplit)
                  _CrowdSplit(state: this, shares: preview.shares, symbol: symbol)
                else
                  for (final m in _people)
                    _SplitRow(state: this, member: m, share: preview.shares?[m.id], symbol: symbol),
                _SplitSummary(state: this, error: preview.error),

                FormSection(l10n.expenseLocation),
                LocationField(
                  name: _place,
                  point: _point,
                  onPoint: (p) => setState(() => _point = p),
                  around: _around,
                ),

                FormSection(l10n.expenseNote),
                TextFormField(
                  controller: _note,
                  minLines: 2,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [LengthLimitingTextInputFormatter(2000)],
                  decoration: InputDecoration(hintText: l10n.expenseNoteHint),
                ),

                // Each occurrence is its own expense, with its own receipt.
                if (_unit == null) ...[
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
    final title = s._received ? l10n.expenseReceivedForLabel : l10n.expensePaidByLabel;
    // A large group offers the likeliest payers and lists only the payers
    // chosen; anyone else is picked from a list.
    final offered = s._crowd
        ? s._likelyPayers()
        : [
            for (final m in s._people)
              if (!m.left || m.id == s._payer) m,
          ];
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
            // A recurring expense is stopped from its page instead.
            if (s.widget.recurring == null)
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
                onSelected: (_) => s._update(() => s._unit = u),
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
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
                  label: Text(end == null ? l10n.repeatEndNone : l10n.repeatEndOn(DateFormat.yMMMEd(locale).format(end))),
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
  const _SplitRow({super.key, required this.state, required this.member, required this.share, required this.symbol});

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
        return parseInput(s._values[m.id]!.text, s._method == SplitMethod.shares ? 4 : s._digits) ?? BigInt.zero;
      } on MoneyException {
        return BigInt.zero;
      }
    }
    final at = {for (final (i, m) in s._people.indexed) m.id: i};
    final sorted = [
      for (final m in [...s._people]..sort((a, b) {
        final bySize = typed(b).compareTo(typed(a));
        return bySize != 0 ? bySize : at[a.id]!.compareTo(at[b.id]!);
      }))
        m.id,
    ];
    // Lit once ticks or shares have put the list out of order.
    final stale = !listEquals(sorted, [for (final m in people) m.id]);
    void sort() => s._update(() => s._splitOrder = sorted);
    // Both act on the people the search shows; people who left can only be taken out.
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
              FilledButton.tonalIcon(onPressed: sort, icon: const Icon(Icons.sort), label: Text(l10n.crowdSort))
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
          currency: s._group.currency,
          symbol: s._group.symbol,
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
