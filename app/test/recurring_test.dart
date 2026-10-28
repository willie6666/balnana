import 'dart:convert';

import 'package:balnana/app.dart';
import 'package:balnana/core/money.dart';
import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/router.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/api.dart' show deviceTimeZone;
import 'package:balnana/data/live.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = 'https://split.example.com';

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

Map<String, Object?> _recurring({
  String id = 'r1',
  String title = 'Rent',
  bool paused = false,
  String? nextAt = '2026-12-01T09:00:00Z',
  int version = 1,
}) => {
  'id': id,
  'title': title,
  'amount': '800.00',
  'splitMethod': 'equal',
  'payers': [
    {'memberId': 'a', 'amount': '800.00'},
  ],
  'splits': [
    {'memberId': 'a', 'amount': '400.00'},
    {'memberId': 'b', 'amount': '400.00'},
  ],
  'repeat': {'unit': 'month', 'every': 1},
  'startsAt': '2026-10-01T09:00:00Z',
  'timeZone': 'Europe/Berlin',
  'nextAt': nextAt,
  'lastAt': '2026-11-01T09:00:00Z',
  'paused': paused,
  'createdBy': 'a',
  'createdAt': '2026-10-01T09:00:00Z',
  'updatedAt': '2026-10-01T09:00:00Z',
  'version': version,
};

/// A server holding the group's recurring expenses, which keeps what is
/// sent to it.
class _Server implements HttpClientAdapter {
  _Server(this.items);

  final List<Map<String, Object?>> items;
  final requests = <String>[];
  final bodies = <Map<String, Object?>>[];

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
    if (options.data case final Map<String, Object?> body) bodies.add(body);
    final id = path.startsWith('/api/v1/g/tok/recurring/') ? path.split('/').last : null;
    final index = items.indexWhere((r) => r['id'] == id);
    switch ((method, id)) {
      case ('GET', null):
        return json(items);
      case ('POST', null):
        // The input's splits carry no amounts, so the reply keeps the stored ones.
        final made = {
          ...options.data as Map<String, Object?>,
          ..._recurring(id: 'r2', title: (options.data as Map)['title'] as String),
        };
        items.add(made);
        return json(made, 201);
      case (_, _) when index < 0:
        return json({'code': 'not_found', 'message': 'no'}, 404);
      case ('GET', _):
        return json(items[index]);
      case ('PATCH', _):
        items[index] = {...items[index], 'paused': (options.data as Map)['paused']};
        return json(items[index]);
      case ('PUT', _):
        final body = options.data as Map<String, Object?>;
        if (body['version'] != items[index]['version']) {
          return json({'code': 'recurring_version_conflict', 'message': 'changed'}, 409);
        }
        items[index] = {
          ...items[index],
          ...body,
          'splits': items[index]['splits'],
          'version': (body['version'] as int) + 1,
        };
        return json(items[index]);
      case ('DELETE', _):
        items.removeAt(index);
        return ResponseBody.fromString('', 204);
    }
    return json({'code': 'not_found', 'message': 'no'}, 404);
  }

  @override
  void close({bool force = false}) {}
}

/// Starts the app in link mode as Ana in group `tok`, on [server].
Future<ProviderContainer> _boot(WidgetTester tester, _Server server, [List<Override> overrides = const []]) async {
  SharedPreferences.setMockInitialValues({
    'settings.server': _server,
    'groups.known': '[{"server":"$_server","token":"tok","memberId":"a","addedAt":"2026-01-01T00:00:00Z"}]',
  });
  final prefs = await SharedPreferences.getInstance();
  final info = ServerInfo(version: '1.0.0', authMode: AuthMode.link, publicUrl: _server);
  final dio = Dio(BaseOptions(baseUrl: '$_server/api/v1', responseType: ResponseType.json))..httpClientAdapter = server;
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

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    final zone = deviceTimeZone;
    addTearDown(() => deviceTimeZone = zone);
    deviceTimeZone = () async => 'Asia/Taipei';
  });

  testWidgets('group settings lead to the recurring expenses, empty at first', (tester) async {
    final server = _Server([]);
    final container = await _boot(tester, server);
    await _go(tester, container, '/g/tok/settings');
    await tester.scrollUntilVisible(find.text('Recurring expenses'), 200, scrollable: find.byType(Scrollable).last);
    await _tapVisible(tester, find.text('Recurring expenses'));

    expect(find.text('No recurring expenses'), findsOneWidget);
    await tester.tap(find.text('Add recurring expense'));
    await tester.pumpAndSettle();

    // The editor opens repeating every month.
    final monthly = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Monthly'));
    expect(monthly.selected, isTrue);
    expect(find.text('Every'), findsOneWidget);
    expect(find.text('Take a photo'), findsNothing);
  });

  testWidgets('a new expense can be made to repeat', (tester) async {
    final server = _Server([]);
    final container = await _boot(tester, server);
    await _go(tester, container, '/g/tok/expenses/new');

    // Repeating hides the receipt, which belongs to each expense added.
    expect(find.text('Take a photo', skipOffstage: false), findsOneWidget);
    await _tapVisible(tester, find.widgetWithText(ChoiceChip, 'Weekly'));
    expect(find.text('Take a photo', skipOffstage: false), findsNothing);

    await tester.enterText(find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == '0.00'), '30');
    await tester.enterText(find.widgetWithText(TextFormField, 'What was it for?'), 'Cleaner');
    final every = find.byWidgetPredicate(
      (w) => w is TextField && w.controller?.text == '1' && w.textAlign == TextAlign.center,
    );
    await tester.enterText(every, '2');
    await tester.pumpAndSettle();
    expect(find.text('weeks'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(server.requests, contains('POST /api/v1/g/tok/recurring'));
    final sent = server.bodies.last;
    expect(sent['title'], 'Cleaner');
    expect(sent['amount'], '30.00');
    expect(sent['repeat'], {'unit': 'week', 'every': 2});
    expect(sent['timeZone'], 'Asia/Taipei');
    expect(sent.containsKey('startsAt'), isTrue);
    expect(sent.containsKey('occurredAt'), isFalse);
    expect(sent.containsKey('endsOn'), isFalse);
  });

  testWidgets('the list shows when each comes back, and pauses, resumes and deletes', (tester) async {
    final server = _Server([
      _recurring(),
      _recurring(id: 'r3', title: 'Gym', paused: true),
      _recurring(id: 'r4', title: 'Old lease', nextAt: null),
    ]);
    final container = await _boot(tester, server);
    await _go(tester, container, '/g/tok/settings/recurring');

    expect(find.text('Rent'), findsOneWidget);
    expect(find.textContaining('Every month · Next on'), findsOneWidget);
    expect(find.text('Every month · Paused'), findsOneWidget);
    expect(find.text('Every month · Ended'), findsOneWidget);
    expect(find.text(r'$800.00'), findsNWidgets(3));

    Future<void> choose(String title, String action) async {
      await tester.tap(
        find.descendant(of: find.widgetWithText(ListTile, title), matching: find.byIcon(Icons.more_vert)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
    }

    // An ended one can only be changed or deleted.
    await tester.tap(
      find.descendant(of: find.widgetWithText(ListTile, 'Old lease'), matching: find.byIcon(Icons.more_vert)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pause'), findsNothing);
    expect(find.text('Resume'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    await choose('Rent', 'Pause');
    expect(server.requests, contains('PATCH /api/v1/g/tok/recurring/r1'));
    expect(server.bodies.last, {'paused': true});
    expect(find.text('Every month · Paused'), findsNWidgets(2));

    await choose('Gym', 'Resume');
    expect(server.bodies.last, {'paused': false});

    // Deleting asks first.
    await choose('Gym', 'Delete');
    expect(find.text('Stop repeating?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(server.requests, isNot(contains('DELETE /api/v1/g/tok/recurring/r3')));
    await choose('Gym', 'Delete');
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(server.requests, contains('DELETE /api/v1/g/tok/recurring/r3'));
    expect(find.text('Gym'), findsNothing);
    expect(find.text('Recurring expense deleted'), findsOneWidget);
  });

  testWidgets('a recurring expense is changed in the editor, and a stale one reloads', (tester) async {
    final server = _Server([_recurring()]);
    final container = await _boot(tester, server);
    await _go(tester, container, '/g/tok/settings/recurring');
    await tester.tap(find.text('Rent'));
    await tester.pumpAndSettle();

    expect(find.text('Edit recurring expense'), findsOneWidget);
    // It cannot be turned into a single expense here; deleting stops it.
    expect(find.widgetWithText(ChoiceChip, "Doesn't repeat"), findsNothing);
    expect(tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Monthly')).selected, isTrue);

    await tester.enterText(find.widgetWithText(TextFormField, 'What was it for?'), 'Rent and heating');
    await _tapVisible(tester, find.widgetWithText(ChoiceChip, 'Yearly'));

    // Someone else changed it meanwhile.
    server.items[0] = {...server.items[0], 'title': 'Flat rent', 'version': 2};
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(server.bodies.last['version'], 1);
    expect(find.textContaining('Someone else changed this recurring expense'), findsOneWidget);
    await tester.tap(find.text('Reload'));
    await tester.pumpAndSettle();
    final title = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'What was it for?'));
    expect(title.controller?.text, 'Flat rent');

    await tester.enterText(find.widgetWithText(TextFormField, 'What was it for?'), 'Rent and heating');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final sent = server.bodies.last;
    expect(sent['version'], 2);
    expect(sent['title'], 'Rent and heating');
    // The zone it was set up in stays.
    expect(sent['timeZone'], 'Europe/Berlin');
    expect(find.text('Edit recurring expense'), findsNothing);
    expect(find.text('Rent and heating'), findsOneWidget);
  });

  testWidgets('an expense added by a schedule links to it', (tester) async {
    final server = _Server([_recurring()]);
    final added = Expense(
      id: 'e1',
      kind: ExpenseKind.expense,
      title: 'Rent',
      amount: BigInt.from(80000),
      occurredAt: DateTime.utc(2026, 11, 1, 9),
      splitMethod: SplitMethod.equal,
      payers: [ExpensePart('a', BigInt.from(80000))],
      splits: [ExpensePart('a', BigInt.from(40000)), ExpensePart('b', BigInt.from(40000))],
      createdAt: DateTime.utc(2026, 11, 1, 9),
      updatedAt: DateTime.utc(2026, 11, 1, 9),
      version: 1,
      recurringId: 'r1',
    );
    final container = await _boot(tester, server, [expenseProvider.overrideWith((ref, key) async => added)]);
    await _go(tester, container, '/g/tok/expenses/e1');

    // An expense already added does not repeat itself.
    expect(find.widgetWithText(ChoiceChip, 'Monthly', skipOffstage: false), findsNothing);
    await _tapVisible(tester, find.text('Added by a recurring expense'));
    expect(find.text('Edit recurring expense'), findsOneWidget);
    expect(server.requests, contains('GET /api/v1/g/tok/recurring/r1'));
  });

  testWidgets('a deleted recurring expense says so', (tester) async {
    final server = _Server([]);
    final container = await _boot(tester, server);
    await _go(tester, container, '/g/tok/recurring/gone');
    expect(find.text('The recurring expense was deleted or is no longer available.'), findsOneWidget);
  });
}
