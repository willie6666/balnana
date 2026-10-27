import 'dart:async';
import 'dart:convert';

import 'package:balnana/app.dart';
import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/push.dart';
import 'package:balnana/core/router.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/core/session.dart';
import 'package:balnana/core/settings.dart';
import 'package:balnana/data/known_groups.dart';
import 'package:balnana/data/live.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _a = 'https://a.example';
const _b = 'https://b.example';
const _token = 'AAAAAAAAAAAAAAAAAAAAAA';

class _NoExpenses extends ExpensesNotifier {
  _NoExpenses(super.token);

  @override
  Future<ExpenseList> build() async => const ExpenseList([], null);
}

Response<Object?> _notFound(RequestOptions o) =>
    Response(requestOptions: o, statusCode: 404, data: {'code': 'not_found'});

void main() {
  // A group's token is the key to it: choosing another server must not hand
  // it the token of a group on the last one.
  testWidgets('a group left open sends nothing of it to the next server', (tester) async {
    SharedPreferences.setMockInitialValues({
      'settings.server': _a,
      'groups.known': jsonEncode([
        {'server': _a, 'token': _token, 'memberId': 'ana', 'addedAt': '2026-01-01T00:00:00Z'},
      ]),
    });
    final prefs = await SharedPreferences.getInstance();
    final sent = <RequestOptions>[];
    final live = <String>[];
    final container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        cacheDbProvider.overrideWithValue(null),
        pushServiceProvider.overrideWithValue(null),
        accountProvider.overrideWithValue(const AsyncData(null)),
        serverInfoProvider.overrideWithValue(
          const AsyncData(ServerInfo(version: 'test', authMode: AuthMode.link, publicUrl: _a)),
        ),
        groupEventsProvider.overrideWithValue((dio, token) {
          live.add('${dio.options.baseUrl} $token');
          return const Stream.empty();
        }),
        balancesProvider.overrideWith((ref, token) async => const Balances(nets: {}, transfers: [])),
        expensesProvider.overrideWith2(_NoExpenses.new),
        statsProvider.overrideWith(
          (ref, key) async => GroupStats(total: BigInt.zero, count: 0, categories: [], members: [], months: []),
        ),
        apiProvider.overrideWith((ref) {
          final url = ref.watch(serverUrlProvider)!;
          ref.watch(sessionProvider);
          final dio = Dio(BaseOptions(baseUrl: '$url/api/v1'));
          dio.interceptors.add(
            InterceptorsWrapper(
              onRequest: (o, handler) {
                sent.add(o);
                if (o.path == '/groups/summaries') {
                  handler.resolve(Response(requestOptions: o, data: {'groups': <Object>[], 'missing': <String>[]}));
                } else if (url == _a && o.path == '/g/$_token') {
                  handler.resolve(
                    Response(
                      requestOptions: o,
                      data: {
                        'token': _token,
                        'name': 'Secret A',
                        'currency': 'USD',
                        'minorDigits': 2,
                        'createdAt': '2026-01-01T00:00:00Z',
                        'members': [
                          {'id': 'ana', 'name': 'Ana', 'balance': '0.00'},
                        ],
                      },
                    ),
                  );
                } else {
                  handler.reject(
                    DioException.badResponse(statusCode: 404, requestOptions: o, response: _notFound(o)),
                  );
                }
              },
            ),
          );
          ref.onDispose(dio.close);
          return dio;
        }),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const BalnanaApp()));
    await tester.pumpAndSettle();
    expect(find.text('Secret A'), findsWidgets);

    // The group page stays under Settings while another server is chosen.
    container.read(routerProvider).go('/settings');
    await tester.pumpAndSettle();
    live.clear();
    container.read(settingsProvider.notifier).setServerUrl(_b);
    await tester.pumpAndSettle();
    final sub = container.listen(summariesProvider, (_, _) {});
    await tester.pumpAndSettle();
    sub.close();

    final toB = sent.where((o) => o.uri.host == 'b.example');
    expect(toB.where((o) => o.uri.toString().contains(_token) || jsonEncode(o.data).contains(_token)), isEmpty);
    expect(container.read(knownGroupsProvider).map((g) => g.token), isNot(contains(_token)));
    expect(live, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  // A session is for the server that gave it, however late it comes back.
  for (final register in [false, true]) {
    testWidgets('a late ${register ? 'sign-up' : 'sign-in'} on one server is not kept for the next', (tester) async {
      SharedPreferences.setMockInitialValues({'settings.server': _a});
      final prefs = await SharedPreferences.getInstance();
      final answer = Completer<Response<Object?>>();
      RequestOptions? asked;
      final sent = <RequestOptions>[];
      final container = ProviderContainer(
        retry: (count, error) => null,
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          cacheDbProvider.overrideWithValue(null),
          pushServiceProvider.overrideWithValue(null),
          accountProvider.overrideWithValue(const AsyncData(null)),
          serverInfoProvider.overrideWithValue(
            const AsyncData(
              ServerInfo(version: 'test', authMode: AuthMode.accounts, password: true, publicUrl: _a),
            ),
          ),
          apiProvider.overrideWith((ref) {
            final url = ref.watch(serverUrlProvider)!;
            final session = ref.watch(sessionProvider);
            final dio = Dio(
              BaseOptions(
                baseUrl: '$url/api/v1',
                headers: {if (session.token != null) 'Authorization': 'Bearer ${session.token}'},
              ),
            );
            dio.interceptors.add(
              InterceptorsWrapper(
                onRequest: (o, handler) async {
                  sent.add(o);
                  if (o.path == '/auth/login' || o.path == '/auth/register') {
                    asked = o;
                    handler.resolve(await answer.future);
                  } else {
                    handler.resolve(Response(requestOptions: o, data: <String, Object?>{}));
                  }
                },
              ),
            );
            ref.onDispose(dio.close);
            return dio;
          }),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const BalnanaApp()));
      await tester.pumpAndSettle();
      if (register) {
        await tester.tap(find.text('Create an account'));
        await tester.pumpAndSettle();
        await tester.enterText(find.widgetWithText(TextFormField, 'Your name'), 'Ana');
      }
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'ana@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'correct horse');
      await tester.tap(find.widgetWithText(FilledButton, register ? 'Create account' : 'Sign in'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(asked?.uri.host, 'a.example');

      container.read(routerProvider).go('/settings');
      await tester.pumpAndSettle();
      container.read(settingsProvider.notifier).setServerUrl(_b);
      await tester.pumpAndSettle();
      answer.complete(
        Response(
          requestOptions: asked!,
          data: {
            'token': 'session-of-a',
            'user': {'id': 'ana', 'name': 'Ana', 'email': 'ana@example.com', 'hasPassword': true},
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(prefs.getString('session.tokens'), isNull);
      expect(container.read(sessionProvider).token, isNull);
      expect(container.read(routerProvider).state.matchedLocation, '/settings');
      await tester.runAsync(() => container.read(apiProvider)!.get<Object?>('/probe'));
      expect(sent.where((o) => o.uri.host == 'b.example' && o.headers.containsKey('Authorization')), isEmpty);
      await tester.pumpWidget(const SizedBox());
    });
  }

  test('a session asked for before another started is not kept', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(await SharedPreferences.getInstance()),
        serverUrlProvider.overrideWithValue(_a),
        cacheDbProvider.overrideWithValue(null),
      ],
    );
    addTearDown(container.dispose);
    final session = container.read(sessionProvider.notifier);
    final first = container.read(identityProvider);
    final second = container.read(identityProvider);
    expect(session.set('newer', from: second), isTrue);
    // The older sign-in, or a sign-out asked for before it, comes back late.
    expect(session.set('older', from: first), isFalse);
    expect(session.set(null, from: first), isFalse);
    expect(container.read(sessionProvider).token, 'newer');
  });
}
