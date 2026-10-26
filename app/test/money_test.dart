import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:balnana/core/money.dart';
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
}
