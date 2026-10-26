import 'package:balnana/data/categories.dart';
import 'package:balnana/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _group({List<Object?>? categories}) => {
  'token': 'tok',
  'name': 'Trip',
  'currency': 'EUR',
  'minorDigits': 2,
  'createdAt': '2026-10-01T00:00:00Z',
  'members': <Object?>[],
  'linkAccess': true,
  'categories': ?categories,
};

void main() {
  test('a server without group categories offers the built-in ones', () {
    final g = Group.fromJson(_group());
    expect(g.allCategories.map((c) => c.id), Category.values.map((c) => c.id));
    expect(g.category('rent')?.builtIn, isTrue);
    expect(g.category('gone'), isNull);
  });

  test('hidden categories are not offered unless already chosen', () {
    final g = Group.fromJson(
      _group(
        categories: [
          {'id': 'food', 'emoji': '🍔', 'color': 0xF07C2E, 'builtIn': true, 'hidden': false},
          {'id': 'rent', 'emoji': '🏠', 'color': 0x8A5A3C, 'builtIn': true, 'hidden': true},
          {'id': 'c1', 'name': 'Pets', 'emoji': '🐶', 'color': 0x112233, 'builtIn': false, 'hidden': false},
        ],
      ),
    );
    expect(g.offeredCategories().map((c) => c.id), ['food', 'c1']);
    expect(g.offeredCategories('rent').map((c) => c.id), ['food', 'rent', 'c1']);
    final pets = g.category('c1')!;
    expect(pets.name, 'Pets');
    expect(pets.color.toARGB32(), 0xFF112233);
    // A built-in one the list leaves out is still known.
    expect(g.category('travel')?.emoji, '✈️');
  });
}
