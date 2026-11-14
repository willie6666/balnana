import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../ui/tokens.dart';

class AdminChangePasswordDialog extends StatefulWidget {
  const AdminChangePasswordDialog({super.key, required this.api, required this.token});

  final AdminApi api;
  final String token;

  @override
  State<AdminChangePasswordDialog> createState() => _AdminChangePasswordDialogState();
}

class _AdminChangePasswordDialogState extends State<AdminChangePasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.changePassword(widget.token, current: _current.text, next: _next.text);
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminPasswordChanged)));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.code == 'wrong_password' ? l10n.errorAdminWrongPassword : errorMessage(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.adminChangePassword),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _current,
              enabled: !_busy,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(labelText: l10n.adminPasswordCurrent),
              validator: (v) => (v ?? '').isEmpty ? l10n.errorRequired : null,
            ),
            const SizedBox(height: BSpace.s16),
            TextFormField(
              controller: _next,
              enabled: !_busy,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: l10n.adminPasswordNew,
                helperText: l10n.accountPasswordHelp,
              ),
              validator: (v) =>
                  (v ?? '').runes.length < 8 || v!.runes.length > 200 ? l10n.errorInvalidPassword : null,
            ),
            if (_error case final error?) ...[
              const SizedBox(height: BSpace.s16),
              Text(error, style: TextStyle(color: scheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _busy ? null : _submit, child: Text(l10n.commonSave)),
      ],
    );
  }
}

/// Asks for the administrator password again and returns the saved settings
/// as the text of a .env file.
class AdminExportSettingsDialog extends StatefulWidget {
  const AdminExportSettingsDialog({super.key, required this.api, required this.token});

  final AdminApi api;
  final String token;

  @override
  State<AdminExportSettingsDialog> createState() => _AdminExportSettingsDialogState();
}

class _AdminExportSettingsDialogState extends State<AdminExportSettingsDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final env = await widget.api.exportSettings(widget.token, _password.text);
      if (mounted) Navigator.pop(context, env);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.code == 'wrong_password' ? l10n.errorAdminWrongPassword : errorMessage(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.adminExport),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.adminExportBody),
            const SizedBox(height: BSpace.s16),
            TextFormField(
              controller: _password,
              enabled: !_busy,
              autofocus: true,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: l10n.adminPasswordCurrent,
                errorText: _error,
                errorMaxLines: 3,
              ),
              validator: (v) => (v ?? '').isEmpty ? l10n.errorRequired : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _busy ? null : _submit, child: Text(l10n.commonContinue)),
      ],
    );
  }
}
