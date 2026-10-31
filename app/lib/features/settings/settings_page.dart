import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/push.dart';
import '../../core/server.dart';
import '../../core/session.dart';
import '../../core/settings.dart';
import '../../data/api.dart';
import '../../data/providers.dart';
import '../../ui/widgets/grouped_list.dart';
import '../../ui/widgets/page.dart';
import '../account/account_section.dart';
import 'my_groups.dart';
import 'privacy_page.dart';

/// Set with `--dart-define=BALNANA_VERSION=...` by release builds.
const appVersion = String.fromEnvironment('BALNANA_VERSION', defaultValue: 'dev');

/// Wallpaper colors exist on Android 12+ only; older devices fall back to the
/// brand palette.
bool get _hasDynamicColor => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final server = ref.watch(serverUrlProvider);
    final sourceUrl = ref.watch(serverInfoProvider).value?.sourceUrl;

    final themeLabel = switch (settings.themeMode) {
      ThemeMode.system => l10n.themeSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };
    // Pure black only changes the dark theme, so it shows only while dark.
    final dark = switch (settings.themeMode) {
      ThemeMode.system => MediaQuery.platformBrightnessOf(context) == Brightness.dark,
      ThemeMode.light => false,
      ThemeMode.dark => true,
    };
    final locale = settings.locale;
    final languageLabel = locale == null
        ? l10n.languageSystem
        : lookupAppLocalizations(locale).languageEndonym;

    return BPage(
      title: l10n.navSettings,
      children: [
        if (ref.watch(accountsModeProvider)) const AccountSection(),
        if (ref.watch(signedInProvider) && (ref.watch(serverInfoProvider).value?.billing ?? false))
          GroupedList(
            children: [
              GroupedTile(
                icon: Icons.workspace_premium_outlined,
                title: l10n.planTitle,
                subtitle: l10n.planSettingsHelp,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/plan'),
              ),
            ],
          ),
        GroupedList(
          title: l10n.settingsAppearance,
          children: [
            GroupedTile(
              icon: Icons.brightness_6_outlined,
              title: l10n.settingsTheme,
              subtitle: themeLabel,
              onTap: () => _pickTheme(context, ref),
            ),
            if (_hasDynamicColor)
              GroupedSwitchTile(
                icon: Icons.palette_outlined,
                title: l10n.settingsDynamicColor,
                subtitle: l10n.settingsDynamicColorSubtitle,
                value: settings.dynamicColor,
                onChanged: notifier.setDynamicColor,
              ),
            if (_hasDynamicColor && settings.dynamicColor)
              GroupedSwitchTile(
                icon: Icons.format_paint_outlined,
                title: l10n.settingsWallpaperGroups,
                subtitle: l10n.settingsWallpaperGroupsSubtitle,
                value: settings.wallpaperGroups,
                onChanged: notifier.setWallpaperGroups,
              ),
            if (dark)
              GroupedSwitchTile(
                icon: Icons.contrast,
                title: l10n.settingsPureBlack,
                subtitle: l10n.settingsPureBlackSubtitle,
                value: settings.pureBlack,
                onChanged: notifier.setPureBlack,
              ),
            GroupedSwitchTile(
              icon: Icons.person_outline,
              title: l10n.settingsMyShare,
              subtitle: l10n.settingsMyShareSubtitle,
              value: settings.myShare,
              onChanged: notifier.setMyShare,
            ),
          ],
        ),
        GroupedList(
          title: l10n.settingsLanguage,
          children: [
            GroupedTile(
              icon: Icons.translate,
              title: l10n.settingsLanguage,
              subtitle: languageLabel,
              onTap: () => _pickLanguage(context, ref),
            ),
          ],
        ),
        if (ref.watch(pushAvailableProvider))
          GroupedList(
            title: l10n.settingsNotifications,
            children: [
              GroupedSwitchTile(
                icon: Icons.notifications_outlined,
                title: l10n.settingsNotifications,
                subtitle: settings.notifications && ref.watch(pushBlockedProvider)
                    ? l10n.settingsNotificationsBlocked
                    : l10n.settingsNotificationsSubtitle,
                value: settings.notifications,
                onChanged: notifier.setNotifications,
              ),
            ],
          ),
        if (canChooseServer)
          GroupedList(
            title: l10n.settingsConnection,
            children: [
              GroupedTile(
                icon: Icons.dns_outlined,
                title: l10n.settingsServer,
                subtitle: server ?? l10n.serverNotSet,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/server'),
              ),
            ],
          ),
        if (server != null && ref.watch(serverInfoProvider).value?.authMode == AuthMode.link)
          const MyGroupsSection(),
        GroupedList(
          title: l10n.settingsAbout,
          children: [
            GroupedTile(
              icon: Icons.info_outline,
              title: l10n.aboutVersion,
              subtitle: appVersion,
              onTap: () => Clipboard.setData(const ClipboardData(text: appVersion)),
            ),
            GroupedTile(
              icon: Icons.gavel_outlined,
              title: l10n.aboutLicenses,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: appVersion,
              ),
            ),
            GroupedTile(
              icon: Icons.privacy_tip_outlined,
              title: l10n.privacyTitle,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openPrivacyPolicy(context, ref),
            ),
            if (sourceUrl != null)
              GroupedTile(
                icon: Icons.code,
                title: l10n.aboutSource,
                subtitle: sourceUrl.toString(),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openSource(context, sourceUrl),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _openSource(BuildContext context, Uri url) async {
    final messenger = ScaffoldMessenger.of(context);
    final copied = context.l10n.aboutSourceCopied;
    if (await launchUrl(url, mode: LaunchMode.externalApplication)) return;
    await Clipboard.setData(ClipboardData(text: url.toString()));
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final picked = await _pick<ThemeMode>(
      context,
      title: l10n.settingsTheme,
      current: ref.read(settingsProvider).themeMode,
      options: {
        ThemeMode.system: l10n.themeSystem,
        ThemeMode.light: l10n.themeLight,
        ThemeMode.dark: l10n.themeDark,
      },
    );
    if (picked != null) ref.read(settingsProvider.notifier).setThemeMode(picked);
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    // A sentinel stands for "follow the device", since null means "dismissed".
    const system = Locale('und');
    final picked = await _pick<Locale>(
      context,
      title: l10n.settingsLanguage,
      current: ref.read(settingsProvider).locale ?? system,
      options: {
        system: l10n.languageSystem,
        for (final locale in AppLocalizations.supportedLocales)
          locale: lookupAppLocalizations(locale).languageEndonym,
      },
    );
    if (picked == null || !context.mounted) return;
    final locale = picked == system ? null : picked;
    final who = ref.read(identityProvider);
    try {
      if (ref.read(signedInProvider)) {
        await ref.read(balnanaApiProvider)!.updateMe(locale: locale?.toLanguageTag() ?? '');
      }
      if (!context.mounted || ref.read(identityProvider) != who) return;
      ref.read(settingsProvider.notifier).setLocale(locale);
      if (ref.read(signedInProvider)) ref.invalidate(accountProvider);
    } on ApiException catch (e) {
      if (!context.mounted || ref.read(identityProvider) != who) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
    }
  }

  static Future<T?> _pick<T>(
    BuildContext context, {
    required String title,
    required T current,
    required Map<T, String> options,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        content: RadioGroup<T>(
          groupValue: current,
          onChanged: (value) => Navigator.pop(context, value),
          // Scrolls once the list outgrows the screen, as the languages do.
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final MapEntry(:key, :value) in options.entries)
                  RadioListTile<T>(value: key, title: Text(value)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.commonCancel)),
        ],
      ),
    );
  }
}
