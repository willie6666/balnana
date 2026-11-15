import 'package:balnana/core/group_keys.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> on(String server) async {
    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(await SharedPreferences.getInstance()),
        serverUrlProvider.overrideWithValue(server),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('keys are kept per server and survive a restart', () async {
    SharedPreferences.setMockInitialValues({});
    final one = await on('https://one.example.com');
    one.read(groupKeysProvider.notifier)
      ..set('tok', 'k1')
      ..set('other', 'k2');

    // The same server later gets them back; another server has none.
    expect((await on('https://one.example.com')).read(groupKeysProvider), {'tok': 'k1', 'other': 'k2'});
    expect((await on('https://two.example.com')).read(groupKeysProvider), isEmpty);
  });

  test('a key follows its group to a new link, and goes when removed', () async {
    SharedPreferences.setMockInitialValues({});
    final container = await on('https://one.example.com');
    final keys = container.read(groupKeysProvider.notifier)..set('old', 'k1');

    keys.replaceToken('old', 'new');
    expect(container.read(groupKeysProvider), {'new': 'k1'});
    // A group without a key has none to move.
    keys.replaceToken('missing', 'elsewhere');
    expect(container.read(groupKeysProvider), {'new': 'k1'});

    keys.remove('new');
    expect(container.read(groupKeysProvider), isEmpty);
    expect((await on('https://one.example.com')).read(groupKeysProvider), isEmpty);
  });

  test('a broken stored value is read as no keys', () async {
    SharedPreferences.setMockInitialValues({'groups.keys': '{not json'});
    expect((await on('https://one.example.com')).read(groupKeysProvider), isEmpty);
  });

  test('the key goes with requests about its group only', () async {
    final sent = <String, String?>{};
    final dio = Dio(BaseOptions(baseUrl: 'https://one.example.com/api/v1'))
      ..interceptors.add(GroupKeyInterceptor((token) => {'a b': 'k1', 'tok': 'k2'}[token]))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            sent[options.path] = options.headers[groupKeyHeader] as String?;
            handler.resolve(Response(requestOptions: options, statusCode: 204));
          },
        ),
      );

    await dio.get<void>('/g/tok');
    await dio.get<void>('/g/tok/expenses?limit=5');
    await dio.get<void>('/g/a%20b/members');
    await dio.get<void>('/g/unknown');
    await dio.get<void>('/me');

    expect(sent, {
      '/g/tok': 'k2',
      '/g/tok/expenses?limit=5': 'k2',
      '/g/a%20b/members': 'k1',
      '/g/unknown': null,
      '/me': null,
    });
    expect(GroupKeyInterceptor.of(dio, 'tok'), 'k2');
    expect(GroupKeyInterceptor.of(Dio(), 'tok'), isNull);
  });
}
