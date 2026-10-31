import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
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
