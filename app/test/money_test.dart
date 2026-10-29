import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:balnana/core/money.dart';
import 'package:balnana/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// api/testdata/money.json is shared with the Go tests in server/internal/domain.
final Map<String, dynamic> vectors =
    jsonDecode(File('../api/testdata/money.json').readAsStringSync()) as Map<String, dynamic>;

List<Map<String, dynamic>> cases(String kind) => (vectors[kind] as List).cast<Map<String, dynamic>>();

Matcher throwsMoney(String code) => throwsA(isA<MoneyException>().having((e) => e.error.code, 'code', code));

void main() {
  group('parse vectors', () {
    for (final c in cases('parse')) {
      final input = c['input'] as String, digits = c['digits'] as int;
      test('${jsonEncode(input)} with $digits digits', () {
        if (c['error'] case final String code) {
          expect(() => parseAmount(input, digits), throwsMoney(code));
        } else {
          expect(parseAmount(input, digits), BigInt.parse(c['minor'] as String));
        }
      });
    }
  });

  group('format vectors', () {
    for (final c in cases('format')) {
      test('${c['minor']} with ${c['digits']} digits', () {
        expect(formatAmount(BigInt.parse(c['minor'] as String), c['digits'] as int), c['output']);
      });
    }
  });

  group('split vectors', () {
    for (final c in cases('split')) {
      test(c['name'] as String, () {
        final digits = c['digits'] as int;
        final parts = [
          for (final p in (c['parts'] as List).cast<Map<String, dynamic>>())
            SplitPart(p['member'] as String, p['value'] as String? ?? ''),
        ];
        final method = SplitMethod.values.byName(c['method'] as String);
        BigInt run() => parseAmount(c['amount'] as String, digits);
        if (c['error'] case final String code) {
          expect(() => split(run(), digits, method, parts), throwsMoney(code));
          return;
        }
        final got = split(run(), digits, method, parts);
        expect(
          got.map((m, v) => MapEntry(m, formatAmount(v, digits))),
          (c['expect'] as Map).cast<String, String>(),
        );
      });
    }
  });

  group('spread vectors', () {
    for (final c in cases('spread')) {
      test(c['name'] as String, () {
        final total = BigInt.parse(c['total'] as String);
        final amounts = (c['amounts'] as Map).cast<String, String>().map((m, v) => MapEntry(m, BigInt.parse(v)));
        if (c['error'] case final String code) {
          expect(() => spread(total, amounts), throwsMoney(code));
          return;
        }
        expect(
          spread(total, amounts).map((m, v) => MapEntry(m, v.toString())),
          (c['expect'] as Map).cast<String, String>(),
        );
      });
    }
  });

  group('rates', () {
    test('convert rounds half up into the other digits', () {
      // 1,000 yen at 0.21445 is 214.45 dollars... in cents, 21445.
      expect(convertAmount(BigInt.from(1000), 0, '0.21445', 2), BigInt.from(21445));
      expect(convertAmount(BigInt.from(1000), 0, '0.0064', 2), BigInt.from(640));
      // 12.34 euros at 34.5 is 425.73 TWD (425.73).
      expect(convertAmount(BigInt.from(1234), 2, '34.5', 2), BigInt.from(42573));
      expect(convertAmount(BigInt.from(1), 2, '0.5', 0), BigInt.zero); // 0.005 rounds to 0
      expect(convertAmount(BigInt.from(1), 0, '0.5', 0), BigInt.one); // 0.5 rounds up
      expect(convertAmount(BigInt.from(1000), 0, '0', 2), isNull);
      expect(convertAmount(BigInt.from(1000), 0, 'x', 2), isNull);
      expect(convertAmount(BigInt.from(1000), 0, '0.123456789', 2), isNull);
    });

    test('rate of a charged amount keeps six significant digits', () {
      expect(rateOf(BigInt.from(1000), 0, BigInt.from(21445), 2), '0.21445');
      expect(rateOf(BigInt.from(1000), 0, BigInt.from(643), 2), '0.00643');
      expect(rateOf(BigInt.from(300000), 0, BigInt.from(1), 2), '0.00000003');
      expect(rateOf(BigInt.from(100), 2, BigInt.from(3125670), 2), '31256.7');
      expect(rateOf(BigInt.from(300), 2, BigInt.from(100), 2), '0.333333');
      expect(rateOf(BigInt.from(100), 2, BigInt.from(100), 2), '1');
      expect(rateOf(BigInt.from(1), 0, BigInt.from(123456789), 0), '123456789');
    });
  });

  group('settle vectors', () {
    for (final c in cases('settle')) {
      test(c['name'] as String, () {
        final digits = c['digits'] as int;
        final nets = (c['nets'] as Map).cast<String, String>().map(
          (m, v) => MapEntry(m, parseAmount(v, digits)),
        );
        if (c['error'] case final String code) {
          expect(() => simplify(nets), throwsMoney(code));
          return;
        }
        expect(simplify(nets), [
          for (final t in (c['expect'] as List).cast<Map<String, dynamic>>())
            Transfer(t['from'] as String, t['to'] as String, parseAmount(t['amount'] as String, digits)),
        ]);
      });
    }
  });

  group('properties', () {
    BigInt randomBig(Random r, BigInt max) {
      // Uniform enough for testing: two 30-bit halves, reduced.
      final v = (BigInt.from(r.nextInt(1 << 30)) << 30) | BigInt.from(r.nextInt(1 << 30));
      return v % (max + BigInt.one);
    }

    test('format and parse round trip', () {
      final r = Random(1);
      for (var i = 0; i < 5000; i++) {
        final digits = r.nextInt(maxDigits + 1);
        var v = randomBig(r, maxMinor);
        if (r.nextBool()) v = -v;
        expect(parseAmount(formatAmount(v, digits), digits), v);
      }
    });

    test('split conserves the total', () {
      final r = Random(3);
      for (var i = 0; i < 2000; i++) {
        final total = randomBig(r, maxMinor - BigInt.one) + BigInt.one;
        final n = r.nextInt(12) + 1;
        final parts = [
          for (var j = 0; j < n; j++)
            SplitPart(
              'm${j.toString().padLeft(2, '0')}',
              j == 0 ? '1' : formatAmount(BigInt.from(r.nextInt(1000000)), 4),
            ),
        ];
        for (final method in [SplitMethod.equal, SplitMethod.shares]) {
          final got = split(total, 2, method, parts);
          expect(got.values.every((v) => !v.isNegative), isTrue);
          expect(got.values.fold(BigInt.zero, (a, b) => a + b), total);
        }
      }
    });

    test('simplify settles everyone in at most n-1 transfers', () {
      final r = Random(5);
      for (var i = 0; i < 1000; i++) {
        final n = r.nextInt(10) + 2;
        final nets = <String, BigInt>{};
        var sum = BigInt.zero;
        for (var j = 0; j < n - 1; j++) {
          final v = BigInt.from(r.nextInt(2000001) - 1000000);
          nets['m$j'] = v;
          sum += v;
        }
        nets['m${n - 1}'] = -sum;
        final transfers = simplify(nets);
        expect(transfers.length, lessThanOrEqualTo(n - 1));
        final after = Map.of(nets);
        for (final t in transfers) {
          expect(t.amount > BigInt.zero, isTrue);
          after[t.from] = after[t.from]! + t.amount;
          after[t.to] = after[t.to]! - t.amount;
        }
        expect(after.values.every((v) => v == BigInt.zero), isTrue);
      }
    });
  });

  test('localized formatting groups digits without going through double', () {
    expect(formatAmountLocalized(BigInt.parse('99999999999999999'), 2, 'en'), '999,999,999,999,999.99');
    expect(formatAmountLocalized(BigInt.from(-123456), 2, 'en'), '-1,234.56');
    expect(formatAmountLocalized(BigInt.from(5), 0, 'en'), '5');
  });

  // One transaction holds at most maxMinor, but a balance or a total is a sum
  // of them and may be larger: the app must still read what the server sends.
  test('sums beyond one transaction are read, single amounts are not', () {
    final big = formatAmount(maxMinor + BigInt.from(98), 2);
    expect(() => parseAmount(big, 2), throwsMoney('amount_too_large'));
    expect(parseAmount(big, 2, total: true), maxMinor + BigInt.from(98));

    final group = Group.fromJson({
      'token': 'tok',
      'name': 'Big',
      'currency': 'USD',
      'minorDigits': 2,
      'createdAt': '2026-01-01T00:00:00Z',
      'members': [
        {'id': 'a', 'name': 'Ana', 'balance': big},
        {'id': 'b', 'name': 'Ben', 'balance': '-$big'},
      ],
    });
    expect(group.members.first.balance, maxMinor + BigInt.from(98));
    final balances = Balances.fromJson({
      'balances': [
        {'memberId': 'a', 'amount': big},
      ],
      'transfers': [
        {'fromMemberId': 'b', 'toMemberId': 'a', 'amount': big},
      ],
    }, 2);
    expect(balances.transfers.single.amount, maxMinor + BigInt.from(98));
    final stats = GroupStats.fromJson({
      'total': big,
      'count': 2,
      'categories': [],
      'members': [
        {'memberId': 'a', 'paid': big, 'share': big},
      ],
      'months': [
        {'month': '2026-01', 'amount': big},
      ],
    }, 2);
    expect(stats.total, maxMinor + BigInt.from(98));
  });
}
