import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:balnana/app.dart';
import 'package:balnana/core/money.dart';
import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/router.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/live.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/features/expense/receipt.dart';
import 'package:balnana/features/group/group_settings_page.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = 'https://split.example.com';

Group _group(String name) => Group(
  token: 'tok',
  name: name,
  currency: 'USD',
  minorDigits: 2,
  createdAt: DateTime.utc(2026),
  members: [
    Member(id: 'a', name: 'Ana', balance: BigInt.zero),
    Member(id: 'b', name: 'Ben', balance: BigInt.zero),
  ],
);

Expense _expense(int version, String title, {bool hasReceipt = false}) => Expense(
  id: 'e1',
  kind: ExpenseKind.expense,
  title: title,
  amount: BigInt.from(1000),
  occurredAt: DateTime.utc(2026, 1, 2),
  splitMethod: SplitMethod.equal,
  payers: [ExpensePart('a', BigInt.from(1000))],
  splits: [ExpensePart('a', BigInt.from(500)), ExpensePart('b', BigInt.from(500))],
  createdAt: DateTime.utc(2026, 1, 2),
  updatedAt: DateTime.utc(2026, 1, 2),
  version: version,
  hasReceipt: hasReceipt,
);

Map<String, Object?> _expenseJson(String id) => {
  'id': id,
  'kind': 'expense',
  'title': 'Item $id',
  'amount': '10.00',
  'occurredAt': '2026-01-02T10:00:00Z',
  'splitMethod': 'equal',
  'payers': [
    {'memberId': 'a', 'amount': '10.00'},
  ],
  'splits': [
    {'memberId': 'a', 'amount': '5.00'},
    {'memberId': 'b', 'amount': '5.00'},
  ],
  'createdAt': '2026-01-02T10:00:00Z',
  'updatedAt': '2026-01-02T10:00:00Z',
  'version': 1,
};

/// Answers expense pages: the first holds one expense and points to a second,
/// which fails until [failing] is turned off.
class _Pages implements HttpClientAdapter {
  var failing = true;
  var secondPage = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.uri.path, '/api/v1/g/tok/expenses');
    ResponseBody reply(Object body, int status) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        'content-type': ['application/json'],
      },
    );
    if (options.queryParameters['cursor'] == null) {
      return reply({'items': [_expenseJson('e1')], 'nextCursor': 'page2'}, 200);
    }
    secondPage++;
    if (failing) return reply({'code': 'internal', 'message': 'boom'}, 500);
    return reply({'items': [_expenseJson('e2')], 'nextCursor': null}, 200);
  }

  @override
  void close({bool force = false}) {}
}

/// Answers expense pages with whatever matches the search, and keeps every
/// query asked.
class _Search implements HttpClientAdapter {
  final queries = <Map<String, dynamic>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.uri.path, '/api/v1/g/tok/expenses');
    queries.add(options.queryParameters);
    final q = options.queryParameters['q'] as String?;
    final items = [
      for (final id in ['e1', 'e2'])
        if (q == null || 'Item $id'.toLowerCase().contains(q.toLowerCase())) _expenseJson(id),
    ];
    return ResponseBody.fromString(
      jsonEncode({'items': items, 'nextCursor': null}),
      200,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Answers the CSV export of group `tok` and keeps the time zone it was asked in.
class _Export implements HttpClientAdapter {
  Object? utcOffset;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.uri.path, '/api/v1/g/tok/export.csv');
    utcOffset = options.queryParameters['utcOffset'];
    return ResponseBody.fromBytes(
      utf8.encode('Date,Title\n'),
      200,
      headers: {
        'content-type': ['text/csv'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A picture of one transparent pixel.
final _png = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');

/// Answers what the expense editor asks about receipts of `e1`, and keeps
/// every request as "METHOD path content-type".
class _Receipts implements HttpClientAdapter {
  final requests = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    final body = requestStream == null ? <int>[] : await requestStream.expand((b) => b).toList();
    requests.add('${options.method} $path${body.isEmpty ? '' : ' ${options.contentType} ${body.length}'}');
    ResponseBody json(Object data) => ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {
        'content-type': ['application/json'],
      },
    );
    return switch ((options.method, path)) {
      ('GET', '/api/v1/g/tok/expenses/e1/receipt') => ResponseBody.fromBytes(_png, 200, headers: {
        'content-type': ['image/jpeg'],
      }),
      ('PUT', '/api/v1/g/tok/expenses/e1/receipt') => json({..._expenseJson('e1'), 'hasReceipt': true}),
      ('DELETE', '/api/v1/g/tok/expenses/e1/receipt') => ResponseBody.fromString('', 204),
      ('GET', '/api/v1/g/tok/expenses') => json({'items': <Object>[], 'nextCursor': null}),
      _ => ResponseBody.fromString('{"code":"not_found"}', 404, headers: {
        'content-type': ['application/json'],
      }),
    };
  }

  @override
  void close({bool force = false}) {}
}

/// Hands over [_png] for every photo asked for, and keeps where it was asked from.
class _Camera extends ImagePickerPlatform {
  final sources = <ImageSource>[];

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    sources.add(source);
    return XFile.fromData(_png, name: 'receipt.png');
  }
}

/// Keeps what would have been saved.
class _Saver extends FilePickerPlatform {
  final saved = <(String, String, String)>[];

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    saved.add((fileName, utf8.decode(bytes), mimeType));
    return Uri.parse('content://saved/$fileName');
  }
}

/// Starts the app in link mode with this device as Ana in group `tok`.
Future<ProviderContainer> _boot(WidgetTester tester, List<Override> overrides) async {
  SharedPreferences.setMockInitialValues({
    'settings.server': _server,
    'groups.known': '[{"server":"$_server","token":"tok","memberId":"a","addedAt":"2026-01-01T00:00:00Z"}]',
  });
  final prefs = await SharedPreferences.getInstance();
  final info = ServerInfo(version: '1.0.0', authMode: AuthMode.link, publicUrl: _server);
  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        cacheDbProvider.overrideWithValue(null),
        serverInfoProvider.overrideWithValue(AsyncValue.data(info)),
        summariesProvider.overrideWith((ref) async => (groups: <GroupSummary>[], missing: <String>[])),
        balancesProvider.overrideWith((ref, token) async => const Balances(nets: {}, transfers: [])),
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

void main() {
  testWidgets('a live update keeps an edited draft until asked to reload', (tester) async {
    var remote = _expense(1, 'Lunch');
    final container = await _boot(tester, [
      groupProvider.overrideWith((ref, token) async => _group('Flat')),
      expenseProvider.overrideWith((ref, key) async => remote),
      groupEventsProvider.overrideWithValue((dio, token) => const Stream.empty()),
    ]);
    await _go(tester, container, '/g/tok/expenses/e1');
    expect(find.widgetWithText(TextFormField, 'Lunch'), findsOneWidget);

    // Untouched, the form follows the newer version.
    remote = _expense(2, 'Brunch');
    refreshGroupIn(container, 'tok');
    container.invalidate(expenseProvider((token: 'tok', id: 'e1')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Brunch'), findsOneWidget);

    // Changed here, it keeps the draft and asks.
    await tester.enterText(find.widgetWithText(TextFormField, 'Brunch'), 'Team lunch');
    await tester.enterText(find.widgetWithText(TextFormField, '10.00'), '12.00');
    remote = _expense(3, 'Dinner');
    refreshGroupIn(container, 'tok');
    container.invalidate(expenseProvider((token: 'tok', id: 'e1')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Team lunch'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '12.00'), findsOneWidget);
    expect(find.textContaining('Someone else changed this expense'), findsOneWidget);

    await tester.tap(find.text('Reload'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Dinner'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '10.00'), findsOneWidget);
    expect(find.textContaining('Someone else changed this expense'), findsNothing);
  });

  testWidgets('a failed page waits for a retry instead of asking again', (tester) async {
    final pages = _Pages();
    final dio = Dio(BaseOptions(baseUrl: '$_server/api/v1', responseType: ResponseType.json))
      ..httpClientAdapter = pages;
    final container = await _boot(tester, [
      apiProvider.overrideWithValue(dio),
      groupProvider.overrideWith((ref, token) async => _group('Flat')),
      groupEventsProvider.overrideWithValue((dio, token) => const Stream.empty()),
    ]);
    await _go(tester, container, '/g/tok');
    expect(find.text('Item e1'), findsOneWidget);
    expect(pages.secondPage, 1);

    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(pages.secondPage, 1);
    expect(find.text('Retry'), findsOneWidget);

    pages.failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(pages.secondPage, 2);
    expect(find.text('Item e1'), findsOneWidget);
    expect(find.text('Item e2'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('a group catches up whenever its live stream connects', (tester) async {
    var name = 'Flat', gets = 0;
    final streams = <StreamController<LiveEvent>>[];
    final container = await _boot(tester, [
      groupProvider.overrideWith((ref, token) async {
        gets++;
        return _group(name);
      }),
      expenseProvider.overrideWith((ref, key) async => _expense(1, 'Lunch')),
      groupEventsProvider.overrideWithValue((dio, token) {
        final events = StreamController<LiveEvent>();
        streams.add(events);
        return events.stream;
      }),
    ]);
    addTearDown(() {
      for (final s in streams) {
        s.close();
      }
    });

    await _go(tester, container, '/g/tok');
    expect(find.text('Flat'), findsWidgets);
    expect(streams, hasLength(1));
    // Changed between loading the group and connecting.
    name = 'Flat 2';
    streams.last.add(LiveEvent.connected);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Flat 2'), findsWidgets);

    // Changed while the page was closed; the group stays cached meanwhile.
    await _go(tester, container, '/groups');
    name = 'Flat 3';
    await _go(tester, container, '/g/tok');
    expect(find.text('Flat 2'), findsWidgets);
    final before = gets;
    expect(streams, hasLength(2));
    streams.last.add(LiveEvent.connected);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(gets, before + 1);
    expect(find.text('Flat 3'), findsWidgets);
  });

  testWidgets('searching asks the server and clearing brings everything back', (tester) async {
    final search = _Search();
    final dio = Dio(BaseOptions(baseUrl: '$_server/api/v1', responseType: ResponseType.json))
      ..httpClientAdapter = search;
    final container = await _boot(tester, [
      apiProvider.overrideWithValue(dio),
      groupProvider.overrideWith((ref, token) async => _group('Flat')),
      groupEventsProvider.overrideWithValue((dio, token) => const Stream.empty()),
    ]);
    await _go(tester, container, '/g/tok');
    expect(find.text('Item e1'), findsOneWidget);
    expect(find.text('Item e2'), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), '  e2 ');
    await tester.pump(const Duration(milliseconds: 100));
    // Waits for a pause in typing.
    expect(search.queries, hasLength(1));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(search.queries.last['q'], 'e2');
    expect(find.text('Item e1'), findsNothing);
    expect(find.text('Item e2'), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), 'nothing');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Nothing matches'), findsOneWidget);

    // Below the group's header, which scrolls away.
    await tester.drag(find.byType(NestedScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear filters'));
    await tester.pumpAndSettle();
    expect(search.queries.last.containsKey('q'), isFalse);
    expect(find.text('Item e1'), findsOneWidget);
    expect(find.text('Item e2'), findsOneWidget);
    expect(find.text('nothing'), findsNothing);
  });

  testWidgets('stats show the spending and lead to its expenses', (tester) async {
    final search = _Search();
    final dio = Dio(BaseOptions(baseUrl: '$_server/api/v1', responseType: ResponseType.json))
      ..httpClientAdapter = search;
    final periods = <Period?>[];
    final container = await _boot(tester, [
      apiProvider.overrideWithValue(dio),
      groupProvider.overrideWith((ref, token) async => _group('Flat')),
      groupEventsProvider.overrideWithValue((dio, token) => const Stream.empty()),
      statsProvider.overrideWith((ref, key) async {
        periods.add(key.period);
        return GroupStats.fromJson({
          'total': '138.00',
          'count': 4,
          'categories': [
            {'categoryId': 'food', 'amount': '90.00', 'count': 1},
            {'categoryId': 'transport', 'amount': '42.00', 'count': 2},
            {'categoryId': null, 'amount': '6.00', 'count': 1},
          ],
          'members': [
            {'memberId': 'a', 'paid': '48.00', 'share': '69.00'},
            {'memberId': 'b', 'paid': '90.00', 'share': '69.00'},
          ],
          'months': [
            {'month': '2026-09', 'amount': '30.00'},
            {'month': '2026-10', 'amount': '108.00'},
          ],
        }, 2);
      }),
    ]);
    await _go(tester, container, '/g/tok');
    await tester.tap(find.byTooltip('Spending'));
    await tester.pumpAndSettle();

    expect(periods, [null]);
    expect(find.text('\$138.00'), findsOneWidget);
    expect(find.text('4 expenses'), findsOneWidget);
    // The latest month is read out first.
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('\$108.00'), findsOneWidget);
    await tester.tap(find.text('Sep'));
    await tester.pump();
    expect(find.text('September 2026'), findsOneWidget);

    expect(find.text('Food & drink'), findsOneWidget);
    expect(find.text('2 expenses'), findsOneWidget);
    // Spending without a category cannot be listed on its own.
    await tester.ensureVisible(find.text('No category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No category'));
    await tester.pumpAndSettle();
    expect(find.text('No category'), findsOneWidget);

    await tester.ensureVisible(find.text('Transport'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transport'));
    await tester.pumpAndSettle();
    expect(container.read(expenseFilterProvider('tok')), const ExpenseFilter(category: 'transport'));
    expect(search.queries.last['category'], 'transport');
    expect(find.text('Clear filters'), findsOneWidget);
  });

  testWidgets('a group exports as a CSV file', (tester) async {
    final export = _Export();
    final saver = _Saver();
    FilePickerPlatform.instance = saver;
    final dio = Dio(BaseOptions(baseUrl: '$_server/api/v1', responseType: ResponseType.json))
      ..httpClientAdapter = export;
    final container = await _boot(tester, [
      apiProvider.overrideWithValue(dio),
      groupProvider.overrideWith((ref, token) async => _group('Trip: Japan/Korea')),
    ]);
    await _go(tester, container, '/g/tok/settings');
    await tester.scrollUntilVisible(find.text('Export as CSV'), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Export as CSV'));
    await tester.pumpAndSettle();

    expect(saver.saved, [('Trip JapanKorea.csv', 'Date,Title\n', 'text/csv')]);
    expect(export.utcOffset, DateTime.now().timeZoneOffset.inMinutes);
    expect(find.text('Exported'), findsOneWidget);
  });

  testWidgets('a receipt photo waits for save, and alone leaves the expense as it is', (tester) async {
    final server = _Receipts();
    final camera = _Camera();
    ImagePickerPlatform.instance = camera;
    final dio = Dio(BaseOptions(baseUrl: '$_server/api/v1', responseType: ResponseType.json))
      ..httpClientAdapter = server;
    var remote = _expense(1, 'Lunch');
    final container = await _boot(tester, [
      apiProvider.overrideWithValue(dio),
      groupProvider.overrideWith((ref, token) async => _group('Flat')),
      expenseProvider.overrideWith((ref, key) async => remote),
      groupEventsProvider.overrideWithValue((dio, token) => const Stream.empty()),
    ]);
    await _go(tester, container, '/g/tok/expenses/e1');
    await tester.ensureVisible(find.text('Take a photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take a photo'));
    await tester.pumpAndSettle();
    expect(camera.sources, [ImageSource.camera]);
    expect(find.text('Remove'), findsOneWidget);
    expect(server.requests, isEmpty);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(server.requests.where((r) => r != 'GET /api/v1/g/tok/expenses'), [
      'PUT /api/v1/g/tok/expenses/e1/receipt image/png ${_png.length}',
    ]);

    // A saved photo shows, and removing it is sent on save.
    server.requests.clear();
    remote = _expense(1, 'Lunch', hasReceipt: true);
    await _go(tester, container, '/g/tok/expenses/e1');
    await tester.ensureVisible(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(server.requests, ['GET /api/v1/g/tok/expenses/e1/receipt']);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a picture'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(server.requests, contains('DELETE /api/v1/g/tok/expenses/e1/receipt'));
    expect(server.requests.where((r) => r.startsWith('PUT')), isEmpty);
  });

  test('only JPEG, PNG and WebP pictures are sent', () {
    expect(receiptType(_png), 'image/png');
    expect(receiptType(Uint8List.fromList([0xff, 0xd8, 0xff, 0xe0])), 'image/jpeg');
    expect(receiptType(Uint8List.fromList([...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits])), 'image/webp');
    expect(receiptType(Uint8List.fromList('GIF89a'.codeUnits)), isNull);
    expect(receiptType(Uint8List(0)), isNull);
  });

  test('file names keep what is safe', () {
    expect(fileName('Trip: Japan/Korea'), 'Trip JapanKorea');
    expect(fileName('Café 2026 🏖'), 'Café 2026 🏖');
    expect(fileName(' ?* '), 'balnana');
  });

  test('a filter asks for what it narrows to', () {
    expect(const ExpenseFilter().query, isEmpty);
    expect(const ExpenseFilter(text: '   ').isEmpty, isTrue);
    final from = DateTime(2026, 10), to = DateTime(2026, 11);
    expect(
      ExpenseFilter(text: ' taxi ', member: 'a', payments: true, period: (from: from, to: to)).query,
      {
        'q': 'taxi',
        'member': 'a',
        'kind': 'payment',
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
      },
    );
    expect(const ExpenseFilter(category: 'food').query, {'category': 'food'});
  });

  test('stats read amounts in minor units and months in local time', () {
    final s = GroupStats.fromJson({
      'total': '1.5',
      'count': 1,
      'categories': [
        {'categoryId': null, 'amount': '1.5', 'count': 1},
      ],
      'members': [
        {'memberId': 'a', 'paid': '1.5', 'share': '0.75'},
      ],
      'months': [
        {'month': '2026-01', 'amount': '1.5'},
      ],
    }, 2);
    expect(s.total, BigInt.from(150));
    expect(s.categories.single.category, isNull);
    expect(s.members.single.share, BigInt.from(75));
    expect(s.months.single.month, DateTime(2026));
  });
}
