import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
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

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await signOut(ref);
    if (context.mounted) context.go('/sign-in');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final account = ref.watch(accountProvider).value;
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
          subtitle: account.email,
          trailing: const Icon(Icons.edit_outlined),
          onTap: () => _rename(context, ref, account.name),
        ),
        if (account.hasPassword)
          GroupedTile(
            icon: Icons.password,
            title: l10n.passwordChange,
            onTap: () => showDialog<void>(context: context, builder: (_) => const _PasswordDialog()),
          ),
        GroupedTile(icon: Icons.logout, title: l10n.signOut, onTap: () => _signOut(context, ref)),
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
    if (!_form.currentState!.validate()) return;
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
