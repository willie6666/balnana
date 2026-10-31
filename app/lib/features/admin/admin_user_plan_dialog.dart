import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../ui/tokens.dart';
import 'admin_plans_page.dart';

/// What plans an account has: every entitlement it was given, to end one or
/// give it another.
class AdminUserPlanDialog extends StatefulWidget {
  const AdminUserPlanDialog({super.key, required this.api, required this.token, required this.user});

  final AdminApi api;
  final String token;
  final AdminUser user;

  @override
  State<AdminUserPlanDialog> createState() => _AdminUserPlanDialogState();
}

class _AdminUserPlanDialogState extends State<AdminUserPlanDialog> {
  final _form = GlobalKey<FormState>();
  final _days = TextEditingController();
  final _note = TextEditingController();
  List<Entitlement>? _entitlements;
  List<Plan> _plans = const [];
  String? _plan;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _days.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final l10n = context.l10n;
    try {
      final entitlements = await widget.api.entitlements(widget.token, widget.user.id);
      final catalog = await widget.api.plans(widget.token);
      if (!mounted) return;
      setState(() {
        _entitlements = entitlements;
        _plans = [...catalog.plans.where((p) => !p.isDefault)];
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = errorMessage(l10n, e));
    }
  }

  Future<void> _do(Future<void> Function() action) async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      await _load();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = errorMessage(l10n, e));
    }
    if (mounted) setState(() => _busy = false);
  }

  void _grant() {
    if (!_form.currentState!.validate()) return;
    final note = _note.text.trim();
    _do(() async {
      await widget.api.grantEntitlement(
        widget.token,
        widget.user.id,
        planId: _plan!,
        days: int.tryParse(_days.text.trim()),
        note: note.isEmpty ? null : note,
      );
      _days.clear();
      _note.clear();
    });
  }

  /// Revoked for good: nothing here brings it back.
  Future<void> _revoke(Entitlement e) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminEntitlementRevokeTitle(e.planName)),
        content: Text(l10n.adminEntitlementRevokeBody(widget.user.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.adminEntitlementRevoke)),
        ],
      ),
    );
    if (ok == true && mounted) await _do(() => widget.api.revokeEntitlement(widget.token, e.id));
  }

  String _describe(AppLocalizations l10n, DateFormat date, Entitlement e, DateTime now) {
    final source = e.source == 'admin' ? l10n.adminEntitlementGranted : providerName(e.source);
    return [
      source,
      if (e.revokedAt != null)
        l10n.adminEntitlementRevoked
      else if (e.expiresAt == null)
        l10n.adminEntitlementForever
      else if (e.expiresAt!.isAfter(now))
        l10n.adminEntitlementUntil(date.format(e.expiresAt!.toLocal()))
      else
        l10n.adminEntitlementEnded(date.format(e.expiresAt!.toLocal())),
      ?e.note,
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag());
    final entitlements = _entitlements;
    final now = DateTime.now();
    const gap = SizedBox(height: BSpace.s16);
    return AlertDialog(
      title: Text(widget.user.name),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (entitlements == null && _error == null)
                const Center(child: CircularProgressIndicator())
              else if (entitlements != null) ...[
                if (entitlements.isEmpty) Text(l10n.adminEntitlementsEmpty),
                for (final e in entitlements)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.planName),
                    subtitle: Text(_describe(l10n, date, e, now)),
                    trailing: e.activeAt(now)
                        ? IconButton(
                            tooltip: l10n.adminEntitlementRevoke,
                            icon: const Icon(Icons.block),
                            onPressed: _busy
                                ? null
                                : () => _revoke(e),
                          )
                        : null,
                  ),
                if (_plans.isNotEmpty)
                  Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        gap,
                        DropdownButtonFormField<String>(
                          initialValue: _plan,
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
                          decoration: InputDecoration(
                            labelText: l10n.adminProductDays,
                            hintText: l10n.adminEntitlementForever,
                          ),
                          validator: (v) {
                            final days = (v ?? '').trim();
                            if (days.isEmpty) return null;
                            final n = int.tryParse(days);
                            return n == null || n < 1 || n > 36500 ? l10n.adminInvalidValue : null;
                          },
                        ),
                        gap,
                        TextFormField(
                          controller: _note,
                          enabled: !_busy,
                          maxLength: 200,
                          decoration: InputDecoration(labelText: l10n.adminEntitlementNote),
                        ),
                      ],
                    ),
                  ),
              ],
              if (_error case final error?) ...[gap, Text(error, style: TextStyle(color: scheme.error))],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonDone)),
        if (entitlements != null && _plans.isNotEmpty)
          TextButton(onPressed: _busy ? null : _grant, child: Text(l10n.adminEntitlementGrant)),
      ],
    );
  }
}
