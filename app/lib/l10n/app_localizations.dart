import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The name of this language, written in this language. Shown in the language picker.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEndonym;

  /// The app name. Usually not translated.
  ///
  /// In en, this message translates to:
  /// **'Balnana'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Navigation destination: the list of groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get navGroups;

  /// Navigation destination: recent changes across groups.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get navActivity;

  /// Navigation destination: app settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @groupsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get groupsEmptyTitle;

  /// No description provided for @groupsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Groups you create or open from a link will show up here.'**
  String get groupsEmptyBody;

  /// No description provided for @groupsNoServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to a server'**
  String get groupsNoServerTitle;

  /// No description provided for @groupsNoServerBody.
  ///
  /// In en, this message translates to:
  /// **'Balnana keeps your groups on a server you choose, such as one you host yourself.'**
  String get groupsNoServerBody;

  /// No description provided for @groupsNoServerAction.
  ///
  /// In en, this message translates to:
  /// **'Choose server'**
  String get groupsNoServerAction;

  /// No description provided for @groupsUnreachableTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server'**
  String get groupsUnreachableTitle;

  /// No description provided for @groupsUnreachableBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection, or the server address in Settings.'**
  String get groupsUnreachableBody;

  /// No description provided for @activityEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get activityEmptyTitle;

  /// No description provided for @activityEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New expenses and payments in your groups will appear here.'**
  String get activityEmptyBody;

  /// No description provided for @groupLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Group link'**
  String get groupLinkTitle;

  /// No description provided for @groupLinkBody.
  ///
  /// In en, this message translates to:
  /// **'Opening groups from a link is coming in the next version.'**
  String get groupLinkBody;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This address doesn\'t lead anywhere in Balnana.'**
  String get notFoundBody;

  /// No description provided for @notFoundAction.
  ///
  /// In en, this message translates to:
  /// **'Go to groups'**
  String get notFoundAction;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsDynamicColor.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper colors'**
  String get settingsDynamicColor;

  /// No description provided for @settingsDynamicColorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use colors from your device instead of Balnana yellow'**
  String get settingsDynamicColorSubtitle;

  /// No description provided for @settingsPureBlack.
  ///
  /// In en, this message translates to:
  /// **'Pure black'**
  String get settingsPureBlack;

  /// No description provided for @settingsPureBlackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A darker dark theme for OLED screens'**
  String get settingsPureBlackSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @settingsConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get settingsConnection;

  /// No description provided for @settingsServer.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get settingsServer;

  /// No description provided for @serverNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get serverNotSet;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get aboutLicenses;

  /// Opens where to get the source code of the server this app is connected to.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSource;

  /// No description provided for @aboutSourceCopied.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open a browser, so the link was copied'**
  String get aboutSourceCopied;

  /// No description provided for @serverTitle.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverTitle;

  /// No description provided for @serverIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the address of a Balnana server. Anyone can host one; the address is usually where its web app opens.'**
  String get serverIntro;

  /// No description provided for @serverUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverUrlLabel;

  /// No description provided for @serverUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://balnana.example.com'**
  String get serverUrlHint;

  /// No description provided for @serverTest.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get serverTest;

  /// No description provided for @serverSaveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get serverSaveAnyway;

  /// No description provided for @serverReset.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get serverReset;

  /// Shows the server address this app uses when none is chosen.
  ///
  /// In en, this message translates to:
  /// **'Default: {url}'**
  String serverDefault(String url);

  /// Shown after a successful connection test.
  ///
  /// In en, this message translates to:
  /// **'Connected to Balnana {version}'**
  String serverConnected(String version);

  /// No description provided for @serverModeLink.
  ///
  /// In en, this message translates to:
  /// **'Groups are shared by private link. No account needed.'**
  String get serverModeLink;

  /// No description provided for @serverModeAccounts.
  ///
  /// In en, this message translates to:
  /// **'People sign in with an account.'**
  String get serverModeAccounts;

  /// No description provided for @serverInsecure.
  ///
  /// In en, this message translates to:
  /// **'This address is not encrypted (http). Anyone on the network could read your data. Use https for servers outside your home network.'**
  String get serverInsecure;

  /// No description provided for @serverErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a web address, like balnana.example.com'**
  String get serverErrorInvalid;

  /// No description provided for @serverErrorUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect. Check the address and that the server is running.'**
  String get serverErrorUnreachable;

  /// No description provided for @serverErrorNotBalnana.
  ///
  /// In en, this message translates to:
  /// **'Something answered, but it isn\'t a Balnana server.'**
  String get serverErrorNotBalnana;

  /// No description provided for @serverSaved.
  ///
  /// In en, this message translates to:
  /// **'Server saved'**
  String get serverSaved;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
