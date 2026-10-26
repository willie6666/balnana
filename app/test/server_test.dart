import 'package:balnana/core/server.dart';
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

    test('rejects other servers', () {
      expect(() => ServerInfo.fromJson(json({'name': 'other'})), throwsFormatException);
    });
  });
}
