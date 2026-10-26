import 'package:balnana/core/money.dart';
import 'package:balnana/features/groups/open_link.dart';
import 'package:balnana/ui/widgets/amount_field.dart';
import 'package:flutter_test/flutter_test.dart';

TextEditingValue _v(String s) => TextEditingValue(text: s);

void main() {
  test('AmountFormatter limits decimals and accepts a comma', () {
    final f = AmountFormatter(2);
    expect(f.formatEditUpdate(_v('1'), _v('1.2')).text, '1.2');
    expect(f.formatEditUpdate(_v('1.23'), _v('1.234')).text, '1.23');
    expect(f.formatEditUpdate(_v('1'), _v('1,5')).text, '1,5');
    expect(f.formatEditUpdate(_v('1'), _v('1a')).text, '1');
    expect(AmountFormatter(0).formatEditUpdate(_v('12'), _v('12.')).text, '12');
  });

  test('parseInput reads partial and localized input', () {
    expect(parseInput('', 2), isNull);
    expect(parseInput('.', 2), isNull);
    expect(parseInput('12,5', 2), BigInt.from(1250));
    expect(parseInput('.5', 2), BigInt.from(50));
    expect(parseInput('7.', 2), BigInt.from(700));
    expect(() => parseInput('9999999999999999', 2), throwsA(isA<MoneyException>()));
  });

  test('shareValue normalizes what was typed', () {
    expect(shareValue(' 33,5 '), '33.5');
    expect(shareValue('.5'), '0.5');
    expect(shareValue('2.'), '2');
  });

  test('tokenFromLink accepts links and bare tokens', () {
    const token = 'abcdefghijklmnopqrstuv';
    expect(tokenFromLink('https://example.com/g/$token', serverUrl: 'https://example.com'), token);
    expect(tokenFromLink(token, serverUrl: 'https://example.com'), token);
    expect(tokenFromLink('https://example.com/groups', serverUrl: 'https://example.com'), isNull);
  });
}
