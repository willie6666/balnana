// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageEndonym => 'English';

  @override
  String get appTitle => 'Balnana';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSave => 'Save';

  @override
  String get navGroups => 'Groups';

  @override
  String get navActivity => 'Activity';

  @override
  String get navSettings => 'Settings';

  @override
  String get groupsEmptyTitle => 'No groups yet';

  @override
  String get groupsEmptyBody => 'Groups you create or open from a link will show up here.';

  @override
  String get groupsNoServerTitle => 'Connect to a server';

  @override
  String get groupsNoServerBody =>
      'Balnana keeps your groups on a server you choose, such as one you host yourself.';

  @override
  String get groupsNoServerAction => 'Choose server';

  @override
  String get groupsUnreachableTitle => 'Can\'t reach the server';

  @override
  String get groupsUnreachableBody => 'Check your connection, or the server address in Settings.';

  @override
  String get activityEmptyTitle => 'Nothing here yet';

  @override
  String get activityEmptyBody => 'New expenses and payments in your groups will appear here.';

  @override
  String get groupLinkTitle => 'Group link';

  @override
  String get groupLinkBody => 'Opening groups from a link is coming in the next version.';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBody => 'This address doesn\'t lead anywhere in Balnana.';

  @override
  String get notFoundAction => 'Go to groups';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsDynamicColor => 'Wallpaper colors';

  @override
  String get settingsDynamicColorSubtitle => 'Use colors from your device instead of Balnana yellow';

  @override
  String get settingsPureBlack => 'Pure black';

  @override
  String get settingsPureBlackSubtitle => 'A darker dark theme for OLED screens';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get settingsConnection => 'Connection';

  @override
  String get settingsServer => 'Server';

  @override
  String get serverNotSet => 'Not set';

  @override
  String get settingsAbout => 'About';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicenses => 'Open source licenses';

  @override
  String get aboutSource => 'Source code';

  @override
  String get aboutSourceCopied => 'Couldn\'t open a browser, so the link was copied';

  @override
  String get serverTitle => 'Server';

  @override
  String get serverIntro =>
      'Enter the address of a Balnana server. Anyone can host one; the address is usually where its web app opens.';

  @override
  String get serverUrlLabel => 'Server address';

  @override
  String get serverUrlHint => 'https://balnana.example.com';

  @override
  String get serverTest => 'Test connection';

  @override
  String get serverSaveAnyway => 'Save anyway';

  @override
  String get serverReset => 'Use default';

  @override
  String serverDefault(String url) {
    return 'Default: $url';
  }

  @override
  String serverConnected(String version) {
    return 'Connected to Balnana $version';
  }

  @override
  String get serverModeLink => 'Groups are shared by private link. No account needed.';

  @override
  String get serverModeAccounts => 'People sign in with an account.';

  @override
  String get serverInsecure =>
      'This address is not encrypted (http). Anyone on the network could read your data. Use https for servers outside your home network.';

  @override
  String get serverErrorInvalid => 'Enter a web address, like balnana.example.com';

  @override
  String get serverErrorUnreachable => 'Couldn\'t connect. Check the address and that the server is running.';

  @override
  String get serverErrorNotBalnana => 'Something answered, but it isn\'t a Balnana server.';

  @override
  String get serverSaved => 'Server saved';
}
