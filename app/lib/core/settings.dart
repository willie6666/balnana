import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'prefs.dart';

/// Device preferences. The language is also saved to a signed-in account.
@immutable
class Settings {
  const Settings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.dynamicColor = false,
    this.wallpaperGroups = false,
    this.pureBlack = false,
    this.serverUrl,
    this.notifications = true,
    this.myShare = false,
  });

  final ThemeMode themeMode;

  /// Null follows the device language.
  final Locale? locale;

  /// Use the wallpaper palette (Android 12+) instead of the brand palette.
  final bool dynamicColor;

  /// With [dynamicColor], group pages wear the wallpaper's colors too instead
  /// of their own.
  final bool wallpaperGroups;
  final bool pureBlack;

  /// The server the user chose. Null means [defaultServerUrl] is used.
  final String? serverUrl;

  /// Push notifications, where the build and the server have them.
  final bool notifications;

  /// Expense rows show what this device's member lent or borrowed instead of
  /// the expense's total.
  final bool myShare;

  Settings copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
    bool? dynamicColor,
    bool? wallpaperGroups,
    bool? pureBlack,
    String? Function()? serverUrl,
    bool? notifications,
    bool? myShare,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale != null ? locale() : this.locale,
      dynamicColor: dynamicColor ?? this.dynamicColor,
      wallpaperGroups: wallpaperGroups ?? this.wallpaperGroups,
      pureBlack: pureBlack ?? this.pureBlack,
      serverUrl: serverUrl != null ? serverUrl() : this.serverUrl,
      notifications: notifications ?? this.notifications,
      myShare: myShare ?? this.myShare,
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<Settings> {
  static const _theme = 'settings.theme';
  static const _locale = 'settings.locale';
  static const _dynamicColor = 'settings.dynamicColor';
  static const _wallpaperGroups = 'settings.wallpaperGroups';
  static const _pureBlack = 'settings.pureBlack';
  static const _server = 'settings.server';
  static const _notifications = 'settings.notifications';
  static const _myShare = 'settings.myShare';

  @override
  Settings build() {
    final prefs = ref.watch(prefsProvider);
    return Settings(
      themeMode: ThemeMode.values.asNameMap()[prefs.getString(_theme)] ?? ThemeMode.system,
      locale: savedLocale(prefs),
      dynamicColor: dynamicColorOn(prefs),
      wallpaperGroups: prefs.getBool(_wallpaperGroups) ?? false,
      pureBlack: prefs.getBool(_pureBlack) ?? false,
      serverUrl: prefs.getString(_server),
      notifications: notificationsOn(prefs),
      myShare: prefs.getBool(_myShare) ?? false,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    ref.read(prefsProvider).setString(_theme, mode.name);
  }

  void setLocale(Locale? locale) {
    state = state.copyWith(locale: () => locale);
    final prefs = ref.read(prefsProvider);
    locale == null ? prefs.remove(_locale) : prefs.setString(_locale, locale.toLanguageTag());
  }

  /// Uses the account's language when this build supports it. An unsupported
  /// language follows the device until the person chooses one in Settings.
  void applyAccountLocale(String? tag) {
    final locale = tag == null || tag.isEmpty ? null : _parseLocale(tag.replaceAll('_', '-'));
    final supported = AppLocalizations.supportedLocales;
    setLocale(
      supported.where((l) => l == locale).firstOrNull ??
          supported.where((l) => l.languageCode == locale?.languageCode).firstOrNull,
    );
  }

  void setDynamicColor(bool on) {
    state = state.copyWith(dynamicColor: on);
    ref.read(prefsProvider).setBool(_dynamicColor, on);
    unawaited(wallpaperSplash(on));
  }

  void setWallpaperGroups(bool on) {
    state = state.copyWith(wallpaperGroups: on);
    ref.read(prefsProvider).setBool(_wallpaperGroups, on);
  }

  void setPureBlack(bool on) {
    state = state.copyWith(pureBlack: on);
    ref.read(prefsProvider).setBool(_pureBlack, on);
  }

  void setNotifications(bool on) {
    state = state.copyWith(notifications: on);
    ref.read(prefsProvider).setBool(_notifications, on);
  }

  void setMyShare(bool on) {
    state = state.copyWith(myShare: on);
    ref.read(prefsProvider).setBool(_myShare, on);
  }

  /// [url] must already be normalized; null returns to the default server.
  void setServerUrl(String? url) {
    state = state.copyWith(serverUrl: () => url);
    final prefs = ref.read(prefsProvider);
    url == null ? prefs.remove(_server) : prefs.setString(_server, url);
  }

  /// Whether the wallpaper palette is on, as [Settings.dynamicColor] says.
  static bool dynamicColorOn(SharedPreferences prefs) => prefs.getBool(_dynamicColor) ?? false;

  /// Whether notifications are on, as [Settings.notifications] says.
  static bool notificationsOn(SharedPreferences prefs) => prefs.getBool(_notifications) ?? true;

  /// The language picked in settings; null follows the device.
  static Locale? savedLocale(SharedPreferences prefs) => switch (prefs.getString(_locale)) {
    final tag? => _parseLocale(tag),
    null => null,
  };

  static Locale _parseLocale(String tag) {
    // language[-Script][-REGION], e.g. "pt", "pt-BR", "sr-Latn", "sr-Latn-RS".
    final parts = tag.split('-');
    String? script, region;
    for (final p in parts.skip(1)) {
      if (p.length == 4) {
        script = p;
      } else {
        region = p;
      }
    }
    return Locale.fromSubtags(languageCode: parts[0], scriptCode: script, countryCode: region);
  }
}

const _splash = MethodChannel('balnana/splash');

/// Has Android 13+ show the splash screen of later launches in the wallpaper's
/// colors, [on], or in Balnana yellow, so it matches the app that follows.
Future<void> wallpaperSplash(bool on) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    await _splash.invokeMethod<void>('setWallpaper', on);
  } on MissingPluginException {
    // Tests, and builds without the channel.
  } on PlatformException {
    // Android 12 and older keep the yellow one.
  }
}
