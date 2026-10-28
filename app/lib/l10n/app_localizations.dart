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

  /// No description provided for @offlineBar.
  ///
  /// In en, this message translates to:
  /// **'Offline. Showing what this device saved; changes wait until you reconnect.'**
  String get offlineBar;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @iconChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose an icon'**
  String get iconChoose;

  /// No description provided for @iconNone.
  ///
  /// In en, this message translates to:
  /// **'No icon'**
  String get iconNone;

  /// No description provided for @iconSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search, or type any emoji'**
  String get iconSearchHint;

  /// No description provided for @iconUseTyped.
  ///
  /// In en, this message translates to:
  /// **'Use this emoji'**
  String get iconUseTyped;

  /// No description provided for @iconNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No icons match. Type an emoji to use it.'**
  String get iconNoMatch;

  /// No description provided for @iconSectionTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel & places'**
  String get iconSectionTravel;

  /// No description provided for @iconSectionFood.
  ///
  /// In en, this message translates to:
  /// **'Food & drink'**
  String get iconSectionFood;

  /// No description provided for @iconSectionActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get iconSectionActivities;

  /// No description provided for @iconSectionHome.
  ///
  /// In en, this message translates to:
  /// **'Home & bills'**
  String get iconSectionHome;

  /// No description provided for @iconSectionPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get iconSectionPeople;

  /// No description provided for @iconSectionNature.
  ///
  /// In en, this message translates to:
  /// **'Animals & nature'**
  String get iconSectionNature;

  /// No description provided for @iconSectionObjects.
  ///
  /// In en, this message translates to:
  /// **'Money & things'**
  String get iconSectionObjects;

  /// No description provided for @iconSectionSymbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols'**
  String get iconSectionSymbols;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// Stands in for a person whose name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get someone;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'This no longer exists.'**
  String get errorNotFound;

  /// No description provided for @errorRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get errorRequired;

  /// No description provided for @errorInvalidName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name of up to 100 characters.'**
  String get errorInvalidName;

  /// No description provided for @errorDuplicateName.
  ///
  /// In en, this message translates to:
  /// **'Someone in this group already has that name.'**
  String get errorDuplicateName;

  /// No description provided for @errorTooManyMembers.
  ///
  /// In en, this message translates to:
  /// **'This group has as many people as it can hold.'**
  String get errorTooManyMembers;

  /// No description provided for @errorTooManyCategories.
  ///
  /// In en, this message translates to:
  /// **'This group has as many categories as it can hold.'**
  String get errorTooManyCategories;

  /// No description provided for @errorDuplicateCategory.
  ///
  /// In en, this message translates to:
  /// **'This group already has a category with that name.'**
  String get errorDuplicateCategory;

  /// No description provided for @errorInvalidCurrency.
  ///
  /// In en, this message translates to:
  /// **'Enter a three-letter currency code, such as USD.'**
  String get errorInvalidCurrency;

  /// No description provided for @errorInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title of up to 200 characters.'**
  String get errorInvalidTitle;

  /// No description provided for @errorInvalidLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter a place name of one line, up to 200 characters.'**
  String get errorInvalidLocation;

  /// No description provided for @errorInvalidSymbol.
  ///
  /// In en, this message translates to:
  /// **'Enter a symbol of up to 8 characters.'**
  String get errorInvalidSymbol;

  /// No description provided for @errorInvalidEmoji.
  ///
  /// In en, this message translates to:
  /// **'Pick a single emoji as the icon.'**
  String get errorInvalidEmoji;

  /// No description provided for @errorMemberHasBalance.
  ///
  /// In en, this message translates to:
  /// **'Settle this person\'s balance before removing them.'**
  String get errorMemberHasBalance;

  /// No description provided for @errorVersionConflict.
  ///
  /// In en, this message translates to:
  /// **'Someone else changed this expense while you were editing it. Reload to see their changes.'**
  String get errorVersionConflict;

  /// No description provided for @errorSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to do this.'**
  String get errorSignInRequired;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a minute and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorNotAMember.
  ///
  /// In en, this message translates to:
  /// **'You\'re not in this group yet.'**
  String get errorNotAMember;

  /// No description provided for @errorNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only that person or the group\'s owner can do this.'**
  String get errorNotAllowed;

  /// No description provided for @errorLinkGroupsOff.
  ///
  /// In en, this message translates to:
  /// **'This server doesn\'t allow opening groups by link alone.'**
  String get errorLinkGroupsOff;

  /// No description provided for @errorMemberClaimed.
  ///
  /// In en, this message translates to:
  /// **'Someone has already joined as that person.'**
  String get errorMemberClaimed;

  /// No description provided for @errorMemberLeft.
  ///
  /// In en, this message translates to:
  /// **'Someone in this has left the group.'**
  String get errorMemberLeft;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter an email address.'**
  String get errorInvalidEmail;

  /// No description provided for @errorInvalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Use 8 to 200 characters.'**
  String get errorInvalidPassword;

  /// No description provided for @errorEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'There\'s already an account with that email. Sign in instead.'**
  String get errorEmailTaken;

  /// No description provided for @errorSignupClosed.
  ///
  /// In en, this message translates to:
  /// **'This server isn\'t taking new accounts.'**
  String get errorSignupClosed;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'That email and password don\'t match.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Your current password isn\'t right.'**
  String get errorWrongPassword;

  /// No description provided for @errorAccountsOff.
  ///
  /// In en, this message translates to:
  /// **'This server doesn\'t use accounts.'**
  String get errorAccountsOff;

  /// No description provided for @errorInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get errorInvalidAmount;

  /// No description provided for @errorTooManyDecimals.
  ///
  /// In en, this message translates to:
  /// **'Too many decimal places for this currency.'**
  String get errorTooManyDecimals;

  /// No description provided for @errorAmountTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That amount is too large.'**
  String get errorAmountTooLarge;

  /// No description provided for @errorNoShares.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one person to share the cost.'**
  String get errorNoShares;

  /// No description provided for @errorInvalidShare.
  ///
  /// In en, this message translates to:
  /// **'Each share must be a number.'**
  String get errorInvalidShare;

  /// No description provided for @errorExactTotal.
  ///
  /// In en, this message translates to:
  /// **'The amounts must add up to the total.'**
  String get errorExactTotal;

  /// No description provided for @errorPercentTotal.
  ///
  /// In en, this message translates to:
  /// **'The percentages must add up to 100%.'**
  String get errorPercentTotal;

  /// No description provided for @errorPayersTotal.
  ///
  /// In en, this message translates to:
  /// **'What everyone paid must add up to the total.'**
  String get errorPayersTotal;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food & drink'**
  String get categoryFood;

  /// No description provided for @categoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryLodging.
  ///
  /// In en, this message translates to:
  /// **'Lodging'**
  String get categoryLodging;

  /// No description provided for @categoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get categoryRent;

  /// No description provided for @categoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get categoryUtilities;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get categoryGifts;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @groupNew.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get groupNew;

  /// Tooltip on the group name at the top of a group page, which lists the groups.
  ///
  /// In en, this message translates to:
  /// **'Switch group'**
  String get groupSwitch;

  /// No description provided for @groupReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get groupReorder;

  /// No description provided for @groupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get groupCreate;

  /// No description provided for @groupMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String groupMemberCount(int count);

  /// No description provided for @pillOwed.
  ///
  /// In en, this message translates to:
  /// **'You\'re owed {amount}'**
  String pillOwed(String amount);

  /// No description provided for @pillOwe.
  ///
  /// In en, this message translates to:
  /// **'You owe {amount}'**
  String pillOwe(String amount);

  /// No description provided for @pillSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled up'**
  String get pillSettled;

  /// No description provided for @groupMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Group not found'**
  String get groupMissingTitle;

  /// No description provided for @groupMissingBody.
  ///
  /// In en, this message translates to:
  /// **'This group was deleted, or its link was reset. Ask someone in the group for the new link.'**
  String get groupMissingBody;

  /// No description provided for @groupForget.
  ///
  /// In en, this message translates to:
  /// **'Remove from this device'**
  String get groupForget;

  /// No description provided for @groupLinkOtherServer.
  ///
  /// In en, this message translates to:
  /// **'This link belongs to another server. Connect to that server to open it.'**
  String get groupLinkOtherServer;

  /// No description provided for @openLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Open a group link'**
  String get openLinkTitle;

  /// No description provided for @openLinkBody.
  ///
  /// In en, this message translates to:
  /// **'Paste a link someone shared with you to join their group.'**
  String get openLinkBody;

  /// No description provided for @openLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Group link'**
  String get openLinkLabel;

  /// No description provided for @openLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openLinkAction;

  /// No description provided for @openLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a Balnana group link.'**
  String get openLinkInvalid;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Trip to Lisbon'**
  String get groupNameHint;

  /// No description provided for @groupCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get groupCurrency;

  /// No description provided for @groupCurrencyHelp.
  ///
  /// In en, this message translates to:
  /// **'All expenses in this group use this currency. It can\'t be changed later.'**
  String get groupCurrencyHelp;

  /// No description provided for @groupCurrencyHelpNamed.
  ///
  /// In en, this message translates to:
  /// **'{name}. All expenses in this group use this currency. It can\'t be changed later.'**
  String groupCurrencyHelpNamed(String name);

  /// No description provided for @currencyChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a currency'**
  String get currencyChoose;

  /// No description provided for @currencySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by code or name'**
  String get currencySearchHint;

  /// No description provided for @currencySuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get currencySuggested;

  /// No description provided for @currencyAll.
  ///
  /// In en, this message translates to:
  /// **'All currencies'**
  String get currencyAll;

  /// No description provided for @currencyUseTyped.
  ///
  /// In en, this message translates to:
  /// **'Use {code}'**
  String currencyUseTyped(String code);

  /// No description provided for @currencyNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No currency matches. Type its three-letter code to use it.'**
  String get currencyNoMatch;

  /// No description provided for @groupSymbol.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get groupSymbol;

  /// No description provided for @groupSymbolChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a symbol'**
  String get groupSymbolChoose;

  /// No description provided for @groupSymbolExample.
  ///
  /// In en, this message translates to:
  /// **'Amounts look like {example}'**
  String groupSymbolExample(String example);

  /// No description provided for @groupColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get groupColor;

  /// No description provided for @colorSwatch.
  ///
  /// In en, this message translates to:
  /// **'Color {number} of {count}'**
  String colorSwatch(int number, int count);

  /// No description provided for @groupPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get groupPeople;

  /// No description provided for @groupYourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get groupYourName;

  /// No description provided for @groupPersonName.
  ///
  /// In en, this message translates to:
  /// **'Person {number}'**
  String groupPersonName(int number);

  /// No description provided for @groupAddPerson.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get groupAddPerson;

  /// No description provided for @groupPeopleHelp.
  ///
  /// In en, this message translates to:
  /// **'You can add more people later, or they can join with the link.'**
  String get groupPeopleHelp;

  /// No description provided for @identityTitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get identityTitle;

  /// No description provided for @identityBody.
  ///
  /// In en, this message translates to:
  /// **'Pick your name so Balnana can show what you owe. Only this device remembers it.'**
  String get identityBody;

  /// No description provided for @identityNew.
  ///
  /// In en, this message translates to:
  /// **'I\'m someone new'**
  String get identityNew;

  /// No description provided for @identityNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Join this group'**
  String get identityNewTitle;

  /// No description provided for @identityJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get identityJoin;

  /// No description provided for @identityChange.
  ///
  /// In en, this message translates to:
  /// **'Who you are'**
  String get identityChange;

  /// No description provided for @identityNone.
  ///
  /// In en, this message translates to:
  /// **'Not chosen yet'**
  String get identityNone;

  /// No description provided for @memberName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get memberName;

  /// No description provided for @memberYou.
  ///
  /// In en, this message translates to:
  /// **'{name} (you)'**
  String memberYou(String name);

  /// No description provided for @memberAdd.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get memberAdd;

  /// No description provided for @memberAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add someone'**
  String get memberAddTitle;

  /// No description provided for @memberRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get memberRename;

  /// No description provided for @memberRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get memberRenameTitle;

  /// No description provided for @memberRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String memberRemoveTitle(String name);

  /// No description provided for @memberRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'They\'ll stay on past expenses but can\'t be added to new ones.'**
  String get memberRemoveBody;

  /// No description provided for @groupLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied. Anyone with it can open this group.'**
  String get groupLinkCopied;

  /// No description provided for @groupShare.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get groupShare;

  /// No description provided for @groupSettings.
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get groupSettings;

  /// No description provided for @groupEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get groupEdit;

  /// No description provided for @groupSharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get groupSharing;

  /// No description provided for @groupCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get groupCopyLink;

  /// No description provided for @groupCopyLinkHelp.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the link can see and edit this group.'**
  String get groupCopyLinkHelp;

  /// No description provided for @groupCopyLinkHelpAccounts.
  ///
  /// In en, this message translates to:
  /// **'People with the link can ask to join after signing in.'**
  String get groupCopyLinkHelpAccounts;

  /// No description provided for @linkAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Open to anyone with the link'**
  String get linkAccessTitle;

  /// No description provided for @linkAccessHelp.
  ///
  /// In en, this message translates to:
  /// **'Let people see and edit without an account'**
  String get linkAccessHelp;

  /// No description provided for @resetLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset link'**
  String get resetLinkTitle;

  /// No description provided for @resetLinkHelp.
  ///
  /// In en, this message translates to:
  /// **'Make a new link; the old one stops working'**
  String get resetLinkHelp;

  /// No description provided for @resetLinkBody.
  ///
  /// In en, this message translates to:
  /// **'The current link will stop working, for everyone. Share the new link with people who should keep access.'**
  String get resetLinkBody;

  /// No description provided for @resetLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetLinkAction;

  /// No description provided for @resetLinkDone.
  ///
  /// In en, this message translates to:
  /// **'Link reset. Share the new one.'**
  String get resetLinkDone;

  /// No description provided for @groupThisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get groupThisDevice;

  /// No description provided for @groupData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get groupData;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @categoriesHelp.
  ///
  /// In en, this message translates to:
  /// **'Add your own, or hide the ones you don\'t use'**
  String get categoriesHelp;

  /// No description provided for @categoriesOwn.
  ///
  /// In en, this message translates to:
  /// **'This group\'s'**
  String get categoriesOwn;

  /// No description provided for @categoriesOwnEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories of the group\'s own yet.'**
  String get categoriesOwnEmpty;

  /// No description provided for @categoriesBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get categoriesBuiltIn;

  /// No description provided for @categoriesBuiltInHelp.
  ///
  /// In en, this message translates to:
  /// **'Hidden categories are not offered for new expenses. Expenses that have one keep it.'**
  String get categoriesBuiltInHelp;

  /// No description provided for @categoryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoryAdd;

  /// No description provided for @categoryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryEdit;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryName;

  /// No description provided for @categoryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get categoryDelete;

  /// No description provided for @categoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String categoryDeleteTitle(String name);

  /// No description provided for @categoryDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Expenses in this category will have none.'**
  String get categoryDeleteBody;

  /// No description provided for @categoryDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get categoryDeleteAction;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportCsv;

  /// No description provided for @exportCsvHelp.
  ///
  /// In en, this message translates to:
  /// **'Every expense and payment, for a spreadsheet'**
  String get exportCsvHelp;

  /// No description provided for @exportCsvDone.
  ///
  /// In en, this message translates to:
  /// **'Exported'**
  String get exportCsvDone;

  /// No description provided for @forgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from this device'**
  String get forgetTitle;

  /// No description provided for @forgetHelp.
  ///
  /// In en, this message translates to:
  /// **'The group stays on the server for everyone else'**
  String get forgetHelp;

  /// No description provided for @forgetBody.
  ///
  /// In en, this message translates to:
  /// **'You can open it again with the link.'**
  String get forgetBody;

  /// No description provided for @groupYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get groupYou;

  /// No description provided for @leaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get leaveTitle;

  /// No description provided for @leaveHelp.
  ///
  /// In en, this message translates to:
  /// **'Your expenses stay; you can join again with the link'**
  String get leaveHelp;

  /// No description provided for @leaveBody.
  ///
  /// In en, this message translates to:
  /// **'The group disappears from your list. Your expenses and balance stay in the group.'**
  String get leaveBody;

  /// No description provided for @leaveAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveAction;

  /// No description provided for @tabExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get tabExpenses;

  /// No description provided for @heroWhoTitle.
  ///
  /// In en, this message translates to:
  /// **'Who are you in this group?'**
  String get heroWhoTitle;

  /// No description provided for @heroWhoBody.
  ///
  /// In en, this message translates to:
  /// **'Pick your name to see what you owe and are owed.'**
  String get heroWhoBody;

  /// No description provided for @heroWhoAction.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get heroWhoAction;

  /// No description provided for @heroJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re viewing this group'**
  String get heroJoinTitle;

  /// No description provided for @heroJoinBody.
  ///
  /// In en, this message translates to:
  /// **'Join to add expenses and see what you owe.'**
  String get heroJoinBody;

  /// No description provided for @joinAction.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinAction;

  /// No description provided for @heroOwed.
  ///
  /// In en, this message translates to:
  /// **'You\'re owed'**
  String get heroOwed;

  /// No description provided for @heroOwe.
  ///
  /// In en, this message translates to:
  /// **'You owe'**
  String get heroOwe;

  /// No description provided for @heroSettled.
  ///
  /// In en, this message translates to:
  /// **'You\'re settled up'**
  String get heroSettled;

  /// No description provided for @heroYouAre.
  ///
  /// In en, this message translates to:
  /// **'You are {name}'**
  String heroYouAre(String name);

  /// No description provided for @expenseAdd.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expenseAdd;

  /// No description provided for @expensesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get expensesEmptyTitle;

  /// No description provided for @expensesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the first one, and Balnana will work out who owes whom.'**
  String get expensesEmptyBody;

  /// No description provided for @expensesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search titles, notes and places'**
  String get expensesSearchHint;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClear;

  /// No description provided for @expensesNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get expensesNoMatchTitle;

  /// No description provided for @expensesNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try other words, or fewer filters.'**
  String get expensesNoMatchBody;

  /// Filter chip: expenses of every member, not just one.
  ///
  /// In en, this message translates to:
  /// **'Anyone'**
  String get filterAnyone;

  /// No description provided for @filterAnyCategory.
  ///
  /// In en, this message translates to:
  /// **'Any category'**
  String get filterAnyCategory;

  /// Filter choice: only payments between members, not expenses.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get filterPayments;

  /// No description provided for @filterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get filterClear;

  /// No description provided for @periodAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAll;

  /// No description provided for @periodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get periodThisMonth;

  /// No description provided for @periodLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get periodLastMonth;

  /// No description provided for @periodThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get periodThisYear;

  /// No description provided for @periodPickDays.
  ///
  /// In en, this message translates to:
  /// **'Pick dates…'**
  String get periodPickDays;

  /// Title of the page with charts of what a group spent.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get statsTitle;

  /// No description provided for @statsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get statsTotal;

  /// No description provided for @statsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense} other{{count} expenses}}'**
  String statsCount(int count);

  /// No description provided for @statsByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get statsByCategory;

  /// Chart heading: what each person paid, next to their share of the costs.
  ///
  /// In en, this message translates to:
  /// **'Paid and share per person'**
  String get statsByMember;

  /// No description provided for @statsPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statsPaid;

  /// No description provided for @statsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get statsShare;

  /// No description provided for @statsByMonth.
  ///
  /// In en, this message translates to:
  /// **'By month'**
  String get statsByMonth;

  /// No description provided for @statsNoCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get statsNoCategory;

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing spent'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'There are no expenses in this period.'**
  String get statsEmptyBody;

  /// No description provided for @statsShowExpenses.
  ///
  /// In en, this message translates to:
  /// **'Show these expenses'**
  String get statsShowExpenses;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'{from} paid {to}'**
  String paymentTitle(String from, String to);

  /// No description provided for @expensePaidBy.
  ///
  /// In en, this message translates to:
  /// **'{name} paid {amount}'**
  String expensePaidBy(String name, String amount);

  /// No description provided for @expensePaidByMany.
  ///
  /// In en, this message translates to:
  /// **'{count} people paid {amount}'**
  String expensePaidByMany(int count, String amount);

  /// No description provided for @expenseReceivedBy.
  ///
  /// In en, this message translates to:
  /// **'{name} received {amount}'**
  String expenseReceivedBy(String name, String amount);

  /// No description provided for @expenseReceivedByMany.
  ///
  /// In en, this message translates to:
  /// **'{count} people received {amount}'**
  String expenseReceivedByMany(int count, String amount);

  /// No description provided for @transactionRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get transactionRefund;

  /// No description provided for @transactionIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionIncome;

  /// No description provided for @effectYouPaid.
  ///
  /// In en, this message translates to:
  /// **'you paid {amount}'**
  String effectYouPaid(String amount);

  /// No description provided for @effectYouReceived.
  ///
  /// In en, this message translates to:
  /// **'you received {amount}'**
  String effectYouReceived(String amount);

  /// No description provided for @effectYouLent.
  ///
  /// In en, this message translates to:
  /// **'you lent {amount}'**
  String effectYouLent(String amount);

  /// No description provided for @effectYouBorrowed.
  ///
  /// In en, this message translates to:
  /// **'you borrowed {amount}'**
  String effectYouBorrowed(String amount);

  /// No description provided for @effectForYou.
  ///
  /// In en, this message translates to:
  /// **'{amount} for you'**
  String effectForYou(String amount);

  /// No description provided for @effectEven.
  ///
  /// In en, this message translates to:
  /// **'even'**
  String get effectEven;

  /// No description provided for @effectNotInvolved.
  ///
  /// In en, this message translates to:
  /// **'not involved'**
  String get effectNotInvolved;

  /// No description provided for @paymentDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete payment'**
  String get paymentDelete;

  /// No description provided for @paymentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Payment deleted'**
  String get paymentDeleted;

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted “{title}”'**
  String expenseDeleted(String title);

  /// No description provided for @expenseNew.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get expenseNew;

  /// No description provided for @expenseEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get expenseEdit;

  /// No description provided for @expenseDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get expenseDelete;

  /// No description provided for @expenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmount;

  /// No description provided for @expenseTitle.
  ///
  /// In en, this message translates to:
  /// **'What was it for?'**
  String get expenseTitle;

  /// No description provided for @expenseTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Dinner, tickets, taxi…'**
  String get expenseTitleHint;

  /// No description provided for @expenseNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get expenseNote;

  /// No description provided for @expenseNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get expenseNoteHint;

  /// No description provided for @expenseLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get expenseLocation;

  /// No description provided for @expenseLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Where was it? (optional)'**
  String get expenseLocationHint;

  /// No description provided for @locationPickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on map'**
  String get locationPickOnMap;

  /// No description provided for @locationUseCurrent.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get locationUseCurrent;

  /// No description provided for @locationFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding where you are…'**
  String get locationFinding;

  /// No description provided for @locationChange.
  ///
  /// In en, this message translates to:
  /// **'Change on map'**
  String get locationChange;

  /// No description provided for @locationRemovePin.
  ///
  /// In en, this message translates to:
  /// **'Remove pin'**
  String get locationRemovePin;

  /// No description provided for @locationOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in maps'**
  String get locationOpenInMaps;

  /// No description provided for @locationPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a location'**
  String get locationPickTitle;

  /// No description provided for @locationPickHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to drop a pin'**
  String get locationPickHint;

  /// No description provided for @locationPickDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get locationPickDone;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Balnana may not use your location. You can allow it in your device or browser settings.'**
  String get locationDenied;

  /// No description provided for @locationOff.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off on this device.'**
  String get locationOff;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find where you are. Try again, or drop a pin on the map.'**
  String get locationUnavailable;

  /// No description provided for @expenseReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get expenseReceipt;

  /// No description provided for @expenseHasReceipt.
  ///
  /// In en, this message translates to:
  /// **'Has a receipt photo'**
  String get expenseHasReceipt;

  /// No description provided for @expenseHasLocation.
  ///
  /// In en, this message translates to:
  /// **'Has a location'**
  String get expenseHasLocation;

  /// No description provided for @receiptTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get receiptTakePhoto;

  /// No description provided for @receiptChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a picture'**
  String get receiptChoose;

  /// No description provided for @receiptRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get receiptRemove;

  /// No description provided for @receiptView.
  ///
  /// In en, this message translates to:
  /// **'Receipt photo'**
  String get receiptView;

  /// No description provided for @receiptNotSaved.
  ///
  /// In en, this message translates to:
  /// **'The expense was saved, but not its receipt photo. {reason}'**
  String receiptNotSaved(String reason);

  /// No description provided for @expensePaidByLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get expensePaidByLabel;

  /// No description provided for @expenseReceivedForLabel.
  ///
  /// In en, this message translates to:
  /// **'Received for'**
  String get expenseReceivedForLabel;

  /// No description provided for @expenseReceivedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Received by'**
  String get expenseReceivedByLabel;

  /// No description provided for @expenseMultiplePayers.
  ///
  /// In en, this message translates to:
  /// **'Several people'**
  String get expenseMultiplePayers;

  /// No description provided for @expenseSplit.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get expenseSplit;

  /// No description provided for @splitEqual.
  ///
  /// In en, this message translates to:
  /// **'Equally'**
  String get splitEqual;

  /// No description provided for @splitExact.
  ///
  /// In en, this message translates to:
  /// **'Amounts'**
  String get splitExact;

  /// No description provided for @splitPercent.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get splitPercent;

  /// No description provided for @splitShares.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get splitShares;

  /// No description provided for @splitLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left to assign'**
  String splitLeft(String amount);

  /// No description provided for @splitOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} too much'**
  String splitOver(String amount);

  /// No description provided for @splitPercentLeft.
  ///
  /// In en, this message translates to:
  /// **'{percent}% left to assign'**
  String splitPercentLeft(String percent);

  /// No description provided for @splitPercentOver.
  ///
  /// In en, this message translates to:
  /// **'{percent}% too much'**
  String splitPercentOver(String percent);

  /// No description provided for @conflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Changed elsewhere'**
  String get conflictTitle;

  /// No description provided for @conflictReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get conflictReload;

  /// No description provided for @expenseChangedElsewhere.
  ///
  /// In en, this message translates to:
  /// **'Someone else changed this expense. Reloading shows their version and drops your changes here.'**
  String get expenseChangedElsewhere;

  /// No description provided for @suggestedPayments.
  ///
  /// In en, this message translates to:
  /// **'Suggested payments'**
  String get suggestedPayments;

  /// No description provided for @allSettled.
  ///
  /// In en, this message translates to:
  /// **'Everyone is settled up.'**
  String get allSettled;

  /// No description provided for @transferYouPay.
  ///
  /// In en, this message translates to:
  /// **'You pay {name}'**
  String transferYouPay(String name);

  /// No description provided for @transferPaysYou.
  ///
  /// In en, this message translates to:
  /// **'{name} pays you'**
  String transferPaysYou(String name);

  /// No description provided for @transferPays.
  ///
  /// In en, this message translates to:
  /// **'{from} pays {to}'**
  String transferPays(String from, String to);

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordPayment;

  /// No description provided for @recordPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Record a payment'**
  String get recordPaymentTitle;

  /// No description provided for @recordPaymentHelp.
  ///
  /// In en, this message translates to:
  /// **'Only record money that was actually paid, outside Balnana.'**
  String get recordPaymentHelp;

  /// No description provided for @paymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get paymentRecorded;

  /// No description provided for @activityGroupCreated.
  ///
  /// In en, this message translates to:
  /// **'{who} created {group}'**
  String activityGroupCreated(String who, String group);

  /// No description provided for @activityGroupUpdated.
  ///
  /// In en, this message translates to:
  /// **'{who} changed the group details'**
  String activityGroupUpdated(String who);

  /// No description provided for @activityLinkReset.
  ///
  /// In en, this message translates to:
  /// **'{who} reset the group link'**
  String activityLinkReset(String who);

  /// No description provided for @activityMemberAdded.
  ///
  /// In en, this message translates to:
  /// **'{who} added {name}'**
  String activityMemberAdded(String who, String name);

  /// No description provided for @activityMemberRenamed.
  ///
  /// In en, this message translates to:
  /// **'{who} renamed {oldName} to {name}'**
  String activityMemberRenamed(String who, String oldName, String name);

  /// No description provided for @activityMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'{who} removed {name}'**
  String activityMemberRemoved(String who, String name);

  /// No description provided for @activityCategoryAdded.
  ///
  /// In en, this message translates to:
  /// **'{who} added the category {name}'**
  String activityCategoryAdded(String who, String name);

  /// No description provided for @activityCategoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'{who} changed the categories'**
  String activityCategoryUpdated(String who);

  /// No description provided for @activityCategoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'{who} deleted the category {name}'**
  String activityCategoryDeleted(String who, String name);

  /// No description provided for @activityMemberJoined.
  ///
  /// In en, this message translates to:
  /// **'{name} joined'**
  String activityMemberJoined(String name);

  /// No description provided for @activityExpenseAdded.
  ///
  /// In en, this message translates to:
  /// **'{who} added “{title}” ({amount})'**
  String activityExpenseAdded(String who, String title, String amount);

  /// No description provided for @activityExpenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'{who} edited “{title}” ({amount})'**
  String activityExpenseUpdated(String who, String title, String amount);

  /// No description provided for @activityExpenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'{who} deleted “{title}”'**
  String activityExpenseDeleted(String who, String title);

  /// No description provided for @activityExpenseRestored.
  ///
  /// In en, this message translates to:
  /// **'{who} restored “{title}”'**
  String activityExpenseRestored(String who, String title);

  /// No description provided for @activityPaymentAdded.
  ///
  /// In en, this message translates to:
  /// **'{who} recorded that {from} paid {to} {amount}'**
  String activityPaymentAdded(String who, String from, String to, String amount);

  /// No description provided for @activityPaymentDeleted.
  ///
  /// In en, this message translates to:
  /// **'{who} deleted a payment of {amount}'**
  String activityPaymentDeleted(String who, String amount);

  /// No description provided for @activityPaymentRestored.
  ///
  /// In en, this message translates to:
  /// **'{who} restored a payment of {amount}'**
  String activityPaymentRestored(String who, String amount);

  /// No description provided for @activityGroupImported.
  ///
  /// In en, this message translates to:
  /// **'{who} imported {count, plural, =1{1 entry} other{{count} entries}} from {source}'**
  String activityGroupImported(String who, int count, String source);

  /// No description provided for @activityReceiptAdded.
  ///
  /// In en, this message translates to:
  /// **'{who} added a receipt photo to “{title}”'**
  String activityReceiptAdded(String who, String title);

  /// No description provided for @activityReceiptRemoved.
  ///
  /// In en, this message translates to:
  /// **'{who} removed the receipt photo from “{title}”'**
  String activityReceiptRemoved(String who, String title);

  /// No description provided for @activityOther.
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

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @accountRename.
  ///
  /// In en, this message translates to:
  /// **'Change name'**
  String get accountRename;

  /// No description provided for @passwordChange.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get passwordChange;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Other devices are signed out.'**
  String get passwordChanged;

  /// No description provided for @passwordSet.
  ///
  /// In en, this message translates to:
  /// **'Set a password'**
  String get passwordSet;

  /// No description provided for @passwordSetHelp.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email or username and a password too'**
  String get passwordSetHelp;

  /// No description provided for @passwordSetDone.
  ///
  /// In en, this message translates to:
  /// **'Password set. Other devices are signed out.'**
  String get passwordSetDone;

  /// No description provided for @passwordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get passwordCurrent;

  /// No description provided for @passwordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNew;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

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

  /// No description provided for @settingsWallpaperGroups.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper colors in groups'**
  String get settingsWallpaperGroups;

  /// No description provided for @settingsWallpaperGroupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Groups use your device colors too, instead of their own'**
  String get settingsWallpaperGroupsSubtitle;

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

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone adds, changes or deletes an expense you are in'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @pushChannel.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get pushChannel;

  /// No description provided for @pushChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'When someone adds, changes or deletes an expense you are in'**
  String get pushChannelDescription;

  /// No description provided for @pushExpenseAdded.
  ///
  /// In en, this message translates to:
  /// **'{who} added {title} · {amount}'**
  String pushExpenseAdded(String who, String title, String amount);

  /// No description provided for @pushExpenseEdited.
  ///
  /// In en, this message translates to:
  /// **'{who} changed {title} · {amount}'**
  String pushExpenseEdited(String who, String title, String amount);

  /// No description provided for @pushExpenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'{who} deleted {title} · {amount}'**
  String pushExpenseDeleted(String who, String title, String amount);

  /// No description provided for @pushExpenseAddedAnon.
  ///
  /// In en, this message translates to:
  /// **'{title} was added · {amount}'**
  String pushExpenseAddedAnon(String title, String amount);

  /// No description provided for @pushExpenseEditedAnon.
  ///
  /// In en, this message translates to:
  /// **'{title} was changed · {amount}'**
  String pushExpenseEditedAnon(String title, String amount);

  /// No description provided for @pushExpenseDeletedAnon.
  ///
  /// In en, this message translates to:
  /// **'{title} was deleted · {amount}'**
  String pushExpenseDeletedAnon(String title, String amount);

  /// No description provided for @pushPaymentAdded.
  ///
  /// In en, this message translates to:
  /// **'{payer} paid {payee} {amount}'**
  String pushPaymentAdded(String payer, String payee, String amount);

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

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @groupSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to open this group'**
  String get groupSignInTitle;

  /// No description provided for @groupSignInBody.
  ///
  /// In en, this message translates to:
  /// **'This group is only for its members. Sign in to see it or to join.'**
  String get groupSignInBody;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// No description provided for @signInBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your groups.'**
  String get signInBody;

  /// No description provided for @signInNoPassword.
  ///
  /// In en, this message translates to:
  /// **'This server signs people in another way. Ask whoever runs it.'**
  String get signInNoPassword;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerBody.
  ///
  /// In en, this message translates to:
  /// **'Keep your groups on every device.'**
  String get registerBody;

  /// No description provided for @registerAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerAction;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get registerHaveAccount;

  /// No description provided for @signInNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signInNoAccount;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get accountName;

  /// No description provided for @accountNameHelp.
  ///
  /// In en, this message translates to:
  /// **'What people in your groups will see'**
  String get accountNameHelp;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmail;

  /// No description provided for @accountPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPassword;

  /// No description provided for @accountPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get accountPasswordHelp;

  /// No description provided for @passwordShow.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get passwordShow;

  /// No description provided for @passwordHide.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get passwordHide;

  /// No description provided for @joinPickName.
  ///
  /// In en, this message translates to:
  /// **'Pick another name'**
  String get joinPickName;

  /// No description provided for @joinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join {name}'**
  String joinTitle(String name);

  /// No description provided for @joinBody.
  ///
  /// In en, this message translates to:
  /// **'Are you one of these people? Pick yourself to take over their expenses.'**
  String get joinBody;

  /// No description provided for @joinBodyNew.
  ///
  /// In en, this message translates to:
  /// **'Join to add expenses and see your balance.'**
  String get joinBodyNew;

  /// No description provided for @joinAsNew.
  ///
  /// In en, this message translates to:
  /// **'I\'m someone new'**
  String get joinAsNew;

  /// No description provided for @joinAsName.
  ///
  /// In en, this message translates to:
  /// **'Join as {name}'**
  String joinAsName(String name);

  /// No description provided for @joinTaken.
  ///
  /// In en, this message translates to:
  /// **'Already joined: {names}'**
  String joinTaken(String names);

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @errorEmailOff.
  ///
  /// In en, this message translates to:
  /// **'This server doesn\'t send email.'**
  String get errorEmailOff;

  /// No description provided for @errorInvalidToken.
  ///
  /// In en, this message translates to:
  /// **'This link has expired or was already used.'**
  String get errorInvalidToken;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email you a link to choose a new password.'**
  String get forgotPasswordBody;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get forgotPasswordAction;

  /// No description provided for @forgotPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'If there\'s an account for that address, a link is on its way.'**
  String get forgotPasswordSent;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be signed out everywhere, then you can sign in with the new password.'**
  String get resetPasswordBody;

  /// No description provided for @resetPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get resetPasswordAction;

  /// No description provided for @resetPasswordDone.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Sign in with your new password.'**
  String get resetPasswordDone;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailHelp.
  ///
  /// In en, this message translates to:
  /// **'So you can reset your password if you forget it'**
  String get verifyEmailHelp;

  /// No description provided for @verifyEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Check {email} for a link.'**
  String verifyEmailSent(String email);

  /// No description provided for @verifyEmailDone.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed'**
  String get verifyEmailDone;

  /// No description provided for @verifyEmailDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your address is confirmed.'**
  String get verifyEmailDoneBody;

  /// No description provided for @verifyEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t confirm your email'**
  String get verifyEmailFailed;

  /// No description provided for @inviteByEmail.
  ///
  /// In en, this message translates to:
  /// **'Invite by email'**
  String get inviteByEmail;

  /// No description provided for @inviteByEmailHelp.
  ///
  /// In en, this message translates to:
  /// **'Send someone a link to join'**
  String get inviteByEmailHelp;

  /// No description provided for @inviteAs.
  ///
  /// In en, this message translates to:
  /// **'Join as'**
  String get inviteAs;

  /// No description provided for @inviteAsHelp.
  ///
  /// In en, this message translates to:
  /// **'They can take over this person\'s expenses'**
  String get inviteAsHelp;

  /// No description provided for @inviteAsAnyone.
  ///
  /// In en, this message translates to:
  /// **'Someone new'**
  String get inviteAsAnyone;

  /// No description provided for @inviteSend.
  ///
  /// In en, this message translates to:
  /// **'Send invite'**
  String get inviteSend;

  /// No description provided for @inviteSent.
  ///
  /// In en, this message translates to:
  /// **'Invite sent to {email}.'**
  String inviteSent(String email);

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} invited you to {group}'**
  String inviteTitle(String name, String group);

  /// No description provided for @inviteTitleAnonymous.
  ///
  /// In en, this message translates to:
  /// **'You\'re invited to {group}'**
  String inviteTitleAnonymous(String group);

  /// No description provided for @inviteBody.
  ///
  /// In en, this message translates to:
  /// **'Create an account with {email} to join, or sign in if you have one.'**
  String inviteBody(String email);

  /// No description provided for @inviteBodySignedIn.
  ///
  /// In en, this message translates to:
  /// **'Join to add expenses and see your balance.'**
  String get inviteBodySignedIn;

  /// No description provided for @inviteAction.
  ///
  /// In en, this message translates to:
  /// **'Open invitation'**
  String get inviteAction;

  /// No description provided for @inviteMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'This invitation doesn\'t work'**
  String get inviteMissingTitle;

  /// No description provided for @inviteMissingBody.
  ///
  /// In en, this message translates to:
  /// **'It may have expired or been used. Ask for a new one.'**
  String get inviteMissingBody;

  /// No description provided for @joinInvitedAs.
  ///
  /// In en, this message translates to:
  /// **'You were invited as this person'**
  String get joinInvitedAs;

  /// No description provided for @signInWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with {provider}'**
  String signInWith(String provider);

  /// No description provided for @signInOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get signInOr;

  /// No description provided for @oauthFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign you in'**
  String get oauthFailedTitle;

  /// No description provided for @oauthEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'There\'s already an account with this email. Sign in with your password and confirm your email in Settings, then this way of signing in works too.'**
  String get oauthEmailTaken;

  /// No description provided for @oauthOtherServer.
  ///
  /// In en, this message translates to:
  /// **'This sign-in was started on another server than the one chosen now. Sign in again.'**
  String get oauthOtherServer;

  /// No description provided for @oauthBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get oauthBackToSignIn;

  /// No description provided for @errorOAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Signing in didn\'t work. Try again.'**
  String get errorOAuthFailed;

  /// No description provided for @errorOAuthCancelled.
  ///
  /// In en, this message translates to:
  /// **'Signing in was cancelled.'**
  String get errorOAuthCancelled;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from Settle Up'**
  String get importTitle;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// No description provided for @importIntro.
  ///
  /// In en, this message translates to:
  /// **'In Settle Up, export the group as a CSV file, then choose the file here. Expenses, payments and everyone in the group come along, and balances stay the same.'**
  String get importIntro;

  /// No description provided for @importChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose CSV file'**
  String get importChooseFile;

  /// No description provided for @importChooseOther.
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get importChooseOther;

  /// No description provided for @importReading.
  ///
  /// In en, this message translates to:
  /// **'Reading the file…'**
  String get importReading;

  /// No description provided for @importSummary.
  ///
  /// In en, this message translates to:
  /// **'{expenses, plural, =1{1 expense} other{{expenses} expenses}}, {payments, plural, =1{1 payment} other{{payments} payments}}'**
  String importSummary(int expenses, int payments);

  /// No description provided for @importDates.
  ///
  /// In en, this message translates to:
  /// **'{from} to {to}'**
  String importDates(String from, String to);

  /// No description provided for @importCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency: {currency}. Entries in other currencies use the amounts Settle Up converted.'**
  String importCurrency(String currency);

  /// No description provided for @importSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry of zero is left out.} other{{count} entries of zero are left out.}}'**
  String importSkipped(int count);

  /// No description provided for @importWhoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Which one are you?'**
  String get importWhoAreYou;

  /// No description provided for @importUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get importUntitled;

  /// No description provided for @errorImportFile.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t look like a Settle Up CSV export.'**
  String get errorImportFile;

  /// No description provided for @errorImportCurrency.
  ///
  /// In en, this message translates to:
  /// **'The file has no entries without an exchange rate, so the group\'s currency is unclear.'**
  String get errorImportCurrency;

  /// No description provided for @errorImportTooBig.
  ///
  /// In en, this message translates to:
  /// **'This file is too big to import.'**
  String get errorImportTooBig;

  /// No description provided for @errorBadImage.
  ///
  /// In en, this message translates to:
  /// **'That picture can\'t be used. Choose a JPEG, PNG or WebP image.'**
  String get errorBadImage;

  /// No description provided for @errorReceiptTooBig.
  ///
  /// In en, this message translates to:
  /// **'That picture is too big. Choose one under 10 MB.'**
  String get errorReceiptTooBig;

  /// No description provided for @errorImportMe.
  ///
  /// In en, this message translates to:
  /// **'Choose which person you are.'**
  String get errorImportMe;

  /// No description provided for @errorImportRow.
  ///
  /// In en, this message translates to:
  /// **'Line {line} of the file can\'t be imported: {reason}'**
  String errorImportRow(int line, String reason);

  /// No description provided for @errorImportAmount.
  ///
  /// In en, this message translates to:
  /// **'an amount can\'t be read.'**
  String get errorImportAmount;

  /// No description provided for @errorImportCounts.
  ///
  /// In en, this message translates to:
  /// **'the names and amounts don\'t match up.'**
  String get errorImportCounts;

  /// No description provided for @errorImportDate.
  ///
  /// In en, this message translates to:
  /// **'the date can\'t be read.'**
  String get errorImportDate;

  /// No description provided for @errorImportType.
  ///
  /// In en, this message translates to:
  /// **'the type isn\'t expense, transfer or income.'**
  String get errorImportType;

  /// No description provided for @errorImportTransfer.
  ///
  /// In en, this message translates to:
  /// **'a transfer needs one person paying someone else.'**
  String get errorImportTransfer;

  /// No description provided for @errorImportRowCurrency.
  ///
  /// In en, this message translates to:
  /// **'it\'s in another currency without an exchange rate.'**
  String get errorImportRowCurrency;

  /// No description provided for @adminSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up this server'**
  String get adminSetupTitle;

  /// No description provided for @adminSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a password for the administrator. It guards this page, where the server\'s settings live. There is no username: whoever knows the password can change the settings.'**
  String get adminSetupBody;

  /// No description provided for @adminSetupCode.
  ///
  /// In en, this message translates to:
  /// **'Setup code'**
  String get adminSetupCode;

  /// No description provided for @adminSetupCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'This server already holds data, so it printed a setup code in its log when it started. With Docker: docker compose logs balnana'**
  String get adminSetupCodeHelp;

  /// No description provided for @adminSetupAction.
  ///
  /// In en, this message translates to:
  /// **'Set password'**
  String get adminSetupAction;

  /// No description provided for @adminPassword.
  ///
  /// In en, this message translates to:
  /// **'Administrator password'**
  String get adminPassword;

  /// No description provided for @adminPasswordRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat the password'**
  String get adminPasswordRepeat;

  /// No description provided for @adminPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords don\'t match.'**
  String get adminPasswordMismatch;

  /// No description provided for @adminLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get adminLoginTitle;

  /// No description provided for @adminLoginBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the administrator password to change this server\'s settings.'**
  String get adminLoginBody;

  /// No description provided for @adminLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get adminLoginAction;

  /// No description provided for @adminSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Server settings'**
  String get adminSettingsTitle;

  /// No description provided for @adminSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved. They apply right away.'**
  String get adminSaved;

  /// No description provided for @adminSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Nothing was saved. Check the highlighted settings.'**
  String get adminSaveFailed;

  /// No description provided for @adminChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change administrator password'**
  String get adminChangePassword;

  /// No description provided for @adminPasswordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get adminPasswordCurrent;

  /// No description provided for @adminPasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get adminPasswordNew;

  /// No description provided for @adminPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Other administrator sessions are signed out.'**
  String get adminPasswordChanged;

  /// No description provided for @adminSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out of administration'**
  String get adminSignOut;

  /// No description provided for @adminBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Balnana'**
  String get adminBackHome;

  /// No description provided for @adminRequireEmail.
  ///
  /// In en, this message translates to:
  /// **'Require an email address'**
  String get adminRequireEmail;

  /// No description provided for @adminRequireEmailHelp.
  ///
  /// In en, this message translates to:
  /// **'When off, people sign up with a username and may leave the email address out. They sign in with either.'**
  String get adminRequireEmailHelp;

  /// No description provided for @accountUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get accountUsername;

  /// No description provided for @accountUsernameHelp.
  ///
  /// In en, this message translates to:
  /// **'3 to 32 letters, digits, dots, dashes or underscores. You sign in with it.'**
  String get accountUsernameHelp;

  /// No description provided for @accountEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get accountEmailOptional;

  /// No description provided for @accountEmailOptionalHelp.
  ///
  /// In en, this message translates to:
  /// **'Lets you get group invitations and reset a forgotten password.'**
  String get accountEmailOptionalHelp;

  /// No description provided for @accountLogin.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get accountLogin;

  /// No description provided for @errorInvalidUsername.
  ///
  /// In en, this message translates to:
  /// **'Use 3 to 32 letters, digits, dots, dashes or underscores, starting with a letter or digit.'**
  String get errorInvalidUsername;

  /// No description provided for @errorUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Someone already has that username.'**
  String get errorUsernameTaken;

  /// No description provided for @adminDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get adminDiscardTitle;

  /// No description provided for @adminDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes to the settings haven\'t been saved.'**
  String get adminDiscardBody;

  /// No description provided for @adminDiscard.
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

  /// No description provided for @adminSecretSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. Type a new one to replace it.'**
  String get adminSecretSaved;

  /// No description provided for @adminSecretRemoved.
  ///
  /// In en, this message translates to:
  /// **'Will be removed when you save.'**
  String get adminSecretRemoved;

  /// No description provided for @adminSecretRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove saved value'**
  String get adminSecretRemove;

  /// No description provided for @adminSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get adminSectionGeneral;

  /// No description provided for @adminSectionAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get adminSectionAccess;

  /// No description provided for @adminSectionAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get adminSectionAccounts;

  /// No description provided for @adminSectionAccountsBody.
  ///
  /// In en, this message translates to:
  /// **'These apply when access is set to accounts.'**
  String get adminSectionAccountsBody;

  /// No description provided for @adminSectionEmail.
  ///
  /// In en, this message translates to:
  /// **'Email (SMTP)'**
  String get adminSectionEmail;

  /// No description provided for @adminSectionEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Lets the server send email: address verification, password resets and invitations. Leave the mail server empty to turn email off.'**
  String get adminSectionEmailBody;

  /// No description provided for @adminSectionGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get adminSectionGoogle;

  /// No description provided for @adminSectionGoogleBody.
  ///
  /// In en, this message translates to:
  /// **'Register {url} as the redirect URI in the Google Cloud console. Leave the client ID empty to turn it off.'**
  String adminSectionGoogleBody(String url);

  /// No description provided for @adminSectionOidc.
  ///
  /// In en, this message translates to:
  /// **'Sign in with OpenID Connect'**
  String get adminSectionOidc;

  /// No description provided for @adminSectionOidcBody.
  ///
  /// In en, this message translates to:
  /// **'Any OpenID Connect provider, such as Authentik, Keycloak or Dex. Register {url} as the redirect URI. Leave the issuer empty to turn it off.'**
  String adminSectionOidcBody(String url);

  /// No description provided for @adminSectionAndroid.
  ///
  /// In en, this message translates to:
  /// **'Android app links'**
  String get adminSectionAndroid;

  /// No description provided for @adminSectionAndroidBody.
  ///
  /// In en, this message translates to:
  /// **'Android builds made for this server open its links in the app. To skip asking, list the SHA-256 fingerprints of the certificates those builds are signed with.'**
  String get adminSectionAndroidBody;

  /// No description provided for @adminSectionAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get adminSectionAdmin;

  /// No description provided for @adminPublicUrl.
  ///
  /// In en, this message translates to:
  /// **'Public address'**
  String get adminPublicUrl;

  /// No description provided for @adminPublicUrlHelp.
  ///
  /// In en, this message translates to:
  /// **'The address people use to reach this server. Group links and email links are built from it.'**
  String get adminPublicUrlHelp;

  /// No description provided for @adminSourceUrl.
  ///
  /// In en, this message translates to:
  /// **'Source code link'**
  String get adminSourceUrl;

  /// No description provided for @adminSourceUrlHelp.
  ///
  /// In en, this message translates to:
  /// **'Where people can get this server\'s source code, as its license (AGPL-3.0) asks when you run a changed version.'**
  String get adminSourceUrlHelp;

  /// No description provided for @adminAuthMode.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get adminAuthMode;

  /// No description provided for @adminAuthModeLink.
  ///
  /// In en, this message translates to:
  /// **'Group links'**
  String get adminAuthModeLink;

  /// No description provided for @adminAuthModeLinkHelp.
  ///
  /// In en, this message translates to:
  /// **'No sign-in: a group\'s private link is all anyone needs.'**
  String get adminAuthModeLinkHelp;

  /// No description provided for @adminAuthModeAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get adminAuthModeAccounts;

  /// No description provided for @adminAuthModeAccountsHelp.
  ///
  /// In en, this message translates to:
  /// **'People sign in, and a link only lets signed-in people join a group.'**
  String get adminAuthModeAccountsHelp;

  /// No description provided for @adminPasswordLogin.
  ///
  /// In en, this message translates to:
  /// **'Email and password sign-in'**
  String get adminPasswordLogin;

  /// No description provided for @adminSignup.
  ///
  /// In en, this message translates to:
  /// **'Who may create an account'**
  String get adminSignup;

  /// No description provided for @adminSignupOpen.
  ///
  /// In en, this message translates to:
  /// **'Anyone'**
  String get adminSignupOpen;

  /// No description provided for @adminSignupInvite.
  ///
  /// In en, this message translates to:
  /// **'Invited people'**
  String get adminSignupInvite;

  /// No description provided for @adminSignupClosed.
  ///
  /// In en, this message translates to:
  /// **'Nobody'**
  String get adminSignupClosed;

  /// No description provided for @adminSignupHelp.
  ///
  /// In en, this message translates to:
  /// **'The first account can always be created.'**
  String get adminSignupHelp;

  /// No description provided for @adminLinkGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups may be opened by link'**
  String get adminLinkGroups;

  /// No description provided for @adminLinkGroupsHelp.
  ///
  /// In en, this message translates to:
  /// **'Group owners may let anyone with the link in, without signing in.'**
  String get adminLinkGroupsHelp;

  /// No description provided for @adminSmtpHost.
  ///
  /// In en, this message translates to:
  /// **'Mail server'**
  String get adminSmtpHost;

  /// No description provided for @adminSmtpPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get adminSmtpPort;

  /// No description provided for @adminSmtpUser.
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get adminSmtpUser;

  /// No description provided for @adminSmtpPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminSmtpPassword;

  /// No description provided for @adminSmtpFrom.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get adminSmtpFrom;

  /// No description provided for @adminSmtpFromHint.
  ///
  /// In en, this message translates to:
  /// **'Balnana <balnana@example.com>'**
  String get adminSmtpFromHint;

  /// No description provided for @adminClientId.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get adminClientId;

  /// No description provided for @adminClientSecret.
  ///
  /// In en, this message translates to:
  /// **'Client secret'**
  String get adminClientSecret;

  /// No description provided for @adminOidcIssuer.
  ///
  /// In en, this message translates to:
  /// **'Issuer URL'**
  String get adminOidcIssuer;

  /// No description provided for @adminOidcName.
  ///
  /// In en, this message translates to:
  /// **'Button name'**
  String get adminOidcName;

  /// No description provided for @adminOidcNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Shown as \"Continue with …\" on the sign-in page.'**
  String get adminOidcNameHelp;

  /// No description provided for @adminFingerprints.
  ///
  /// In en, this message translates to:
  /// **'Certificate fingerprints'**
  String get adminFingerprints;

  /// No description provided for @adminFingerprintsHelp.
  ///
  /// In en, this message translates to:
  /// **'SHA-256, separated by commas. keytool -list -v and apksigner verify --print-certs show them.'**
  String get adminFingerprintsHelp;

  /// No description provided for @adminInvalidValue.
  ///
  /// In en, this message translates to:
  /// **'This value isn\'t valid.'**
  String get adminInvalidValue;

  /// No description provided for @adminInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a full address starting with https:// or http://.'**
  String get adminInvalidUrl;

  /// No description provided for @adminInvalidFrom.
  ///
  /// In en, this message translates to:
  /// **'Enter a sender such as Balnana <balnana@example.com>; email needs one.'**
  String get adminInvalidFrom;

  /// No description provided for @adminInvalidPort.
  ///
  /// In en, this message translates to:
  /// **'Enter a port number from 1 to 65535.'**
  String get adminInvalidPort;

  /// No description provided for @adminInvalidRequired.
  ///
  /// In en, this message translates to:
  /// **'This sign-in provider needs it.'**
  String get adminInvalidRequired;

  /// No description provided for @adminInvalidFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Enter SHA-256 fingerprints: 64 hexadecimal digits each, colons allowed.'**
  String get adminInvalidFingerprint;

  /// No description provided for @adminNeedsSignIn.
  ///
  /// In en, this message translates to:
  /// **'Accounts need a way to sign in: turn on email and password, or set up a provider.'**
  String get adminNeedsSignIn;

  /// No description provided for @adminLockedChange.
  ///
  /// In en, this message translates to:
  /// **'This is set on the server and can\'t be changed here.'**
  String get adminLockedChange;

  /// No description provided for @errorAdminRequired.
  ///
  /// In en, this message translates to:
  /// **'Your administrator session has ended. Sign in again.'**
  String get errorAdminRequired;

  /// No description provided for @errorAdminWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'That password isn\'t right.'**
  String get errorAdminWrongPassword;

  /// No description provided for @errorInvalidSetupCode.
  ///
  /// In en, this message translates to:
  /// **'That setup code isn\'t right. Look for it in the server\'s log.'**
  String get errorInvalidSetupCode;

  /// No description provided for @errorAlreadySetUp.
  ///
  /// In en, this message translates to:
  /// **'This server has been set up already. Sign in with its administrator password.'**
  String get errorAlreadySetUp;

  /// No description provided for @linkOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening link…'**
  String get linkOpening;

  /// No description provided for @linkForeignTitle.
  ///
  /// In en, this message translates to:
  /// **'This link is for another server'**
  String get linkForeignTitle;

  /// No description provided for @linkForeignBody.
  ///
  /// In en, this message translates to:
  /// **'This app is connected to {server}, and the link belongs to a different server. Change the server in Settings to open it.'**
  String linkForeignBody(String server);

  /// No description provided for @linkInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'This link can\'t be opened'**
  String get linkInvalidTitle;

  /// No description provided for @linkInvalidBody.
  ///
  /// In en, this message translates to:
  /// **'It isn\'t a Balnana link this app knows.'**
  String get linkInvalidBody;

  /// No description provided for @linkGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to groups'**
  String get linkGoHome;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Balnana is open-source software. Whoever runs the server this app is connected to (its operator) decides where your data is kept and is responsible for it. This page describes what the software itself stores and does.'**
  String get privacyIntro;

  /// No description provided for @privacyStoredTitle.
  ///
  /// In en, this message translates to:
  /// **'What is stored'**
  String get privacyStoredTitle;

  /// No description provided for @privacyStoredBody.
  ///
  /// In en, this message translates to:
  /// **'The groups you create or join: their names, the members\' names, expenses, payments, notes, any receipt photos and the places you add to expenses. With an account, also your name, your email address or username, a hash of your password (never the password itself) and which sign-in provider you use, such as Google. If notifications are on, an identifier for your device and the address its push service gave it.'**
  String get privacyStoredBody;

  /// No description provided for @privacyUseTitle.
  ///
  /// In en, this message translates to:
  /// **'How it is used'**
  String get privacyUseTitle;

  /// No description provided for @privacyUseBody.
  ///
  /// In en, this message translates to:
  /// **'Only to run the app: to show each group to its members, work out balances, and send the emails and notifications the app needs, such as address verification, password resets and invitations. The app has no ads and no analytics, and nothing is sold.'**
  String get privacyUseBody;

  /// No description provided for @privacySharedTitle.
  ///
  /// In en, this message translates to:
  /// **'Who can see it'**
  String get privacySharedTitle;

  /// No description provided for @privacySharedBody.
  ///
  /// In en, this message translates to:
  /// **'Everyone in a group sees its members, expenses and history. When a group is open by link, anyone with the link can open it. Sign-in with Google goes through Google, and notifications, when the operator turns them on, go through the push service your phone uses: Google\'s Firebase Cloud Messaging, or another UnifiedPush service you installed, such as ntfy. The notification\'s content is encrypted on the way. Maps load their pictures from the map provider the operator chose, OpenStreetMap unless they changed it, which sees your network address and which area you look at. Your own location is read only when you tap \"Use current location\", and only the point you then keep is saved.'**
  String get privacySharedBody;

  /// No description provided for @privacyDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get privacyDeviceTitle;

  /// No description provided for @privacyDeviceBody.
  ///
  /// In en, this message translates to:
  /// **'The app keeps the server\'s address, your settings and a copy of your groups for when you\'re offline. Uninstalling the app removes them.'**
  String get privacyDeviceBody;

  /// No description provided for @privacyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Deleting your data'**
  String get privacyDeleteTitle;

  /// No description provided for @privacyDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'You can delete your account in Settings. Your name then stays in your groups as a member nobody has claimed, so their balances still add up, and groups nobody else can reach are deleted with it. A group\'s owner can delete the whole group in its settings. For anything else, contact the server\'s operator.'**
  String get privacyDeleteBody;

  /// No description provided for @privacyOperatorPolicy.
  ///
  /// In en, this message translates to:
  /// **'The operator\'s privacy policy'**
  String get privacyOperatorPolicy;

  /// Short link to the privacy policy, under the sign-in form.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyLink;

  /// No description provided for @accountEmailAdd.
  ///
  /// In en, this message translates to:
  /// **'Add email address'**
  String get accountEmailAdd;

  /// No description provided for @accountEmailChange.
  ///
  /// In en, this message translates to:
  /// **'Change email address'**
  String get accountEmailChange;

  /// No description provided for @accountEmailNew.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get accountEmailNew;

  /// No description provided for @accountEmailVerifyNote.
  ///
  /// In en, this message translates to:
  /// **'You\'ll get a link to confirm the new address. Your current address stays until then.'**
  String get accountEmailVerifyNote;

  /// No description provided for @accountEmailPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new email'**
  String get accountEmailPendingTitle;

  /// No description provided for @accountEmailPendingHelp.
  ///
  /// In en, this message translates to:
  /// **'{email} takes your current address\'s place once you open the link sent to it. Tap to send it again.'**
  String accountEmailPendingHelp(String email);

  /// No description provided for @accountEmailRemoveNote.
  ///
  /// In en, this message translates to:
  /// **'Leave it empty to remove your address. You keep signing in with your username.'**
  String get accountEmailRemoveNote;

  /// No description provided for @accountEmailSaved.
  ///
  /// In en, this message translates to:
  /// **'Email address saved'**
  String get accountEmailSaved;

  /// No description provided for @accountEmailRemoved.
  ///
  /// In en, this message translates to:
  /// **'Email address removed'**
  String get accountEmailRemoved;

  /// No description provided for @accountConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get accountConfirmPassword;

  /// No description provided for @accountConfirmPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'To confirm it\'s you.'**
  String get accountConfirmPasswordHelp;

  /// No description provided for @errorEmailNeeded.
  ///
  /// In en, this message translates to:
  /// **'You sign in with your email address, so it can\'t be removed.'**
  String get errorEmailNeeded;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDelete;

  /// No description provided for @accountDeleteHelp.
  ///
  /// In en, this message translates to:
  /// **'Remove your account from this server'**
  String get accountDeleteHelp;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is deleted for good, and you\'re signed out. In your groups your name stays as a member nobody has claimed, so balances still add up. Groups nobody else is in are deleted.'**
  String get accountDeleteBody;

  /// No description provided for @accountDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete for good'**
  String get accountDeleteAction;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeleted;

  /// No description provided for @accountDeletePageSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Sign in to delete your account on this server.'**
  String get accountDeletePageSignedOut;

  /// No description provided for @accountDeletePageLinkMode.
  ///
  /// In en, this message translates to:
  /// **'This server has no accounts: a group\'s link is all anyone needs. To delete a group with everything in it, open the group\'s settings and choose Delete group.'**
  String get accountDeletePageLinkMode;

  /// No description provided for @groupDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get groupDelete;

  /// No description provided for @groupDeleteHelp.
  ///
  /// In en, this message translates to:
  /// **'Delete it with all its expenses, for everyone'**
  String get groupDeleteHelp;

  /// No description provided for @groupDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String groupDeleteTitle(String name);

  /// No description provided for @groupDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The group and all its expenses, payments and history are deleted for everyone. This can\'t be undone. Type the group\'s name to confirm.'**
  String get groupDeleteBody;

  /// No description provided for @groupDeleteName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupDeleteName;

  /// No description provided for @groupDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete for good'**
  String get groupDeleteAction;

  /// No description provided for @groupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Group deleted'**
  String get groupDeleted;

  /// No description provided for @groupDeleteOwnerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the group\'s owner can delete it.'**
  String get groupDeleteOwnerOnly;

  /// No description provided for @expenseDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get expenseDiscardTitle;

  /// No description provided for @expenseDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes to this expense haven\'t been saved.'**
  String get expenseDiscardBody;

  /// No description provided for @expenseDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get expenseDiscard;

  /// No description provided for @adminPrivacyUrl.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy link'**
  String get adminPrivacyUrl;

  /// No description provided for @adminPrivacyUrlHelp.
  ///
  /// In en, this message translates to:
  /// **'Your privacy policy, which app stores ask for. When empty, the app shows a general one about what Balnana stores.'**
  String get adminPrivacyUrlHelp;

  /// No description provided for @adminMapTiles.
  ///
  /// In en, this message translates to:
  /// **'Map tiles'**
  String get adminMapTiles;

  /// No description provided for @adminMapTilesHelp.
  ///
  /// In en, this message translates to:
  /// **'Where maps load their pictures from, as a tile URL template like the default one, or \"off\" to turn maps off. OpenStreetMap\'s own servers are only for light use; a busy server should use a tile provider.'**
  String get adminMapTilesHelp;

  /// No description provided for @adminMapAttribution.
  ///
  /// In en, this message translates to:
  /// **'Map credit'**
  String get adminMapAttribution;

  /// No description provided for @adminMapAttributionHelp.
  ///
  /// In en, this message translates to:
  /// **'Shown on every map, as the tile provider asks.'**
  String get adminMapAttributionHelp;

  /// No description provided for @adminInvalidMapTiles.
  ///
  /// In en, this message translates to:
  /// **'Enter an http(s) URL template with z, x and y in braces, or \"off\".'**
  String get adminInvalidMapTiles;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get adminUsers;

  /// No description provided for @adminUsersSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email or username'**
  String get adminUsersSearch;

  /// No description provided for @adminUsersShown.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total} accounts'**
  String adminUsersShown(int shown, int total);

  /// No description provided for @adminUsersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account} other{{count} accounts}}'**
  String adminUsersCount(int count);

  /// No description provided for @adminUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No accounts match.'**
  String get adminUsersEmpty;

  /// No description provided for @adminUserGroups.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No groups} =1{1 group} other{{count} groups}}'**
  String adminUserGroups(int count);

  /// No description provided for @adminUserUnverified.
  ///
  /// In en, this message translates to:
  /// **'not verified'**
  String get adminUserUnverified;

  /// No description provided for @adminUserDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}\'s account?'**
  String adminUserDeleteTitle(String name);

  /// No description provided for @adminUserDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The account is deleted for good and signed out everywhere. Its name stays in its groups as a member nobody has claimed; groups nobody else is in are deleted.'**
  String get adminUserDeleteBody;

  /// No description provided for @adminUserDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get adminUserDeleted;
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
