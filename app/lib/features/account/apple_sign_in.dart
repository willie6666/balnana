import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_store.dart';
import '../../core/router.dart';
import '../../core/server.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import 'oauth.dart';

/// Sign in with Apple, which only the iOS app offers: it asks Apple itself
/// and hands the server the identity token. Linked, it is listed and removed
/// like any other provider, by this id.
const appleProvider = OAuthProvider(id: 'apple', name: 'Apple');

/// Whether this app can sign in with Apple on a server that allows it.
bool appleSignInOffered(ServerInfo? info) => iosApp && (info?.appleSignIn ?? false);

/// What Apple gave the app: the identity token, and the person's name the
/// first time they sign in to this app.
typedef AppleCredential = ({String identityToken, String? name});

/// AuthenticationServices, through AppleSignIn.swift. Returns null when the
/// person cancelled.
Future<AppleCredential?> askApple(String hashedNonce) async {
  try {
    final got = await const MethodChannel('balnana/apple_sign_in').invokeMapMethod<String, Object?>(
      'signIn',
      {'nonce': hashedNonce},
    );
    return switch (got) {
      {'identityToken': final String token} => (identityToken: token, name: got['name'] as String?),
      _ => throw const ApiException('oauth_failed'),
    };
  } on PlatformException catch (e) {
    if (e.code == 'cancelled') return null;
    throw const ApiException('oauth_failed');
  }
}

String _randomNonce() {
  final random = Random.secure();
  return base64Url.encode([for (var i = 0; i < 32; i++) random.nextInt(256)]).replaceAll('=', '');
}

/// Signs in with Apple and goes on as a provider's sign-in coming back would,
/// through /oauth-done. With a [link] ticket from [BalnanaApi.linkOAuth],
/// Apple is added to the signed-in account instead.
Future<void> signInWithApple(WidgetRef ref, String next, {String? link}) async {
  final server = ref.read(serverUrlProvider);
  final api = ref.read(balnanaApiProvider);
  if (server == null || api == null) return;
  final router = ref.read(routerProvider);
  // Apple puts the nonce's hash in the token; the server is sent the nonce
  // itself, which only this app knows, so a token caught elsewhere is useless.
  final nonce = _randomNonce();
  final query = {'next': next};
  try {
    final credential = await askApple(sha256.convert(utf8.encode(nonce)).toString());
    if (credential == null) return;
    final challenge = link == null ? await saveOAuthAttempt(ref, server) : null;
    final result = await api.signInWithApple(
      identityToken: credential.identityToken,
      nonce: nonce,
      challenge: challenge,
      name: credential.name,
      link: link,
    );
    switch (result) {
      case AppleSignInResult(linked: true):
        query['linked'] = appleProvider.id;
      case AppleSignInResult(pending: final String pending):
        query['pending'] = pending;
      case AppleSignInResult(code: final String code):
        query['code'] = code;
      default:
        query['error'] = 'oauth_failed';
    }
  } on ApiException catch (e) {
    query['error'] = e.code;
  }
  router.go(Uri(path: '/oauth-done', queryParameters: query).toString());
}
