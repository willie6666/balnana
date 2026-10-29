import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/prefs.dart';
import '../../core/server.dart';
import '../../core/session.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/layout.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import 'sign_in_page.dart';

/// Sign-in with Google or an OpenID Connect provider. The browser goes
/// through the server to the provider and comes back to /oauth-done: in this
/// tab on the web, through a balnana://app link on Android.

/// The sign-in under way: the server it was started on and its PKCE
/// verifier. The code coming back belongs to that server alone, and together
/// with the verifier signs in to it, so neither goes to any other.
const _attemptKey = 'oauth.attempt';

/// Where an earlier version kept the verifier, without its server.
const _oldVerifierKey = 'oauth.verifier';

String _base64Url(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');

/// Leaves for [provider]'s sign-in page, coming back to [next]. With a
/// [link] ticket from [BalnanaApi.linkOAuth], the sign-in adds the provider
/// to the signed-in account instead.
Future<void> startOAuth(WidgetRef ref, OAuthProvider provider, String next, {String? link}) async {
  final server = ref.read(serverUrlProvider);
  if (server == null) return;
  final query = {'app': kIsWeb ? 'web' : 'android', 'next': next, 'link': ?link};
  if (!cookieSession(server)) {
    // A web app on another origin gets the sign-in back there as a code.
    if (kIsWeb) query['origin'] = Uri.base.origin;
    // Only this app knows the verifier, so another app catching the link
    // back cannot use its code.
    final random = Random.secure();
    final verifier = _base64Url([for (var i = 0; i < 32; i++) random.nextInt(256)]);
    final attempt = jsonEncode({'server': server, 'verifier': verifier});
    await ref.read(prefsProvider).setString(_attemptKey, attempt);
    query['challenge'] = _base64Url(sha256.convert(utf8.encode(verifier)).bytes);
  }
  final url = Uri.parse(
    '$server$apiBasePath/auth/oauth/${Uri.encodeComponent(provider.id)}/start',
  ).replace(queryParameters: query);
  await launchUrl(
    url,
    mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    webOnlyWindowName: '_self',
  );
}

/// Where the provider's sign-in ends: signs in, then goes on to [next].
class OAuthDonePage extends ConsumerStatefulWidget {
  const OAuthDonePage({super.key, this.code, this.pending, this.linked, this.error, this.next});

  /// Android, or a web app on another origin: the code to trade for a session.
  final String? code;

  /// The sign-in matched an account that never confirmed its address: the
  /// person says what that account is to them.
  final String? pending;

  /// The provider added to the signed-in account.
  final String? linked;
  final String? error;
  final String? next;

  @override
  ConsumerState<OAuthDonePage> createState() => _OAuthDonePageState();
}

/// A sign-in waiting for its choice, and the verifier it started with.
typedef _Pending = ({String token, OAuthPending info, String? verifier});

class _OAuthDonePageState extends ConsumerState<OAuthDonePage> {
  late final Future<_Pending?> _done = _finish();

  /// The sign-in's verifier, which only this app knows, if it started with
  /// one; checks it was started on the server chosen now.
  Future<String?> _verifier() async {
    final prefs = ref.read(prefsProvider);
    final attempt = prefs.getString(_attemptKey);
    await prefs.remove(_attemptKey);
    await prefs.remove(_oldVerifierKey);
    final (server, verifier) = switch (attempt == null ? null : jsonDecode(attempt)) {
      {'server': final String server, 'verifier': final String verifier} => (server, verifier),
      _ => throw const ApiException('invalid_token'),
    };
    // Started on another server than the one chosen now: its code and
    // verifier are that server's secrets.
    if (server != ref.read(identityProvider).server) throw const ApiException('oauth_other_server');
    return verifier;
  }

  Future<_Pending?> _finish() async {
    if (widget.error case final error?) throw ApiException(error);
    final who = ref.read(identityProvider);
    if (widget.linked case final provider?) {
      // The app adds it with its verifier, and keeps its session.
      if (widget.code case final code?) {
        await ref.read(balnanaApiProvider)!.exchangeOAuthCode(code: code, verifier: (await _verifier())!);
      }
      await ref.read(prefsProvider).remove(_attemptKey);
      ref.invalidate(myOAuthProvider);
      if (mounted) {
        final name = _providerName(ref, provider);
        context.go(safeNext(widget.next) ?? '/settings');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.accountOAuthAdded(name))));
      }
      return null;
    }
    final api = ref.read(balnanaApiProvider)!;
    if (widget.pending case final token?) {
      // The web app on its own server proves the sign-in with its cookie.
      final verifier = cookieSession(who.server ?? '') ? null : await _verifier();
      return (token: token, info: await api.oauthPending(token), verifier: verifier);
    }
    String? token;
    if (widget.code case final code?) {
      (token, _) = await api.exchangeOAuthCode(code: code, verifier: (await _verifier())!);
    }
    // The web app on its own server already has the session cookie.
    if (startSession(ref, token, from: who) && mounted) context.go(safeNext(widget.next) ?? '/groups');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: FutureBuilder(
        future: _done,
        builder: (context, snapshot) {
          final error = snapshot.error;
          if (snapshot.data case final pending?) {
            return _PendingChoice(pending: pending, next: safeNext(widget.next) ?? '/groups');
          }
          if (error == null) return const Center(child: CircularProgressIndicator());
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(BSpace.s16),
              child: EmptyState(
                icon: Icons.no_accounts_outlined,
                title: l10n.oauthFailedTitle,
                body: switch (error) {
                  ApiException(code: 'oauth_other_server') => l10n.oauthOtherServer,
                  _ => errorMessage(l10n, error),
                },
                action: FilledButton(
                  onPressed: () => context.go(signInPath(safeNext(widget.next) ?? '/groups')),
                  child: Text(l10n.oauthBackToSignIn),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _providerName(WidgetRef ref, String id) =>
    ref.read(serverInfoProvider).value?.oauthProviders.where((p) => p.id == id).firstOrNull?.name ?? id;

/// Asks what the account a sign-in matched by an unconfirmed address is to
/// the person: theirs, to keep with its password; theirs, to take over from
/// whoever else may get in; or someone else's.
class _PendingChoice extends ConsumerStatefulWidget {
  const _PendingChoice({required this.pending, required this.next});

  final _Pending pending;
  final String next;

  @override
  ConsumerState<_PendingChoice> createState() => _PendingChoiceState();
}

enum _Choice { link, takeOver, newAccount }

class _PendingChoiceState extends ConsumerState<_PendingChoice> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  late _Choice _choice = widget.pending.info.hasPassword ? _Choice.link : _Choice.takeOver;
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
    final who = ref.read(identityProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final (token, _) = await ref
          .read(balnanaApiProvider)!
          .finishOAuthPending(
            token: widget.pending.token,
            choice: switch (_choice) {
              _Choice.link => 'link',
              _Choice.takeOver => 'take_over',
              _Choice.newAccount => 'new_account',
            },
            password: _choice == _Choice.link ? _password.text : null,
            verifier: widget.pending.verifier,
          );
      if (startSession(ref, token, from: who) && mounted) context.go(widget.next);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.code == 'wrong_password' ? l10n.oauthPendingWrongPassword : errorMessage(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final info = widget.pending.info;
    final provider = _providerName(ref, info.provider);
    final options = {
      if (info.hasPassword) _Choice.link: (l10n.oauthPendingLink, l10n.oauthPendingLinkHelp),
      _Choice.takeOver: (l10n.oauthPendingTakeOver, l10n.oauthPendingTakeOverHelp),
      if (info.signup) _Choice.newAccount: (l10n.oauthPendingNew, l10n.oauthPendingNewHelp(info.email)),
    };
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BSpace.s16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: formMaxWidth),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.oauthPendingTitle, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: BSpace.s8),
                  Text(
                    l10n.oauthPendingBody(provider, info.email),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: BSpace.s16),
                  RadioGroup<_Choice>(
                    groupValue: _choice,
                    onChanged: (v) {
                      if (_busy || v == null) return;
                      setState(() {
                        _choice = v;
                        _error = null;
                      });
                    },
                    child: Column(
                      children: [
                        for (final MapEntry(key: choice, value: (title, help)) in options.entries)
                          RadioListTile<_Choice>(
                            value: choice,
                            enabled: !_busy,
                            contentPadding: EdgeInsets.zero,
                            title: Text(title),
                            subtitle: Text(help),
                          ),
                      ],
                    ),
                  ),
                  if (_choice == _Choice.link) ...[
                    const SizedBox(height: BSpace.s8),
                    TextFormField(
                      controller: _password,
                      enabled: !_busy,
                      autofocus: true,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(labelText: l10n.oauthPendingPassword),
                      validator: (v) => (v ?? '').isEmpty ? l10n.errorRequired : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                  if (_error case final error?) ...[
                    const SizedBox(height: BSpace.s16),
                    Text(error, style: TextStyle(color: theme.colorScheme.error)),
                  ],
                  const SizedBox(height: BSpace.s24),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.commonContinue),
                  ),
                  const SizedBox(height: BSpace.s8),
                  TextButton(
                    onPressed: _busy ? null : () => context.go(signInPath(widget.next)),
                    child: Text(l10n.oauthBackToSignIn),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
