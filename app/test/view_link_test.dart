import 'dart:convert';

import 'package:balnana/app.dart';
import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/router.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/live.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/ui/widgets/grouped_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = 'https://split.example.com';
const _viewToken = 'VVVVVVVVVVVVVVVVVVVVVV';

final _group = Group(
  token: 'tok',
  name: 'Flat',
  currency: 'USD',
  minorDigits: 2,
  createdAt: DateTime.utc(2026),
  members: [
    Member(id: 'a', name: 'Ana', balance: BigInt.zero),
    Member(id: 'b', name: 'Ben', balance: BigInt.zero),
  ],
);

/// A server with group `tok`'s view-only link, which keeps what is sent to it.
class _Server implements HttpClientAdapter {
  Map<String, Object?>? link;
  final requests = <String>[];
  final bodies = <Object?>[];

  static ResponseBody json(Object? data, [int status = 200]) => ResponseBody.fromString(
    jsonEncode(data),
    status,
    headers: {
      'content-type': ['application/json'],
    },
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path, method = options.method;
    if (path == '/api/v1/g/tok/expenses') return json({'items': <Object>[], 'nextCursor': null});
    requests.add('$method $path');
    if (options.data != null) bodies.add(options.data);
    final body = options.data is Map ? options.data as Map<String, Object?> : const <String, Object?>{};
    switch ((method, path)) {
      case ('GET', '/api/v1/g/tok/view-link'):
        return json({'link': link});
      case ('POST', '/api/v1/g/tok/view-link'):
        link = {
          'token': _viewToken,
          'live': body['live'],
          'snapshotAt': body['live'] == true ? null : '2026-11-20T10:00:00Z',
          'show': body['show'],
          'createdAt': '2026-11-20T10:00:00Z',
          'expiresAt': body['expiresAt'],
        };
        return json(link, 201);
      case ('PUT', '/api/v1/g/tok/view-link'):
        link = {...link!, 'show': body['show'], 'expiresAt': body['expiresAt']};
        return json(link);
      case ('DELETE', '/api/v1/g/tok/view-link'):
        link = null;
        return ResponseBody.fromString('', 204);
    }
    return json({'code': 'not_found', 'message': 'no'}, 404);
  }

  @override
  void close({bool force = false}) {}
}

/// A server whose view-only link shows a group to anyone.
class _Viewer implements HttpClientAdapter {
  _Viewer(this.status, [this.code]);

  final int status;
  final String? code;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (code != null) return _Server.json({'code': code, 'message': 'no'}, status);
    return switch (options.uri.path) {
      '/api/v1/v/$_viewToken' => _Server.json({
        'name': 'Trip',
        'emoji': '🏔',
        'currency': 'USD',
        'minorDigits': 2,
        'live': false,
        'asOf': '2026-11-20T10:00:00Z',
        'show': {
          'balances': true,
          'expenses': true,
          'spending': false,
          'notes': false,
          'places': false,
          'receipts': false,
        },
        'members': [
          {'id': 'a', 'name': 'Ana', 'balance': '5.00'},
          {'id': 'b', 'name': 'Ben', 'balance': '-5.00'},
        ],
        'categories': <Object>[],
        'transfers': [
          {'fromMemberId': 'b', 'toMemberId': 'a', 'amount': '5.00'},
        ],
      }),
      '/api/v1/v/$_viewToken/expenses' => _Server.json({
        'items': [
          {
            'id': 'e1',
            'title': 'Lunch',
            'amount': '10.00',
            'occurredAt': '2026-11-19T10:00:00Z',
            'splitMethod': 'equal',
            'payers': [
              {'memberId': 'a', 'amount': '10.00'},
            ],
            'splits': [
              {'memberId': 'a', 'amount': '5.00'},
              {'memberId': 'b', 'amount': '5.00'},
            ],
            'createdAt': '2026-11-19T10:00:00Z',
            'updatedAt': '2026-11-19T10:00:00Z',
          },
        ],
        'nextCursor': null,
      }),
      _ => _Server.json({'code': 'not_found', 'message': 'no'}, 404),
    };
  }

  @override
  void close({bool force = false}) {}
}

/// Starts the app in link mode as Ana in group `tok`, talking to [adapter].
Future<ProviderContainer> _boot(
  WidgetTester tester,
  HttpClientAdapter adapter, {
  bool billing = false,
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({
    'settings.server': _server,
    'groups.known': '[{"server":"$_server","token":"tok","memberId":"a","addedAt":"2026-01-01T00:00:00Z"}]',
  });
  final prefs = await SharedPreferences.getInstance();
  final info = ServerInfo(version: '1.0.0', authMode: AuthMode.link, publicUrl: _server, billing: billing);
  final dio = Dio(BaseOptions(baseUrl: '$_server/api/v1', responseType: ResponseType.json))
    ..httpClientAdapter = adapter;
  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        cacheDbProvider.overrideWithValue(null),
        serverInfoProvider.overrideWithValue(AsyncValue.data(info)),
        summariesProvider.overrideWith((ref) async => const Summaries(groups: [], missing: [])),
        balancesProvider.overrideWith((ref, token) async => const Balances(nets: {}, transfers: [])),
        apiProvider.overrideWithValue(dio),
        groupProvider.overrideWith((ref, token) async => _group),
        groupEventsProvider.overrideWithValue((dio, token) => const Stream.empty()),
        ...overrides,
      ],
      child: const BalnanaApp(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(BalnanaApp)));
}

Future<void> _go(WidgetTester tester, ProviderContainer container, String path) async {
  container.read(routerProvider).go(path);
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).last);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder _switch(String title) => find.byWidgetPredicate((w) => w is GroupedSwitchTile && w.title == title);

void main() {
  testWidgets('group settings lead to making, changing and turning off the link', (tester) async {
    final server = _Server();
    final container = await _boot(tester, server);
    await _go(tester, container, '/g/tok/settings');
    await _tap(tester, find.widgetWithText(GroupedTile, 'View-only link'));
    expect(server.requests, ['GET /api/v1/g/tok/view-link']);

    // A snapshot can't show receipts, so that switch is off and dimmed.
    await _tap(tester, find.text('Snapshot'));
    expect(tester.widget<GroupedSwitchTile>(_switch('Receipt photos')).onChanged, isNull);
    await _tap(tester, _switch('Expense notes'));
    await _tap(tester, find.text('Create link'));
    // Then it loads the link as it is now.
    expect(server.requests.sublist(1), ['POST /api/v1/g/tok/view-link', 'GET /api/v1/g/tok/view-link']);
    expect(server.bodies.last, {
      'live': false,
      'show': {
        'balances': true,
        'expenses': true,
        'spending': true,
        'notes': true,
        'places': false,
        'receipts': false,
      },
    });

    // The link is shown to pass on.
    expect(find.text('$_server/v/$_viewToken'), findsOneWidget);
    expect(find.textContaining('Snapshot of'), findsOneWidget);
    expect(find.text('Not opened yet'), findsOneWidget);

    // A change is saved at once, keeping the rest as it was.
    await _tap(tester, _switch('Spending'));
    expect(server.requests.reversed.elementAt(1), 'PUT /api/v1/g/tok/view-link');
    expect((server.bodies.last as Map)['show'], containsPair('spending', false));
    expect((server.bodies.last as Map)['show'], containsPair('notes', true));

    await _tap(tester, find.text('Turn off link'));
    await tester.tap(find.widgetWithText(FilledButton, 'Turn off link'));
    await tester.pumpAndSettle();
    expect(server.requests.last, 'GET /api/v1/g/tok/view-link');
    expect(server.requests, contains('DELETE /api/v1/g/tok/view-link'));
    expect(find.text('Create link'), findsOneWidget);
  });

  testWidgets('a link always shows balances, expenses or spending', (tester) async {
    final container = await _boot(tester, _Server());
    await _go(tester, container, '/g/tok/settings/view-link');
    await _tap(tester, _switch('Balances'));
    await _tap(tester, _switch('Spending'));
    // Expenses are all that is left, and what an expense shows goes with them.
    expect(tester.widget<GroupedSwitchTile>(_switch('Expenses')).onChanged, isNull);
    expect(tester.widget<GroupedSwitchTile>(_switch('Expense notes')).onChanged, isNotNull);
    await _tap(tester, _switch('Balances'));
    await _tap(tester, _switch('Expenses'));
    expect(tester.widget<GroupedSwitchTile>(_switch('Expense notes')).onChanged, isNull);
  });

  testWidgets('a plan without the link offers the plans instead of making one', (tester) async {
    final container = await _boot(
      tester,
      _Server(),
      billing: true,
      overrides: [
        groupPlanProvider.overrideWith(
          (ref, token) async => const GroupPlan(
            planName: 'Free',
            members: PlanUsage(),
            receipts: PlanUsage(),
            recurring: PlanUsage(),
          ),
        ),
      ],
    );
    await _go(tester, container, '/g/tok/settings/view-link');
    expect(find.text('Needs an upgraded plan'), findsOneWidget);
    final create = find.widgetWithText(FilledButton, 'Create link');
    await tester.scrollUntilVisible(create, 200, scrollable: find.byType(Scrollable).last);
    expect(tester.widget<FilledButton>(create).onPressed, isNull);
  });

  testWidgets('anyone with the link sees the group as it was, read-only', (tester) async {
    final container = await _boot(tester, _Viewer(200));
    await _go(tester, container, '/v/$_viewToken');
    expect(find.text('🏔 Trip'), findsOneWidget);
    expect(find.text('Ana'), findsWidgets);
    expect(find.textContaining('View only'), findsOneWidget);
    expect(find.text('Lunch', skipOffstage: false), findsOneWidget);
    // Nothing to add or edit.
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  for (final (status, code, title) in [
    (404, 'not_found', "This link doesn't work"),
    (410, 'view_link_expired', 'This link has expired'),
    (403, 'view_link_paused', 'This link is paused'),
  ]) {
    testWidgets('a link that is $code says so', (tester) async {
      final container = await _boot(tester, _Viewer(status, code));
      await _go(tester, container, '/v/$_viewToken');
      expect(find.text(title), findsOneWidget);
    });
  }
}
