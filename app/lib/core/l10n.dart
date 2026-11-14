import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The app's translations and Material's own, which cover the widgets and
/// Cupertino strings too.
const l10nDelegates = <LocalizationsDelegate<dynamic>>[_L10nDelegate(), ...GlobalMaterialLocalizations.delegates];

/// Translations loaded so far, by [_key].
final _loaded = <String, AppLocalizations>{};

String _key(Locale locale) => [locale.languageCode, ?locale.scriptCode].join('_');

/// Loads translations ahead of use. Each is a download of its own on the
/// web, so loading waits a frame; once loaded, a translation shows at once.
Future<void> loadTranslations(Iterable<Locale> locales) => Future.wait(locales.map(const _L10nDelegate().load));

/// [AppLocalizations.delegate], keeping what it loads: going back to a
/// language shows it in the same frame, as before translations were deferred.
class _L10nDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _L10nDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.delegate.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) {
    final loaded = _loaded[_key(locale)];
    if (loaded != null) return SynchronousFuture(loaded);
    return lookupAppLocalizations(locale).then((l10n) => _loaded[_key(locale)] = l10n);
  }

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

/// Each supported language's name, written in that language, for the
/// language picker. Kept here rather than in each translation: on the web
/// every translation is a download of its own, made only for the language in
/// use.
const _languageNames = {
  'ar': 'العربية',
  'de': 'Deutsch',
  'en': 'English',
  'es': 'Español',
  'fr': 'Français',
  'hi': 'हिन्दी',
  'id': 'Bahasa Indonesia',
  'it': 'Italiano',
  'ja': '日本語',
  'ko': '한국어',
  'nl': 'Nederlands',
  'pl': 'Polski',
  'pt': 'Português',
  'ru': 'Русский',
  'th': 'ไทย',
  'tr': 'Türkçe',
  'uk': 'Українська',
  'vi': 'Tiếng Việt',
  'zh': '简体中文',
  'zh_Hant': '繁體中文',
};

/// The name of [locale]'s language in that language, as the picker shows it.
String languageName(Locale locale) {
  return _languageNames[_key(supportedLocaleFor(locale) ?? locale)] ?? locale.toLanguageTag();
}

/// Regions that write Chinese in Traditional characters.
const _traditionalChinese = {'TW', 'HK', 'MO'};

/// The supported locale that serves [locale], or null when its language has
/// no translation. Chinese without a script, as browsers and some phones send
/// it, follows its region: "zh-TW" is Traditional, "zh-CN" Simplified.
Locale? supportedLocaleFor(Locale locale) {
  final same = AppLocalizations.supportedLocales.where((l) => l.languageCode == locale.languageCode);
  final script =
      locale.scriptCode ??
      (locale.languageCode == 'zh' && _traditionalChinese.contains(locale.countryCode) ? 'Hant' : null);
  return same.where((l) => l.scriptCode == script).firstOrNull ??
      same.where((l) => l.scriptCode == null).firstOrNull ??
      same.firstOrNull;
}

/// The locale the app shows: the first of [preferred] (the chosen language,
/// or else the device's) that has a translation, or English. It keeps a
/// region, taken from the [device] locales when the choice has none, since
/// dates and the default currency follow it.
Locale resolveLocale(List<Locale>? preferred, List<Locale> device) {
  for (final locale in preferred ?? const <Locale>[]) {
    final match = supportedLocaleFor(locale);
    if (match == null) continue;
    final region =
        locale.countryCode ??
        device.where((d) => supportedLocaleFor(d) == match).firstOrNull?.countryCode ??
        // intl has no plain "zh-Hant": it would fall back to mainland China.
        (match.scriptCode == 'Hant' ? 'TW' : null);
    return Locale.fromSubtags(
      languageCode: match.languageCode,
      scriptCode: match.scriptCode,
      countryCode: region,
    );
  }
  return const Locale('en');
}

/// Dates show the same digits as amounts, which are all Latin and are what
/// people type. Left alone, intl writes Arabic dates in Arabic-Indic digits.
void useLatinDigits() {
  for (final locale in const ['ar', 'ar_EG']) {
    DateFormat.useNativeDigitsByDefaultFor(locale, false);
  }
}
