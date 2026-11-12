import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/grouped_list.dart';
import '../group/share_sheet.dart';

/// Two-step sign-in in Settings: an account that signs in with a password
/// may also ask for a code from an authenticator app, by email, or both.
class TwoFactorSection extends ConsumerWidget {
  const TwoFactorSection({super.key});

  Future<void> _totp(BuildContext context, WidgetRef ref, bool on) async {
    final l10n = context.l10n;
    if (!on) {
      final off = await showDialog<bool>(
        context: context,
        builder: (_) => _PasswordDialog(
          title: l10n.twoFactorTotp,
          body: l10n.twoFactorTotpOffBody,
          action: l10n.twoFactorTurnOff,
          run: (api, password) => api.disableTotp(password: password),
        ),
      );
      if (off == true) ref.invalidate(accountProvider);
      return;
    }
    final setup = await showDialog<TotpSetup>(
      context: context,
      builder: (_) => _PasswordDialog<TotpSetup>(
        title: l10n.twoFactorTotp,
        body: l10n.twoFactorConfirmBody,
        action: l10n.commonContinue,
        run: (api, password) => api.setupTotp(password: password),
      ),
    );
    if (setup == null || !context.mounted) return;
    final codes = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TotpDialog(setup: setup),
    );
    if (codes == null) return;
    ref.invalidate(accountProvider);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RecoveryCodesDialog(codes: codes),
    );
  }

  Future<void> _email(BuildContext context, WidgetRef ref, bool on) async {
    final l10n = context.l10n;
    final done = await showDialog<bool>(
      context: context,
      builder: (_) => _PasswordDialog(
        title: l10n.twoFactorEmail,
        body: l10n.twoFactorConfirmBody,
        action: on ? l10n.twoFactorTurnOn : l10n.twoFactorTurnOff,
        run: (api, password) => api.setEmailTwoFactor(on, password: password),
      ),
    );
    if (done == true) ref.invalidate(accountProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final account = ref.watch(currentAccountProvider).value;
    final passwords = ref.watch(serverInfoProvider.select((i) => i.value?.password ?? false));
    final email = ref.watch(serverInfoProvider.select((i) => i.value?.email ?? false));
    // The second step comes after a password: an account that signs in
    // through a provider alone has that provider's.
    if (account == null || !account.hasPassword || !passwords) return const SizedBox.shrink();
    final confirmed = account.email != null && account.emailVerified;
    return GroupedList(
      title: l10n.twoFactorTitle,
      children: [
        GroupedSwitchTile(
          icon: Icons.phonelink_lock_outlined,
          title: l10n.twoFactorTotp,
          subtitle: l10n.twoFactorTotpHelp,
          value: account.totp,
          onChanged: (on) => _totp(context, ref, on),
        ),
        if (email || account.emailTwoFactor)
          GroupedSwitchTile(
            icon: Icons.mark_email_read_outlined,
            title: l10n.twoFactorEmail,
            subtitle: !email
                ? l10n.errorEmailOff
                : confirmed
                ? l10n.twoFactorEmailHelp(account.email!)
                : l10n.errorEmailUnverified,
            value: account.emailTwoFactor,
            // It can always be turned off; on takes an address to send to.
            onChanged: account.emailTwoFactor || email && confirmed ? (on) => _email(context, ref, on) : null,
          ),
      ],
    );
  }
}

/// Confirms a change with the account's password and makes it: [run] sends
/// the request, and its answer closes the dialog.
class _PasswordDialog<T> extends ConsumerStatefulWidget {
  const _PasswordDialog({required this.title, required this.body, required this.action, required this.run});

  final String title;
  final String body;
  final String action;
  final Future<T> Function(BalnanaApi api, String password) run;

  @override
  ConsumerState<_PasswordDialog<T>> createState() => _PasswordDialogState<T>();
}

class _PasswordDialogState<T> extends ConsumerState<_PasswordDialog<T>> {
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
      final result = await widget.run(ref.read(balnanaApiProvider)!, _password.text);
      if (mounted) Navigator.pop(context, result is User ? true : result);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorMessage(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.body),
            const SizedBox(height: BSpace.s16),
            TextFormField(
              controller: _password,
              enabled: !_busy,
              autofocus: true,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: l10n.accountConfirmPassword,
                helperText: l10n.accountConfirmPasswordHelp,
                errorText: _error,
                errorMaxLines: 3,
              ),
              validator: (v) => (v ?? '').isEmpty ? l10n.errorRequired : null,
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _busy ? null : _submit, child: Text(widget.action)),
      ],
    );
  }
}

/// Shows the new key for the authenticator app, as a QR code and as text,
/// and turns the app on with a code from it. Returns the recovery codes.
class _TotpDialog extends ConsumerStatefulWidget {
  const _TotpDialog({required this.setup});

  final TotpSetup setup;

  @override
  ConsumerState<_TotpDialog> createState() => _TotpDialogState();
}

class _TotpDialogState extends ConsumerState<_TotpDialog> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
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
      final codes = await ref.read(balnanaApiProvider)!.confirmTotp(_code.text.trim());
      if (mounted) Navigator.pop(context, codes);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorMessage(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final secret = widget.setup.secret;
    // In fours, as authenticator apps show a key to type.
    final spaced = [for (var i = 0; i < secret.length; i += 4) secret.substring(i, (i + 4).clamp(0, secret.length))]
        .join(' ');
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.twoFactorTotp),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.twoFactorTotpScan),
              const SizedBox(height: BSpace.s16),
              Center(
                child: QrCodeView(data: widget.setup.uri, size: 200, semanticLabel: l10n.twoFactorTotp),
              ),
              const SizedBox(height: BSpace.s16),
              Row(
                children: [
                  Expanded(child: SelectableText(spaced, style: text.bodyMedium)),
                  IconButton(
                    tooltip: l10n.paymentDetailCopy,
                    icon: const Icon(Icons.copy),
                    onPressed: () => Clipboard.setData(ClipboardData(text: secret)),
                  ),
                ],
              ),
              const SizedBox(height: BSpace.s16),
              _CodeField(controller: _code, enabled: !_busy, error: _error, onSubmitted: _submit),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _busy ? null : _submit, child: Text(l10n.twoFactorTurnOn)),
      ],
    );
  }
}

/// The field a sign-in code is typed into.
class _CodeField extends StatelessWidget {
  const _CodeField({required this.controller, required this.enabled, this.error, this.onSubmitted});

  final TextEditingController controller;
  final bool enabled;
  final String? error;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      autofocus: true,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.number,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [LengthLimitingTextInputFormatter(32)],
      decoration: InputDecoration(labelText: l10n.twoFactorCode, errorText: error, errorMaxLines: 3),
      validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
    );
  }
}

/// The recovery codes, shown once: each signs in when the authenticator app
/// is not at hand.
class _RecoveryCodesDialog extends StatelessWidget {
  const _RecoveryCodesDialog({required this.codes});

  final List<String> codes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.twoFactorRecoveryTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.twoFactorRecoveryBody),
            const SizedBox(height: BSpace.s16),
            SelectableText(codes.join('\n'), textAlign: TextAlign.center, style: text.titleMedium),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: codes.join('\n')));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.twoFactorRecoveryCopied)));
          },
          child: Text(l10n.paymentDetailCopy),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonDone)),
      ],
    );
  }
}
