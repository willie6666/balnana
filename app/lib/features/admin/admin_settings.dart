import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
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
import 'admin_payments_page.dart';
import 'admin_plans_page.dart';
import 'admin_users_page.dart';

/// Settings that are on or off; the server reads them as "true" or "false".
const _toggles = {
  'BALNANA_AUTH_PASSWORD',
  'BALNANA_AUTH_REQUIRE_EMAIL',
  'BALNANA_AUTH_REQUIRE_VERIFIED',
  'BALNANA_BILLING_ENABLED',
  'BALNANA_LINK_GROUPS',
  'BALNANA_OAUTH_GOOGLE_TRUST_EMAIL',
};

/// Settings picked from a few values.
const _choices = {'BALNANA_AUTH_MODE', 'BALNANA_AUTH_SIGNUP', 'BALNANA_MAP_SOURCE'};

/// The setting that turns each optional section on: the server uses the
/// section when it is set. Its switch shows the rest of the section.
const _smtp = 'BALNANA_SMTP_HOST';
const _google = 'BALNANA_OAUTH_GOOGLE_CLIENT_ID';

/// The OpenID Connect providers, by id; each has the settings in
/// [_oidcFields] under [_oidcKey].
const _oidcProviders = 'BALNANA_OAUTH_OIDC_PROVIDERS';
const _oidcFields = ['NAME', 'ISSUER', 'CLIENT_ID', 'SECRET'];
const _oidcTrust = 'TRUST_EMAIL';
final _oidcId = RegExp(r'^[a-z0-9][a-z0-9-]{0,31}$');

String _oidcKey(String id, String field) =>
    'BALNANA_OAUTH_OIDC_${id.replaceAll('-', '_').toUpperCase()}_$field';

List<String> _splitList(String value) => [
  for (final part in value.split(','))
    if (part.trim() case final id when id.isNotEmpty) id,
];

/// An OpenID Connect provider in the form. Its id is fixed once saved, as
/// it is part of the redirect URI and of its settings' names.
class _Oidc {
  _Oidc(this.saved, Map<String, AdminSetting> settings) {
    if (saved case final id?) {
      this.id.text = id;
      for (final MapEntry(key: field, value: c) in fields.entries) {
        final s = settings[_oidcKey(id, field)];
        c.text = s == null || s.secret ? '' : s.value ?? '';
      }
    }
  }

  /// The id it has on the server; null while new.
  final String? saved;
  final id = TextEditingController();
  final fields = {for (final f in _oidcFields) f: TextEditingController()};

  /// Whether to trust its addresses, when changed here.
  bool? trust;

  /// Names its id field in [_AdminSettingsPageState._invalid].
  late final idKey = 'oidc-id-${identityHashCode(this)}';

  String get current => id.text.trim();

  void dispose() {
    id.dispose();
    for (final c in fields.values) {
      c.dispose();
    }
  }
}

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

  /// Whether each optional section is on, by the setting that turns it on.
  final _on = <String, bool>{};

  /// The OpenID Connect providers, in order.
  final _oidc = <_Oidc>[];

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
    for (final o in _oidc) {
      o.dispose();
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
      final byKey = _settings = {for (final s in settings) s.key: s};
      for (final s in settings) {
        if (_toggles.contains(s.key) || _choices.contains(s.key) || _isOidc(s.key)) continue;
        (_text[s.key] ??= TextEditingController()).text = s.secret ? '' : s.value ?? '';
      }
      _picked.clear();
      _removed.clear();
      for (final key in [_smtp, _google]) {
        _on[key] = settings.any((s) => s.key == key && s.effective.isNotEmpty);
      }
      for (final o in _oidc) {
        o.dispose();
      }
      _oidc
        ..clear()
        ..addAll([for (final id in _savedOidc(byKey)) _Oidc(id, byKey)]);
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
      // A section switched off is turned off on the server by clearing the
      // setting that turns it on; its other settings stay for next time.
      if (_on[key] == false) {
        if (s.effective.isNotEmpty) out[key] = '';
        continue;
      }
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
    if (_passwordForced && !_current('BALNANA_AUTH_PASSWORD', settings).isTrue) {
      out['BALNANA_AUTH_PASSWORD'] = 'true';
    }
    // Confirming addresses takes email.
    const verified = 'BALNANA_AUTH_REQUIRE_VERIFIED';
    if (_on[_smtp] == false && _current(verified, settings).isTrue && !(settings[verified]?.locked ?? true)) {
      out[verified] = 'false';
    }
    if (!(settings[_oidcProviders]?.locked ?? true)) _oidcChanges(settings, out);
    return out;
  }

  static bool _isOidc(String key) => key.startsWith('BALNANA_OAUTH_OIDC_');

  static List<String> _savedOidc(Map<String, AdminSetting> settings) =>
      _splitList(settings[_oidcProviders]?.effective ?? '');

  bool get _oidcLocked => _settings?[_oidcProviders]?.locked ?? true;

  /// Adds what the OpenID Connect providers change to [out]: their list, the
  /// settings of each, and empty values clearing the settings of those
  /// removed.
  void _oidcChanges(Map<String, AdminSetting> settings, Map<String, String> out) {
    final saved = _savedOidc(settings);
    final ids = [for (final o in _oidc) o.current];
    if (!listEquals(ids, saved)) out[_oidcProviders] = ids.join(',');
    for (final id in saved) {
      if (_oidc.any((o) => o.saved == id)) continue;
      for (final field in [..._oidcFields, _oidcTrust]) {
        final s = settings[_oidcKey(id, field)];
        if (s != null && s.set && !s.locked) out[s.key] = '';
      }
    }
    for (final o in _oidc) {
      final id = o.current;
      if (id.isEmpty) continue;
      for (final MapEntry(key: field, value: c) in o.fields.entries) {
        final key = _oidcKey(id, field);
        final s = o.saved == null ? null : settings[key];
        if (s?.locked ?? false) continue;
        final v = c.text.trim();
        if (field == 'SECRET' ? v.isNotEmpty : v != (s?.value ?? '')) out[key] = v;
      }
      final key = _oidcKey(id, _oidcTrust);
      final s = o.saved == null ? null : settings[key];
      final trust = o.trust;
      if (trust != null && !(s?.locked ?? false) && trust != (s?.effective ?? 'false').isTrue) {
        out[key] = '$trust';
      }
    }
  }

  /// What is wrong with an OpenID Connect provider's id, if anything.
  String? _oidcIdProblem(AppLocalizations l10n, _Oidc o) {
    if (o.saved != null) return null;
    final id = o.current;
    if (id.isEmpty) return l10n.errorRequired;
    if (!_oidcId.hasMatch(id) || id == 'google') return l10n.adminOidcIdInvalid;
    if (_oidc.where((other) => other.current == id).length > 1) return l10n.adminOidcIdTaken;
    return null;
  }

  String _current(String key, Map<String, AdminSetting> settings) =>
      _picked[key] ?? settings[key]?.effective ?? '';

  /// Accounts need a way to sign in, so email and password stays on while
  /// no provider is.
  bool get _passwordForced {
    final settings = _settings ?? const {};
    return _current('BALNANA_AUTH_MODE', settings) == 'accounts' &&
        !(settings['BALNANA_AUTH_PASSWORD']?.locked ?? false) &&
        _on[_google] != true &&
        _oidc.isEmpty;
  }

  /// Switched-on sections whose setting that turns them on is empty, and
  /// what OpenID Connect providers are missing.
  Set<String> get _missing {
    final settings = _settings ?? const {};
    return {
      for (final key in [_smtp, _google])
        if (_on[key] == true && !(settings[key]?.locked ?? false) && (_text[key]?.text.trim() ?? '').isEmpty)
          key,
      if (!_oidcLocked)
        for (final o in _oidc) ...[
          if (_oidcIdProblem(context.l10n, o) != null)
            o.idKey
          else
            for (final field in ['ISSUER', 'CLIENT_ID', 'SECRET'])
              if (_oidcKey(o.current, field) case final key
                  when o.fields[field]!.text.trim().isEmpty &&
                      !(field == 'SECRET' && o.saved != null && (settings[key]?.set ?? false)) &&
                      !(settings[key]?.locked ?? false))
                key,
        ],
    };
  }

  Future<void> _save() async {
    final changes = _changes;
    if (changes.isEmpty) return;
    if (_missing.isNotEmpty) {
      setState(() => _invalid = {..._invalid, ..._missing});
      return;
    }
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
              tooltip: l10n.adminUsers,
              icon: const Icon(Icons.people_outline),
              onPressed: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => AdminUsersPage(token: widget.token))),
            ),
            IconButton(
              tooltip: l10n.adminPlans,
              icon: const Icon(Icons.workspace_premium_outlined),
              onPressed: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => AdminPlansPage(token: widget.token))),
            ),
            IconButton(
              tooltip: l10n.adminPayments,
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => AdminPaymentsPage(token: widget.token))),
            ),
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
    final accounts = _current('BALNANA_AUTH_MODE', settings) == 'accounts';
    final passwords = _passwordForced || _current('BALNANA_AUTH_PASSWORD', settings).isTrue;
    final mapSource = _current('BALNANA_MAP_SOURCE', settings);
    return [
      FormSection(l10n.adminSectionGeneral),
      _textField('BALNANA_PUBLIC_URL', keyboard: TextInputType.url),
      gap,
      _textField('BALNANA_SOURCE_URL', keyboard: TextInputType.url),
      gap,
      _textField('BALNANA_PRIVACY_URL', keyboard: TextInputType.url),
      FormSection(l10n.adminSectionMaps),
      _choice('BALNANA_MAP_SOURCE', titled: false, {
        'style': (l10n.adminMapSourceStyle, l10n.adminMapSourceStyleHelp),
        'tiles': (l10n.adminMapSourceTiles, l10n.adminMapSourceTilesHelp),
        'off': (l10n.adminMapSourceOff, l10n.adminMapSourceOffHelp),
      }),
      if (mapSource == 'style') ...[gap, _textField('BALNANA_MAP_STYLE', keyboard: TextInputType.url)],
      if (mapSource == 'tiles') ...[gap, _textField('BALNANA_MAP_TILES', keyboard: TextInputType.url)],
      if (mapSource != 'off') ...[gap, _textField('BALNANA_MAP_ATTRIBUTION')],
      FormSection(l10n.adminSectionAccess),
      _choice('BALNANA_AUTH_MODE', titled: false, {
        'link': (l10n.adminAuthModeLink, l10n.adminAuthModeLinkHelp),
        'accounts': (l10n.adminAuthModeAccounts, l10n.adminAuthModeAccountsHelp),
      }),
      if (accounts) ...[
        FormSection(l10n.adminSectionAccounts),
        _note(l10n.adminSectionAccountsBody),
        _toggle(
          'BALNANA_AUTH_PASSWORD',
          forced: _passwordForced,
          help: _passwordForced ? l10n.adminPasswordForced : null,
        ),
        _toggle(
          'BALNANA_AUTH_REQUIRE_EMAIL',
          enabled: passwords,
          help: passwords ? null : l10n.adminRequireEmailUnused,
        ),
        _toggle(
          'BALNANA_AUTH_REQUIRE_VERIFIED',
          enabled: _on[_smtp]!,
          off: !_on[_smtp]!,
          help: _on[_smtp]! ? null : l10n.adminRequireVerifiedUnused,
        ),
        _toggle('BALNANA_LINK_GROUPS'),
        gap,
        _choice('BALNANA_AUTH_SIGNUP', {
          'open': (l10n.adminSignupOpen, l10n.adminSignupOpenHelp),
          'invite_only': (l10n.adminSignupInvite, l10n.adminSignupInviteHelp),
          'closed': (l10n.adminSignupClosed, l10n.adminSignupClosedHelp),
        }),
        FormSection(l10n.adminSectionEmail),
        _section(_smtp, l10n.adminSmtpOn, l10n.adminSectionEmailBody),
        if (_on[_smtp]!) ...[
          _textField(_smtp, keyboard: TextInputType.url),
          gap,
          _textField('BALNANA_SMTP_PORT', keyboard: TextInputType.number),
          gap,
          _textField('BALNANA_SMTP_USER'),
          gap,
          _textField('BALNANA_SMTP_PASSWORD'),
          gap,
          _textField('BALNANA_SMTP_FROM', hint: l10n.adminSmtpFromHint),
        ],
        FormSection(l10n.adminSectionGoogle),
        _section(_google, l10n.adminGoogleOn, l10n.adminGoogleOnHelp),
        if (_on[_google]!) ...[
          _note(l10n.adminSectionGoogleBody(callback('google'))),
          _textField(_google),
          gap,
          _textField('BALNANA_OAUTH_GOOGLE_SECRET'),
          _toggle('BALNANA_OAUTH_GOOGLE_TRUST_EMAIL'),
        ],
        FormSection(l10n.adminSectionOidc),
        _note(
          _oidcLocked && settings.containsKey(_oidcProviders)
              ? '${l10n.adminOidcHelp}\n${l10n.adminLocked(_oidcProviders)}'
              : l10n.adminOidcHelp,
        ),
        for (final o in _oidc) ...[_oidcCard(o, callback), gap],
        if (!_oidcLocked)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : () => setState(() => _oidc.add(_Oidc(null, settings))),
              icon: const Icon(Icons.add),
              label: Text(l10n.adminOidcAdd),
            ),
          ),
      ],
      FormSection(l10n.adminSectionBilling),
      _note(l10n.adminSectionBillingBody),
      _toggle(
        'BALNANA_BILLING_ENABLED',
        enabled: accounts,
        help: accounts ? null : l10n.adminBillingNeedsAccounts,
      ),
      gap,
      _textField('BALNANA_KOFI_URL', keyboard: TextInputType.url),
      gap,
      _note(l10n.adminKofiWebhook('$publicUrl$apiBasePath/webhooks/kofi')),
      _textField('BALNANA_KOFI_TOKEN'),
      FormSection(l10n.adminSectionAndroid),
      _note(l10n.adminSectionAndroidBody),
      _textField('BALNANA_ANDROID_CERT_SHA256', maxLines: 3),
    ];
  }

  /// An OpenID Connect provider's settings.
  Widget _oidcCard(_Oidc o, String Function(String) callback) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = _settings!;
    final id = o.current;
    final idProblem = _oidcIdProblem(l10n, o);
    final name = o.fields['NAME']!.text.trim();
    final trustKey = _oidcKey(id, _oidcTrust);
    final trustSetting = o.saved == null ? null : settings[trustKey];
    const gap = SizedBox(height: BSpace.s16);

    Widget field(String field, {TextInputType? keyboard}) {
      final key = _oidcKey(id, field);
      final s = o.saved == null ? null : settings[key];
      final c = o.fields[field]!;
      final secret = field == 'SECRET';
      final locked = _oidcLocked || (s?.locked ?? false);
      return TextField(
        controller: c,
        enabled: !_busy && !locked,
        obscureText: secret,
        autocorrect: false,
        enableSuggestions: false,
        keyboardType: keyboard,
        onChanged: (_) => setState(() => _invalid.remove(key)),
        decoration: InputDecoration(
          labelText: _label(l10n, 'BALNANA_OAUTH_OIDC_$field'),
          hintText: field == 'NAME' && id.isNotEmpty ? l10n.adminDefault(id) : null,
          floatingLabelBehavior: field == 'NAME' && id.isNotEmpty ? FloatingLabelBehavior.always : null,
          helperText: s?.locked ?? false
              ? l10n.adminLocked(key)
              : secret && (s?.set ?? false) && c.text.isEmpty
              ? l10n.adminSecretSaved
              : _help(l10n, 'BALNANA_OAUTH_OIDC_$field'),
          helperMaxLines: 4,
          errorText: !_invalid.contains(key)
              ? null
              : c.text.trim().isEmpty
              ? l10n.errorRequired
              : _problem(l10n, 'BALNANA_OAUTH_OIDC_$field'),
          errorMaxLines: 4,
        ),
      );
    }

    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s8, BSpace.s8, BSpace.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name.isNotEmpty
                        ? name
                        : id.isNotEmpty
                        ? id
                        : l10n.adminOidcNew,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (!_oidcLocked)
                  IconButton(
                    tooltip: l10n.adminOidcRemove,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _oidc.remove(o);
                            o.dispose();
                          }),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: BSpace.s8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  gap,
                  TextField(
                    controller: o.id,
                    enabled: !_busy && o.saved == null,
                    autocorrect: false,
                    enableSuggestions: false,
                    onChanged: (_) => setState(() => _invalid.remove(o.idKey)),
                    decoration: InputDecoration(
                      labelText: l10n.adminOidcId,
                      helperText: o.saved == null ? l10n.adminOidcIdHelp : null,
                      helperMaxLines: 4,
                      errorText: _invalid.contains(o.idKey) ? idProblem : null,
                      errorMaxLines: 4,
                    ),
                  ),
                  if (idProblem == null) ...[gap, _note(l10n.adminSectionOidcBody(callback(id)))] else gap,
                  field('NAME'),
                  gap,
                  field('ISSUER', keyboard: TextInputType.url),
                  gap,
                  field('CLIENT_ID'),
                  gap,
                  field('SECRET'),
                ],
              ),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.only(left: BSpace.s4, right: BSpace.s8),
              title: Text(l10n.adminTrustEmail),
              subtitle: Text(
                trustSetting?.locked ?? false ? l10n.adminLocked(trustKey) : l10n.adminOidcTrustEmailHelp,
              ),
              value: o.trust ?? (trustSetting?.effective ?? 'false').isTrue,
              onChanged: _busy || _oidcLocked || (trustSetting?.locked ?? false)
                  ? null
                  : (v) => setState(() => o.trust = v),
            ),
          ],
        ),
      ),
    );
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
        errorText: !_invalid.contains(key)
            ? null
            : _on.containsKey(key) && controller.text.trim().isEmpty
            ? l10n.errorRequired
            : _problem(l10n, key),
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

  /// An on or off setting. [forced] holds it on, [off] holds it off;
  /// [enabled] false dims it, as it does nothing then. [help] replaces its
  /// usual help.
  Widget _toggle(String key, {bool forced = false, bool off = false, bool enabled = true, String? help}) {
    final l10n = context.l10n;
    final s = _settings![key];
    if (s == null) return const SizedBox.shrink();
    final value = !off && (forced || (_picked[key] ?? s.effective).isTrue);
    final scheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: BSpace.s4),
      title: Text(_label(l10n, key)),
      subtitle: Text(
        _invalid.contains(key)
            ? _problem(l10n, key)
            : s.locked
            ? l10n.adminLocked(key)
            : help ?? _help(l10n, key) ?? '',
        style: _invalid.contains(key) ? TextStyle(color: scheme.error) : null,
      ),
      value: value,
      onChanged: _busy || s.locked || forced || !enabled ? null : (v) => _pick(key, '$v'),
    );
  }

  /// The switch of an optional section, turned on by [key].
  Widget _section(String key, String title, String help) {
    final l10n = context.l10n;
    final s = _settings![key];
    if (s == null) return const SizedBox.shrink();
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: BSpace.s4),
      title: Text(title),
      subtitle: Text(s.locked ? l10n.adminLocked(key) : help),
      value: _on[key]!,
      onChanged: _busy || s.locked
          ? null
          : (v) => setState(() {
              _on[key] = v;
              _invalid.remove(key);
            }),
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

extension on String {
  bool get isTrue => this == 'true';
}

String _label(AppLocalizations l10n, String key) => switch (key) {
  'BALNANA_PUBLIC_URL' => l10n.adminPublicUrl,
  'BALNANA_SOURCE_URL' => l10n.adminSourceUrl,
  'BALNANA_PRIVACY_URL' => l10n.adminPrivacyUrl,
  'BALNANA_MAP_SOURCE' => l10n.adminMapSource,
  'BALNANA_MAP_STYLE' => l10n.adminMapStyle,
  'BALNANA_MAP_TILES' => l10n.adminMapTiles,
  'BALNANA_MAP_ATTRIBUTION' => l10n.adminMapAttribution,
  'BALNANA_AUTH_MODE' => l10n.adminAuthMode,
  'BALNANA_AUTH_PASSWORD' => l10n.adminPasswordLogin,
  'BALNANA_AUTH_REQUIRE_EMAIL' => l10n.adminRequireEmail,
  'BALNANA_AUTH_REQUIRE_VERIFIED' => l10n.adminRequireVerified,
  'BALNANA_OAUTH_GOOGLE_TRUST_EMAIL' => l10n.adminTrustEmail,
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
  'BALNANA_BILLING_ENABLED' => l10n.adminBillingOn,
  'BALNANA_KOFI_URL' => l10n.adminKofiUrl,
  'BALNANA_KOFI_TOKEN' => l10n.adminKofiToken,
  _ => key,
};

String? _help(AppLocalizations l10n, String key) => switch (key) {
  'BALNANA_PUBLIC_URL' => l10n.adminPublicUrlHelp,
  'BALNANA_SOURCE_URL' => l10n.adminSourceUrlHelp,
  'BALNANA_PRIVACY_URL' => l10n.adminPrivacyUrlHelp,
  'BALNANA_MAP_STYLE' => l10n.adminMapStyleHelp,
  'BALNANA_MAP_TILES' => l10n.adminMapTilesHelp,
  'BALNANA_MAP_ATTRIBUTION' => l10n.adminMapAttributionHelp,
  'BALNANA_AUTH_SIGNUP' => l10n.adminSignupHelp,
  'BALNANA_AUTH_REQUIRE_EMAIL' => l10n.adminRequireEmailHelp,
  'BALNANA_AUTH_REQUIRE_VERIFIED' => l10n.adminRequireVerifiedHelp,
  'BALNANA_OAUTH_GOOGLE_TRUST_EMAIL' => l10n.adminGoogleTrustEmailHelp,
  'BALNANA_LINK_GROUPS' => l10n.adminLinkGroupsHelp,
  'BALNANA_OAUTH_OIDC_NAME' => l10n.adminOidcNameHelp,
  'BALNANA_ANDROID_CERT_SHA256' => l10n.adminFingerprintsHelp,
  'BALNANA_BILLING_ENABLED' => l10n.adminBillingOnHelp,
  'BALNANA_KOFI_URL' => l10n.adminKofiUrlHelp,
  'BALNANA_KOFI_TOKEN' => l10n.adminKofiTokenHelp,
  _ => null,
};

/// Why the server refused a setting.
String _problem(AppLocalizations l10n, String key) => switch (key) {
  'BALNANA_PUBLIC_URL' ||
  'BALNANA_SOURCE_URL' ||
  'BALNANA_PRIVACY_URL' ||
  'BALNANA_KOFI_URL' ||
  'BALNANA_MAP_STYLE' ||
  'BALNANA_OAUTH_OIDC_ISSUER' => l10n.adminInvalidUrl,
  'BALNANA_SMTP_FROM' => l10n.adminInvalidFrom,
  'BALNANA_SMTP_PORT' => l10n.adminInvalidPort,
  'BALNANA_OAUTH_GOOGLE_SECRET' ||
  'BALNANA_OAUTH_OIDC_CLIENT_ID' ||
  'BALNANA_OAUTH_OIDC_SECRET' => l10n.adminInvalidRequired,
  'BALNANA_AUTH_MODE' => l10n.adminNeedsSignIn,
  'BALNANA_BILLING_ENABLED' => l10n.adminBillingNeedsAccounts,
  'BALNANA_ANDROID_CERT_SHA256' => l10n.adminInvalidFingerprint,
  'BALNANA_MAP_TILES' => l10n.adminInvalidMapTiles,
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
