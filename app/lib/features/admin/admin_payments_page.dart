import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../ui/layout.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import 'admin_page.dart';
import 'admin_plans_page.dart';

/// The payments providers reported, to give the ones that found no account
/// or no plan to someone.
class AdminPaymentsPage extends ConsumerStatefulWidget {
  const AdminPaymentsPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<AdminPaymentsPage> createState() => _AdminPaymentsPageState();
}

class _AdminPaymentsPageState extends ConsumerState<AdminPaymentsPage> {
  List<AdminPayment>? _payments;
  int _total = 0;
  String _state = '';
  Object? _error;

  /// Answers for a filter no longer picked are dropped.
  int _generation = 0;

  AdminApi get _api => ref.read(adminApiProvider)!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    try {
      final (payments, total) = await _api.payments(widget.token, state: _state.isEmpty ? null : _state);
      if (!mounted || generation != _generation) return;
      setState(() {
        _payments = payments;
        _total = total;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() => _error = e);
    }
  }

  Future<void> _assign(AdminPayment payment) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final done = await showDialog<bool>(
      context: context,
      builder: (_) => _AssignDialog(api: _api, token: widget.token, payment: payment),
    );
    if (done != true || !mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.adminPaymentAssigned)));
    await _load();
  }

  String _stateName(AppLocalizations l10n, String state) => switch (state) {
    'applied' => l10n.adminPaymentApplied,
    'unclaimed' => l10n.adminPaymentUnclaimed,
    'unmatched' => l10n.adminPaymentUnmatched,
    _ => state,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag());
    final payments = _payments;

    Widget body;
    if (payments == null && _error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(BSpace.s16),
          child: EmptyState(
            icon: Icons.cloud_off_outlined,
            title: l10n.adminPayments,
            body: errorMessage(l10n, _error!),
            action: FilledButton(onPressed: _load, child: Text(l10n.commonRetry)),
          ),
        ),
      );
    } else if (payments == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = LayoutBuilder(
        builder: (context, constraints) {
          final side = math.max(BSpace.s16, (constraints.maxWidth - contentMaxWidth) / 2);
          return ListView(
            padding: EdgeInsets.fromLTRB(side, BSpace.s8, side, BSpace.s32),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: '', label: Text(l10n.adminPaymentsAll)),
                    for (final state in ['unclaimed', 'unmatched', 'applied'])
                      ButtonSegment(value: state, label: Text(_stateName(l10n, state))),
                  ],
                  selected: {_state},
                  showSelectedIcon: false,
                  onSelectionChanged: (picked) {
                    setState(() => _state = picked.first);
                    _load();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: BSpace.s12),
                // A refresh that failed says so; the list is from the last one that worked.
                child: _error != null
                    ? Text(errorMessage(l10n, _error!), style: text.bodyMedium?.copyWith(color: scheme.error))
                    : Text(
                        l10n.adminPaymentsCount(_total),
                        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
              ),
              if (payments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: BSpace.s24),
                  child: Text(l10n.adminPaymentsEmpty, textAlign: TextAlign.center, style: text.bodyLarge),
                ),
              for (final p in payments)
                ListTile(
                  contentPadding: const EdgeInsetsDirectional.only(start: BSpace.s4, end: 0),
                  title: Text(p.payerName ?? p.email ?? providerName(p.provider)),
                  subtitle: Text(
                    [
                      ?p.email,
                      if (p.amount != null) '${p.amount} ${p.currency ?? ''}'.trim(),
                      providerName(p.provider),
                      p.kind,
                      ?p.product,
                      _stateName(l10n, p.state),
                      ?p.userName,
                      date.format(p.paidAt.toLocal()),
                    ].join(' · '),
                  ),
                  trailing: p.state == 'applied' ? null : const Icon(Icons.chevron_right),
                  onTap: p.state == 'applied' ? null : () => _assign(p),
                ),
            ],
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminPayments)),
      body: body,
    );
  }
}

/// Picks whose payment it was and, when no product matched, what it paid for.
class _AssignDialog extends StatefulWidget {
  const _AssignDialog({required this.api, required this.token, required this.payment});

  final AdminApi api;
  final String token;
  final AdminPayment payment;

  @override
  State<_AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<_AssignDialog> {
  final _form = GlobalKey<FormState>();
  final _query = TextEditingController();
  late final _days = TextEditingController(text: widget.payment.days?.toString());
  Timer? _debounce;
  List<AdminUser> _users = const [];
  List<Plan> _plans = const [];
  AdminUser? _user;
  late String? _plan = widget.payment.planId;
  bool _busy = false;
  String? _error;

  /// Answers to older searches are dropped.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _query.text = widget.payment.email ?? '';
    _loadPlans();
    _search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _days.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    final l10n = context.l10n;
    try {
      final catalog = await widget.api.plans(widget.token);
      if (mounted) setState(() => _plans = [...catalog.plans.where((p) => !p.isDefault)]);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = errorMessage(l10n, e));
    }
  }

  Future<void> _search() async {
    final l10n = context.l10n;
    final generation = ++_generation;
    try {
      final (users, _) = await widget.api.users(widget.token, query: _query.text.trim());
      if (mounted && generation == _generation) setState(() => _users = users.take(5).toList());
    } on ApiException catch (e) {
      if (mounted && generation == _generation) setState(() => _error = errorMessage(l10n, e));
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.assignPayment(
        widget.token,
        widget.payment.id,
        userId: _user!.id,
        planId: _plan,
        days: int.tryParse(_days.text.trim()),
      );
      if (mounted) navigator.pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorMessage(l10n, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    const gap = SizedBox(height: BSpace.s16);
    final plan = _plans.any((p) => p.id == _plan) ? _plan : null;
    return AlertDialog(
      title: Text(l10n.adminPaymentAssign),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _query,
                  enabled: !_busy,
                  autocorrect: false,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    labelText: l10n.adminUsersSearch,
                  ),
                  onChanged: (_) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), _search);
                  },
                ),
                for (final u in _users)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    selected: _user?.id == u.id,
                    leading: Icon(_user?.id == u.id ? Icons.check_circle : Icons.circle_outlined),
                    title: Text(u.name),
                    subtitle: u.email == null ? null : Text(u.email!),
                    onTap: _busy ? null : () => setState(() => _user = u),
                  ),
                FormField<void>(
                  validator: (_) => _user == null ? l10n.adminPaymentPickUser : null,
                  builder: (state) => state.hasError
                      ? Text(state.errorText!, style: TextStyle(color: scheme.error))
                      : const SizedBox.shrink(),
                ),
                gap,
                DropdownButtonFormField<String>(
                  key: ValueKey(_plans.length),
                  initialValue: plan,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.adminProductPlan),
                  items: [for (final p in _plans) DropdownMenuItem(value: p.id, child: Text(p.name))],
                  onChanged: _busy ? null : (v) => setState(() => _plan = v),
                  validator: (v) => v == null ? l10n.errorRequired : null,
                ),
                gap,
                TextFormField(
                  controller: _days,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: l10n.adminProductDays),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    return n == null || n < 1 || n > 36500 ? l10n.adminInvalidValue : null;
                  },
                ),
                if (_error case final error?) ...[gap, Text(error, style: TextStyle(color: scheme.error))],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _busy ? null : _submit, child: Text(l10n.adminPaymentAssign)),
      ],
    );
  }
}
