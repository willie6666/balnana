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

  /// Label above the total others owe the reader across groups.
  ///
  /// In en, this message translates to:
  /// **'You\'re owed'**
  String get totalOwed;

  /// Label above the total the reader owes across groups.
  ///
  /// In en, this message translates to:
  /// **'You owe'**
  String get totalOwe;

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

  /// Example emoji shown in the empty emoji field. Not translated.
  ///
  /// In en, this message translates to:
  /// **'🏝️'**
  String get groupEmojiHint;

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

  /// No description provided for @groupColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get groupColor;

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
  /// **'Copy link'**
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

  /// No description provided for @tabBalances.
  ///
  /// In en, this message translates to:
  /// **'Balances'**
  String get tabBalances;

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

  /// No description provided for @settleUp.
  ///
  /// In en, this message translates to:
  /// **'Settle up'**
  String get settleUp;

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

  /// No description provided for @expensePaidByLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get expensePaidByLabel;

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
