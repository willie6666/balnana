// Writes web/push_strings.json: the notification lines of lib/l10n in every
// language, for the web app's push worker (web/push_sw.js), which cannot use
// Flutter's localizations. Run from app/ after changing a push* message:
//
//   dart run tool/push_strings.dart
//
// test/push_strings_test.dart fails while the file is out of date.

import 'dart:convert';
import 'dart:io';

/// Each server key (see notify in server/internal/api/push.go), with the ARB
/// message that words it and that message's placeholders in the order the
/// server sends its arguments. core/push.dart renders the same on Android.
const pushMessages = {
  'push_payment_added': ('pushPaymentAdded', ['payer', 'payee', 'amount']),
  'push_expense_added': ('pushExpenseAdded', ['who', 'title', 'amount']),
  'push_expense_edited': ('pushExpenseEdited', ['who', 'title', 'amount']),
  'push_expense_deleted': ('pushExpenseDeleted', ['who', 'title', 'amount']),
  'push_expense_added_anon': ('pushExpenseAddedAnon', ['title', 'amount']),
  'push_expense_edited_anon': ('pushExpenseEditedAnon', ['title', 'amount']),
  'push_expense_deleted_anon': ('pushExpenseDeletedAnon', ['title', 'amount']),
  'push_reminder': ('pushReminder', ['who', 'amount']),
};

/// The messages by language tag ("en", "zh-Hant") and server key, with the
/// placeholders numbered: "{0} added {1} · {2}".
Map<String, Map<String, String>> pushStrings(Directory l10n) {
  final files = l10n.listSync().whereType<File>().where((f) => f.path.endsWith('.arb')).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return {
    for (final file in files)
      _tag(file): {
        for (final MapEntry(key: key, value: (message, names)) in pushMessages.entries)
          if ((jsonDecode(file.readAsStringSync()) as Map<String, Object?>)[message] case final String text)
            key: _number(text, names, '${file.path} $message'),
      },
  };
}

/// "app_zh_Hant.arb" is "zh-Hant".
String _tag(File file) {
  final name = file.uri.pathSegments.last;
  return name.substring('app_'.length, name.length - '.arb'.length).replaceAll('_', '-');
}

String _number(String text, List<String> names, String where) {
  final numbered = text.replaceAllMapped(RegExp(r'\{(\w+)\}'), (m) {
    final i = names.indexOf(m[1]!);
    if (i < 0) throw FormatException('$where: unknown placeholder {${m[1]}}');
    return '{$i}';
  });
  // Plurals and selects would need ICU in the worker.
  if (RegExp(r'\{[^0-9]').hasMatch(numbered)) throw FormatException('$where: more than placeholders');
  return numbered;
}

/// The file as written: one language per line, so changes read well.
String encodePushStrings(Map<String, Map<String, String>> strings) {
  final lines = [for (final MapEntry(:key, :value) in strings.entries) '  ${jsonEncode(key)}: ${jsonEncode(value)}'];
  return '{\n${lines.join(',\n')}\n}\n';
}

void main() {
  File('web/push_strings.json').writeAsStringSync(encodePushStrings(pushStrings(Directory('lib/l10n'))));
}
