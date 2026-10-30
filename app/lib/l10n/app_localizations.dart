import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

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

  /// Label or control text for common cancel in shared buttons and controls.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Label or control text for common retry in shared buttons and controls.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Label or control text for offline bar in the offline cache banner.
  ///
  /// In en, this message translates to:
  /// **'Offline. Showing what this device saved; changes cannot be saved until you reconnect.'**
  String get offlineBar;

  /// Label or control text for common save in shared buttons and controls.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Label or control text for common clear in shared buttons and controls.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// Label or control text for icon choose in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'Choose an icon'**
  String get iconChoose;

  /// Label or control text for icon none in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'No icon'**
  String get iconNone;

  /// Input hint for icon search hint in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'Search, or type any emoji'**
  String get iconSearchHint;

  /// Label or control text for icon use typed in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'Use this emoji'**
  String get iconUseTyped;

  /// Label or control text for icon no match in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'No icons match. Type an emoji to use it.'**
  String get iconNoMatch;

  /// Label or control text for icon section travel in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'Travel & places'**
  String get iconSectionTravel;

  /// Label or control text for icon section food in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'Food & drink'**
  String get iconSectionFood;

  /// Label or control text for icon section activities in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get iconSectionActivities;

  /// Label or control text for icon section home in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'Home & bills'**
  String get iconSectionHome;

  /// Label or control text for icon section people in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get iconSectionPeople;

  /// Label or control text for icon section nature in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'Animals & nature'**
  String get iconSectionNature;

  /// Label or control text for icon section objects in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'Money & things'**
  String get iconSectionObjects;

  /// Label or control text for icon section symbols in the icon and emoji chooser.
  ///
  /// In en, this message translates to:
  /// **'Symbols'**
  String get iconSectionSymbols;

  /// Label or control text for common remove in shared buttons and controls.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// Label or control text for common undo in shared buttons and controls.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// Stands in for a person whose name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get someone;

  /// Message for a request the server refused as too big, such as a receipt photo or an import file.
  ///
  /// In en, this message translates to:
  /// **'This is too big to send to the server.'**
  String get errorTooLarge;

  /// Message when the server has too much work to take this request now.
  ///
  /// In en, this message translates to:
  /// **'The server is busy. Please try again in a moment.'**
  String get errorBusy;

  /// Message when the server stopped waiting for an upload.
  ///
  /// In en, this message translates to:
  /// **'This took too long to send. Check your connection and try again.'**
  String get errorTimeout;

  /// Message when the server refuses a signed-in request from a web address it was not set up for.
  ///
  /// In en, this message translates to:
  /// **'The server does not accept sign-ins from this address. Whoever runs it should check its public URL.'**
  String get errorBadOrigin;

  /// Message when the expense's category no longer exists in the group.
  ///
  /// In en, this message translates to:
  /// **'That category was deleted meanwhile. Pick another one.'**
  String get errorInvalidCategory;

  /// Message when trying to rename or delete a built-in category.
  ///
  /// In en, this message translates to:
  /// **'Built-in categories can only be hidden.'**
  String get errorBuiltinCategory;

  /// Message when an expense names a member the group does not have.
  ///
  /// In en, this message translates to:
  /// **'Someone in this is no longer in the group. Reload and try again.'**
  String get errorUnknownMember;

  /// Message when an expense has no payer.
  ///
  /// In en, this message translates to:
  /// **'Choose who paid.'**
  String get errorNoPayers;

  /// Message when the payers' amounts do not add up to the expense amount.
  ///
  /// In en, this message translates to:
  /// **'What each person paid must add up to the amount.'**
  String get errorPayerTotal;

  /// Message when a payer's part of an expense in a foreign currency rounds to zero in the group's currency.
  ///
  /// In en, this message translates to:
  /// **'Someone\'s part of what was paid comes to nothing in the group\'s currency. Check the amounts.'**
  String get errorPayerTooSmall;

  /// Message when an expense note is refused.
  ///
  /// In en, this message translates to:
  /// **'The note is too long or has characters that cannot be saved.'**
  String get errorInvalidNote;

  /// Message when an expense date is outside the years allowed.
  ///
  /// In en, this message translates to:
  /// **'That date is out of range.'**
  String get errorInvalidDate;

  /// Message for error generic in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Message for error network in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection.'**
  String get errorNetwork;

  /// Message for error not found in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'This no longer exists.'**
  String get errorNotFound;

  /// Message for error required in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get errorRequired;

  /// Message for error invalid name in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Enter a name of up to 100 characters.'**
  String get errorInvalidName;

  /// Message for error duplicate name in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Someone in this group already has that name.'**
  String get errorDuplicateName;

  /// Message for error too many members in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'This group has as many people as it can hold.'**
  String get errorTooManyMembers;

  /// Message for error too many categories in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'This group has as many categories as it can hold.'**
  String get errorTooManyCategories;

  /// Message for error duplicate category in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'This group already has a category with that name.'**
  String get errorDuplicateCategory;

  /// Message for error invalid currency in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Enter a three-letter currency code, such as USD.'**
  String get errorInvalidCurrency;

  /// Heading for error invalid title in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Enter a title of up to 200 characters.'**
  String get errorInvalidTitle;

  /// Message for error invalid location in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Enter a place name of one line, up to 200 characters.'**
  String get errorInvalidLocation;

  /// Message for error invalid symbol in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Enter a symbol of up to 8 characters.'**
  String get errorInvalidSymbol;

  /// Message for error invalid emoji in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Pick a single emoji as the icon.'**
  String get errorInvalidEmoji;

  /// Message for error member has balance in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Settle this person\'s balance before removing them.'**
  String get errorMemberHasBalance;

  /// Message for error version conflict in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Someone else changed this expense while you were editing it. Reload to see their changes.'**
  String get errorVersionConflict;

  /// Message for error sign in required in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Sign in to do this.'**
  String get errorSignInRequired;

  /// Message for error rate limited in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a minute and try again.'**
  String get errorRateLimited;

  /// Message for error not a member in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'You\'re not in this group yet.'**
  String get errorNotAMember;

  /// Message for error not allowed in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Only that person or the group\'s owner can do this.'**
  String get errorNotAllowed;

  /// Message for error link groups off in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'This server doesn\'t allow opening groups by link alone.'**
  String get errorLinkGroupsOff;

  /// Message for error member claimed in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Someone has already joined as that person.'**
  String get errorMemberClaimed;

  /// Message for error member left in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Someone in this has left the group.'**
  String get errorMemberLeft;

  /// Message for error invalid email in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Enter an email address.'**
  String get errorInvalidEmail;

  /// Message for error invalid password in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Use 8 to 200 characters.'**
  String get errorInvalidPassword;

  /// Message for error email taken in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'There\'s already an account with that email. Sign in instead.'**
  String get errorEmailTaken;

  /// Message for error signup closed in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'This server isn\'t taking new accounts.'**
  String get errorSignupClosed;

  /// Message for error invalid credentials in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'That email and password don\'t match.'**
  String get errorInvalidCredentials;

  /// Message for error wrong password in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Your current password isn\'t right.'**
  String get errorWrongPassword;

  /// Message for error accounts off in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'This server doesn\'t use accounts.'**
  String get errorAccountsOff;

  /// Message for error invalid amount in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get errorInvalidAmount;

  /// Message for error too many decimals in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Too many decimal places for this currency.'**
  String get errorTooManyDecimals;

  /// Message for error amount too large in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'That amount is too large.'**
  String get errorAmountTooLarge;

  /// Message for error no shares in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one person to share the cost.'**
  String get errorNoShares;

  /// Message for error invalid share in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Each share must be a number.'**
  String get errorInvalidShare;

  /// Message for error exact total in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'The amounts must add up to the total.'**
  String get errorExactTotal;

  /// Message for error payers total in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'What everyone paid must add up to the total.'**
  String get errorPayersTotal;

  /// Label or control text for category food in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Food & drink'**
  String get categoryFood;

  /// Label or control text for category groceries in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// Label or control text for category transport in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// Label or control text for category travel in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// Label or control text for category lodging in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Lodging'**
  String get categoryLodging;

  /// Label or control text for category rent in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get categoryRent;

  /// Label or control text for category utilities in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get categoryUtilities;

  /// Label or control text for category entertainment in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// Label or control text for category shopping in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// Label or control text for category health in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// Label or control text for category gifts in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get categoryGifts;

  /// Label or control text for category other in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Label or control text for group new in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get groupNew;

  /// Tooltip on the group name at the top of a group page, which lists the groups.
  ///
  /// In en, this message translates to:
  /// **'Switch group'**
  String get groupSwitch;

  /// Label or control text for group reorder in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get groupReorder;

  /// Label or control text for group create in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get groupCreate;

  /// Label or control text for group member count in group creation, settings, or switching. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String groupMemberCount(int count);

  /// Label or control text for pill owed in the application interface. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'You\'re owed {amount}'**
  String pillOwed(String amount);

  /// Label or control text for pill owe in the application interface. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'You owe {amount}'**
  String pillOwe(String amount);

  /// Label or control text for pill settled in the application interface.
  ///
  /// In en, this message translates to:
  /// **'Settled up'**
  String get pillSettled;

  /// Heading for group missing title in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Group not found'**
  String get groupMissingTitle;

  /// Explanatory text for group missing body in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'This group was deleted, or its link was reset. Ask someone in the group for the new link.'**
  String get groupMissingBody;

  /// Heading in the group switcher for a group on this device that the server keeps for signed-in members.
  ///
  /// In en, this message translates to:
  /// **'Sign in to open this group'**
  String get groupLockedTitle;

  /// Explanation under groupLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'This group is only open to its members\' accounts. Sign in to the account that belongs to it.'**
  String get groupLockedBody;

  /// Label or control text for group forget in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Remove from this device'**
  String get groupForget;

  /// Label or control text for group link other server in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'This link belongs to another server. Connect to that server to open it.'**
  String get groupLinkOtherServer;

  /// Heading for open link title in opening one saved group URL.
  ///
  /// In en, this message translates to:
  /// **'Open a group link'**
  String get openLinkTitle;

  /// Explanatory text for open link body in opening one saved group URL.
  ///
  /// In en, this message translates to:
  /// **'Paste a link someone shared with you to join their group.'**
  String get openLinkBody;

  /// Field label for open link label in opening one saved group URL.
  ///
  /// In en, this message translates to:
  /// **'Group link'**
  String get openLinkLabel;

  /// Action button for open link action in opening one saved group URL.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLinkAction;

  /// Label or control text for open link invalid in opening one saved group URL.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a Balnana group link.'**
  String get openLinkInvalid;

  /// Label or control text for group name in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// Input hint for group name hint in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Trip to Lisbon'**
  String get groupNameHint;

  /// Label or control text for group currency in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get groupCurrency;

  /// Help text for group currency help in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'All expenses in this group use this currency. It can\'t be changed later.'**
  String get groupCurrencyHelp;

  /// Label or control text for group currency help named in group creation, settings, or switching. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{name}. All expenses in this group use this currency. It can\'t be changed later.'**
  String groupCurrencyHelpNamed(String name);

  /// Label or control text for currency choose in the currency chooser.
  ///
  /// In en, this message translates to:
  /// **'Choose a currency'**
  String get currencyChoose;

  /// Input hint for currency search hint in the currency chooser.
  ///
  /// In en, this message translates to:
  /// **'Search by code or name'**
  String get currencySearchHint;

  /// Label or control text for currency suggested in the currency chooser.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get currencySuggested;

  /// Label or control text for currency all in the currency chooser.
  ///
  /// In en, this message translates to:
  /// **'All currencies'**
  String get currencyAll;

  /// Label or control text for currency use typed in the currency chooser. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Use {code}'**
  String currencyUseTyped(String code);

  /// Label or control text for currency no match in the currency chooser.
  ///
  /// In en, this message translates to:
  /// **'No currency matches. Type its three-letter code to use it.'**
  String get currencyNoMatch;

  /// Label or control text for group symbol in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get groupSymbol;

  /// Label or control text for group symbol choose in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Choose a symbol'**
  String get groupSymbolChoose;

  /// Label or control text for group symbol example in group creation, settings, or switching. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Amounts look like {example}'**
  String groupSymbolExample(String example);

  /// Label or control text for group color in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get groupColor;

  /// Label or control text for color swatch in group or member color selection. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Color {number} of {count}'**
  String colorSwatch(int number, int count);

  /// Label or control text for group people in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get groupPeople;

  /// Label or control text for group your name in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get groupYourName;

  /// Label or control text for group person name in group creation, settings, or switching. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Person {number}'**
  String groupPersonName(int number);

  /// Label or control text for group add person in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get groupAddPerson;

  /// Help text for group people help in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'You can add more people later, or they can join with the link.'**
  String get groupPeopleHelp;

  /// Heading for identity title in link-mode member identity selection.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get identityTitle;

  /// Explanatory text for identity body in link-mode member identity selection.
  ///
  /// In en, this message translates to:
  /// **'Pick your name so Balnana can show what you owe. Only this device remembers it.'**
  String get identityBody;

  /// Label or control text for identity new in link-mode member identity selection.
  ///
  /// In en, this message translates to:
  /// **'I\'m someone new'**
  String get identityNew;

  /// Heading for identity new title in link-mode member identity selection.
  ///
  /// In en, this message translates to:
  /// **'Join this group'**
  String get identityNewTitle;

  /// Label or control text for identity join in link-mode member identity selection.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get identityJoin;

  /// Label or control text for identity change in link-mode member identity selection.
  ///
  /// In en, this message translates to:
  /// **'Who you are'**
  String get identityChange;

  /// Label or control text for identity none in link-mode member identity selection.
  ///
  /// In en, this message translates to:
  /// **'Not chosen yet'**
  String get identityNone;

  /// Label or control text for member name in group member management.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get memberName;

  /// Label or control text for member you in group member management. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{name} (you)'**
  String memberYou(String name);

  /// Label or control text for member add in group member management.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get memberAdd;

  /// Heading for member add title in group member management.
  ///
  /// In en, this message translates to:
  /// **'Add someone'**
  String get memberAddTitle;

  /// Label or control text for member rename in group member management.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get memberRename;

  /// Heading for member rename title in group member management.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get memberRenameTitle;

  /// Heading for member remove title in group member management. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String memberRemoveTitle(String name);

  /// Explanatory text for member remove body in group member management.
  ///
  /// In en, this message translates to:
  /// **'They\'ll stay on past expenses but can\'t be added to new ones.'**
  String get memberRemoveBody;

  /// Label or control text for group link copied in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Link copied. Anyone with it can open this group.'**
  String get groupLinkCopied;

  /// Label or control text for group share in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get groupShare;

  /// Label or control text for group settings in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get groupSettings;

  /// Label or control text for group edit in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get groupEdit;

  /// Label or control text for group sharing in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get groupSharing;

  /// Label or control text for group copy link in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get groupCopyLink;

  /// Settings tile that shows the group's link as a QR code to scan.
  ///
  /// In en, this message translates to:
  /// **'Show QR code'**
  String get groupQrCode;

  /// Help text under the tile that shows the group's QR code.
  ///
  /// In en, this message translates to:
  /// **'Let people scan the link with their phone\'s camera.'**
  String get groupQrCodeHelp;

  /// Screen reader label of the QR code that encodes a group's link.
  ///
  /// In en, this message translates to:
  /// **'QR code for the link to {group}'**
  String groupQrLabel(String group);

  /// Help text for group copy link help in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the link can see and edit this group.'**
  String get groupCopyLinkHelp;

  /// Label or control text for group copy link help accounts in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'People with the link can ask to join after signing in.'**
  String get groupCopyLinkHelpAccounts;

  /// Heading for link access title in group link-access permissions.
  ///
  /// In en, this message translates to:
  /// **'Open to anyone with the link'**
  String get linkAccessTitle;

  /// Help text for link access help in group link-access permissions.
  ///
  /// In en, this message translates to:
  /// **'Let people see and edit without an account'**
  String get linkAccessHelp;

  /// Heading for reset link title in group-link rotation.
  ///
  /// In en, this message translates to:
  /// **'Reset link'**
  String get resetLinkTitle;

  /// Help text for reset link help in group-link rotation.
  ///
  /// In en, this message translates to:
  /// **'Make a new link; the old one stops working'**
  String get resetLinkHelp;

  /// Explanatory text for reset link body in group-link rotation.
  ///
  /// In en, this message translates to:
  /// **'The current link will stop working, for everyone. Share the new link with people who should keep access.'**
  String get resetLinkBody;

  /// Action button for reset link action in group-link rotation.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetLinkAction;

  /// Label or control text for reset link done in group-link rotation.
  ///
  /// In en, this message translates to:
  /// **'Link reset. Share the new one.'**
  String get resetLinkDone;

  /// Label or control text for group this device in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get groupThisDevice;

  /// Label or control text for group data in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get groupData;

  /// Heading for categories title in group category settings.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// Help text for categories help in group category settings.
  ///
  /// In en, this message translates to:
  /// **'Add your own, or hide the ones you don\'t use'**
  String get categoriesHelp;

  /// Label or control text for categories own in group category settings.
  ///
  /// In en, this message translates to:
  /// **'This group\'s'**
  String get categoriesOwn;

  /// Label or control text for categories own empty in group category settings.
  ///
  /// In en, this message translates to:
  /// **'No categories of the group\'s own yet.'**
  String get categoriesOwnEmpty;

  /// Label or control text for categories built in in group category settings.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get categoriesBuiltIn;

  /// Help text for categories built in help in group category settings.
  ///
  /// In en, this message translates to:
  /// **'Hidden categories are not offered for new expenses. Expenses that have one keep it.'**
  String get categoriesBuiltInHelp;

  /// Label or control text for category add in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoryAdd;

  /// Label or control text for category edit in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryEdit;

  /// Label or control text for category name in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryName;

  /// Label or control text for category delete in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get categoryDelete;

  /// Heading for category delete title in built-in category names or category management. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String categoryDeleteTitle(String name);

  /// Explanatory text for category delete body in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Expenses in this category will have none.'**
  String get categoryDeleteBody;

  /// Action button for category delete action in built-in category names or category management.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get categoryDeleteAction;

  /// Label or control text for export csv in the ledger CSV download.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportCsv;

  /// Help text for export csv help in the ledger CSV download.
  ///
  /// In en, this message translates to:
  /// **'Every expense and payment, for a spreadsheet'**
  String get exportCsvHelp;

  /// Label or control text for export csv done in the ledger CSV download.
  ///
  /// In en, this message translates to:
  /// **'Exported'**
  String get exportCsvDone;

  /// Heading for forget title in removing a group link from this device.
  ///
  /// In en, this message translates to:
  /// **'Remove from this device'**
  String get forgetTitle;

  /// Help text for forget help in removing a group link from this device.
  ///
  /// In en, this message translates to:
  /// **'The group stays on the server for everyone else'**
  String get forgetHelp;

  /// Explanatory text for forget body in removing a group link from this device.
  ///
  /// In en, this message translates to:
  /// **'You can open it again with the link.'**
  String get forgetBody;

  /// Label or control text for group you in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get groupYou;

  /// Heading for leave title in leaving a group.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get leaveTitle;

  /// Help text for leave help in leaving a group.
  ///
  /// In en, this message translates to:
  /// **'Your expenses stay; you can join again with the link'**
  String get leaveHelp;

  /// Explanatory text for leave body in leaving a group.
  ///
  /// In en, this message translates to:
  /// **'The group disappears from your list. Your expenses and balance stay in the group.'**
  String get leaveBody;

  /// Action button for leave action in leaving a group.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveAction;

  /// Label or control text for tab expenses in the application interface.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get tabExpenses;

  /// Heading for hero who title in the group balance card.
  ///
  /// In en, this message translates to:
  /// **'Who are you in this group?'**
  String get heroWhoTitle;

  /// Explanatory text for hero who body in the group balance card.
  ///
  /// In en, this message translates to:
  /// **'Pick your name to see what you owe and are owed.'**
  String get heroWhoBody;

  /// Action button for hero who action in the group balance card.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get heroWhoAction;

  /// Heading for hero join title in the group balance card.
  ///
  /// In en, this message translates to:
  /// **'You\'re viewing this group'**
  String get heroJoinTitle;

  /// Explanatory text for hero join body in the group balance card.
  ///
  /// In en, this message translates to:
  /// **'Join to add expenses and see what you owe.'**
  String get heroJoinBody;

  /// Action button for join action in joining or claiming a group member.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinAction;

  /// Positive balance label: other members owe this device's selected member money.
  ///
  /// In en, this message translates to:
  /// **'You\'re owed'**
  String get heroOwed;

  /// Negative balance label: this device's selected member owes other members money.
  ///
  /// In en, this message translates to:
  /// **'You owe'**
  String get heroOwe;

  /// Zero balance label: the selected member neither owes nor is owed money.
  ///
  /// In en, this message translates to:
  /// **'You\'re settled up'**
  String get heroSettled;

  /// Label or control text for hero you are in the group balance card. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'You are {name}'**
  String heroYouAre(String name);

  /// Label or control text for expense add in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expenseAdd;

  /// Heading for expenses empty title in expense search and empty states.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get expensesEmptyTitle;

  /// Explanatory text for expenses empty body in expense search and empty states.
  ///
  /// In en, this message translates to:
  /// **'Add the first one, and Balnana will work out who owes whom.'**
  String get expensesEmptyBody;

  /// Input hint for expenses search hint in expense search and empty states.
  ///
  /// In en, this message translates to:
  /// **'Search titles, notes and places'**
  String get expensesSearchHint;

  /// Label or control text for search clear in the application interface.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClear;

  /// Heading for expenses no match title in expense search and empty states.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get expensesNoMatchTitle;

  /// Explanatory text for expenses no match body in expense search and empty states.
  ///
  /// In en, this message translates to:
  /// **'Try other words, or fewer filters.'**
  String get expensesNoMatchBody;

  /// Filter chip: expenses of every member, not just one.
  ///
  /// In en, this message translates to:
  /// **'Anyone'**
  String get filterAnyone;

  /// Label or control text for filter any category in expense filters.
  ///
  /// In en, this message translates to:
  /// **'Any category'**
  String get filterAnyCategory;

  /// Filter choice: only payments between members, not expenses.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get filterPayments;

  /// Label or control text for filter clear in expense filters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get filterClear;

  /// Label or control text for period all in the expense and statistics date range filter.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAll;

  /// Label or control text for period this month in the expense and statistics date range filter.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get periodThisMonth;

  /// Label or control text for period last month in the expense and statistics date range filter.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get periodLastMonth;

  /// Label or control text for period this year in the expense and statistics date range filter.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get periodThisYear;

  /// Label or control text for period pick days in the expense and statistics date range filter.
  ///
  /// In en, this message translates to:
  /// **'Pick dates…'**
  String get periodPickDays;

  /// Title of the page with charts of what a group spent.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get statsTitle;

  /// Label or control text for stats total in spending statistics.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get statsTotal;

  /// Label or control text for stats count in spending statistics. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense} other{{count} expenses}}'**
  String statsCount(int count);

  /// Label or control text for stats by category in spending statistics.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get statsByCategory;

  /// Chart heading: what each person paid, next to their share of the costs.
  ///
  /// In en, this message translates to:
  /// **'Paid and share per person'**
  String get statsByMember;

  /// Legend for outgoing spending paid by a member, net of refunds and excluding income and settlement payments.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statsPaid;

  /// Legend for a member's allocated share of spending, net of refunds and excluding income and settlement payments.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get statsShare;

  /// Label or control text for stats by month in spending statistics.
  ///
  /// In en, this message translates to:
  /// **'By month'**
  String get statsByMonth;

  /// Label or control text for stats no category in spending statistics.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get statsNoCategory;

  /// Heading for stats empty title in spending statistics.
  ///
  /// In en, this message translates to:
  /// **'Nothing spent'**
  String get statsEmptyTitle;

  /// Explanatory text for stats empty body in spending statistics.
  ///
  /// In en, this message translates to:
  /// **'There are no expenses in this period.'**
  String get statsEmptyBody;

  /// Label or control text for stats show expenses in spending statistics.
  ///
  /// In en, this message translates to:
  /// **'Show these expenses'**
  String get statsShowExpenses;

  /// Label or control text for date today in expense date headings.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// Label or control text for date yesterday in expense date headings.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// Heading for payment title in recorded member-to-member payments. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{from} paid {to}'**
  String paymentTitle(String from, String to);

  /// Caption naming who originally paid an outgoing expense, followed by a preformatted amount. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{name} paid {amount}'**
  String expensePaidBy(String name, String amount);

  /// Caption for an outgoing expense paid by several people, followed by a preformatted amount. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{count} people paid {amount}'**
  String expensePaidByMany(int count, String amount);

  /// Caption naming who originally paid an outgoing expense, shown beside its total so it carries no amount. Placeholders are supplied by the app.
  ///
  /// In en, this message translates to:
  /// **'{name} paid'**
  String expensePaidByName(String name);

  /// Caption for an outgoing expense paid by several people, shown beside its total so it carries no amount. Placeholders are supplied by the app.
  ///
  /// In en, this message translates to:
  /// **'{count} people paid'**
  String expensePaidByManyNames(int count);

  /// Caption naming the original receiver of an imported refund or income. Stored ledger payer and split roles are reversed for these entries. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{name} received {amount}'**
  String expenseReceivedBy(String name, String amount);

  /// Caption naming the original receiver of a refund or income, shown beside its total so it carries no amount. Stored ledger payer and split roles are reversed for these entries. Placeholders are supplied by the app.
  ///
  /// In en, this message translates to:
  /// **'{name} received'**
  String expenseReceivedByName(String name);

  /// Caption naming several original receivers of a refund or income, shown beside its total so it carries no amount. Do not describe them as expense payers. Placeholders are supplied by the app.
  ///
  /// In en, this message translates to:
  /// **'{count} people received'**
  String expenseReceivedByManyNames(int count);

  /// Caption naming several original receivers of a refund or income. Do not describe them as expense payers. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{count} people received {amount}'**
  String expenseReceivedByMany(int count, String amount);

  /// Label or control text for transaction refund in imported transaction direction.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get transactionRefund;

  /// Label or control text for transaction income in imported transaction direction.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionIncome;

  /// Label or control text for payment delete in recorded member-to-member payments.
  ///
  /// In en, this message translates to:
  /// **'Delete payment'**
  String get paymentDelete;

  /// Label or control text for payment deleted in recorded member-to-member payments.
  ///
  /// In en, this message translates to:
  /// **'Payment deleted'**
  String get paymentDeleted;

  /// Label or control text for expense deleted in the expense editor or expense list. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Deleted “{title}”'**
  String expenseDeleted(String title);

  /// Label or control text for expense new in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get expenseNew;

  /// Label or control text for expense edit in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get expenseEdit;

  /// Label or control text for expense delete in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get expenseDelete;

  /// Label or control text for expense amount in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmount;

  /// Heading for expense title in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'What was it for?'**
  String get expenseTitle;

  /// Input hint for expense title hint in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Dinner, tickets, taxi…'**
  String get expenseTitleHint;

  /// Label or control text for expense amount from payers in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'What everyone paid, added up'**
  String get expenseAmountFromPayers;

  /// Button under the amount in the expense editor that picks the currency the expense was paid in.
  ///
  /// In en, this message translates to:
  /// **'Paid in {currency}'**
  String expensePaidIn(String currency);

  /// Label of the exchange rate field in the expense editor: how much one unit of the currency paid in is worth in the group's currency.
  ///
  /// In en, this message translates to:
  /// **'1 {from} in {to}'**
  String expenseRate(String from, String to);

  /// Label of the field in the expense editor for what an expense paid in another currency came to in the group's currency.
  ///
  /// In en, this message translates to:
  /// **'Total in {currency}'**
  String expenseInGroupCurrency(String currency);

  /// Help under the exchange rate fields in the expense editor.
  ///
  /// In en, this message translates to:
  /// **'Balances stay in {currency}. Type the rate, or what it came to, such as from a card statement.'**
  String expenseForeignHelp(String currency);

  /// Label or control text for expense note in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get expenseNote;

  /// Input hint for expense note hint in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get expenseNoteHint;

  /// Label or control text for expense location in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get expenseLocation;

  /// Input hint for expense location hint in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Where was it? (optional)'**
  String get expenseLocationHint;

  /// Label or control text for location pick on map in the expense location picker.
  ///
  /// In en, this message translates to:
  /// **'Pick on map'**
  String get locationPickOnMap;

  /// Label or control text for location use current in the expense location picker.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get locationUseCurrent;

  /// Label or control text for location finding in the expense location picker.
  ///
  /// In en, this message translates to:
  /// **'Finding where you are…'**
  String get locationFinding;

  /// Label or control text for location change in the expense location picker.
  ///
  /// In en, this message translates to:
  /// **'Change on map'**
  String get locationChange;

  /// Label or control text for location remove pin in the expense location picker.
  ///
  /// In en, this message translates to:
  /// **'Remove pin'**
  String get locationRemovePin;

  /// Label or control text for location open in maps in the expense location picker.
  ///
  /// In en, this message translates to:
  /// **'Open in maps'**
  String get locationOpenInMaps;

  /// Heading for location pick title in the expense location picker.
  ///
  /// In en, this message translates to:
  /// **'Pick a location'**
  String get locationPickTitle;

  /// Input hint for location pick hint in the expense location picker.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to drop a pin'**
  String get locationPickHint;

  /// Label or control text for location pick done in the expense location picker.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get locationPickDone;

  /// Label or control text for location denied in the expense location picker.
  ///
  /// In en, this message translates to:
  /// **'Balnana may not use your location. You can allow it in your device or browser settings.'**
  String get locationDenied;

  /// Label or control text for location off in the expense location picker.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off on this device.'**
  String get locationOff;

  /// Label or control text for location unavailable in the expense location picker.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find where you are. Try again, or drop a pin on the map.'**
  String get locationUnavailable;

  /// Label or control text for expense receipt in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get expenseReceipt;

  /// Label or control text for expense has receipt in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Has a receipt photo'**
  String get expenseHasReceipt;

  /// Label or control text for expense has location in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Has a location'**
  String get expenseHasLocation;

  /// Label or control text for receipt take photo in receipt photo controls.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get receiptTakePhoto;

  /// Label or control text for receipt choose in receipt photo controls.
  ///
  /// In en, this message translates to:
  /// **'Choose a picture'**
  String get receiptChoose;

  /// Label or control text for receipt remove in receipt photo controls.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get receiptRemove;

  /// Label or control text for receipt view in receipt photo controls.
  ///
  /// In en, this message translates to:
  /// **'Receipt photo'**
  String get receiptView;

  /// Label or control text for receipt not saved in receipt photo controls. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'The expense was saved, but not its receipt photo. {reason}'**
  String receiptNotSaved(String reason);

  /// Field label for expense paid by label in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get expensePaidByLabel;

  /// Field heading for the people whose spending was refunded or who benefited from received money; maps to reversed ledger payers.
  ///
  /// In en, this message translates to:
  /// **'Received for'**
  String get expenseReceivedForLabel;

  /// Field heading for the people who received refund or income money; maps to reversed ledger splits.
  ///
  /// In en, this message translates to:
  /// **'Received by'**
  String get expenseReceivedByLabel;

  /// Label or control text for expense multiple payers in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Several people'**
  String get expenseMultiplePayers;

  /// Label or control text for expense split in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get expenseSplit;

  /// Label or control text for split equal in expense split entry.
  ///
  /// In en, this message translates to:
  /// **'Equally'**
  String get splitEqual;

  /// Label or control text for split exact in expense split entry.
  ///
  /// In en, this message translates to:
  /// **'Amounts'**
  String get splitExact;

  /// Label or control text for split shares in expense split entry.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get splitShares;

  /// Label or control text for split left in expense split entry. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{amount} left to assign'**
  String splitLeft(String amount);

  /// Label or control text for split over in expense split entry. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{amount} too much'**
  String splitOver(String amount);

  /// Heading for conflict title in concurrent expense edit resolution.
  ///
  /// In en, this message translates to:
  /// **'Changed elsewhere'**
  String get conflictTitle;

  /// Label or control text for conflict reload in concurrent expense edit resolution.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get conflictReload;

  /// Label or control text for expense changed elsewhere in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Someone else changed this expense. Reloading shows their version and drops your changes here.'**
  String get expenseChangedElsewhere;

  /// Label or control text for suggested payments in the application interface.
  ///
  /// In en, this message translates to:
  /// **'Suggested payments'**
  String get suggestedPayments;

  /// Label or control text for all settled in the application interface.
  ///
  /// In en, this message translates to:
  /// **'Everyone is settled up.'**
  String get allSettled;

  /// Label or control text for transfer you pay in a suggested settlement payment. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'You pay {name}'**
  String transferYouPay(String name);

  /// Label or control text for transfer pays you in a suggested settlement payment. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{name} pays you'**
  String transferPaysYou(String name);

  /// Label or control text for transfer pays in a suggested settlement payment. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{from} pays {to}'**
  String transferPays(String from, String to);

  /// Label or control text for record payment in the settlement dialog.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordPayment;

  /// Heading for record payment title in the settlement dialog.
  ///
  /// In en, this message translates to:
  /// **'Record a payment'**
  String get recordPaymentTitle;

  /// Help text for record payment help in the settlement dialog.
  ///
  /// In en, this message translates to:
  /// **'Only record money that was actually paid, outside Balnana.'**
  String get recordPaymentHelp;

  /// Label or control text for payment recorded in recorded member-to-member payments.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get paymentRecorded;

  /// Message for activity group created in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} created {group}'**
  String activityGroupCreated(String who, String group);

  /// Message for activity group updated in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} changed the group details'**
  String activityGroupUpdated(String who);

  /// Message for activity link reset in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} reset the group link'**
  String activityLinkReset(String who);

  /// Message for activity member added in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} added {name}'**
  String activityMemberAdded(String who, String name);

  /// Message for activity member renamed in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} renamed {oldName} to {name}'**
  String activityMemberRenamed(String who, String oldName, String name);

  /// Message for activity member removed in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} removed {name}'**
  String activityMemberRemoved(String who, String name);

  /// Message for activity category added in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} added the category {name}'**
  String activityCategoryAdded(String who, String name);

  /// Message for activity category updated in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} changed the categories'**
  String activityCategoryUpdated(String who);

  /// Message for activity category deleted in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} deleted the category {name}'**
  String activityCategoryDeleted(String who, String name);

  /// Message for activity member joined in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{name} joined'**
  String activityMemberJoined(String name);

  /// Message for activity expense added in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} added “{title}” ({amount})'**
  String activityExpenseAdded(String who, String title, String amount);

  /// Message for activity expense updated in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} edited “{title}” ({amount})'**
  String activityExpenseUpdated(String who, String title, String amount);

  /// Message for activity expense deleted in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} deleted “{title}”'**
  String activityExpenseDeleted(String who, String title);

  /// Message for activity expense restored in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} restored “{title}”'**
  String activityExpenseRestored(String who, String title);

  /// Message for activity payment added in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} recorded that {from} paid {to} {amount}'**
  String activityPaymentAdded(String who, String from, String to, String amount);

  /// Message for activity payment deleted in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} deleted a payment of {amount}'**
  String activityPaymentDeleted(String who, String amount);

  /// Message for activity payment restored in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} restored a payment of {amount}'**
  String activityPaymentRestored(String who, String amount);

  /// Message for activity group imported in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} imported {count, plural, =1{1 entry} other{{count} entries}} from {source}'**
  String activityGroupImported(String who, int count, String source);

  /// Message for activity receipt added in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} added a receipt photo to “{title}”'**
  String activityReceiptAdded(String who, String title);

  /// Message for activity receipt removed in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} removed the receipt photo from “{title}”'**
  String activityReceiptRemoved(String who, String title);

  /// Message for activity other in the cross-group activity timeline. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} made a change'**
  String activityOther(String who);

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

  /// Heading for groups empty title in the groups home page.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get groupsEmptyTitle;

  /// Explanatory text for groups empty body in the groups home page.
  ///
  /// In en, this message translates to:
  /// **'Groups you create or open from a link will show up here.'**
  String get groupsEmptyBody;

  /// Heading for groups no server title in the groups home page.
  ///
  /// In en, this message translates to:
  /// **'Connect to a server'**
  String get groupsNoServerTitle;

  /// Explanatory text for groups no server body in the groups home page.
  ///
  /// In en, this message translates to:
  /// **'Balnana keeps your groups on a server you choose, such as one you host yourself.'**
  String get groupsNoServerBody;

  /// Action button for groups no server action in the groups home page.
  ///
  /// In en, this message translates to:
  /// **'Choose server'**
  String get groupsNoServerAction;

  /// Heading for groups unreachable title in the groups home page.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server'**
  String get groupsUnreachableTitle;

  /// Explanatory text for groups unreachable body in the groups home page.
  ///
  /// In en, this message translates to:
  /// **'Check your connection, or the server address in Settings.'**
  String get groupsUnreachableBody;

  /// Shown on the activity page when some groups could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One group could not be loaded, so its changes are missing.} other{{count} groups could not be loaded, so their changes are missing.}}'**
  String activityPartial(int count);

  /// Heading for activity empty title in the cross-group activity timeline.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get activityEmptyTitle;

  /// Explanatory text for activity empty body in the cross-group activity timeline.
  ///
  /// In en, this message translates to:
  /// **'New expenses and payments in your groups will appear here.'**
  String get activityEmptyBody;

  /// Heading for not found title in the missing route page.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// Explanatory text for not found body in the missing route page.
  ///
  /// In en, this message translates to:
  /// **'This address doesn\'t lead anywhere in Balnana.'**
  String get notFoundBody;

  /// Action button for not found action in the missing route page.
  ///
  /// In en, this message translates to:
  /// **'Go to groups'**
  String get notFoundAction;

  /// Label or control text for settings appearance in application settings.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Label or control text for settings account in application settings.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// Label or control text for account rename in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Change name'**
  String get accountRename;

  /// Label or control text for password change in password setup or change.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get passwordChange;

  /// Label or control text for password changed in password setup or change.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Other devices are signed out.'**
  String get passwordChanged;

  /// Label or control text for password set in password setup or change.
  ///
  /// In en, this message translates to:
  /// **'Set a password'**
  String get passwordSet;

  /// Help text for password set help in password setup or change.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email or username and a password too'**
  String get passwordSetHelp;

  /// Label or control text for password set done in password setup or change.
  ///
  /// In en, this message translates to:
  /// **'Password set. Other devices are signed out.'**
  String get passwordSetDone;

  /// Label or control text for password current in password setup or change.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get passwordCurrent;

  /// Label or control text for password new in password setup or change.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNew;

  /// Label or control text for sign out in the application interface.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Subtitle of a sign-in provider tile in account settings when the account uses it.
  ///
  /// In en, this message translates to:
  /// **'Signs in to this account. Tap to remove.'**
  String get accountOAuthLinked;

  /// Subtitle of a sign-in provider tile in account settings when the account doesn't use it yet.
  ///
  /// In en, this message translates to:
  /// **'Add as a way to sign in'**
  String get accountOAuthAdd;

  /// Title of the dialog asking for the password before adding a sign-in provider.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String accountOAuthAddTitle(String name);

  /// Snack bar after adding a sign-in provider to the account.
  ///
  /// In en, this message translates to:
  /// **'You can now sign in with {name}.'**
  String accountOAuthAdded(String name);

  /// Title of the dialog confirming removing a sign-in provider.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String accountOAuthRemoveTitle(String name);

  /// Body of the dialog confirming removing a sign-in provider.
  ///
  /// In en, this message translates to:
  /// **'You won\'t be able to sign in with {name} until you add it again.'**
  String accountOAuthRemoveBody(String name);

  /// Button that removes a sign-in provider from the account.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get accountOAuthRemove;

  /// Snack bar after removing a sign-in provider.
  ///
  /// In en, this message translates to:
  /// **'{name} removed.'**
  String accountOAuthRemoved(String name);

  /// Heading of the page shown until the account's email is confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get confirmEmailTitle;

  /// Body of the page shown until the account's email is confirmed.
  ///
  /// In en, this message translates to:
  /// **'This server needs a confirmed email. Open the link we sent to {email}.'**
  String confirmEmailBody(String email);

  /// Button that checks whether the email has been confirmed.
  ///
  /// In en, this message translates to:
  /// **'I\'ve confirmed it'**
  String get confirmEmailDone;

  /// Button that sends the confirmation email again.
  ///
  /// In en, this message translates to:
  /// **'Send the link again'**
  String get confirmEmailResend;

  /// Snack bar when the email still isn't confirmed.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed yet. Open the link in the email.'**
  String get confirmEmailNotYet;

  /// Label or control text for settings theme in application settings.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Label or control text for theme system in appearance settings.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// Label or control text for theme light in appearance settings.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Label or control text for theme dark in appearance settings.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Label or control text for settings dynamic color in application settings.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper colors'**
  String get settingsDynamicColor;

  /// Supporting text for settings dynamic color subtitle in application settings.
  ///
  /// In en, this message translates to:
  /// **'Use colors from your device instead of Balnana yellow'**
  String get settingsDynamicColorSubtitle;

  /// Label or control text for settings wallpaper groups in application settings.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper colors in groups'**
  String get settingsWallpaperGroups;

  /// Supporting text for settings wallpaper groups subtitle in application settings.
  ///
  /// In en, this message translates to:
  /// **'Groups use your device colors too, instead of their own'**
  String get settingsWallpaperGroupsSubtitle;

  /// Label or control text for settings pure black in application settings.
  ///
  /// In en, this message translates to:
  /// **'Pure black'**
  String get settingsPureBlack;

  /// Supporting text for settings pure black subtitle in application settings.
  ///
  /// In en, this message translates to:
  /// **'A darker dark theme for OLED screens'**
  String get settingsPureBlackSubtitle;

  /// Label or control text for settings my share in application settings.
  ///
  /// In en, this message translates to:
  /// **'Show my share'**
  String get settingsMyShare;

  /// Explains the optional expense-list setting that replaces each transaction's total with this member's lent or borrowed amount.
  ///
  /// In en, this message translates to:
  /// **'Expenses show what you lent or borrowed instead of the total'**
  String get settingsMyShareSubtitle;

  /// Label or control text for settings language in application settings.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language option that follows the device and clears the signed-in account's language override.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// Label or control text for settings notifications in application settings.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Supporting text for settings notifications subtitle in application settings.
  ///
  /// In en, this message translates to:
  /// **'When someone adds, changes or deletes an expense you are in'**
  String get settingsNotificationsSubtitle;

  /// Subtitle of the notifications switch when the system blocks the app's notifications.
  ///
  /// In en, this message translates to:
  /// **'Blocked in the phone\'s settings: allow notifications for Balnana there to see them'**
  String get settingsNotificationsBlocked;

  /// Message for push channel in Android notification content.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get pushChannel;

  /// Message for push channel description in Android notification content.
  ///
  /// In en, this message translates to:
  /// **'When someone adds, changes or deletes an expense you are in'**
  String get pushChannelDescription;

  /// Message for push expense added in Android notification content. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} added {title} · {amount}'**
  String pushExpenseAdded(String who, String title, String amount);

  /// Message for push expense edited in Android notification content. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} changed {title} · {amount}'**
  String pushExpenseEdited(String who, String title, String amount);

  /// Message for push expense deleted in Android notification content. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{who} deleted {title} · {amount}'**
  String pushExpenseDeleted(String who, String title, String amount);

  /// Message for push expense added anon in Android notification content. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{title} was added · {amount}'**
  String pushExpenseAddedAnon(String title, String amount);

  /// Message for push expense edited anon in Android notification content. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{title} was changed · {amount}'**
  String pushExpenseEditedAnon(String title, String amount);

  /// Message for push expense deleted anon in Android notification content. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{title} was deleted · {amount}'**
  String pushExpenseDeletedAnon(String title, String amount);

  /// Message for push payment added in Android notification content. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{payer} paid {payee} {amount}'**
  String pushPaymentAdded(String payer, String payee, String amount);

  /// Label or control text for settings connection in application settings.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get settingsConnection;

  /// Label or control text for settings server in application settings.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get settingsServer;

  /// Label or control text for server not set in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get serverNotSet;

  /// Label or control text for settings about in application settings.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Label or control text for about version in the About settings section.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// Label or control text for about licenses in the About settings section.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get aboutLicenses;

  /// Opens where to get the source code of the server this app is connected to.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get aboutSource;

  /// Label or control text for about source copied in the About settings section.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open a browser, so the link was copied'**
  String get aboutSourceCopied;

  /// Heading for server title in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverTitle;

  /// Label or control text for server intro in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'Enter the address of a Balnana server. Anyone can host one; the address is usually where its web app opens.'**
  String get serverIntro;

  /// Field label for server url label in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverUrlLabel;

  /// Input hint for server url hint in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'https://balnana.example.com'**
  String get serverUrlHint;

  /// Label or control text for server test in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get serverTest;

  /// Label or control text for server save anyway in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get serverSaveAnyway;

  /// Label or control text for server reset in the server address and connection settings.
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

  /// Label or control text for server mode link in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'Groups are shared by private link. No account needed.'**
  String get serverModeLink;

  /// Label or control text for server mode accounts in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'People sign in with an account.'**
  String get serverModeAccounts;

  /// Label or control text for server insecure in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'This address is not encrypted (http). Anyone on the network could read your data. Use https for servers outside your home network.'**
  String get serverInsecure;

  /// Label or control text for server error invalid in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'Enter a web address, like balnana.example.com'**
  String get serverErrorInvalid;

  /// Label or control text for server error unreachable in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect. Check the address and that the server is running.'**
  String get serverErrorUnreachable;

  /// Label or control text for server error not balnana in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'Something answered, but it isn\'t a Balnana server.'**
  String get serverErrorNotBalnana;

  /// Label or control text for server saved in the server address and connection settings.
  ///
  /// In en, this message translates to:
  /// **'Server saved'**
  String get serverSaved;

  /// Label or control text for sign in in account sign-in.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Heading for group sign in title in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Sign in to open this group'**
  String get groupSignInTitle;

  /// Explanatory text for group sign in body in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'This group is only for its members. Sign in to see it or to join.'**
  String get groupSignInBody;

  /// Heading for sign in title in account sign-in.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// Explanatory text for sign in body in account sign-in.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your groups.'**
  String get signInBody;

  /// Label or control text for sign in no password in account sign-in.
  ///
  /// In en, this message translates to:
  /// **'This server signs people in another way. Ask whoever runs it.'**
  String get signInNoPassword;

  /// Heading for register title in account registration.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// Explanatory text for register body in account registration.
  ///
  /// In en, this message translates to:
  /// **'Keep your groups on every device.'**
  String get registerBody;

  /// Action button for register action in account registration.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerAction;

  /// Label or control text for register have account in account registration.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get registerHaveAccount;

  /// Label or control text for sign in no account in account sign-in.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signInNoAccount;

  /// Label or control text for account name in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get accountName;

  /// Help text for account name help in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'What people in your groups will see'**
  String get accountNameHelp;

  /// Label or control text for account email in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmail;

  /// Label or control text for account password in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPassword;

  /// Help text for account password help in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get accountPasswordHelp;

  /// Label or control text for password show in password setup or change.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get passwordShow;

  /// Label or control text for password hide in password setup or change.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get passwordHide;

  /// Label or control text for join pick name in joining or claiming a group member.
  ///
  /// In en, this message translates to:
  /// **'Pick another name'**
  String get joinPickName;

  /// Heading for join title in joining or claiming a group member. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Join {name}'**
  String joinTitle(String name);

  /// Explanatory text for join body in joining or claiming a group member.
  ///
  /// In en, this message translates to:
  /// **'Are you one of these people? Pick yourself to take over their expenses.'**
  String get joinBody;

  /// Label or control text for join body new in joining or claiming a group member.
  ///
  /// In en, this message translates to:
  /// **'Join to add expenses and see your balance.'**
  String get joinBodyNew;

  /// Label or control text for join as new in joining or claiming a group member.
  ///
  /// In en, this message translates to:
  /// **'I\'m someone new'**
  String get joinAsNew;

  /// Label or control text for join as name in joining or claiming a group member. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Join as {name}'**
  String joinAsName(String name);

  /// Label or control text for join taken in joining or claiming a group member. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Already joined: {names}'**
  String joinTaken(String names);

  /// Label or control text for join taken count in joining or claiming a group member. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{count} people have already joined.'**
  String joinTakenCount(int count);

  /// Label or control text for common continue in shared buttons and controls.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Message for error email off in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'This server doesn\'t send email.'**
  String get errorEmailOff;

  /// Message for error invalid token in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'This link has expired or was already used.'**
  String get errorInvalidToken;

  /// Heading for forgot password title in the password-reset email request.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordTitle;

  /// Explanatory text for forgot password body in the password-reset email request.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email you a link to choose a new password.'**
  String get forgotPasswordBody;

  /// Action button for forgot password action in the password-reset email request.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get forgotPasswordAction;

  /// Label or control text for forgot password sent in the password-reset email request.
  ///
  /// In en, this message translates to:
  /// **'If there\'s an account for that address, a link is on its way.'**
  String get forgotPasswordSent;

  /// Heading for reset password title in password reset through an emailed link.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get resetPasswordTitle;

  /// Explanatory text for reset password body in password reset through an emailed link.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be signed out everywhere, then you can sign in with the new password.'**
  String get resetPasswordBody;

  /// Action button for reset password action in password reset through an emailed link.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get resetPasswordAction;

  /// Label or control text for reset password done in password reset through an emailed link.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Sign in with your new password.'**
  String get resetPasswordDone;

  /// Heading for verify email title in email verification.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get verifyEmailTitle;

  /// Help text for verify email help in email verification.
  ///
  /// In en, this message translates to:
  /// **'So you can reset your password if you forget it'**
  String get verifyEmailHelp;

  /// Label or control text for verify email sent in email verification. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Check {email} for a link.'**
  String verifyEmailSent(String email);

  /// Label or control text for verify email done in email verification.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed'**
  String get verifyEmailDone;

  /// Explanatory text for verify email done body in email verification.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your address is confirmed.'**
  String get verifyEmailDoneBody;

  /// Label or control text for verify email failed in email verification.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t confirm your email'**
  String get verifyEmailFailed;

  /// Label or control text for invite by email in email group invitations.
  ///
  /// In en, this message translates to:
  /// **'Invite by email'**
  String get inviteByEmail;

  /// Help text for invite by email help in email group invitations.
  ///
  /// In en, this message translates to:
  /// **'Send someone a link to join'**
  String get inviteByEmailHelp;

  /// Label or control text for invite as in email group invitations.
  ///
  /// In en, this message translates to:
  /// **'Join as'**
  String get inviteAs;

  /// Help text for invite as help in email group invitations.
  ///
  /// In en, this message translates to:
  /// **'They can take over this person\'s expenses'**
  String get inviteAsHelp;

  /// Label or control text for invite as anyone in email group invitations.
  ///
  /// In en, this message translates to:
  /// **'Someone new'**
  String get inviteAsAnyone;

  /// Label or control text for invite send in email group invitations.
  ///
  /// In en, this message translates to:
  /// **'Send invite'**
  String get inviteSend;

  /// Label or control text for invite sent in email group invitations. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Invite sent to {email}.'**
  String inviteSent(String email);

  /// Heading for invite title in email group invitations. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{name} invited you to {group}'**
  String inviteTitle(String name, String group);

  /// Label or control text for invite title anonymous in email group invitations. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'You\'re invited to {group}'**
  String inviteTitleAnonymous(String group);

  /// Explanatory text for invite body in email group invitations. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Create an account with {email} to join, or sign in if you have one.'**
  String inviteBody(String email);

  /// Label or control text for invite body signed in in email group invitations.
  ///
  /// In en, this message translates to:
  /// **'Join to add expenses and see your balance.'**
  String get inviteBodySignedIn;

  /// Action button for invite action in email group invitations.
  ///
  /// In en, this message translates to:
  /// **'Open invitation'**
  String get inviteAction;

  /// Heading for invite missing title in email group invitations.
  ///
  /// In en, this message translates to:
  /// **'This invitation doesn\'t work'**
  String get inviteMissingTitle;

  /// Explanatory text for invite missing body in email group invitations.
  ///
  /// In en, this message translates to:
  /// **'It may have expired or been used. Ask for a new one.'**
  String get inviteMissingBody;

  /// Label or control text for join invited as in joining or claiming a group member.
  ///
  /// In en, this message translates to:
  /// **'You were invited as this person'**
  String get joinInvitedAs;

  /// Label or control text for sign in with in account sign-in. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Continue with {provider}'**
  String signInWith(String provider);

  /// Label or control text for sign in or in account sign-in.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get signInOr;

  /// Heading for oauth failed title in the OAuth sign-in return page.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign you in'**
  String get oauthFailedTitle;

  /// Heading of the page asking what to do when a provider sign-in matches an existing account's unconfirmed email.
  ///
  /// In en, this message translates to:
  /// **'This email already has an account'**
  String get oauthPendingTitle;

  /// Body of the choice page after a provider sign-in matches an unconfirmed account.
  ///
  /// In en, this message translates to:
  /// **'{provider} says {email} is yours, but an account with that email hasn\'t confirmed it. What should happen?'**
  String oauthPendingBody(String provider, String email);

  /// Choice that adds the provider sign-in to the existing account.
  ///
  /// In en, this message translates to:
  /// **'Add to that account'**
  String get oauthPendingLink;

  /// Help text for adding the provider sign-in to the existing account.
  ///
  /// In en, this message translates to:
  /// **'Enter that account\'s password. Its password keeps working.'**
  String get oauthPendingLinkHelp;

  /// Choice that makes the existing account the person's, removing its other ways to sign in.
  ///
  /// In en, this message translates to:
  /// **'Take over that account'**
  String get oauthPendingTakeOver;

  /// Help text for taking over the existing account.
  ///
  /// In en, this message translates to:
  /// **'Its password and other ways to sign in are removed, and anyone signed in to it is signed out.'**
  String get oauthPendingTakeOverHelp;

  /// Choice that creates a new account instead of using the existing one.
  ///
  /// In en, this message translates to:
  /// **'Start a new account'**
  String get oauthPendingNew;

  /// Help text for starting a new account.
  ///
  /// In en, this message translates to:
  /// **'The other account keeps its groups but no longer has {email}.'**
  String oauthPendingNewHelp(String email);

  /// Label of the password field on the choice page.
  ///
  /// In en, this message translates to:
  /// **'Password of that account'**
  String get oauthPendingPassword;

  /// Error shown when the password for adding to the existing account is wrong.
  ///
  /// In en, this message translates to:
  /// **'That password isn\'t right.'**
  String get oauthPendingWrongPassword;

  /// Label or control text for oauth other server in the OAuth sign-in return page.
  ///
  /// In en, this message translates to:
  /// **'This sign-in was started on another server than the one chosen now. Sign in again.'**
  String get oauthOtherServer;

  /// Label or control text for oauth back to sign in in the OAuth sign-in return page.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get oauthBackToSignIn;

  /// Message for error o auth failed in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Signing in didn\'t work. Try again.'**
  String get errorOAuthFailed;

  /// Error shown when a sign-in provider's email belongs to an account and the server doesn't take that provider's word for the email.
  ///
  /// In en, this message translates to:
  /// **'There\'s already an account with this email. Sign in to it, then add this way of signing in from Settings.'**
  String get errorEmailHasAccount;

  /// Error shown when adding a sign-in provider identity that another account already uses.
  ///
  /// In en, this message translates to:
  /// **'This sign-in already belongs to another account.'**
  String get errorIdentityTaken;

  /// Error shown when removing an account's last way to sign in.
  ///
  /// In en, this message translates to:
  /// **'This is your only way to sign in. Set a password or add another way first.'**
  String get errorLastSignInMethod;

  /// Error shown when the server requires a confirmed email before using the app.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email first.'**
  String get errorEmailUnverified;

  /// Message for error o auth cancelled in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Signing in was cancelled.'**
  String get errorOAuthCancelled;

  /// Heading for import title in Settle Up CSV import.
  ///
  /// In en, this message translates to:
  /// **'Import from Settle Up'**
  String get importTitle;

  /// Action button for import action in Settle Up CSV import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// Label or control text for import intro in Settle Up CSV import.
  ///
  /// In en, this message translates to:
  /// **'In Settle Up, export the group as a CSV file, then choose the file here. Expenses, payments and everyone in the group come along, and balances stay the same.'**
  String get importIntro;

  /// Label or control text for import choose file in Settle Up CSV import.
  ///
  /// In en, this message translates to:
  /// **'Choose CSV file'**
  String get importChooseFile;

  /// Label or control text for import choose other in Settle Up CSV import.
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get importChooseOther;

  /// Label or control text for import reading in Settle Up CSV import.
  ///
  /// In en, this message translates to:
  /// **'Reading the file…'**
  String get importReading;

  /// Label or control text for import summary in Settle Up CSV import. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{expenses, plural, =1{1 expense} other{{expenses} expenses}}, {payments, plural, =1{1 payment} other{{payments} payments}}'**
  String importSummary(int expenses, int payments);

  /// Label or control text for import dates in Settle Up CSV import. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{from} to {to}'**
  String importDates(String from, String to);

  /// Label or control text for import currency in Settle Up CSV import. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Currency: {currency}. Entries in other currencies use the amounts Settle Up converted.'**
  String importCurrency(String currency);

  /// Label or control text for import skipped in Settle Up CSV import. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry of zero is left out.} other{{count} entries of zero are left out.}}'**
  String importSkipped(int count);

  /// Label or control text for import who are you in Settle Up CSV import.
  ///
  /// In en, this message translates to:
  /// **'Which one are you?'**
  String get importWhoAreYou;

  /// Label or control text for import untitled in Settle Up CSV import.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get importUntitled;

  /// Message for error import file in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t look like a Settle Up CSV export.'**
  String get errorImportFile;

  /// Message for error import currency in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'The file has no entries without an exchange rate, so the group\'s currency is unclear.'**
  String get errorImportCurrency;

  /// Message for error import too big in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'This file is too big to import.'**
  String get errorImportTooBig;

  /// Message for error bad image in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'That picture can\'t be used. Choose a JPEG, PNG or WebP image.'**
  String get errorBadImage;

  /// Message for error receipt too big in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'That picture is too big. Choose one under 10 MB.'**
  String get errorReceiptTooBig;

  /// Message for error import me in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Choose which person you are.'**
  String get errorImportMe;

  /// Message for error import row in API error feedback. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Line {line} of the file can\'t be imported: {reason}'**
  String errorImportRow(int line, String reason);

  /// Message for error import amount in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'an amount can\'t be read.'**
  String get errorImportAmount;

  /// Message for error import counts in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'the names and amounts don\'t match up.'**
  String get errorImportCounts;

  /// Message for error import date in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'the date can\'t be read.'**
  String get errorImportDate;

  /// Message for error import type in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'the type isn\'t expense, transfer or income.'**
  String get errorImportType;

  /// Message for error import transfer in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'a transfer needs one person paying someone else.'**
  String get errorImportTransfer;

  /// Message for error import row currency in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'it\'s in another currency without an exchange rate.'**
  String get errorImportRowCurrency;

  /// Heading for admin setup title in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Set up this server'**
  String get adminSetupTitle;

  /// Explanatory text for admin setup body in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Choose a password for the administrator. It guards this page, where the server\'s settings live. There is no username: whoever knows the password can change the settings.'**
  String get adminSetupBody;

  /// Label or control text for admin setup code in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Setup code'**
  String get adminSetupCode;

  /// Help text for admin setup code help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'This server already holds data, so it printed a setup code in its log when it started. With Docker: docker compose logs balnana'**
  String get adminSetupCodeHelp;

  /// Action button for admin setup action in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Set password'**
  String get adminSetupAction;

  /// Label or control text for admin password in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Administrator password'**
  String get adminPassword;

  /// Label or control text for admin password repeat in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Repeat the password'**
  String get adminPasswordRepeat;

  /// Label or control text for admin password mismatch in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'The passwords don\'t match.'**
  String get adminPasswordMismatch;

  /// Heading for admin login title in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get adminLoginTitle;

  /// Explanatory text for admin login body in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Enter the administrator password to change this server\'s settings.'**
  String get adminLoginBody;

  /// Action button for admin login action in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get adminLoginAction;

  /// Heading for admin settings title in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Server settings'**
  String get adminSettingsTitle;

  /// Label or control text for admin saved in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Settings saved. They apply right away.'**
  String get adminSaved;

  /// Label or control text for admin save failed in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Nothing was saved. Check the highlighted settings.'**
  String get adminSaveFailed;

  /// Label or control text for admin change password in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Change administrator password'**
  String get adminChangePassword;

  /// Label or control text for admin password current in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get adminPasswordCurrent;

  /// Label or control text for admin password new in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get adminPasswordNew;

  /// Label or control text for admin password changed in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Other administrator sessions are signed out.'**
  String get adminPasswordChanged;

  /// Label or control text for admin sign out in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Sign out of administration'**
  String get adminSignOut;

  /// Label or control text for admin back home in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Back to Balnana'**
  String get adminBackHome;

  /// Label or control text for admin require email in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Require an email address'**
  String get adminRequireEmail;

  /// Help text for admin require email help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'When off, people sign up with a username and may leave the email address out. They sign in with either.'**
  String get adminRequireEmailHelp;

  /// Help text for admin require email unused in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Only applies to email and password sign-in, which is off.'**
  String get adminRequireEmailUnused;

  /// Label or control text for account username in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get accountUsername;

  /// Help text for account username help in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'3 to 32 letters, digits, dots, dashes or underscores. You sign in with it.'**
  String get accountUsernameHelp;

  /// Label or control text for account email optional in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get accountEmailOptional;

  /// Help text for account email optional help in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Lets you get group invitations and reset a forgotten password.'**
  String get accountEmailOptionalHelp;

  /// Label or control text for account login in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get accountLogin;

  /// Message for error invalid username in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Use 3 to 32 letters, digits, dots, dashes or underscores, starting with a letter or digit.'**
  String get errorInvalidUsername;

  /// Message for error username taken in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Someone already has that username.'**
  String get errorUsernameTaken;

  /// Heading for admin discard title in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get adminDiscardTitle;

  /// Explanatory text for admin discard body in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Your changes to the settings haven\'t been saved.'**
  String get adminDiscardBody;

  /// Label or control text for admin discard in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get adminDiscard;

  /// Helper text of a setting an environment variable fixes, so it can't be changed here.
  ///
  /// In en, this message translates to:
  /// **'Set on the server by {key}'**
  String adminLocked(String key);

  /// Hint showing a setting's value when nothing sets it.
  ///
  /// In en, this message translates to:
  /// **'Default: {value}'**
  String adminDefault(String value);

  /// Label or control text for admin secret saved in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Saved. Type a new one to replace it.'**
  String get adminSecretSaved;

  /// Label or control text for admin secret removed in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Will be removed when you save.'**
  String get adminSecretRemoved;

  /// Label or control text for admin secret remove in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Remove saved value'**
  String get adminSecretRemove;

  /// Label or control text for admin section general in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get adminSectionGeneral;

  /// Label or control text for admin section access in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get adminSectionAccess;

  /// Heading of the section of map settings in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get adminSectionMaps;

  /// Label or control text for admin section accounts in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get adminSectionAccounts;

  /// Explanatory text for admin section accounts body in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'These apply when access is set to accounts.'**
  String get adminSectionAccountsBody;

  /// Label or control text for admin section email in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Email (SMTP)'**
  String get adminSectionEmail;

  /// Explanatory text for admin section email body in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Address verification, password resets and invitations.'**
  String get adminSectionEmailBody;

  /// Label or control text for admin smtp on in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get adminSmtpOn;

  /// Label or control text for admin section google in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get adminSectionGoogle;

  /// Explanatory text for admin section google body in the server administrator interface. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Register {url} as the redirect URI in the Google Cloud console.'**
  String adminSectionGoogleBody(String url);

  /// Label or control text for admin google on in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Offer Google sign-in'**
  String get adminGoogleOn;

  /// Help text for admin google on help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'People sign in with their Google account.'**
  String get adminGoogleOnHelp;

  /// Label or control text for admin section oidc in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Sign in with OpenID Connect'**
  String get adminSectionOidc;

  /// Explanatory text for admin section oidc body in the server administrator interface. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Register {url} as the redirect URI with the provider.'**
  String adminSectionOidcBody(String url);

  /// Help text above the list of OpenID Connect providers in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Any OpenID Connect provider, such as Authentik, Keycloak or Dex. Add as many as you like.'**
  String get adminOidcHelp;

  /// Button adding an OpenID Connect provider in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Add provider'**
  String get adminOidcAdd;

  /// Tooltip of the button removing an OpenID Connect provider.
  ///
  /// In en, this message translates to:
  /// **'Remove provider'**
  String get adminOidcRemove;

  /// Title of an OpenID Connect provider card before it has a name.
  ///
  /// In en, this message translates to:
  /// **'New provider'**
  String get adminOidcNew;

  /// Label of an OpenID Connect provider's ID field.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get adminOidcId;

  /// Help text of an OpenID Connect provider's ID field.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letters, digits and dashes. It\'s part of the redirect URI and can\'t change later.'**
  String get adminOidcIdHelp;

  /// Error for an invalid OpenID Connect provider ID.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase letters, digits and dashes, starting with a letter or digit, up to 32.'**
  String get adminOidcIdInvalid;

  /// Error for a duplicate OpenID Connect provider ID.
  ///
  /// In en, this message translates to:
  /// **'Another provider has this ID.'**
  String get adminOidcIdTaken;

  /// Label of the switch that lets a sign-in provider's verified email find or take over an account.
  ///
  /// In en, this message translates to:
  /// **'Trust its email'**
  String get adminTrustEmail;

  /// Help text of the Google trust email switch.
  ///
  /// In en, this message translates to:
  /// **'A Google sign-in with an email that has an account signs in to it. Off: they sign in with their password and add Google in Settings.'**
  String get adminGoogleTrustEmailHelp;

  /// Help text of an OpenID Connect provider's trust email switch.
  ///
  /// In en, this message translates to:
  /// **'Only for a provider you run or trust to check emails. Off: people with an account sign in with their password and add it in Settings.'**
  String get adminOidcTrustEmailHelp;

  /// Label of the switch that keeps accounts out until they confirm their email.
  ///
  /// In en, this message translates to:
  /// **'Require a confirmed email'**
  String get adminRequireVerified;

  /// Help text of the require confirmed email switch.
  ///
  /// In en, this message translates to:
  /// **'Accounts can\'t use the app until they confirm their email, and a trusted sign-in with the same email takes over an unconfirmed account. Off: people choose what happens.'**
  String get adminRequireVerifiedHelp;

  /// Help text of the require confirmed email switch when email sending is off.
  ///
  /// In en, this message translates to:
  /// **'Needs email sending.'**
  String get adminRequireVerifiedUnused;

  /// Label or control text for admin section android in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Android app links'**
  String get adminSectionAndroid;

  /// Explanatory text for admin section android body in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Android builds made for this server open its links in the app. To skip asking, list the SHA-256 fingerprints of the certificates those builds are signed with.'**
  String get adminSectionAndroidBody;

  /// Label or control text for admin section admin in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get adminSectionAdmin;

  /// Label or control text for admin public url in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Public address'**
  String get adminPublicUrl;

  /// Help text for admin public url help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'The address people use to reach this server. Group links and email links are built from it.'**
  String get adminPublicUrlHelp;

  /// Label or control text for admin source url in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Source code link'**
  String get adminSourceUrl;

  /// Help text for admin source url help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Where people can get this server\'s source code, as its license (AGPL-3.0) asks when you run a changed version.'**
  String get adminSourceUrlHelp;

  /// Label or control text for admin auth mode in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get adminAuthMode;

  /// Label or control text for admin auth mode link in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Group links'**
  String get adminAuthModeLink;

  /// Help text for admin auth mode link help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'No sign-in: a group\'s private link is all anyone needs.'**
  String get adminAuthModeLinkHelp;

  /// Label or control text for admin auth mode accounts in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get adminAuthModeAccounts;

  /// Help text for admin auth mode accounts help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'People sign in, and a link only lets signed-in people join a group.'**
  String get adminAuthModeAccountsHelp;

  /// Label or control text for admin password login in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Email and password sign-in'**
  String get adminPasswordLogin;

  /// Help text for admin password forced in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Stays on until Google or OpenID Connect sign-in is on, so there is always a way to sign in.'**
  String get adminPasswordForced;

  /// Label or control text for admin signup in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Who may create an account'**
  String get adminSignup;

  /// Label or control text for admin signup open in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Anyone'**
  String get adminSignupOpen;

  /// Help text for admin signup open help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Anyone who can reach this server may sign up.'**
  String get adminSignupOpenHelp;

  /// Label or control text for admin signup invite in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Invited people'**
  String get adminSignupInvite;

  /// Help text for admin signup invite help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Only people invited to a group by email may sign up, and only with the address the invitation went to. Group links alone don\'t let anyone in. Invitations need email to be on.'**
  String get adminSignupInviteHelp;

  /// Label or control text for admin signup closed in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Nobody'**
  String get adminSignupClosed;

  /// Help text for admin signup closed help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'No one may sign up. Existing accounts keep working.'**
  String get adminSignupClosedHelp;

  /// Help text for admin signup help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'The first account can always be created.'**
  String get adminSignupHelp;

  /// Label or control text for admin link groups in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Groups may be opened by link'**
  String get adminLinkGroups;

  /// Help text for admin link groups help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Group owners may let anyone with the link in, without signing in.'**
  String get adminLinkGroupsHelp;

  /// Label or control text for admin smtp host in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Mail server'**
  String get adminSmtpHost;

  /// Label or control text for admin smtp port in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get adminSmtpPort;

  /// Label or control text for admin smtp user in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get adminSmtpUser;

  /// Label or control text for admin smtp password in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminSmtpPassword;

  /// Label or control text for admin smtp from in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get adminSmtpFrom;

  /// Input hint for admin smtp from hint in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Balnana <balnana@example.com>'**
  String get adminSmtpFromHint;

  /// Label or control text for admin client id in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get adminClientId;

  /// Label or control text for admin client secret in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Client secret'**
  String get adminClientSecret;

  /// Label or control text for admin oidc issuer in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Issuer URL'**
  String get adminOidcIssuer;

  /// Label or control text for admin oidc name in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Button name'**
  String get adminOidcName;

  /// Help text for admin oidc name help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Shown as \"Continue with …\" on the sign-in page.'**
  String get adminOidcNameHelp;

  /// Label or control text for admin fingerprints in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Certificate fingerprints'**
  String get adminFingerprints;

  /// Help text for admin fingerprints help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'SHA-256, separated by commas. keytool -list -v and apksigner verify --print-certs show them.'**
  String get adminFingerprintsHelp;

  /// Label or control text for admin invalid value in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'This value isn\'t valid.'**
  String get adminInvalidValue;

  /// Label or control text for admin invalid url in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Enter a full address starting with https:// or http://.'**
  String get adminInvalidUrl;

  /// Label or control text for admin invalid from in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Enter a sender such as Balnana <balnana@example.com>; email needs one.'**
  String get adminInvalidFrom;

  /// Label or control text for admin invalid port in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Enter a port number from 1 to 65535.'**
  String get adminInvalidPort;

  /// Label or control text for admin invalid required in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'This sign-in provider needs it.'**
  String get adminInvalidRequired;

  /// Label or control text for admin invalid fingerprint in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Enter SHA-256 fingerprints: 64 hexadecimal digits each, colons allowed.'**
  String get adminInvalidFingerprint;

  /// Label or control text for admin needs sign in in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Accounts need a way to sign in: turn on email and password, or set up a provider.'**
  String get adminNeedsSignIn;

  /// Label or control text for admin locked change in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'This is set on the server and can\'t be changed here.'**
  String get adminLockedChange;

  /// Message for error admin required in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'Your administrator session has ended. Sign in again.'**
  String get errorAdminRequired;

  /// Message for error admin wrong password in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'That password isn\'t right.'**
  String get errorAdminWrongPassword;

  /// Message for error invalid setup code in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'That setup code isn\'t right. Look for it in the server\'s log.'**
  String get errorInvalidSetupCode;

  /// Message for error already set up in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'This server has been set up already. Sign in with its administrator password.'**
  String get errorAlreadySetUp;

  /// Label or control text for link opening in opening an app or group link.
  ///
  /// In en, this message translates to:
  /// **'Opening link…'**
  String get linkOpening;

  /// Heading for link foreign title in opening an app or group link.
  ///
  /// In en, this message translates to:
  /// **'This link is for another server'**
  String get linkForeignTitle;

  /// Explanatory text for link foreign body in opening an app or group link. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'This app is connected to {server}, and the link belongs to a different server. Change the server in Settings to open it.'**
  String linkForeignBody(String server);

  /// Heading for link invalid title in opening an app or group link.
  ///
  /// In en, this message translates to:
  /// **'This link can\'t be opened'**
  String get linkInvalidTitle;

  /// Explanatory text for link invalid body in opening an app or group link.
  ///
  /// In en, this message translates to:
  /// **'It isn\'t a Balnana link this app knows.'**
  String get linkInvalidBody;

  /// Label or control text for link go home in opening an app or group link.
  ///
  /// In en, this message translates to:
  /// **'Go to groups'**
  String get linkGoHome;

  /// Button on the page for a link the app cannot open, which opens it in a browser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get linkOpenInBrowser;

  /// Heading for privacy title in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyTitle;

  /// Label or control text for privacy intro in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'Balnana is open-source software. Whoever runs the server this app is connected to (its operator) decides where your data is kept and is responsible for it. This page describes what the software itself stores and does.'**
  String get privacyIntro;

  /// Heading for privacy stored title in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'What is stored'**
  String get privacyStoredTitle;

  /// Explanatory text for privacy stored body in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'The groups you create or join: their names, the members\' names, expenses, payments, notes, any receipt photos and the places you add to expenses. With an account, also your name, your email address or username, a hash of your password (never the password itself) and which sign-in provider you use, such as Google. If notifications are on, an identifier for your device and the address its push service gave it.'**
  String get privacyStoredBody;

  /// Heading for privacy use title in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'How it is used'**
  String get privacyUseTitle;

  /// Explanatory text for privacy use body in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'Only to run the app: to show each group to its members, work out balances, and send the emails and notifications the app needs, such as address verification, password resets and invitations. The app has no ads and no analytics, and nothing is sold.'**
  String get privacyUseBody;

  /// Heading for privacy shared title in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'Who can see it'**
  String get privacySharedTitle;

  /// Explanatory text for privacy shared body in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'Everyone in a group sees its members, expenses and history. When a group is open by link, anyone with the link can open it. Sign-in with Google goes through Google, and notifications, when the operator turns them on, go through the push service your phone uses: Google\'s Firebase Cloud Messaging, or another UnifiedPush service you installed, such as ntfy. The notification\'s content is encrypted on the way. Maps load their pictures from the map provider the operator chose, OpenFreeMap unless they changed it, which sees your network address and which area you look at. Your own location is read only when you tap \"Use current location\", and only the point you then keep is saved.'**
  String get privacySharedBody;

  /// Heading for privacy device title in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get privacyDeviceTitle;

  /// Explanatory text for privacy device body in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'The app keeps the server\'s address, your settings and a copy of your groups for when you\'re offline. Uninstalling the app removes them.'**
  String get privacyDeviceBody;

  /// Heading for privacy delete title in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'Deleting your data'**
  String get privacyDeleteTitle;

  /// Explanatory text for privacy delete body in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'You can delete your account in Settings. Your name then stays in your groups as a member nobody has claimed, so their balances still add up, and groups nobody else can reach are deleted with it. A group\'s owner can delete the whole group in its settings. For anything else, contact the server\'s operator.'**
  String get privacyDeleteBody;

  /// Label or control text for privacy operator policy in the built-in privacy notice.
  ///
  /// In en, this message translates to:
  /// **'The operator\'s privacy policy'**
  String get privacyOperatorPolicy;

  /// Short link to the privacy policy, under the sign-in form.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyLink;

  /// Label or control text for account email add in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Add email address'**
  String get accountEmailAdd;

  /// Label or control text for account email change in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Change email address'**
  String get accountEmailChange;

  /// Label or control text for account email new in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get accountEmailNew;

  /// Label or control text for account email verify note in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get a link to confirm the new address. Your current address stays until then.'**
  String get accountEmailVerifyNote;

  /// Heading for account email pending title in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new email'**
  String get accountEmailPendingTitle;

  /// Help text for account email pending help in account profile and credentials. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{email} takes your current address\'s place once you open the link sent to it. Tap to send it again.'**
  String accountEmailPendingHelp(String email);

  /// Label or control text for account email remove note in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Leave it empty to remove your address. You keep signing in with your username.'**
  String get accountEmailRemoveNote;

  /// Label or control text for account email saved in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Email address saved'**
  String get accountEmailSaved;

  /// Label or control text for account email removed in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Email address removed'**
  String get accountEmailRemoved;

  /// Label or control text for account confirm password in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get accountConfirmPassword;

  /// Help text for account confirm password help in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'To confirm it\'s you.'**
  String get accountConfirmPasswordHelp;

  /// Message for error email needed in API error feedback.
  ///
  /// In en, this message translates to:
  /// **'You sign in with your email address, so it can\'t be removed.'**
  String get errorEmailNeeded;

  /// Label or control text for account delete in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDelete;

  /// Help text for account delete help in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Remove your account from this server'**
  String get accountDeleteHelp;

  /// Heading for account delete title in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get accountDeleteTitle;

  /// Explanatory text for account delete body in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Your account is deleted for good, and you\'re signed out. In your groups your name stays as a member nobody has claimed, so balances still add up. Groups nobody else is in are deleted.'**
  String get accountDeleteBody;

  /// Action button for account delete action in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Delete for good'**
  String get accountDeleteAction;

  /// Label or control text for account deleted in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeleted;

  /// Label or control text for account delete page signed out in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'Sign in to delete your account on this server.'**
  String get accountDeletePageSignedOut;

  /// Label or control text for account delete page link mode in account profile and credentials.
  ///
  /// In en, this message translates to:
  /// **'This server has no accounts: a group\'s link is all anyone needs. To delete a group with everything in it, open the group\'s settings and choose Delete group.'**
  String get accountDeletePageLinkMode;

  /// Label or control text for group delete in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get groupDelete;

  /// Help text for group delete help in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Delete it with all its expenses, for everyone'**
  String get groupDeleteHelp;

  /// Heading for group delete title in group creation, settings, or switching. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String groupDeleteTitle(String name);

  /// Explanatory text for group delete body in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'The group and all its expenses, payments and history are deleted for everyone. This can\'t be undone. Type the group\'s name to confirm.'**
  String get groupDeleteBody;

  /// Label or control text for group delete name in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupDeleteName;

  /// Action button for group delete action in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Delete for good'**
  String get groupDeleteAction;

  /// Label or control text for group deleted in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Group deleted'**
  String get groupDeleted;

  /// Label or control text for group delete owner only in group creation, settings, or switching.
  ///
  /// In en, this message translates to:
  /// **'Only the group\'s owner can delete it.'**
  String get groupDeleteOwnerOnly;

  /// Heading for expense discard title in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get expenseDiscardTitle;

  /// Explanatory text for expense discard body in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Your changes to this expense haven\'t been saved.'**
  String get expenseDiscardBody;

  /// Label or control text for expense discard in the expense editor or expense list.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get expenseDiscard;

  /// Label or control text for admin privacy url in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy link'**
  String get adminPrivacyUrl;

  /// Help text for admin privacy url help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Your privacy policy, which app stores ask for. When empty, the app shows a general one about what Balnana stores.'**
  String get adminPrivacyUrlHelp;

  /// Label or control text for admin map tiles in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Map tiles'**
  String get adminMapTiles;

  /// Label of the choice of where maps come from in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Map source'**
  String get adminMapSource;

  /// Choice: maps drawn from a MapLibre vector style, such as OpenFreeMap's.
  ///
  /// In en, this message translates to:
  /// **'Vector style'**
  String get adminMapSourceStyle;

  /// Help for the vector style map source in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Maps drawn from a MapLibre style, such as OpenFreeMap\'s, which is free and needs no key.'**
  String get adminMapSourceStyleHelp;

  /// Choice: maps shown from raster tile images.
  ///
  /// In en, this message translates to:
  /// **'Raster tiles'**
  String get adminMapSourceTiles;

  /// Help for the raster tiles map source in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Maps shown from tile pictures, such as OpenStreetMap\'s.'**
  String get adminMapSourceTilesHelp;

  /// Choice: no maps.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get adminMapSourceOff;

  /// Help for turning maps off in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'No maps. Expenses still keep place names and points.'**
  String get adminMapSourceOffHelp;

  /// Label of the MapLibre style URL setting in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Style URL'**
  String get adminMapStyle;

  /// Help for the MapLibre style URL setting in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'The address of a MapLibre style.json, like OpenFreeMap\'s Liberty (the default), Bright or Positron.'**
  String get adminMapStyleHelp;

  /// Help text for admin map tiles help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'A raster tile URL template with z, x and y in braces, like the default one. OpenStreetMap\'s own servers are only for light use; a busy server should use a tile provider.'**
  String get adminMapTilesHelp;

  /// Label or control text for admin map attribution in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Map credit'**
  String get adminMapAttribution;

  /// Help text for admin map attribution help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Shown on every map, as the map provider asks. When empty, a style shows the credits it names, and tiles credit OpenStreetMap.'**
  String get adminMapAttributionHelp;

  /// Label or control text for admin invalid map tiles in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Enter an http(s) URL template with z, x and y in braces.'**
  String get adminInvalidMapTiles;

  /// Label or control text for admin users in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get adminUsers;

  /// Label or control text for admin users search in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email or username'**
  String get adminUsersSearch;

  /// Label or control text for admin users shown in the server administrator interface. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total} accounts'**
  String adminUsersShown(int shown, int total);

  /// Label or control text for admin users count in the server administrator interface. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account} other{{count} accounts}}'**
  String adminUsersCount(int count);

  /// Label or control text for admin users empty in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'No accounts match.'**
  String get adminUsersEmpty;

  /// Label or control text for admin user groups in the server administrator interface. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No groups} =1{1 group} other{{count} groups}}'**
  String adminUserGroups(int count);

  /// Label or control text for admin user unverified in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'not verified'**
  String get adminUserUnverified;

  /// Heading for admin user delete title in the server administrator interface. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}\'s account?'**
  String adminUserDeleteTitle(String name);

  /// Explanatory text for admin user delete body in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'The account is deleted for good and signed out everywhere. Its name stays in its groups as a member nobody has claimed; groups nobody else is in are deleted.'**
  String get adminUserDeleteBody;

  /// Label or control text for admin user deleted in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get adminUserDeleted;

  /// Label or control text for common done in shared buttons and controls.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// Label or control text for crowd search in searchable and condensed member lists.
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get crowdSearch;

  /// Label or control text for crowd no match in searchable and condensed member lists.
  ///
  /// In en, this message translates to:
  /// **'No one matches.'**
  String get crowdNoMatch;

  /// Label or control text for crowd all in searchable and condensed member lists.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get crowdAll;

  /// Label or control text for crowd none in searchable and condensed member lists.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get crowdNone;

  /// Label or control text for crowd chosen in searchable and condensed member lists. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} chosen'**
  String crowdChosen(int count, int total);

  /// Label or control text for crowd show more in searchable and condensed member lists. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more} other{{count} more}}'**
  String crowdShowMore(int count);

  /// Label or control text for crowd show fewer in searchable and condensed member lists.
  ///
  /// In en, this message translates to:
  /// **'Show fewer'**
  String get crowdShowFewer;

  /// Label or control text for crowd sort in searchable and condensed member lists.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get crowdSort;

  /// Label or control text for crowd show all in searchable and condensed member lists. Placeholders are supplied by the app; amounts and dates are already formatted for the active locale.
  ///
  /// In en, this message translates to:
  /// **'Show all {count}'**
  String crowdShowAll(int count);

  /// Label or control text for crowd balances in searchable and condensed member lists.
  ///
  /// In en, this message translates to:
  /// **'Everyone\'s balance'**
  String get crowdBalances;

  /// Label or control text for crowd someone else in searchable and condensed member lists.
  ///
  /// In en, this message translates to:
  /// **'Someone else'**
  String get crowdSomeoneElse;

  /// Label or control text for crowd choose payers in searchable and condensed member lists.
  ///
  /// In en, this message translates to:
  /// **'Choose payers'**
  String get crowdChoosePayers;

  /// Heading for crowd filter title in searchable and condensed member lists.
  ///
  /// In en, this message translates to:
  /// **'Whose expenses?'**
  String get crowdFilterTitle;

  /// Settings section for backing up link-mode access links on the selected server.
  ///
  /// In en, this message translates to:
  /// **'My group links'**
  String get myGroupsTitle;

  /// Action showing all saved group links for the current server.
  ///
  /// In en, this message translates to:
  /// **'Export my groups'**
  String get myGroupsExport;

  /// Supporting text for the link-mode group-link export action.
  ///
  /// In en, this message translates to:
  /// **'Copy your group links to keep a backup or move to another device.'**
  String get myGroupsExportHelp;

  /// Explains that exported link-mode URLs grant access to the group.
  ///
  /// In en, this message translates to:
  /// **'Keep these links private. Anyone with a link can open its group.'**
  String get myGroupsPrivate;

  /// Button copying the displayed group-link backup to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy links'**
  String get myGroupsCopy;

  /// Title and action for importing saved access links, distinct from importing a Settle Up CSV.
  ///
  /// In en, this message translates to:
  /// **'Import groups'**
  String get myGroupsImport;

  /// Instructions for importing a link-mode group catalog. Foreign-server links are rejected together.
  ///
  /// In en, this message translates to:
  /// **'Paste group links from this server, one per line. Existing groups keep their place and identity.'**
  String get myGroupsImportHelp;

  /// Multiline field for group URLs or bare tokens from the selected server.
  ///
  /// In en, this message translates to:
  /// **'Group links'**
  String get myGroupsLinks;

  /// Button validating all pasted links before saving any of them.
  ///
  /// In en, this message translates to:
  /// **'Import links'**
  String get myGroupsImportAction;

  /// Error for an empty or malformed group-link list; import is atomic.
  ///
  /// In en, this message translates to:
  /// **'Enter valid group links, one per line. Nothing was imported.'**
  String get myGroupsInvalid;

  /// Error when server selection changes while the import dialog is open; prevents capability disclosure.
  ///
  /// In en, this message translates to:
  /// **'The selected server changed. Close this dialog and import the links on their own server.'**
  String get myGroupsServerChanged;

  /// Error when importing links would exceed the per-server catalog limit.
  ///
  /// In en, this message translates to:
  /// **'Keep at most {count} group links per server. Nothing was imported.'**
  String myGroupsLimit(int count);

  /// Success message counting only newly saved links; repeated and existing links are ignored.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{These groups are already saved.} =1{Imported 1 new group link.} other{Imported {count} new group links.}}'**
  String myGroupsImported(int count);

  /// Section heading in the expense editor for making an expense repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatSection;

  /// Choice in the expense editor: the expense is added once.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t repeat'**
  String get repeatNever;

  /// Choice in the expense editor: the expense repeats every day or every few days.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// Choice in the expense editor: the expense repeats every week or every few weeks.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// Choice in the expense editor: the expense repeats every month or every few months.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// Choice in the expense editor: the expense repeats every year or every few years.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get repeatYearly;

  /// Label before the number field that sets how many days, weeks, months or years apart a recurring expense comes back.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get repeatEvery;

  /// Unit after the repeat number field.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day} other{days}}'**
  String repeatUnitDay(int count);

  /// Unit after the repeat number field.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{week} other{weeks}}'**
  String repeatUnitWeek(int count);

  /// Unit after the repeat number field.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{month} other{months}}'**
  String repeatUnitMonth(int count);

  /// Unit after the repeat number field.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{year} other{years}}'**
  String repeatUnitYear(int count);

  /// How often a recurring expense comes back.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String repeatIntervalDay(int count);

  /// How often a recurring expense comes back.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week} other{Every {count} weeks}}'**
  String repeatIntervalWeek(int count);

  /// How often a recurring expense comes back.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every month} other{Every {count} months}}'**
  String repeatIntervalMonth(int count);

  /// How often a recurring expense comes back.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every year} other{Every {count} years}}'**
  String repeatIntervalYear(int count);

  /// Button in the expense editor: the recurring expense repeats until stopped. Tapping it picks an end date.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get repeatEndNone;

  /// Button in the expense editor showing the last day a recurring expense may be added.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String repeatEndOn(String date);

  /// Tooltip of the button that makes a recurring expense repeat until stopped.
  ///
  /// In en, this message translates to:
  /// **'Remove the end date'**
  String get repeatEndClear;

  /// Help text under the repeat settings in the expense editor.
  ///
  /// In en, this message translates to:
  /// **'Added to the group automatically on each date, starting from the date above. Dates already past are added when you save.'**
  String get repeatHelp;

  /// Title of the dialog shown when the user makes an expense repeat after picking a receipt photo for it.
  ///
  /// In en, this message translates to:
  /// **'Remove the receipt?'**
  String get repeatDropReceiptTitle;

  /// Body of the dialog shown when the user makes an expense repeat after picking a receipt photo for it.
  ///
  /// In en, this message translates to:
  /// **'A repeating expense can\'t keep a receipt. You can add one to each expense it adds instead.'**
  String get repeatDropReceiptBody;

  /// Button that removes the picked receipt and makes the expense repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatDropReceiptAction;

  /// Title of the page listing a group's recurring expenses, and of its entry in group settings.
  ///
  /// In en, this message translates to:
  /// **'Recurring expenses'**
  String get recurringTitle;

  /// Subtitle of the recurring expenses entry in group settings.
  ///
  /// In en, this message translates to:
  /// **'Expenses that add themselves on a schedule'**
  String get recurringHelp;

  /// Empty state title on the recurring expenses page.
  ///
  /// In en, this message translates to:
  /// **'No recurring expenses'**
  String get recurringEmptyTitle;

  /// Empty state body on the recurring expenses page.
  ///
  /// In en, this message translates to:
  /// **'Rent, subscriptions and other costs that come back can be added for you on every date.'**
  String get recurringEmptyBody;

  /// Button that opens the expense editor set to repeat.
  ///
  /// In en, this message translates to:
  /// **'Add recurring expense'**
  String get recurringAdd;

  /// Title of the expense editor when it changes a recurring expense.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring expense'**
  String get recurringEdit;

  /// When a recurring expense is added next.
  ///
  /// In en, this message translates to:
  /// **'Next on {date}'**
  String recurringNext(String date);

  /// Status of a recurring expense that is not being added for now.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get recurringPaused;

  /// Status of a recurring expense past its end date.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get recurringEnded;

  /// Menu action that stops a recurring expense from being added for now.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get recurringPause;

  /// Menu action that lets a paused recurring expense be added again; dates missed while paused are skipped.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get recurringResume;

  /// Label of the switch that pauses or resumes a recurring expense.
  ///
  /// In en, this message translates to:
  /// **'Repeating'**
  String get recurringActive;

  /// Menu action and button that deletes a recurring expense.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get recurringDelete;

  /// Title of the dialog confirming that a recurring expense is deleted.
  ///
  /// In en, this message translates to:
  /// **'Stop repeating?'**
  String get recurringDeleteTitle;

  /// Body of the dialog confirming that a recurring expense is deleted.
  ///
  /// In en, this message translates to:
  /// **'“{title}” won\'t be added again. Expenses it already added stay.'**
  String recurringDeleteBody(String title);

  /// Snackbar after a recurring expense is deleted.
  ///
  /// In en, this message translates to:
  /// **'Recurring expense deleted'**
  String get recurringDeleted;

  /// Shown in the editor of an expense that a recurring expense added.
  ///
  /// In en, this message translates to:
  /// **'Added by a recurring expense'**
  String get recurringFromSchedule;

  /// Subtitle of the tile that opens the recurring expense that added this expense.
  ///
  /// In en, this message translates to:
  /// **'Change the schedule'**
  String get recurringOpen;

  /// Shown when the recurring expense being edited cannot be found.
  ///
  /// In en, this message translates to:
  /// **'The recurring expense was deleted or is no longer available.'**
  String get recurringMissing;

  /// Error when a recurring expense would add too many past occurrences.
  ///
  /// In en, this message translates to:
  /// **'That start date is too long ago: more than 100 expenses would be added at once.'**
  String get errorTooManyDue;

  /// Error for an invalid end date of a recurring expense.
  ///
  /// In en, this message translates to:
  /// **'The end date cannot be before the start date.'**
  String get errorInvalidEnd;

  /// Error for an invalid repeat interval.
  ///
  /// In en, this message translates to:
  /// **'Repeat every 1 to 999 days, weeks, months or years.'**
  String get errorInvalidRepeat;

  /// Error when a recurring expense was changed by someone else.
  ///
  /// In en, this message translates to:
  /// **'Someone else changed this recurring expense while you were editing it. Reload to see their changes.'**
  String get errorRecurringConflict;

  /// Activity entry.
  ///
  /// In en, this message translates to:
  /// **'{who} set “{title}” to repeat'**
  String activityRecurringCreated(String who, String title);

  /// Activity entry.
  ///
  /// In en, this message translates to:
  /// **'{who} changed the recurring expense “{title}”'**
  String activityRecurringUpdated(String who, String title);

  /// Activity entry.
  ///
  /// In en, this message translates to:
  /// **'{who} paused the recurring expense “{title}”'**
  String activityRecurringPaused(String who, String title);

  /// Activity entry when the server paused a recurring expense.
  ///
  /// In en, this message translates to:
  /// **'The recurring expense “{title}” was paused because someone in it left the group'**
  String activityRecurringPausedMemberLeft(String title);

  /// Activity entry when the server paused a recurring expense for another reason.
  ///
  /// In en, this message translates to:
  /// **'The recurring expense “{title}” was paused because it could not be added'**
  String activityRecurringPausedFailed(String title);

  /// Activity entry.
  ///
  /// In en, this message translates to:
  /// **'{who} resumed the recurring expense “{title}”'**
  String activityRecurringResumed(String who, String title);

  /// Activity entry.
  ///
  /// In en, this message translates to:
  /// **'{who} stopped the recurring expense “{title}”'**
  String activityRecurringDeleted(String who, String title);

  /// Activity entry for an expense a recurring expense added.
  ///
  /// In en, this message translates to:
  /// **'“{title}” ({amount}) was added automatically'**
  String activityRecurringAdded(String title, String amount);

  /// Accessibility label of the icon on expenses that a recurring expense added.
  ///
  /// In en, this message translates to:
  /// **'Added by a recurring expense'**
  String get expenseRecurring;

  /// Label or control text for admin plans in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get adminPlans;

  /// Label or control text for admin payments in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get adminPayments;

  /// Label or control text for admin section billing in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Plans and payments'**
  String get adminSectionBilling;

  /// Label or control text for admin section billing body in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Plans raise the limits on what this server keeps. Splitting expenses and settling up stay free.'**
  String get adminSectionBillingBody;

  /// Label or control text for admin billing on in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Plans and limits'**
  String get adminBillingOn;

  /// Label or control text for admin billing on help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'When off, this server limits nothing and shows no plans.'**
  String get adminBillingOnHelp;

  /// Label or control text for admin billing needs accounts in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Plans need accounts: set Access to Accounts first.'**
  String get adminBillingNeedsAccounts;

  /// Label or control text for admin kofi url in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Ko-fi page'**
  String get adminKofiUrl;

  /// Label or control text for admin kofi url help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Where people go to pay. Only builds that allow outside payments link to it.'**
  String get adminKofiUrlHelp;

  /// Label or control text for admin kofi webhook in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Webhook URL to enter on Ko-fi: {url}'**
  String adminKofiWebhook(String url);

  /// Label or control text for admin kofi token in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Ko-fi verification token'**
  String get adminKofiToken;

  /// Label or control text for admin kofi token help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Shown on Ko-fi\'s webhook page. Without it, this server ignores Ko-fi.'**
  String get adminKofiTokenHelp;

  /// Label or control text for admin user plan until in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'{plan} until {date}'**
  String adminUserPlanUntil(String plan, String date);

  /// Label or control text for admin plans help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'A new limit applies to what people add next. What they already have stays. Leave a limit empty for no limit.'**
  String get adminPlansHelp;

  /// Label or control text for admin plan add in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Add plan'**
  String get adminPlanAdd;

  /// Label or control text for admin plan default name in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'{name} (default)'**
  String adminPlanDefaultName(String name);

  /// Label or control text for admin plan limit in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String adminPlanLimit(String label, String value);

  /// Label or control text for admin plan days in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Days: {count}'**
  String adminPlanDays(int count);

  /// Label or control text for admin products section in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get adminProductsSection;

  /// Label or control text for admin products help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'A payment goes to the product with its tier name, or else to the one without a tier name that its amount reaches.'**
  String get adminProductsHelp;

  /// Label or control text for admin product add in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get adminProductAdd;

  /// Label or control text for admin product edit in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get adminProductEdit;

  /// Label or control text for admin product any payment in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Any payment of at least {amount}'**
  String adminProductAnyPayment(String amount);

  /// Label or control text for admin product name in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Tier name'**
  String get adminProductName;

  /// Label or control text for admin product name help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'As written on Ko-fi. Leave empty to match any one-off or monthly payment by its amount.'**
  String get adminProductNameHelp;

  /// Label or control text for admin product plan in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get adminProductPlan;

  /// Label or control text for admin product days in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get adminProductDays;

  /// Label or control text for admin product days help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'How long one payment lasts. Paying again adds to what is left.'**
  String get adminProductDaysHelp;

  /// Label or control text for admin product min amount in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount'**
  String get adminProductMinAmount;

  /// Label or control text for admin product currency in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Currency code'**
  String get adminProductCurrency;

  /// Label or control text for admin plan id in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get adminPlanId;

  /// Label or control text for admin plan id help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Lowercase letters, digits and hyphens. It can\'t be changed later.'**
  String get adminPlanIdHelp;

  /// Label or control text for admin plan name in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminPlanName;

  /// Label or control text for admin plan rank in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get adminPlanRank;

  /// Label or control text for admin plan rank help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'An account with several plans gets the one with the highest rank.'**
  String get adminPlanRankHelp;

  /// Label or control text for admin plan default in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Default plan'**
  String get adminPlanDefault;

  /// Label or control text for admin plan default help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'For every account without another plan.'**
  String get adminPlanDefaultHelp;

  /// Label or control text for admin entitlement granted in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Given by an administrator'**
  String get adminEntitlementGranted;

  /// Label or control text for admin entitlement revoked in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get adminEntitlementRevoked;

  /// Label or control text for admin entitlement forever in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get adminEntitlementForever;

  /// Label or control text for admin entitlement until in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String adminEntitlementUntil(String date);

  /// Label or control text for admin entitlement ended in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Ended {date}'**
  String adminEntitlementEnded(String date);

  /// Label or control text for admin entitlements empty in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'This account has no plans yet.'**
  String get adminEntitlementsEmpty;

  /// Label or control text for admin entitlement revoke in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get adminEntitlementRevoke;

  /// Label or control text for admin entitlement note in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get adminEntitlementNote;

  /// Label or control text for admin entitlement grant in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Give plan'**
  String get adminEntitlementGrant;

  /// Label or control text for admin payment applied in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get adminPaymentApplied;

  /// Label or control text for admin payment unclaimed in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Unclaimed'**
  String get adminPaymentUnclaimed;

  /// Label or control text for admin payment unmatched in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Unmatched'**
  String get adminPaymentUnmatched;

  /// Label or control text for admin payments all in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminPaymentsAll;

  /// Label or control text for admin payments count in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment} other{{count} payments}}'**
  String adminPaymentsCount(int count);

  /// Label or control text for admin payments empty in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'No payments here.'**
  String get adminPaymentsEmpty;

  /// Label or control text for admin payment assigned in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Plan given to the account.'**
  String get adminPaymentAssigned;

  /// Label or control text for admin payment assign in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Give to an account'**
  String get adminPaymentAssign;

  /// Label or control text for admin payment pick user in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Choose an account.'**
  String get adminPaymentPickUser;

  /// Label or control text for error billing off in an error message.
  ///
  /// In en, this message translates to:
  /// **'This server has no plans.'**
  String get errorBillingOff;

  /// Label or control text for error already sponsored in an error message.
  ///
  /// In en, this message translates to:
  /// **'Another member\'s plan already covers this group.'**
  String get errorAlreadySponsored;

  /// Label or control text for error plan in use in an error message.
  ///
  /// In en, this message translates to:
  /// **'Accounts or products still use this plan.'**
  String get errorPlanInUse;

  /// Label or control text for error payment applied in an error message.
  ///
  /// In en, this message translates to:
  /// **'This payment has already been applied.'**
  String get errorPaymentApplied;

  /// Label or control text for error invalid plan in an error message.
  ///
  /// In en, this message translates to:
  /// **'Check the plan settings: something in them isn\'t valid.'**
  String get errorInvalidPlan;

  /// Label or control text for error limit receipts in an error message.
  ///
  /// In en, this message translates to:
  /// **'This group has reached its limit of {max} receipt photos.'**
  String errorLimitReceipts(int max);

  /// Label or control text for error limit recurring in an error message.
  ///
  /// In en, this message translates to:
  /// **'This group has reached its limit of {max} recurring expenses.'**
  String errorLimitRecurring(int max);

  /// Label or control text for error limit own groups in an error message.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your limit of {max} groups.'**
  String errorLimitOwnGroups(int max);

  /// Label or control text for error limit sponsored in an error message.
  ///
  /// In en, this message translates to:
  /// **'Your plan can\'t be shared with more than {max} groups.'**
  String errorLimitSponsored(int max);

  /// Label or control text for error limit other in an error message.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached a limit on this server.'**
  String get errorLimitOther;

  /// Label or control text for plan title in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planTitle;

  /// Label or control text for plan unlimited in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get planUnlimited;

  /// Label or control text for plan until in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String planUntil(String date);

  /// Label or control text for plan settings help in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'What this server keeps for you'**
  String get planSettingsHelp;

  /// Label or control text for plan intro in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Splitting and settling up are always free. A plan only changes how much this server keeps for you.'**
  String get planIntro;

  /// Label or control text for plan usage in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit}'**
  String planUsage(int used, int limit);

  /// Label or control text for plan used in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'{used} used'**
  String planUsed(int used);

  /// Label or control text for plan limits in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Limits'**
  String get planLimits;

  /// Label or control text for plan limit receipts in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Receipt photos per group'**
  String get planLimitReceipts;

  /// Label or control text for plan limit recurring in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Recurring expenses per group'**
  String get planLimitRecurring;

  /// Label or control text for plan limit own groups in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Groups you created'**
  String get planLimitOwnGroups;

  /// Label or control text for plan limit sponsored in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Groups sharing your plan'**
  String get planLimitSponsored;

  /// Label or control text for plan get in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Get a plan'**
  String get planGet;

  /// Label or control text for plan kofi in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Ko-fi'**
  String get planKofi;

  /// Label or control text for plan kofi help in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Pay with your account\'s confirmed email, or add the address you pay with below.'**
  String get planKofiHelp;

  /// Label or control text for plan payment email confirmed in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Payments from this address count for your account'**
  String get planPaymentEmailConfirmed;

  /// Label or control text for plan payment email add in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Add a payment email'**
  String get planPaymentEmailAdd;

  /// Label or control text for plan payment email help in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a link to confirm it\'s yours.'**
  String get planPaymentEmailHelp;

  /// Label or control text for payment email done in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Address confirmed'**
  String get paymentEmailDone;

  /// Label or control text for payment email done body in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Payments from this address now count for your account.'**
  String get paymentEmailDoneBody;

  /// Label or control text for group plan usage in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Receipt photos: {receipts} · Recurring: {recurring}'**
  String groupPlanUsage(String receipts, String recurring);

  /// Label or control text for group sponsor in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Share my plan with this group'**
  String get groupSponsor;

  /// Label or control text for group unsponsor in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Stop sharing my plan'**
  String get groupUnsponsor;

  /// Label or control text for group sponsored by in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Uses {name}\'s plan'**
  String groupSponsoredBy(String name);

  /// Label or control text for account delete play note in the account screens.
  ///
  /// In en, this message translates to:
  /// **'A Google Play subscription doesn\'t end with your account. Cancel it on Google Play first.'**
  String get accountDeletePlayNote;

  /// Label or control text for plan play manage in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get planPlayManage;

  /// Label or control text for plan play manage help in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Change or cancel it on Google Play'**
  String get planPlayManageHelp;

  /// Label or control text for plan play price in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'{price} every {months, plural, =1{month} other{{months} months}}'**
  String planPlayPrice(int months, String price);

  /// Label or control text for plan play failed in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Google Play couldn\'t complete the purchase.'**
  String get planPlayFailed;

  /// Label or control text for plan play pending in the plan screens.
  ///
  /// In en, this message translates to:
  /// **'Your payment is still being processed. The plan starts once it goes through.'**
  String get planPlayPending;

  /// Label or control text for error invalid purchase in an error message.
  ///
  /// In en, this message translates to:
  /// **'Google Play doesn\'t recognize this purchase.'**
  String get errorInvalidPurchase;

  /// Label or control text for error play other account in an error message.
  ///
  /// In en, this message translates to:
  /// **'This subscription belongs to another account. Sign in to that one, or cancel it on Google Play.'**
  String get errorPlayOtherAccount;

  /// Label or control text for error play unavailable in an error message.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach Google Play. Try again in a moment.'**
  String get errorPlayUnavailable;

  /// Label or control text for admin play package in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Google Play package name'**
  String get adminPlayPackage;

  /// Label or control text for admin play package help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'The app\'s ID on Google Play. With the service account below, it turns on Google Play subscriptions.'**
  String get adminPlayPackageHelp;

  /// Label or control text for admin play service account in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Google Play service account'**
  String get adminPlayServiceAccount;

  /// Label or control text for admin play service account help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'The JSON key of a service account that can view and manage orders and subscriptions in Play Console.'**
  String get adminPlayServiceAccountHelp;

  /// Label or control text for admin play push account in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Pub/Sub push account'**
  String get adminPlayPushAccount;

  /// Label or control text for admin play push account help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'The service account email Pub/Sub signs its deliveries with. Without one, renewals arrive only when someone opens the plan page.'**
  String get adminPlayPushAccountHelp;

  /// Label or control text for admin play webhook in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Pub/Sub push endpoint, and its audience too: {url}'**
  String adminPlayWebhook(String url);

  /// Label or control text for admin product provider in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Paid through'**
  String get adminProductProvider;

  /// Label or control text for admin product play id in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'Product ID'**
  String get adminProductPlayId;

  /// Label or control text for admin product play id help in the server administrator interface.
  ///
  /// In en, this message translates to:
  /// **'As written in Play Console. Google Play says when each payment ends, so there are no days to set.'**
  String get adminProductPlayIdHelp;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'nl',
    'pl',
    'pt',
    'ru',
    'th',
    'tr',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
