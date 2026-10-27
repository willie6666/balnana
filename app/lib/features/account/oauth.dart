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
import '../../data/providers.dart';
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

/// Leaves for [provider]'s sign-in page, coming back to [next].
Future<void> startOAuth(WidgetRef ref, OAuthProvider provider, String next) async {
  final server = ref.read(serverUrlProvider);
  if (server == null) return;
  final query = {'app': kIsWeb ? 'web' : 'android', 'next': next};
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
  const OAuthDonePage({super.key, this.code, this.error, this.next});

  /// Android, or a web app on another origin: the code to trade for a session.
  final String? code;
  final String? error;
  final String? next;

  @override
  ConsumerState<OAuthDonePage> createState() => _OAuthDonePageState();
}

class _OAuthDonePageState extends ConsumerState<OAuthDonePage> {
  late final Future<void> _done = _finish();

  Future<void> _finish() async {
    if (widget.error case final error?) throw ApiException(error);
    final who = ref.read(identityProvider);
    String? token;
    if (widget.code case final code?) {
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
      if (server != who.server) throw const ApiException('oauth_other_server');
      (token, _) = await ref.read(balnanaApiProvider)!.exchangeOAuthCode(code: code, verifier: verifier);
    }
    // The web app on its own server already has the session cookie.
    if (startSession(ref, token, from: who) && mounted) context.go(safeNext(widget.next) ?? '/groups');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: FutureBuilder(
        future: _done,
        builder: (context, snapshot) {
          final error = snapshot.error;
          if (error == null) return const Center(child: CircularProgressIndicator());
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(BSpace.s16),
              child: EmptyState(
                icon: Icons.no_accounts_outlined,
                title: l10n.oauthFailedTitle,
                body: switch (error) {
                  ApiException(code: 'email_taken') => l10n.oauthEmailTaken,
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
