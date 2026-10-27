import 'dart:async';

import 'package:balnana/core/server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizeServerUrl', () {
    expect(normalizeServerUrl('balnana.example.com'), 'https://balnana.example.com');
    expect(normalizeServerUrl(' https://b.example.com/ '), 'https://b.example.com');
    expect(normalizeServerUrl('http://192.168.1.5:8080'), 'http://192.168.1.5:8080');
    expect(normalizeServerUrl('https://example.com/balnana//?x=1#y'), 'https://example.com/balnana');
    expect(normalizeServerUrl('HTTPS://Example.COM'), 'https://example.com');
    expect(normalizeServerUrl(''), isNull);
    expect(normalizeServerUrl('not a url'), isNull);
    expect(normalizeServerUrl('ftp://example.com'), isNull);
    expect(normalizeServerUrl('https://user:pw@example.com'), isNull);
  });

  // A browser keeps a server's cookie from web apps on other origins: they
  // keep a token instead.
  test('cookieSession', () {
    final page = Uri.parse('https://balnana.example.com/groups');
    expect(cookieSession('https://balnana.example.com', web: true, page: page), isTrue);
    expect(cookieSession('https://balnana.example.com/api/v1', web: true, page: page), isTrue);
    expect(cookieSession('https://api.example.com', web: true, page: page), isFalse);
    expect(cookieSession('http://balnana.example.com', web: true, page: page), isFalse);
    expect(cookieSession('https://balnana.example.com', web: false, page: page), isFalse);
  });

  test('isInsecureServerUrl', () {
    expect(isInsecureServerUrl('https://example.com'), isFalse);
    expect(isInsecureServerUrl('http://example.com'), isTrue);
    expect(isInsecureServerUrl('http://8.8.8.8'), isTrue);
    expect(isInsecureServerUrl('http://localhost:8080'), isFalse);
    expect(isInsecureServerUrl('http://10.0.2.2:8080'), isFalse);
    expect(isInsecureServerUrl('http://192.168.1.5'), isFalse);
    expect(isInsecureServerUrl('http://172.20.0.1'), isFalse);
    expect(isInsecureServerUrl('http://nas.local'), isFalse);
    expect(isInsecureServerUrl('http://[::1]:8080'), isFalse);
  });

  test('link aliases ignore previous server metadata during reload or failure', () async {
    const old = ServerInfo(version: 'test', authMode: AuthMode.link, publicUrl: 'https://old.example');
    var server = 'https://old.example';
    var answer = Completer<ServerInfo>();
    final container = ProviderContainer.test(
      retry: (retryCount, error) => null,
      overrides: [
        serverUrlProvider.overrideWith((ref) => server),
        serverInfoProvider.overrideWith((ref) {
          ref.watch(serverUrlProvider);
          return answer.future;
        }),
      ],
    );
    container.listen(serverPublicUrlProvider, (previous, next) {});
    answer.complete(old);
    await container.read(serverInfoProvider.future);
    expect(container.read(serverPublicUrlProvider), old.publicUrl);
    server = 'https://new.example';
    answer = Completer<ServerInfo>();
    container.invalidate(serverUrlProvider);
    expect(container.read(serverInfoProvider).value, old);
    expect(container.read(serverPublicUrlProvider), isNull);
    answer.completeError(StateError('offline'));
    await expectLater(container.read(serverInfoProvider.future), throwsStateError);
    expect(container.read(serverPublicUrlProvider), isNull);
  });

  group('ServerInfo.fromJson', () {
    Map<String, Object?> json([Map<String, Object?> extra = const {}]) => {
      'name': 'balnana',
      'version': '1.0.0',
      'authMode': 'link',
      'publicUrl': 'https://split.example.com',
      ...extra,
    };

    test('reads an optional source link', () {
      expect(ServerInfo.fromJson(json()).sourceUrl, isNull);
      expect(
        ServerInfo.fromJson(json({'sourceUrl': 'https://git.example.com/balnana'})).sourceUrl,
        Uri.parse('https://git.example.com/balnana'),
      );
    });

    test('ignores source links a browser should not open', () {
      for (final bad in ['javascript:alert(1)', 'intent://x', 'git.example.com', 42]) {
        expect(ServerInfo.fromJson(json({'sourceUrl': bad})).sourceUrl, isNull, reason: '$bad');
      }
    });

    test('reads sign-in providers, skipping malformed ones', () {
      expect(ServerInfo.fromJson(json()).oauthProviders, isEmpty);
      final providers = ServerInfo.fromJson(
        json({
          'oauthProviders': [
            {'id': 'google', 'name': 'Google'},
            {'id': 'oidc'},
            'x',
            {'id': 'oidc', 'name': 'Company SSO'},
          ],
        }),
      ).oauthProviders;
      expect([for (final p in providers) '${p.id}:${p.name}'], ['google:Google', 'oidc:Company SSO']);
    });

    test('rejects other servers', () {
      expect(() => ServerInfo.fromJson(json({'name': 'other'})), throwsFormatException);
    });
  });
}
