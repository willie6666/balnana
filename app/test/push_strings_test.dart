import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/push_strings.dart';

void main() {
  test('web/push_strings.json is what the ARB files say', () {
    expect(
      File('web/push_strings.json').readAsStringSync(),
      encodePushStrings(pushStrings(Directory('lib/l10n'))),
      reason: 'run: dart run tool/push_strings.dart',
    );
  });

  test('every language words every notification', () {
    final strings = pushStrings(Directory('lib/l10n'));
    expect(strings, hasLength(20));
    for (final MapEntry(key: tag, value: messages) in strings.entries) {
      expect(messages.keys, unorderedEquals(pushMessages.keys), reason: tag);
    }
    expect(strings['en']!['push_expense_added'], '{0} added {1} · {2}');
  });
}
