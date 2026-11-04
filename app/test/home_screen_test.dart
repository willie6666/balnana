import 'package:balnana/core/home_screen.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:balnana/ui/widgets/home_screen_sync.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _server = 'https://split.example.com';
const _token = 'AAAAAAAAAAAAAAAAAAAAAA';

/// Keeps what the app hands the home screen.
class _Home extends HomeScreen {
  _Home();

  final updates = <({String server, List<HomeScreenGroup> groups, Map<String, String> labels})>[];

  @override
  Future<void> update(String server, List<HomeScreenGroup> groups, Map<String, String> labels) async =>
      updates.add((server: server, groups: groups, labels: labels));
}

GroupSummary _group(String token, String name, BigInt? balance) => GroupSummary(
  token: token,
  name: name,
  currency: 'USD',
  minorDigits: 2,
  memberCount: 3,
  balance: balance,
  updatedAt: DateTime.utc(2026),
);

void main() {
  group('openPath', () {
    test('opens the group, or its new expense', () {
      expect(openPath({'server': _server, 'token': _token}, _server), '/g/$_token');
      expect(openPath({'server': _server, 'token': _token, 'add': '1'}, _server), '/g/$_token/expenses/new');
    });

    test('opens home for another server or a token that is not one', () {
      expect(openPath({'server': 'https://other.example', 'token': _token}, _server), '/groups');
      expect(openPath({'server': _server, 'token': _token}, null), '/groups');
      for (final token in [null, 'short', '$_token/x', '../../../../../../../xx']) {
        expect(openPath({'server': _server, 'token': ?token}, _server), '/groups');
      }
    });
  });

  testWidgets('hands the home screen the groups as home words them, once', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final home = _Home();
    final summaries = Summaries(
      groups: [
        _group('a' * 22, 'Trip', BigInt.from(1250)),
        _group('b' * 22, 'Flat', BigInt.from(-300)),
        _group('c' * 22, 'Lunch', BigInt.zero),
        _group('d' * 22, 'New', null),
      ],
      missing: [],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          serverUrlProvider.overrideWithValue(_server),
          homeScreenProvider.overrideWithValue(home),
          summariesProvider.overrideWith((ref) async => summaries),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreenSync(child: SizedBox()),
        ),
      ),
    );
    await tester.pump();

    final update = home.updates.single;
    expect(update.server, _server);
    expect(update.groups.map((g) => (g.name, g.tone, g.shortcut)), [
      ('Trip', 1, 'Add expense in Trip'),
      ('Flat', -1, 'Add expense in Flat'),
      ('Lunch', 0, 'Add expense in Lunch'),
      ('New', 0, 'Add expense in New'),
    ]);
    expect(update.groups.map((g) => g.balance), [
      allOf(startsWith("You're owed"), contains('12.50')),
      allOf(startsWith('You owe'), contains('3.00')),
      'Settled up',
      '3 people',
    ]);
    expect(update.labels.keys, unorderedEquals(['pick', 'empty', 'add']));

    // Nothing changed, so nothing is sent again.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          serverUrlProvider.overrideWithValue(_server),
          homeScreenProvider.overrideWithValue(home),
          summariesProvider.overrideWith((ref) async => summaries),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreenSync(child: SizedBox(key: Key('again'))),
        ),
      ),
    );
    await tester.pump();
    expect(home.updates, hasLength(1));
  });
}
