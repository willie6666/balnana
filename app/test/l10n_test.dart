import 'package:balnana/core/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Locale _tag(String tag) {
  final [language, ...rest] = tag.split('-');
  return Locale.fromSubtags(
    languageCode: language,
    scriptCode: rest.where((p) => p.length == 4).firstOrNull,
    countryCode: rest.where((p) => p.length != 4).firstOrNull,
  );
}

void main() {
  for (final (device, expected) in [
    ('zh-TW', 'zh-Hant-TW'),
    ('zh-HK', 'zh-Hant-HK'),
    ('zh-Hant-TW', 'zh-Hant-TW'),
    ('zh-Hant-HK', 'zh-Hant-HK'),
    // Without a region, intl would take it for mainland China.
    ('zh-Hant', 'zh-Hant-TW'),
    ('zh-Hans-TW', 'zh-TW'),
    ('zh-CN', 'zh-CN'),
    ('zh', 'zh'),
    ('pt-BR', 'pt-BR'),
    ('en-GB', 'en-GB'),
    ('zz-ZZ', 'en'),
  ]) {
    test('device language $device shows as $expected', () {
      final locales = [_tag(device)];
      expect(resolveLocale(locales, locales).toLanguageTag(), expected);
    });
  }

  test('the first device language with a translation wins', () {
    final device = [_tag('zz-ZZ'), _tag('ja-JP'), _tag('en-US')];
    expect(resolveLocale(device, device).toLanguageTag(), 'ja-JP');
  });

  test('a chosen language takes its region from the device', () {
    final device = [_tag('zz-ZZ'), _tag('zh-TW')];
    expect(resolveLocale([_tag('zh-Hant')], device).toLanguageTag(), 'zh-Hant-TW');
    expect(resolveLocale([_tag('de')], device).toLanguageTag(), 'de');
  });

  test('no languages at all shows English', () {
    expect(resolveLocale(null, const []).toLanguageTag(), 'en');
  });
}
