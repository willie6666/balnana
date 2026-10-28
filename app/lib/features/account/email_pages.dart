import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/layout.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import 'sign_in_page.dart';

/// The pages that links in emails open: confirming an address, choosing a new
/// password and accepting an invitation.

class _LinkScaffold extends StatelessWidget {
  const _LinkScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: CloseButton(onPressed: () => context.go('/groups'))),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final side = math.max(BSpace.s16, (constraints.maxWidth - formMaxWidth) / 2);
        return ListView(padding: EdgeInsets.fromLTRB(side, BSpace.s8, side, BSpace.s32), children: [child]);
      },
    ),
  );
}

Widget _centered(Widget child) => Padding(
  padding: const EdgeInsets.only(top: BSpace.s48),
  child: Center(child: child),
);

/// Opened from the confirmation email: confirms the address right away.
class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  late final Future<void> _verified = _verify();

  Future<void> _verify() async {
    try {
      await ref.read(balnanaApiProvider)!.verifyEmail(widget.token);
    } on ApiException catch (e) {
      // Opening the link twice is fine once the address is confirmed.
      final account = await ref.read(accountProvider.future).catchError((_) => null);
      if (e.code != 'invalid_token' || account?.emailVerified != true) rethrow;
    }
    ref.invalidate(accountProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _LinkScaffold(
      child: FutureBuilder(
        future: _verified,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _centered(const CircularProgressIndicator());
          }
          final error = snapshot.error;
          return _centered(
            EmptyState(
              icon: error == null ? Icons.mark_email_read_outlined : Icons.link_off,
              title: error == null ? l10n.verifyEmailDone : l10n.verifyEmailFailed,
              body: error == null ? l10n.verifyEmailDoneBody : errorMessage(l10n, error),
              action: FilledButton(onPressed: () => context.go('/groups'), child: Text(l10n.commonContinue)),
            ),
          );
        },
      ),
    );
  }
}

/// Opened from the password reset email.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _show = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
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
      await ref.read(balnanaApiProvider)!.resetPassword(token: widget.token, password: _password.text);
      if (!mounted) return;
      TextInput.finishAutofillContext();
      // Every session of the account just ended, perhaps this one too.
      ref.invalidate(accountProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.resetPasswordDone)));
      context.go('/sign-in');
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
    final scheme = Theme.of(context).colorScheme;
    return _LinkScaffold(
      child: AutofillGroup(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.resetPasswordTitle, style: text.headlineMedium),
              const SizedBox(height: BSpace.s8),
              Text(l10n.resetPasswordBody, style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: BSpace.s24),
              TextFormField(
                controller: _password,
                enabled: !_busy,
                autofocus: true,
                obscureText: !_show,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  labelText: l10n.passwordNew,
                  helperText: l10n.accountPasswordHelp,
                  suffixIcon: IconButton(
                    tooltip: _show ? l10n.passwordHide : l10n.passwordShow,
                    icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _show = !_show),
                  ),
                ),
                validator: (v) => (v ?? '').runes.length < 8 ? l10n.errorInvalidPassword : null,
              ),
              if (_error case final error?) ...[
                const SizedBox(height: BSpace.s16),
                Text(error, style: text.bodyMedium?.copyWith(color: scheme.error)),
              ],
              const SizedBox(height: BSpace.s24),
              FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.resetPasswordAction)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks for an address and emails it a password reset link.
Future<void> showForgotPasswordDialog(BuildContext context, {String? email}) =>
    showDialog<void>(context: context, builder: (_) => _ForgotPasswordDialog(email: email));

class _ForgotPasswordDialog extends ConsumerStatefulWidget {
  const _ForgotPasswordDialog({this.email});

  final String? email;

  @override
  ConsumerState<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<_ForgotPasswordDialog> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.email);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(balnanaApiProvider)!.requestPasswordReset(_email.text.trim());
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.forgotPasswordSent)));
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
      title: Text(l10n.forgotPasswordTitle),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.forgotPasswordBody),
            const SizedBox(height: BSpace.s16),
            TextFormField(
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(labelText: l10n.accountEmail, errorText: _error, errorMaxLines: 3),
              validator: (v) => (v ?? '').contains('@') ? null : l10n.errorInvalidEmail,
              onFieldSubmitted: (_) => _send(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _busy ? null : _send, child: Text(l10n.forgotPasswordAction)),
      ],
    );
  }
}

final _inviteProvider = FutureProvider.autoDispose.family<InviteInfo, String>(
  (ref, token) => ref.watch(balnanaApiProvider)!.invite(token),
);

/// Opened from an invitation email: says who invited whom where, then signs
/// in or creates the account and goes on to join the group.
class InvitePage extends ConsumerWidget {
  const InvitePage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(_inviteProvider(token));
    final account = ref.watch(currentAccountProvider);
    final invite = async.value;

    final Widget child;
    if (invite == null || account.isLoading) {
      final error = async.error;
      child = error == null || async.isLoading
          ? const CircularProgressIndicator()
          : EmptyState(
              icon: Icons.link_off,
              title: l10n.inviteMissingTitle,
              body: error is ApiException && error.isNotFound ? l10n.inviteMissingBody : errorMessage(l10n, error),
              action: FilledButton.tonal(onPressed: () => context.go('/groups'), child: Text(l10n.commonContinue)),
            );
    } else {
      final join = '/g/${invite.groupToken}/join';
      final title = invite.invitedBy == null
          ? l10n.inviteTitleAnonymous(invite.groupName)
          : l10n.inviteTitle(invite.invitedBy!, invite.groupName);
      child = account.value != null
          ? EmptyState(
              icon: Icons.group_add_outlined,
              title: title,
              body: l10n.inviteBodySignedIn,
              action: FilledButton(onPressed: () => context.go(join), child: Text(l10n.inviteAction)),
            )
          : EmptyState(
              icon: Icons.group_add_outlined,
              title: title,
              body: l10n.inviteBody(invite.email),
              action: Wrap(
                spacing: BSpace.s8,
                runSpacing: BSpace.s8,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () => context.go(
                      signInPath(join),
                      extra: SignInPrefill(email: invite.email, invite: token, register: true),
                    ),
                    child: Text(l10n.registerAction),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go(signInPath(join), extra: SignInPrefill(email: invite.email)),
                    child: Text(l10n.signIn),
                  ),
                ],
              ),
            );
    }
    return _LinkScaffold(child: _centered(child));
  }
}

/// Where an account waits while the server needs its address confirmed:
/// everything but its settings stays closed until then.
class ConfirmEmailPage extends ConsumerStatefulWidget {
  const ConfirmEmailPage({super.key, this.next});

  final String? next;

  @override
  ConsumerState<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends ConsumerState<ConfirmEmailPage> {
  bool _busy = false;

  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _send(String email) async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await ref.read(balnanaApiProvider)!.sendVerifyEmail();
      if (mounted) _snack(l10n.verifyEmailSent(email));
    } on ApiException catch (e) {
      if (mounted) _snack(errorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Looks again; the router moves on once the address is confirmed.
  Future<void> _check() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    ref.invalidate(accountProvider);
    try {
      final account = await ref.read(accountProvider.future);
      if (mounted && account?.emailVerified != true) _snack(l10n.confirmEmailNotYet);
    } on ApiException catch (e) {
      if (mounted) _snack(errorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = ref.watch(currentAccountProvider).value?.email ?? '';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(BSpace.s16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: formMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EmptyState(
                    icon: Icons.mark_email_unread_outlined,
                    title: l10n.confirmEmailTitle,
                    body: l10n.confirmEmailBody(email),
                  ),
                  const SizedBox(height: BSpace.s24),
                  FilledButton(onPressed: _busy ? null : _check, child: Text(l10n.confirmEmailDone)),
                  const SizedBox(height: BSpace.s8),
                  OutlinedButton(
                    onPressed: _busy || email.isEmpty ? null : () => _send(email),
                    child: Text(l10n.confirmEmailResend),
                  ),
                  const SizedBox(height: BSpace.s8),
                  TextButton(onPressed: () => context.go('/settings'), child: Text(l10n.navSettings)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
