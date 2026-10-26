import 'package:balnana/features/groups/link_page.dart';
import 'package:balnana/features/groups/open_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const token = 'AAAAAAAAAAAAAAAAAAAAAA';

  String? route(String link, {String? server = 'https://split.example.com', String? public}) =>
      appRouteFromLink(link, serverUrl: server, publicUrl: public);

  test('links to this server open their page', () {
    expect(route('https://split.example.com/g/$token'), '/g/$token');
    expect(route('https://SPLIT.example.com/g/$token/'), '/g/$token');
    expect(route('https://split.example.com/invite/abc_DEF-1'), '/invite/abc_DEF-1');
    expect(route('https://split.example.com/verify-email?token=t1'), '/verify-email?token=t1');
    expect(route('https://split.example.com/reset-password?token=t2'), '/reset-password?token=t2');
  });

  test('a server under a sub-path and its advertised address both count', () {
    expect(route('https://example.com/balnana/g/$token', server: 'https://example.com/balnana'), '/g/$token');
    expect(
      route(
        'https://split.example.com/g/$token',
        server: 'http://10.0.0.5:8080',
        public: 'https://split.example.com',
      ),
      '/g/$token',
    );
  });

  test("another server's secrets stay away from this one", () {
    for (final link in [
      'https://elsewhere.example.com/g/$token',
      'http://split.example.com/g/$token',
      'https://split.example.com:8443/g/$token',
      'https://example.com/other/g/$token',
      'https://elsewhere.example.com/invite/secret',
    ]) {
      expect(
        () => route(link, server: link.contains('/other/') ? 'https://example.com/balnana' : null),
        throwsA(isA<ForeignGroupLink>()),
        reason: link,
      );
    }
    expect(() => route('https://elsewhere.example.com/g/$token'), throwsA(isA<ForeignGroupLink>()));
  });

  test('anything else is not a link the app opens', () {
    expect(route('https://split.example.com/'), isNull);
    expect(route('https://split.example.com/groups'), isNull);
    expect(route('https://split.example.com/g/short'), isNull);
    expect(route('https://split.example.com/admin'), isNull);
    expect(route('balnana://app/oauth-done'), isNull);
    expect(route('https://user@split.example.com/g/$token'), isNull);
    expect(route('https://example.org/about'), isNull);
  });
}
