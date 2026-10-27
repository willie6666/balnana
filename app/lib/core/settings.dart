import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'prefs.dart';

/// Device-local preferences. Nothing here is sent to the server.
@immutable
class Settings {
  const Settings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.dynamicColor = false,
    this.pureBlack = false,
    this.serverUrl,
    this.notifications = true,
  });

  final ThemeMode themeMode;

  /// Null follows the device language.
  final Locale? locale;

  /// Use the wallpaper palette (Android 12+) instead of the brand palette.
  final bool dynamicColor;
  final bool pureBlack;

  /// The server the user chose. Null means [defaultServerUrl] is used.
  final String? serverUrl;

  /// Push notifications, where the build and the server have them.
  final bool notifications;

  Settings copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
    bool? dynamicColor,
    bool? pureBlack,
    String? Function()? serverUrl,
    bool? notifications,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale != null ? locale() : this.locale,
      dynamicColor: dynamicColor ?? this.dynamicColor,
      pureBlack: pureBlack ?? this.pureBlack,
      serverUrl: serverUrl != null ? serverUrl() : this.serverUrl,
      notifications: notifications ?? this.notifications,
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<Settings> {
  static const _theme = 'settings.theme';
  static const _locale = 'settings.locale';
  static const _dynamicColor = 'settings.dynamicColor';
  static const _pureBlack = 'settings.pureBlack';
  static const _server = 'settings.server';
  static const _notifications = 'settings.notifications';

  @override
  Settings build() {
    final prefs = ref.watch(prefsProvider);
    return Settings(
      themeMode: ThemeMode.values.asNameMap()[prefs.getString(_theme)] ?? ThemeMode.system,
      locale: savedLocale(prefs),
      dynamicColor: prefs.getBool(_dynamicColor) ?? false,
      pureBlack: prefs.getBool(_pureBlack) ?? false,
      serverUrl: prefs.getString(_server),
      notifications: notificationsOn(prefs),
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

  void setDynamicColor(bool on) {
    state = state.copyWith(dynamicColor: on);
    ref.read(prefsProvider).setBool(_dynamicColor, on);
  }

  void setPureBlack(bool on) {
    state = state.copyWith(pureBlack: on);
    ref.read(prefsProvider).setBool(_pureBlack, on);
  }

  void setNotifications(bool on) {
    state = state.copyWith(notifications: on);
    ref.read(prefsProvider).setBool(_notifications, on);
  }

  /// [url] must already be normalized; null returns to the default server.
  void setServerUrl(String? url) {
    state = state.copyWith(serverUrl: () => url);
    final prefs = ref.read(prefsProvider);
    url == null ? prefs.remove(_server) : prefs.setString(_server, url);
  }

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
