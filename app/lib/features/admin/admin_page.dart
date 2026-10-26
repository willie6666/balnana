import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/api.dart';
import '../../ui/layout.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import 'admin_settings.dart';

/// The administrator's API on the chosen server, without the account's
/// session.
final adminApiProvider = Provider<AdminApi?>((ref) {
  final url = ref.watch(serverUrlProvider);
  if (url == null) return null;
  final dio = plainDio(url);
  ref.onDispose(dio.close);
  return AdminApi(dio);
});

/// The administrator session on the chosen server. It lives in memory only,
/// so reloading the page or restarting the app asks for the password again.
final adminTokenProvider = NotifierProvider<AdminTokenNotifier, String?>(AdminTokenNotifier.new);

class AdminTokenNotifier extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(serverUrlProvider);
    return null;
  }

  void set(String? token) => state = token;
}

/// /admin: nothing links here. A new server sends everyone here until its
/// administrator password is set; afterwards it asks for that password and
/// shows the server's settings.
class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final info = ref.watch(serverInfoProvider);
    final token = ref.watch(adminTokenProvider);
    if (token != null) return AdminSettingsPage(token: token);
    if (info.value case final value?) {
      return _PasswordPage(
        key: ValueKey(value.setupRequired),
        setup: value.setupRequired,
        code: value.setupCode,
      );
    }
    return switch (info) {
      AsyncValue(:final error?) when !info.isLoading => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(BSpace.s16),
            child: EmptyState(
              icon: Icons.cloud_off_outlined,
              title: l10n.adminLoginTitle,
              body: errorMessage(l10n, error),
              action: FilledButton(
                onPressed: () => ref.invalidate(serverInfoProvider),
                child: Text(l10n.commonRetry),
              ),
            ),
          ),
        ),
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

/// Sets the password on a new server ([setup]), or signs in with it.
class _PasswordPage extends ConsumerStatefulWidget {
  const _PasswordPage({super.key, required this.setup, required this.code});

  final bool setup;

  /// Setup also asks for the code from the server's log.
  final bool code;

  @override
  ConsumerState<_PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends ConsumerState<_PasswordPage> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  final _code = TextEditingController();
  bool _show = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final api = ref.read(adminApiProvider);
    if (api == null) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final token = widget.setup
          ? await api.setup(password: _password.text, code: widget.code ? _code.text.trim() : null)
          : await api.login(_password.text);
      if (!mounted) return;
      TextInput.finishAutofillContext();
      if (widget.setup) ref.invalidate(serverInfoProvider);
      ref.read(adminTokenProvider.notifier).set(token);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'already_set_up' || e.code == 'setup_required') ref.invalidate(serverInfoProvider);
      setState(() {
        _busy = false;
        _error = e.code == 'invalid_credentials' ? l10n.errorAdminWrongPassword : errorMessage(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final setup = widget.setup;

    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = math.max(BSpace.s16, (constraints.maxWidth - formMaxWidth) / 2);
          return AutofillGroup(
            child: Form(
              key: _form,
              child: ListView(
                padding: EdgeInsets.fromLTRB(side, BSpace.s8, side, BSpace.s32),
                children: [
                  Icon(
                    setup ? Icons.admin_panel_settings_outlined : Icons.lock_outline,
                    size: 48,
                    color: scheme.primary,
                  ),
                  const SizedBox(height: BSpace.s16),
                  Text(setup ? l10n.adminSetupTitle : l10n.adminLoginTitle, style: text.headlineMedium),
                  const SizedBox(height: BSpace.s8),
                  Text(
                    setup ? l10n.adminSetupBody : l10n.adminLoginBody,
                    style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: BSpace.s24),
                  if (setup && widget.code) ...[
                    TextFormField(
                      controller: _code,
                      enabled: !_busy,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.adminSetupCode,
                        helperText: l10n.adminSetupCodeHelp,
                        helperMaxLines: 4,
                      ),
                      validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
                    ),
                    const SizedBox(height: BSpace.s16),
                  ],
                  TextFormField(
                    controller: _password,
                    enabled: !_busy,
                    obscureText: !_show,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: setup ? TextInputAction.next : TextInputAction.done,
                    autofillHints: [setup ? AutofillHints.newPassword : AutofillHints.password],
                    onFieldSubmitted: setup ? null : (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: l10n.adminPassword,
                      helperText: setup ? l10n.accountPasswordHelp : null,
                      suffixIcon: IconButton(
                        tooltip: _show ? l10n.passwordHide : l10n.passwordShow,
                        icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _show = !_show),
                      ),
                    ),
                    validator: (v) {
                      if ((v ?? '').isEmpty) return l10n.errorRequired;
                      final n = v!.runes.length;
                      return setup && (n < 8 || n > 200) ? l10n.errorInvalidPassword : null;
                    },
                  ),
                  if (setup) ...[
                    const SizedBox(height: BSpace.s16),
                    TextFormField(
                      controller: _repeat,
                      enabled: !_busy,
                      obscureText: !_show,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(labelText: l10n.adminPasswordRepeat),
                      validator: (v) => v == _password.text ? null : l10n.adminPasswordMismatch,
                    ),
                  ],
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
                        : Text(setup ? l10n.adminSetupAction : l10n.adminLoginAction),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
