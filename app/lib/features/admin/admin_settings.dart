import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../ui/layout.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/form_page.dart';
import 'admin_page.dart';

/// Settings that are on or off; the server reads them as "true" or "false".
const _toggles = {'BALNANA_AUTH_PASSWORD', 'BALNANA_AUTH_REQUIRE_EMAIL', 'BALNANA_LINK_GROUPS'};

/// Settings picked from a few values.
const _choices = {'BALNANA_AUTH_MODE', 'BALNANA_AUTH_SIGNUP'};

/// The server's settings, as the administrator sees them. Only what changed
/// is sent, and the server takes all of it or nothing.
class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  Map<String, AdminSetting>? _settings;
  Object? _loadError;
  final _text = <String, TextEditingController>{};

  /// New values of toggles and choices.
  final _picked = <String, String>{};

  /// Saved secrets to remove on saving.
  final _removed = <String>{};

  /// Settings the server refused at the last save.
  var _invalid = <String>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  AdminApi get _api => ref.read(adminApiProvider)!;

  Future<void> _load() async {
    setState(() => _loadError = null);
    try {
      _show(await _api.settings(widget.token));
    } on ApiException catch (e) {
      if (!_signedOut(e) && mounted) setState(() => _loadError = e);
    }
  }

  /// Ends the admin session here when the server no longer knows it.
  bool _signedOut(ApiException e) {
    if (e.code != 'admin_required' || !mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorAdminRequired)));
    ref.read(adminTokenProvider.notifier).set(null);
    return true;
  }

  void _show(List<AdminSetting> settings) {
    if (!mounted) return;
    setState(() {
      _settings = {for (final s in settings) s.key: s};
      for (final s in settings) {
        if (_toggles.contains(s.key) || _choices.contains(s.key)) continue;
        (_text[s.key] ??= TextEditingController()).text = s.secret ? '' : s.value ?? '';
      }
      _picked.clear();
      _removed.clear();
      _invalid = {};
    });
  }

  /// What the form changes, by setting; an empty value returns a setting to
  /// its default.
  Map<String, String> get _changes {
    final settings = _settings ?? const {};
    final out = <String, String>{..._picked};
    for (final MapEntry(:key, value: c) in _text.entries) {
      final s = settings[key];
      if (s == null || s.locked) continue;
      final v = c.text.trim();
      if (s.secret) {
        if (v.isNotEmpty) {
          out[key] = v;
        } else if (_removed.contains(key)) {
          out[key] = '';
        }
      } else if (v != (s.value ?? '')) {
        out[key] = v;
      }
    }
    return out;
  }

  Future<void> _save() async {
    final changes = _changes;
    if (changes.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      _show(await _api.save(widget.token, changes));
      // This app follows the server's new mode and features too.
      ref.invalidate(serverInfoProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminSaved)));
    } on ApiException catch (e) {
      if (_signedOut(e) || !mounted) return;
      if (e.code == 'invalid_settings') {
        setState(() => _invalid = {...?(e.params['keys'] as List<Object?>?)?.whereType<String>()});
        messenger.showSnackBar(SnackBar(content: Text(l10n.adminSaveFailed)));
      } else {
        messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    final router = GoRouter.of(context);
    try {
      await _api.logout(widget.token);
    } on ApiException {
      // Forget the session here all the same.
    }
    ref.read(adminTokenProvider.notifier).set(null);
    router.go('/');
  }

  void _pick(String key, String value) {
    final s = _settings![key]!;
    setState(() {
      _invalid.remove(key);
      if (value == s.effective) {
        _picked.remove(key);
      } else {
        _picked[key] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = _settings;
    final dirty = settings != null && _changes.isNotEmpty;

    final Widget body;
    if (settings == null) {
      body = Center(
        child: _loadError == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(BSpace.s16),
                child: EmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.adminSettingsTitle,
                  body: errorMessage(l10n, _loadError!),
                  action: FilledButton(onPressed: _load, child: Text(l10n.commonRetry)),
                ),
              ),
      );
    } else {
      body = LayoutBuilder(
        builder: (context, constraints) {
          final side = math.max(BSpace.s16, (constraints.maxWidth - contentMaxWidth) / 2);
          return ListView(
            padding: EdgeInsets.fromLTRB(side, 0, side, BSpace.s32),
            children: _form(context, settings),
          );
        },
      );
    }

    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmDiscard(context)) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.adminSettingsTitle),
          actions: [
            IconButton(
              tooltip: l10n.adminChangePassword,
              icon: const Icon(Icons.key_outlined),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => _ChangePasswordDialog(api: _api, token: widget.token),
              ),
            ),
            IconButton(tooltip: l10n.adminSignOut, icon: const Icon(Icons.logout), onPressed: _signOut),
          ],
        ),
        body: body,
        bottomNavigationBar: settings == null
            ? null
            : SafeArea(
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: contentMaxWidth),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s8, BSpace.s16, BSpace.s16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _busy || !dirty ? null : _save,
                          child: _busy
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.commonSave),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _form(BuildContext context, Map<String, AdminSetting> settings) {
    final l10n = context.l10n;
    final publicUrl = settings['BALNANA_PUBLIC_URL']?.effective ?? '';
    String callback(String provider) => '$publicUrl$apiBasePath/auth/oauth/$provider/callback';
    const gap = SizedBox(height: BSpace.s16);
    // Only what the picked mode uses; hidden settings keep their values.
    String current(String key) => _picked[key] ?? settings[key]?.effective ?? '';
    final accounts = current('BALNANA_AUTH_MODE') == 'accounts';
    final passwords = current('BALNANA_AUTH_PASSWORD') == 'true';
    return [
      FormSection(l10n.adminSectionGeneral),
      _textField('BALNANA_PUBLIC_URL', keyboard: TextInputType.url),
      gap,
      _textField('BALNANA_SOURCE_URL', keyboard: TextInputType.url),
      FormSection(l10n.adminSectionAccess),
      _choice('BALNANA_AUTH_MODE', titled: false, {
        'link': (l10n.adminAuthModeLink, l10n.adminAuthModeLinkHelp),
        'accounts': (l10n.adminAuthModeAccounts, l10n.adminAuthModeAccountsHelp),
      }),
      if (accounts) ...[
        FormSection(l10n.adminSectionAccounts),
        _note(l10n.adminSectionAccountsBody),
        _toggle('BALNANA_AUTH_PASSWORD'),
        if (passwords) _toggle('BALNANA_AUTH_REQUIRE_EMAIL'),
        _toggle('BALNANA_LINK_GROUPS'),
        gap,
        _choice('BALNANA_AUTH_SIGNUP', {
          'open': (l10n.adminSignupOpen, null),
          'invite_only': (l10n.adminSignupInvite, null),
          'closed': (l10n.adminSignupClosed, null),
        }),
        FormSection(l10n.adminSectionEmail),
        _note(l10n.adminSectionEmailBody),
        _textField('BALNANA_SMTP_HOST', keyboard: TextInputType.url),
        gap,
        _textField('BALNANA_SMTP_PORT', keyboard: TextInputType.number),
        gap,
        _textField('BALNANA_SMTP_USER'),
        gap,
        _textField('BALNANA_SMTP_PASSWORD'),
        gap,
        _textField('BALNANA_SMTP_FROM', hint: l10n.adminSmtpFromHint),
        FormSection(l10n.adminSectionGoogle),
        _note(l10n.adminSectionGoogleBody(callback('google'))),
        _textField('BALNANA_OAUTH_GOOGLE_CLIENT_ID'),
        gap,
        _textField('BALNANA_OAUTH_GOOGLE_SECRET'),
        FormSection(l10n.adminSectionOidc),
        _note(l10n.adminSectionOidcBody(callback('oidc'))),
        _textField('BALNANA_OAUTH_OIDC_ISSUER', keyboard: TextInputType.url),
        gap,
        _textField('BALNANA_OAUTH_OIDC_CLIENT_ID'),
        gap,
        _textField('BALNANA_OAUTH_OIDC_SECRET'),
        gap,
        _textField('BALNANA_OAUTH_OIDC_NAME'),
      ],
      FormSection(l10n.adminSectionAndroid),
      _note(l10n.adminSectionAndroidBody),
      _textField('BALNANA_ANDROID_CERT_SHA256', maxLines: 3),
    ];
  }

  Widget _note(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(BSpace.s4, 0, BSpace.s4, BSpace.s16),
      child: SelectableText(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  /// A text or secret setting.
  Widget _textField(String key, {TextInputType? keyboard, int maxLines = 1, String? hint}) {
    final l10n = context.l10n;
    final s = _settings![key];
    final controller = _text[key];
    if (s == null || controller == null) return const SizedBox.shrink();
    final removing = _removed.contains(key);
    String? helper = s.locked ? l10n.adminLocked(key) : _help(l10n, key);
    if (s.secret && !s.locked && s.set && controller.text.isEmpty) {
      helper = removing ? l10n.adminSecretRemoved : l10n.adminSecretSaved;
    }
    return TextField(
      controller: controller,
      enabled: !_busy && !s.locked,
      obscureText: s.secret,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: keyboard,
      minLines: 1,
      maxLines: s.secret ? 1 : maxLines,
      onChanged: (_) => setState(() => _invalid.remove(key)),
      decoration: InputDecoration(
        labelText: _label(l10n, key),
        hintText: hint ?? (s.defaultValue.isEmpty ? null : l10n.adminDefault(s.defaultValue)),
        // An empty field means the default; show it without waiting for focus.
        floatingLabelBehavior: hint != null || s.defaultValue.isNotEmpty
            ? FloatingLabelBehavior.always
            : null,
        helperText: helper,
        helperMaxLines: 4,
        errorText: _invalid.contains(key) ? _problem(l10n, key) : null,
        errorMaxLines: 4,
        suffixIcon: s.secret && s.set && !s.locked
            ? IconButton(
                tooltip: l10n.adminSecretRemove,
                isSelected: removing,
                icon: const Icon(Icons.delete_outline),
                selectedIcon: const Icon(Icons.delete),
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        controller.clear();
                        removing ? _removed.remove(key) : _removed.add(key);
                      }),
              )
            : null,
      ),
    );
  }

  Widget _toggle(String key) {
    final l10n = context.l10n;
    final s = _settings![key];
    if (s == null) return const SizedBox.shrink();
    final value = (_picked[key] ?? s.effective) == 'true';
    final scheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: BSpace.s4),
      title: Text(_label(l10n, key)),
      subtitle: Text(
        _invalid.contains(key)
            ? _problem(l10n, key)
            : s.locked
            ? l10n.adminLocked(key)
            : _help(l10n, key) ?? '',
        style: _invalid.contains(key) ? TextStyle(color: scheme.error) : null,
      ),
      value: value,
      onChanged: _busy || s.locked ? null : (v) => _pick(key, '$v'),
    );
  }

  /// A setting picked from [options]: value to label and optional help.
  /// [titled] false leaves the label to the section heading above.
  Widget _choice(String key, Map<String, (String, String?)> options, {bool titled = true}) {
    final l10n = context.l10n;
    final s = _settings![key];
    if (s == null) return const SizedBox.shrink();
    final value = _picked[key] ?? s.effective;
    final theme = Theme.of(context);
    final note = _invalid.contains(key)
        ? _problem(l10n, key)
        : s.locked
        ? l10n.adminLocked(key)
        : options[value]?.$2 ?? _help(l10n, key);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (titled)
          Padding(
            padding: const EdgeInsets.fromLTRB(BSpace.s4, 0, BSpace.s4, BSpace.s8),
            child: Text(_label(l10n, key), style: theme.textTheme.titleMedium),
          ),
        SegmentedButton<String>(
          segments: [
            for (final MapEntry(key: v, value: (label, _)) in options.entries)
              ButtonSegment(value: v, label: Text(label)),
          ],
          selected: {value},
          showSelectedIcon: false,
          onSelectionChanged: _busy || s.locked ? null : (picked) => _pick(key, picked.first),
        ),
        if (note != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(BSpace.s4, BSpace.s8, BSpace.s4, 0),
            child: Text(
              note,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _invalid.contains(key) ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

Future<bool> _confirmDiscard(BuildContext context) async {
  final l10n = context.l10n;
  final discard = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.adminDiscardTitle),
      content: Text(l10n.adminDiscardBody),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.adminDiscard)),
      ],
    ),
  );
  return discard ?? false;
}

String _label(AppLocalizations l10n, String key) => switch (key) {
  'BALNANA_PUBLIC_URL' => l10n.adminPublicUrl,
  'BALNANA_SOURCE_URL' => l10n.adminSourceUrl,
  'BALNANA_AUTH_MODE' => l10n.adminAuthMode,
  'BALNANA_AUTH_PASSWORD' => l10n.adminPasswordLogin,
  'BALNANA_AUTH_REQUIRE_EMAIL' => l10n.adminRequireEmail,
  'BALNANA_AUTH_SIGNUP' => l10n.adminSignup,
  'BALNANA_LINK_GROUPS' => l10n.adminLinkGroups,
  'BALNANA_SMTP_HOST' => l10n.adminSmtpHost,
  'BALNANA_SMTP_PORT' => l10n.adminSmtpPort,
  'BALNANA_SMTP_USER' => l10n.adminSmtpUser,
  'BALNANA_SMTP_PASSWORD' => l10n.adminSmtpPassword,
  'BALNANA_SMTP_FROM' => l10n.adminSmtpFrom,
  'BALNANA_OAUTH_GOOGLE_CLIENT_ID' || 'BALNANA_OAUTH_OIDC_CLIENT_ID' => l10n.adminClientId,
  'BALNANA_OAUTH_GOOGLE_SECRET' || 'BALNANA_OAUTH_OIDC_SECRET' => l10n.adminClientSecret,
  'BALNANA_OAUTH_OIDC_ISSUER' => l10n.adminOidcIssuer,
  'BALNANA_OAUTH_OIDC_NAME' => l10n.adminOidcName,
  'BALNANA_ANDROID_CERT_SHA256' => l10n.adminFingerprints,
  _ => key,
};

String? _help(AppLocalizations l10n, String key) => switch (key) {
  'BALNANA_PUBLIC_URL' => l10n.adminPublicUrlHelp,
  'BALNANA_SOURCE_URL' => l10n.adminSourceUrlHelp,
  'BALNANA_AUTH_SIGNUP' => l10n.adminSignupHelp,
  'BALNANA_AUTH_REQUIRE_EMAIL' => l10n.adminRequireEmailHelp,
  'BALNANA_LINK_GROUPS' => l10n.adminLinkGroupsHelp,
  'BALNANA_OAUTH_OIDC_NAME' => l10n.adminOidcNameHelp,
  'BALNANA_ANDROID_CERT_SHA256' => l10n.adminFingerprintsHelp,
  _ => null,
};

/// Why the server refused a setting.
String _problem(AppLocalizations l10n, String key) => switch (key) {
  'BALNANA_PUBLIC_URL' || 'BALNANA_SOURCE_URL' || 'BALNANA_OAUTH_OIDC_ISSUER' => l10n.adminInvalidUrl,
  'BALNANA_SMTP_FROM' => l10n.adminInvalidFrom,
  'BALNANA_SMTP_PORT' => l10n.adminInvalidPort,
  'BALNANA_OAUTH_GOOGLE_SECRET' ||
  'BALNANA_OAUTH_OIDC_CLIENT_ID' ||
  'BALNANA_OAUTH_OIDC_SECRET' => l10n.adminInvalidRequired,
  'BALNANA_AUTH_MODE' => l10n.adminNeedsSignIn,
  'BALNANA_ANDROID_CERT_SHA256' => l10n.adminInvalidFingerprint,
  _ => l10n.adminInvalidValue,
};

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({required this.api, required this.token});

  final AdminApi api;
  final String token;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
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
    if (!_form.currentState!.validate()) return;
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
