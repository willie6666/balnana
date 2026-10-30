import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../ui/layout.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/form_page.dart';
import 'admin_page.dart';

/// The plans the server has, what they allow and which payments give them.
/// Every change is saved at once, as the server takes the whole list.
class AdminPlansPage extends ConsumerStatefulWidget {
  const AdminPlansPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<AdminPlansPage> createState() => _AdminPlansPageState();
}

class _AdminPlansPageState extends ConsumerState<AdminPlansPage> {
  PlanCatalog? _catalog;
  Object? _error;
  bool _busy = false;

  AdminApi get _api => ref.read(adminApiProvider)!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final catalog = await _api.plans(widget.token);
      if (mounted) {
        setState(() {
          _catalog = catalog;
          _error = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _save(PlanCatalog next) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final saved = await _api.savePlans(widget.token, next);
      if (mounted) setState(() => _catalog = saved);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _editPlan(Plan? plan) async {
    final catalog = _catalog!;
    final edited = await showDialog<Plan>(
      context: context,
      builder: (_) => _PlanDialog(plan: plan, taken: {for (final p in catalog.plans) p.id}),
    );
    if (edited == null || !mounted) return;
    Plan demoted(Plan p) =>
        edited.isDefault && p.isDefault ? Plan(id: p.id, name: p.name, rank: p.rank, limits: p.limits) : p;
    await _save(
      PlanCatalog(
        plans: [
          for (final p in catalog.plans)
            if (p.id == edited.id) edited else demoted(p),
          if (plan == null) edited,
        ],
        products: catalog.products,
      ),
    );
  }

  Future<void> _removePlan(Plan plan) async {
    final catalog = _catalog!;
    await _save(
      PlanCatalog(
        plans: [...catalog.plans.where((p) => p.id != plan.id)],
        products: [...catalog.products.where((p) => p.planId != plan.id)],
      ),
    );
  }

  Future<void> _editProduct(PlanProduct? product) async {
    final catalog = _catalog!;
    final edited = await showDialog<PlanProduct>(
      context: context,
      builder: (_) => _ProductDialog(product: product, plans: catalog.plans),
    );
    if (edited == null || !mounted) return;
    await _save(
      PlanCatalog(
        plans: catalog.plans,
        products: [
          for (final p in catalog.products) identical(p, product) ? edited : p,
          if (product == null) edited,
        ],
      ),
    );
  }

  Future<void> _removeProduct(PlanProduct product) {
    final catalog = _catalog!;
    return _save(
      PlanCatalog(plans: catalog.plans, products: [...catalog.products.where((p) => !identical(p, product))]),
    );
  }

  String _limits(AppLocalizations l10n, PlanLimits limits) {
    String value(int? n) => n?.toString() ?? l10n.planUnlimited;
    return [
      l10n.adminPlanLimit(l10n.planLimitReceipts, value(limits.receiptsPerGroup)),
      l10n.adminPlanLimit(l10n.planLimitRecurring, value(limits.recurringPerGroup)),
      l10n.adminPlanLimit(l10n.planLimitOwnGroups, value(limits.ownGroups)),
      l10n.adminPlanLimit(l10n.planLimitSponsored, value(limits.sponsoredGroups)),
    ].join(' · ');
  }

  String _productName(AppLocalizations l10n, PlanProduct p) =>
      p.product.isNotEmpty ? p.product : l10n.adminProductAnyPayment('${p.minAmount} ${p.currency}');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final catalog = _catalog;

    Widget body;
    if (catalog == null && _error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(BSpace.s16),
          child: EmptyState(
            icon: Icons.cloud_off_outlined,
            title: l10n.adminPlans,
            body: errorMessage(l10n, _error!),
            action: FilledButton(onPressed: _load, child: Text(l10n.commonRetry)),
          ),
        ),
      );
    } else if (catalog == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      const tilePadding = EdgeInsetsDirectional.only(start: BSpace.s4, end: 0);
      Widget note(String message) => Padding(
        padding: const EdgeInsets.only(bottom: BSpace.s8),
        child: Text(message, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
      );
      String planName(String id) =>
          catalog.plans.where((p) => p.id == id).map((p) => p.name).firstOrNull ?? id;
      body = LayoutBuilder(
        builder: (context, constraints) {
          final side = math.max(BSpace.s16, (constraints.maxWidth - contentMaxWidth) / 2);
          return ListView(
            padding: EdgeInsets.fromLTRB(side, BSpace.s8, side, BSpace.s32),
            children: [
              FormSection(l10n.adminPlans),
              note(l10n.adminPlansHelp),
              for (final p in catalog.plans)
                ListTile(
                  contentPadding: tilePadding,
                  title: Text(p.isDefault ? l10n.adminPlanDefaultName(p.name) : p.name),
                  subtitle: Text(_limits(l10n, p.limits)),
                  onTap: _busy ? null : () => _editPlan(p),
                  trailing: p.isDefault
                      ? null
                      : IconButton(
                          tooltip: l10n.commonRemove,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: _busy ? null : () => _removePlan(p),
                        ),
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _editPlan(null),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.adminPlanAdd),
                ),
              ),
              FormSection(l10n.adminProductsSection),
              note(l10n.adminProductsHelp),
              for (final p in catalog.products)
                ListTile(
                  contentPadding: tilePadding,
                  title: Text(_productName(l10n, p)),
                  subtitle: Text(
                    [
                      providerName(p.provider),
                      planName(p.planId),
                      l10n.adminPlanDays(p.days),
                      if (p.product.isNotEmpty && p.minAmount != null)
                        '${p.minAmount} ${p.currency ?? ''}'.trim(),
                    ].join(' · '),
                  ),
                  onTap: _busy || p.provider != 'kofi' ? null : () => _editProduct(p),
                  trailing: IconButton(
                    tooltip: l10n.commonRemove,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _busy ? null : () => _removeProduct(p),
                  ),
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _editProduct(null),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.adminProductAdd),
                ),
              ),
            ],
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminPlans)),
      body: body,
    );
  }
}

/// The name of a payment provider.
String providerName(String provider) => switch (provider) {
  'kofi' => 'Ko-fi',
  'play' => 'Google Play',
  _ => provider,
};

/// The most a limit may be; the server refuses more.
const _maxLimit = 100000000;

/// The most days a plan may run for; the server refuses more.
const _maxDays = 36500;

/// A whole number from 0 (or [min]) to [max], or empty when [optional].
String? _checkNumber(
  AppLocalizations l10n,
  String? value, {
  int min = 0,
  required int max,
  bool optional = false,
}) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return optional ? null : l10n.errorRequired;
  final n = int.tryParse(v);
  return n == null || n < min || n > max ? l10n.adminInvalidValue : null;
}

final _digits = [FilteringTextInputFormatter.digitsOnly];

class _PlanDialog extends StatefulWidget {
  const _PlanDialog({required this.plan, required this.taken});

  final Plan? plan;
  final Set<String> taken;

  @override
  State<_PlanDialog> createState() => _PlanDialogState();
}

class _PlanDialogState extends State<_PlanDialog> {
  static final _id = RegExp(r'^[a-z0-9][a-z0-9-]{0,31}$');

  final _form = GlobalKey<FormState>();
  late final _idField = TextEditingController(text: widget.plan?.id);
  late final _name = TextEditingController(text: widget.plan?.name);
  late final _rank = TextEditingController(text: '${widget.plan?.rank ?? 1}');
  late final _receipts = TextEditingController(text: widget.plan?.limits.receiptsPerGroup?.toString());
  late final _recurring = TextEditingController(text: widget.plan?.limits.recurringPerGroup?.toString());
  late final _groups = TextEditingController(text: widget.plan?.limits.ownGroups?.toString());
  late final _sponsored = TextEditingController(text: widget.plan?.limits.sponsoredGroups?.toString());
  late bool _default = widget.plan?.isDefault ?? false;

  @override
  void dispose() {
    for (final c in [_idField, _name, _rank, _receipts, _recurring, _groups, _sponsored]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    int? number(TextEditingController c) => int.tryParse(c.text.trim());
    Navigator.pop(
      context,
      Plan(
        id: _idField.text.trim(),
        name: _name.text.trim(),
        rank: number(_rank) ?? 0,
        isDefault: _default,
        limits: PlanLimits(
          receiptsPerGroup: number(_receipts),
          recurringPerGroup: number(_recurring),
          ownGroups: number(_groups),
          sponsoredGroups: number(_sponsored),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const gap = SizedBox(height: BSpace.s16);
    Widget limit(TextEditingController c, String label) => TextFormField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: _digits,
      decoration: InputDecoration(labelText: label, hintText: l10n.planUnlimited),
      validator: (v) => _checkNumber(l10n, v, max: _maxLimit, optional: true),
    );
    return AlertDialog(
      title: Text(widget.plan == null ? l10n.adminPlanAdd : widget.plan!.name),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.plan == null) ...[
                TextFormField(
                  controller: _idField,
                  autocorrect: false,
                  decoration: InputDecoration(labelText: l10n.adminPlanId, helperText: l10n.adminPlanIdHelp),
                  validator: (v) {
                    final id = (v ?? '').trim();
                    return !_id.hasMatch(id) || widget.taken.contains(id) ? l10n.adminInvalidValue : null;
                  },
                ),
                gap,
              ],
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.adminPlanName),
                validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
              ),
              gap,
              TextFormField(
                controller: _rank,
                keyboardType: TextInputType.number,
                inputFormatters: _digits,
                decoration: InputDecoration(
                  labelText: l10n.adminPlanRank,
                  helperText: l10n.adminPlanRankHelp,
                ),
                validator: (v) => _checkNumber(l10n, v, max: _maxLimit),
              ),
              gap,
              limit(_receipts, l10n.planLimitReceipts),
              gap,
              limit(_recurring, l10n.planLimitRecurring),
              gap,
              limit(_groups, l10n.planLimitOwnGroups),
              gap,
              limit(_sponsored, l10n.planLimitSponsored),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.adminPlanDefault),
                subtitle: Text(l10n.adminPlanDefaultHelp),
                value: _default,
                // There is always one: another plan takes over, not none.
                onChanged: widget.plan?.isDefault ?? false ? null : (v) => setState(() => _default = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _submit, child: Text(l10n.commonSave)),
      ],
    );
  }
}

class _ProductDialog extends StatefulWidget {
  const _ProductDialog({required this.product, required this.plans});

  final PlanProduct? product;
  final List<Plan> plans;

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  static final _amount = RegExp(r'^\d{1,10}(\.\d{1,2})?$');
  static final _currencyCode = RegExp(r'^[A-Z]{3}$');

  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.product);
  late final _days = TextEditingController(text: '${widget.product?.days ?? 35}');
  late final _minAmount = TextEditingController(text: widget.product?.minAmount);
  late final _currency = TextEditingController(text: widget.product?.currency);
  late String? _plan = widget.product?.planId;

  List<Plan> get _plans => [...widget.plans.where((p) => !p.isDefault)];

  @override
  void dispose() {
    for (final c in [_name, _days, _minAmount, _currency]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final amount = _minAmount.text.trim();
    final currency = _currency.text.trim().toUpperCase();
    Navigator.pop(
      context,
      PlanProduct(
        provider: 'kofi',
        product: _name.text.trim(),
        planId: _plan!,
        days: int.parse(_days.text.trim()),
        minAmount: amount.isEmpty ? null : amount,
        currency: currency.isEmpty ? null : currency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const gap = SizedBox(height: BSpace.s16);
    // Without a tier name, the amount is all there is to go by.
    bool needsAmount() => _name.text.trim().isEmpty;
    return AlertDialog(
      title: Text(widget.product == null ? l10n.adminProductAdd : l10n.adminProductEdit),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: l10n.adminProductName,
                  helperText: l10n.adminProductNameHelp,
                  helperMaxLines: 4,
                ),
              ),
              gap,
              DropdownButtonFormField<String>(
                initialValue: _plans.any((p) => p.id == _plan) ? _plan : null,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.adminProductPlan),
                items: [for (final p in _plans) DropdownMenuItem(value: p.id, child: Text(p.name))],
                onChanged: (v) => setState(() => _plan = v),
                validator: (v) => v == null ? l10n.errorRequired : null,
              ),
              gap,
              TextFormField(
                controller: _days,
                keyboardType: TextInputType.number,
                inputFormatters: _digits,
                decoration: InputDecoration(
                  labelText: l10n.adminProductDays,
                  helperText: l10n.adminProductDaysHelp,
                  helperMaxLines: 4,
                ),
                validator: (v) => _checkNumber(l10n, v, min: 1, max: _maxDays),
              ),
              gap,
              TextFormField(
                controller: _minAmount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.adminProductMinAmount),
                validator: (v) {
                  final amount = (v ?? '').trim();
                  if (amount.isEmpty) return needsAmount() ? l10n.errorRequired : null;
                  return _amount.hasMatch(amount) ? null : l10n.adminInvalidValue;
                },
              ),
              gap,
              TextFormField(
                controller: _currency,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                decoration: InputDecoration(labelText: l10n.adminProductCurrency),
                validator: (v) {
                  final currency = (v ?? '').trim().toUpperCase();
                  if (currency.isEmpty) {
                    return needsAmount() || _minAmount.text.trim().isNotEmpty ? l10n.errorRequired : null;
                  }
                  return _currencyCode.hasMatch(currency) ? null : l10n.adminInvalidValue;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _submit, child: Text(l10n.commonSave)),
      ],
    );
  }
}
