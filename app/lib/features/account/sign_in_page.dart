import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/api.dart';
import '../../data/providers.dart';
import '../../ui/layout.dart';
import '../../ui/tokens.dart';
import 'email_pages.dart';
import 'oauth.dart';

/// The sign-in page, coming back to [next] afterwards.
String signInPath(String next) => Uri(path: '/sign-in', queryParameters: {'next': next}).toString();

/// [next] when it is a path inside this app, else null; a link must not be
/// able to send someone elsewhere after signing in.
String? safeNext(String? next) {
  if (next == null || !next.startsWith('/') || next.startsWith('//') || next.startsWith('/sign-in')) return null;
  return next;
}

/// What an invitation fills in on the sign-in page. It travels as the
/// route's extra, so the address never shows in the location bar.
class SignInPrefill {
  const SignInPrefill({this.email, this.invite, this.register = false});

  final String? email;

  /// The invitation token, which lets the address sign up and verifies it.
  final String? invite;
  final bool register;
}

/// Sign in, or create an account (accounts mode).
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key, this.next, this.prefill});

  final String? next;
  final SignInPrefill? prefill;

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  late final _email = TextEditingController(text: widget.prefill?.email);
  final _password = TextEditingController();
  late bool _register = widget.prefill?.register ?? false;
  bool _showPassword = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final api = ref.read(balnanaApiProvider);
    if (api == null) return;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final (token, _) = _register
          ? await api.register(
              email: _email.text.trim(),
              password: _password.text,
              name: _name.text.trim(),
              locale: locale,
              invite: widget.prefill?.invite,
            )
          : await api.login(email: _email.text.trim(), password: _password.text);
      if (!mounted) return;
      TextInput.finishAutofillContext();
      // Whether a first account may still sign up has changed.
      if (_register) ref.invalidate(serverInfoProvider);
      startSession(ref, token);
      context.go(safeNext(widget.next) ?? '/groups');
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
    final info = ref.watch(serverInfoProvider).value;
    final passwords = info?.password ?? true;
    final canRegister =
        info?.signup != SignupPolicy.closed || (info?.firstAccount ?? false) || widget.prefill?.invite != null;
    final canReset = info?.email ?? false;
    final providers = info?.oauthProviders ?? const <OAuthProvider>[];

    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = math.max(BSpace.s16, (constraints.maxWidth - formMaxWidth) / 2);
          return ListView(
            padding: EdgeInsets.fromLTRB(side, BSpace.s8, side, BSpace.s32),
            children: [
              Text(_register ? l10n.registerTitle : l10n.signInTitle, style: text.headlineMedium),
              const SizedBox(height: BSpace.s8),
              Text(
                _register ? l10n.registerBody : l10n.signInBody,
                style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: BSpace.s24),
              for (final provider in providers) ...[
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => startOAuth(ref, provider, safeNext(widget.next) ?? '/groups'),
                  icon: const Icon(Icons.login),
                  label: Text(l10n.signInWith(provider.name)),
                ),
                const SizedBox(height: BSpace.s8),
              ],
              if (providers.isNotEmpty && passwords) ...[
                const SizedBox(height: BSpace.s8),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: BSpace.s16),
                      child: Text(l10n.signInOr, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: BSpace.s16),
              ],
              if (!passwords && providers.isEmpty)
                Text(l10n.signInNoPassword, style: text.bodyLarge)
              else if (passwords)
                AutofillGroup(
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_register) ...[
                          TextFormField(
                            controller: _name,
                            enabled: !_busy,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            inputFormatters: [LengthLimitingTextInputFormatter(100)],
                            decoration: InputDecoration(
                              labelText: l10n.accountName,
                              helperText: l10n.accountNameHelp,
                            ),
                            validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
                          ),
                          const SizedBox(height: BSpace.s16),
                        ],
                        TextFormField(
                          controller: _email,
                          enabled: !_busy,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(labelText: l10n.accountEmail),
                          validator: (v) => (v ?? '').contains('@') ? null : l10n.errorInvalidEmail,
                        ),
                        const SizedBox(height: BSpace.s16),
                        TextFormField(
                          controller: _password,
                          enabled: !_busy,
                          obscureText: !_showPassword,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          autofillHints: [_register ? AutofillHints.newPassword : AutofillHints.password],
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: l10n.accountPassword,
                            helperText: _register ? l10n.accountPasswordHelp : null,
                            suffixIcon: IconButton(
                              tooltip: _showPassword ? l10n.passwordHide : l10n.passwordShow,
                              icon: Icon(
                                _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            ),
                          ),
                          validator: (v) {
                            if ((v ?? '').isEmpty) return l10n.errorRequired;
                            if (_register && v!.runes.length < 8) return l10n.errorInvalidPassword;
                            return null;
                          },
                        ),
                        if (_error case final error?) ...[
                          const SizedBox(height: BSpace.s16),
                          Text(error, style: text.bodyMedium?.copyWith(color: scheme.error)),
                        ],
                        const SizedBox(height: BSpace.s24),
                        FilledButton(
                          onPressed: _busy ? null : _submit,
                          child: _busy
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_register ? l10n.registerAction : l10n.signIn),
                        ),
                        if (canReset && !_register) ...[
                          const SizedBox(height: BSpace.s8),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => showForgotPasswordDialog(context, email: _email.text.trim()),
                            child: Text(l10n.forgotPasswordTitle),
                          ),
                        ],
                        if (canRegister || _register) ...[
                          const SizedBox(height: BSpace.s8),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => setState(() {
                                    _register = !_register;
                                    _error = null;
                                  }),
                            child: Text(_register ? l10n.registerHaveAccount : l10n.signInNoAccount),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
