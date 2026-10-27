import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/grouped_list.dart';
import '../group/identity_sheet.dart';

/// The signed-in account in Settings (accounts mode).
class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  void _snack(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _rename(BuildContext context, WidgetRef ref, String current) async {
    final l10n = context.l10n;
    final name = await askForName(
      context,
      title: l10n.accountRename,
      action: l10n.commonSave,
      initial: current,
    );
    if (name == null || name == current || !context.mounted) return;
    try {
      await ref.read(balnanaApiProvider)!.updateMe(name: name);
      ref.invalidate(accountProvider);
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, errorMessage(l10n, e));
    }
  }

  Future<void> _sendVerify(BuildContext context, WidgetRef ref, String email) async {
    final l10n = context.l10n;
    try {
      await ref.read(balnanaApiProvider)!.sendVerifyEmail();
      if (context.mounted) _snack(context, l10n.verifyEmailSent(email));
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, errorMessage(l10n, e));
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await signOut(ref);
    if (context.mounted) context.go('/sign-in');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final account = ref.watch(accountProvider).value;
    final email = ref.watch(serverInfoProvider.select((i) => i.value?.email ?? false));
    if (account == null) {
      return GroupedList(
        title: l10n.settingsAccount,
        children: [
          GroupedTile(
            icon: Icons.login,
            title: l10n.signIn,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/sign-in'),
          ),
        ],
      );
    }
    return GroupedList(
      title: l10n.settingsAccount,
      children: [
        GroupedTile(
          icon: Icons.account_circle_outlined,
          title: account.name,
          subtitle: account.email ?? account.username,
          trailing: const Icon(Icons.edit_outlined),
          onTap: () => _rename(context, ref, account.name),
        ),
        if (account.pendingEmail case final pending? when email)
          GroupedTile(
            icon: Icons.mark_email_unread_outlined,
            title: l10n.accountEmailPendingTitle,
            subtitle: l10n.accountEmailPendingHelp(pending),
            onTap: () => _sendVerify(context, ref, pending),
          )
        else if (email && !account.emailVerified && account.email != null)
          GroupedTile(
            icon: Icons.mark_email_unread_outlined,
            title: l10n.verifyEmailTitle,
            subtitle: l10n.verifyEmailHelp,
            onTap: () => _sendVerify(context, ref, account.email!),
          ),
        GroupedTile(
          icon: Icons.alternate_email,
          title: account.email == null ? l10n.accountEmailAdd : l10n.accountEmailChange,
          onTap: () => showDialog<void>(context: context, builder: (_) => _EmailDialog(account: account)),
        ),
        if (account.hasPassword)
          GroupedTile(
            icon: Icons.password,
            title: l10n.passwordChange,
            onTap: () => showDialog<void>(context: context, builder: (_) => const _PasswordDialog()),
          ),
        GroupedTile(icon: Icons.logout, title: l10n.signOut, onTap: () => _signOut(context, ref)),
        GroupedTile(
          icon: Icons.delete_forever_outlined,
          title: l10n.accountDelete,
          subtitle: l10n.accountDeleteHelp,
          onTap: () => deleteAccount(context, ref),
        ),
      ],
    );
  }
}

/// Asks to confirm, deletes the signed-in account and goes to the sign-in
/// page.
Future<void> deleteAccount(BuildContext context, WidgetRef ref) async {
  final account = ref.read(accountProvider).value;
  if (account == null) return;
  final deleted = await showDialog<bool>(
    context: context,
    builder: (_) => _DeleteAccountDialog(askPassword: account.hasPassword),
  );
  if (deleted != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final done = context.l10n.accountDeleted;
  // The server ended the session with the account.
  startSession(ref, null);
  context.go('/sign-in');
  messenger.showSnackBar(SnackBar(content: Text(done)));
}

/// The password field of a dialog that confirms a change with it.
class _ConfirmPassword extends StatelessWidget {
  const _ConfirmPassword({required this.controller, this.error, this.onSubmitted, this.autofocus = false});

  final TextEditingController controller;
  final String? error;
  final VoidCallback? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      obscureText: true,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: l10n.accountConfirmPassword,
        helperText: l10n.accountConfirmPasswordHelp,
        errorText: error,
        errorMaxLines: 3,
      ),
      validator: (v) => (v ?? '').isEmpty ? l10n.errorRequired : null,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
    );
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog({required this.askPassword});

  final bool askPassword;

  @override
  ConsumerState<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_busy || !_form.currentState!.validate()) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(balnanaApiProvider)!.deleteMe(password: widget.askPassword ? _password.text : null);
      if (mounted) Navigator.of(context).pop(true);
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
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: const Icon(Icons.delete_forever_outlined),
      title: Text(l10n.accountDeleteTitle),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.accountDeleteBody),
            if (widget.askPassword) ...[
              const SizedBox(height: BSpace.s16),
              _ConfirmPassword(controller: _password, error: _error, onSubmitted: _delete, autofocus: true),
            ] else if (_error case final error?) ...[
              const SizedBox(height: BSpace.s16),
              Text(error, style: TextStyle(color: scheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
          onPressed: _busy ? null : _delete,
          child: Text(l10n.accountDeleteAction),
        ),
      ],
    );
  }
}

/// Adds, changes or (for accounts with a username) removes the address.
class _EmailDialog extends ConsumerStatefulWidget {
  const _EmailDialog({required this.account});

  final User account;

  @override
  ConsumerState<_EmailDialog> createState() => _EmailDialogState();
}

class _EmailDialogState extends ConsumerState<_EmailDialog> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.account.email);
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  /// The password was wrong, so the error goes under that field.
  bool _passwordError = false;

  bool get _canRemove => widget.account.username != null;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    final l10n = context.l10n;
    final email = _email.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final me = await ref
          .read(balnanaApiProvider)!
          .changeEmail(email, password: widget.account.hasPassword ? _password.text : null);
      if (!mounted) return;
      ref.invalidate(accountProvider);
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      // A new address waits for its link before it takes the old one's place.
      final done = switch (me.pendingEmail) {
        final pending? => l10n.verifyEmailSent(pending),
        null when email.isEmpty => l10n.accountEmailRemoved,
        null => l10n.accountEmailSaved,
      };
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorMessage(l10n, e);
        _passwordError = e.code == 'wrong_password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = ref.watch(serverInfoProvider.select((i) => i.value?.email ?? false));
    return AlertDialog(
      title: Text(widget.account.email == null ? l10n.accountEmailAdd : l10n.accountEmailChange),
      content: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _email,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: l10n.accountEmailNew,
                  helperText: [
                    if (email) l10n.accountEmailVerifyNote,
                    if (_canRemove) l10n.accountEmailRemoveNote,
                  ].join(' '),
                  helperMaxLines: 4,
                  errorText: _passwordError ? null : _error,
                  errorMaxLines: 3,
                ),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return _canRemove ? null : l10n.errorRequired;
                  return value.contains('@') ? null : l10n.errorInvalidEmail;
                },
                onFieldSubmitted: widget.account.hasPassword ? null : (_) => _save(),
              ),
              if (widget.account.hasPassword) ...[
                const SizedBox(height: BSpace.s16),
                _ConfirmPassword(controller: _password, error: _passwordError ? _error : null, onSubmitted: _save),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.commonSave)),
      ],
    );
  }
}

class _PasswordDialog extends ConsumerStatefulWidget {
  const _PasswordDialog();

  @override
  ConsumerState<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends ConsumerState<_PasswordDialog> {
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

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(balnanaApiProvider)!.changePassword(current: _current.text, next: _next.text);
      if (!mounted) return;
      TextInput.finishAutofillContext();
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.passwordChanged)));
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
      title: Text(l10n.passwordChange),
      content: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _current,
                autofocus: true,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(labelText: l10n.passwordCurrent),
                validator: (v) => (v ?? '').isEmpty ? l10n.errorRequired : null,
              ),
              const SizedBox(height: BSpace.s16),
              TextFormField(
                controller: _next,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  labelText: l10n.passwordNew,
                  helperText: l10n.accountPasswordHelp,
                  errorText: _error,
                  errorMaxLines: 3,
                ),
                validator: (v) => (v ?? '').runes.length < 8 ? l10n.errorInvalidPassword : null,
                onFieldSubmitted: (_) => _save(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.commonSave)),
      ],
    );
  }
}
