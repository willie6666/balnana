import 'package:balnana/core/location.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/features/expense/location.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('a location is read from and written as JSON', () {
    final both = ExpenseLocation.fromJson({
      'name': 'Night market',
      'point': {'latitude': 25.0339, 'longitude': 121},
    })!;
    expect(both.name, 'Night market');
    expect(both.point, const GeoPoint(25.0339, 121));
    expect(both.toJson(), {
      'name': 'Night market',
      'point': {'latitude': 25.0339, 'longitude': 121.0},
    });
    expect(const ExpenseLocation(name: 'Home').toJson(), {'name': 'Home'});
    expect(ExpenseLocation.fromJson({'name': ''}), isNull);
    expect(ExpenseLocation.fromJson(null), isNull);
  });

  test('map tiles are only taken over http(s)', () {
    ServerInfo info(Object? tiles) =>
        ServerInfo.fromJson({
          'name': 'balnana',
          'version': 'test',
          'authMode': 'link',
          'publicUrl': 'https://x.test',
          'mapTiles': tiles,
        });
    expect(info('https://tile.example/{z}/{x}/{y}.png').mapTiles, 'https://tile.example/{z}/{x}/{y}.png');
    expect(info('javascript:alert(1)').mapTiles, isNull);
    expect(info(null).mapTiles, isNull);
  });

  testWidgets('the device position is read only when asked for', (tester) async {
    var asked = 0;
    Object answer = const GeoPoint(25.0339, 121.5645);
    final name = TextEditingController();
    addTearDown(name.dispose);
    GeoPoint? point;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // No map tiles: the field still works with coordinates alone.
          serverInfoProvider.overrideWithValue(
            const AsyncValue.data(ServerInfo(version: 'test', authMode: AuthMode.link, publicUrl: 'https://x.test')),
          ),
          currentLocationProvider.overrideWithValue(() async {
            asked++;
            if (answer case final LocationException e) throw e;
            return answer as GeoPoint;
          }),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => LocationField(
                name: name,
                point: point,
                onPoint: (p) => setState(() => point = p),
              ),
            ),
          ),
        ),
      ),
    );
    expect(asked, 0);
    expect(find.text('Pick on map'), findsNothing);

    await tester.tap(find.text('Use current location'));
    await tester.pumpAndSettle();
    expect(asked, 1);
    expect(point, const GeoPoint(25.0339, 121.5645));
    expect(find.text('25.03390, 121.56450'), findsOneWidget);

    await tester.tap(find.text('Remove pin'));
    await tester.pumpAndSettle();
    expect(point, isNull);

    answer = const LocationException(LocationProblem.denied);
    await tester.tap(find.text('Use current location'));
    await tester.pumpAndSettle();
    expect(asked, 2);
    expect(point, isNull);
    expect(find.textContaining('may not use your location'), findsOneWidget);
  });
}
