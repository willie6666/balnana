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
  String get offlineBar => 'Offline. Showing what this device saved; changes wait until you reconnect.';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClear => 'Clear';

  @override
  String get iconChoose => 'Choose an icon';

  @override
  String get iconNone => 'No icon';

  @override
  String get iconSearchHint => 'Search, or type any emoji';

  @override
  String get iconUseTyped => 'Use this emoji';

  @override
  String get iconNoMatch => 'No icons match. Type an emoji to use it.';

  @override
  String get iconSectionTravel => 'Travel & places';

  @override
  String get iconSectionFood => 'Food & drink';

  @override
  String get iconSectionActivities => 'Activities';

  @override
  String get iconSectionHome => 'Home & bills';

  @override
  String get iconSectionPeople => 'People';

  @override
  String get iconSectionNature => 'Animals & nature';

  @override
  String get iconSectionObjects => 'Money & things';

  @override
  String get iconSectionSymbols => 'Symbols';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonUndo => 'Undo';

  @override
  String get someone => 'Someone';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'Can\'t reach the server. Check your connection.';

  @override
  String get errorNotFound => 'This no longer exists.';

  @override
  String get errorRequired => 'Required';

  @override
  String get errorInvalidName => 'Enter a name of up to 100 characters.';

  @override
  String get errorDuplicateName => 'Someone in this group already has that name.';

  @override
  String get errorTooManyMembers => 'This group has as many people as it can hold.';

  @override
  String get errorTooManyCategories => 'This group has as many categories as it can hold.';

  @override
  String get errorDuplicateCategory => 'This group already has a category with that name.';

  @override
  String get errorInvalidCurrency => 'Enter a three-letter currency code, such as USD.';

  @override
  String get errorInvalidTitle => 'Enter a title of up to 200 characters.';

  @override
  String get errorInvalidLocation => 'Enter a place name of one line, up to 200 characters.';

  @override
  String get errorInvalidSymbol => 'Enter a symbol of up to 8 characters.';

  @override
  String get errorInvalidEmoji => 'Pick a single emoji as the icon.';

  @override
  String get errorMemberHasBalance => 'Settle this person\'s balance before removing them.';

  @override
  String get errorVersionConflict =>
      'Someone else changed this expense while you were editing it. Reload to see their changes.';

  @override
  String get errorSignInRequired => 'Sign in to do this.';

  @override
  String get errorRateLimited => 'Too many requests. Wait a minute and try again.';

  @override
  String get errorNotAMember => 'You\'re not in this group yet.';

  @override
  String get errorNotAllowed => 'Only that person or the group\'s owner can do this.';

  @override
  String get errorLinkGroupsOff => 'This server doesn\'t allow opening groups by link alone.';

  @override
  String get errorMemberClaimed => 'Someone has already joined as that person.';

  @override
  String get errorMemberLeft => 'Someone in this has left the group.';

  @override
  String get errorInvalidEmail => 'Enter an email address.';

  @override
  String get errorInvalidPassword => 'Use 8 to 200 characters.';

  @override
  String get errorEmailTaken => 'There\'s already an account with that email. Sign in instead.';

  @override
  String get errorSignupClosed => 'This server isn\'t taking new accounts.';

  @override
  String get errorInvalidCredentials => 'That email and password don\'t match.';

  @override
  String get errorWrongPassword => 'Your current password isn\'t right.';

  @override
  String get errorAccountsOff => 'This server doesn\'t use accounts.';

  @override
  String get errorInvalidAmount => 'Enter an amount greater than zero.';

  @override
  String get errorTooManyDecimals => 'Too many decimal places for this currency.';

  @override
  String get errorAmountTooLarge => 'That amount is too large.';

  @override
  String get errorNoShares => 'Pick at least one person to share the cost.';

  @override
  String get errorInvalidShare => 'Each share must be a number.';

  @override
  String get errorExactTotal => 'The amounts must add up to the total.';

  @override
  String get errorPercentTotal => 'The percentages must add up to 100%.';

  @override
  String get errorPayersTotal => 'What everyone paid must add up to the total.';

  @override
  String get categoryFood => 'Food & drink';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryLodging => 'Lodging';

  @override
  String get categoryRent => 'Rent';

  @override
  String get categoryUtilities => 'Utilities';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryGifts => 'Gifts';

  @override
  String get categoryOther => 'Other';

  @override
  String get groupNew => 'New group';

  @override
  String get groupSwitch => 'Switch group';

  @override
  String get groupReorder => 'Drag to reorder';

  @override
  String get groupCreate => 'Create group';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count people', one: '1 person');
    return '$_temp0';
  }

  @override
  String pillOwed(String amount) {
    return 'You\'re owed $amount';
  }

  @override
  String pillOwe(String amount) {
    return 'You owe $amount';
  }

  @override
  String get pillSettled => 'Settled up';

  @override
  String get groupMissingTitle => 'Group not found';

  @override
  String get groupMissingBody =>
      'This group was deleted, or its link was reset. Ask someone in the group for the new link.';

  @override
  String get groupForget => 'Remove from this device';

  @override
  String get groupLinkOtherServer =>
      'This link belongs to another server. Connect to that server to open it.';

  @override
  String get openLinkTitle => 'Open a group link';

  @override
  String get openLinkBody => 'Paste a link someone shared with you to join their group.';

  @override
  String get openLinkLabel => 'Group link';

  @override
  String get openLinkAction => 'Open';

  @override
  String get openLinkInvalid => 'That doesn\'t look like a Balnana group link.';

  @override
  String get groupName => 'Group name';

  @override
  String get groupNameHint => 'Trip to Lisbon';

  @override
  String get groupCurrency => 'Currency';

  @override
  String get groupCurrencyHelp => 'All expenses in this group use this currency. It can\'t be changed later.';

  @override
  String groupCurrencyHelpNamed(String name) {
    return '$name. All expenses in this group use this currency. It can\'t be changed later.';
  }

  @override
  String get currencyChoose => 'Choose a currency';

  @override
  String get currencySearchHint => 'Search by code or name';

  @override
  String get currencySuggested => 'Suggested';

  @override
  String get currencyAll => 'All currencies';

  @override
  String currencyUseTyped(String code) {
    return 'Use $code';
  }

  @override
  String get currencyNoMatch => 'No currency matches. Type its three-letter code to use it.';

  @override
  String get groupSymbol => 'Symbol';

  @override
  String get groupSymbolChoose => 'Choose a symbol';

  @override
  String groupSymbolExample(String example) {
    return 'Amounts look like $example';
  }

  @override
  String get groupColor => 'Color';

  @override
  String colorSwatch(int number, int count) {
    return 'Color $number of $count';
  }

  @override
  String get groupPeople => 'People';

  @override
  String get groupYourName => 'Your name';

  @override
  String groupPersonName(int number) {
    return 'Person $number';
  }

  @override
  String get groupAddPerson => 'Add person';

  @override
  String get groupPeopleHelp => 'You can add more people later, or they can join with the link.';

  @override
  String get identityTitle => 'Who are you?';

  @override
  String get identityBody =>
      'Pick your name so Balnana can show what you owe. Only this device remembers it.';

  @override
  String get identityNew => 'I\'m someone new';

  @override
  String get identityNewTitle => 'Join this group';

  @override
  String get identityJoin => 'Join';

  @override
  String get identityChange => 'Who you are';

  @override
  String get identityNone => 'Not chosen yet';

  @override
  String get memberName => 'Name';

  @override
  String memberYou(String name) {
    return '$name (you)';
  }

  @override
  String get memberAdd => 'Add person';

  @override
  String get memberAddTitle => 'Add someone';

  @override
  String get memberRename => 'Rename';

  @override
  String get memberRenameTitle => 'Rename';

  @override
  String memberRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get memberRemoveBody => 'They\'ll stay on past expenses but can\'t be added to new ones.';

  @override
  String get groupLinkCopied => 'Link copied. Anyone with it can open this group.';

  @override
  String get groupShare => 'Share link';

  @override
  String get groupSettings => 'Group settings';

  @override
  String get groupEdit => 'Edit group';

  @override
  String get groupSharing => 'Sharing';

  @override
  String get groupCopyLink => 'Copy link';

  @override
  String get groupCopyLinkHelp => 'Anyone with the link can see and edit this group.';

  @override
  String get groupCopyLinkHelpAccounts => 'People with the link can ask to join after signing in.';

  @override
  String get linkAccessTitle => 'Open to anyone with the link';

  @override
  String get linkAccessHelp => 'Let people see and edit without an account';

  @override
  String get resetLinkTitle => 'Reset link';

  @override
  String get resetLinkHelp => 'Make a new link; the old one stops working';

  @override
  String get resetLinkBody =>
      'The current link will stop working, for everyone. Share the new link with people who should keep access.';

  @override
  String get resetLinkAction => 'Reset';

  @override
  String get resetLinkDone => 'Link reset. Share the new one.';

  @override
  String get groupThisDevice => 'This device';

  @override
  String get groupData => 'Data';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoriesHelp => 'Add your own, or hide the ones you don\'t use';

  @override
  String get categoriesOwn => 'This group\'s';

  @override
  String get categoriesOwnEmpty => 'No categories of the group\'s own yet.';

  @override
  String get categoriesBuiltIn => 'Built-in';

  @override
  String get categoriesBuiltInHelp =>
      'Hidden categories are not offered for new expenses. Expenses that have one keep it.';

  @override
  String get categoryAdd => 'Add category';

  @override
  String get categoryEdit => 'Edit category';

  @override
  String get categoryName => 'Name';

  @override
  String get categoryDelete => 'Delete category';

  @override
  String categoryDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get categoryDeleteBody => 'Expenses in this category will have none.';

  @override
  String get categoryDeleteAction => 'Delete';

  @override
  String get exportCsv => 'Export as CSV';

  @override
  String get exportCsvHelp => 'Every expense and payment, for a spreadsheet';

  @override
  String get exportCsvDone => 'Exported';

  @override
  String get forgetTitle => 'Remove from this device';

  @override
  String get forgetHelp => 'The group stays on the server for everyone else';

  @override
  String get forgetBody => 'You can open it again with the link.';

  @override
  String get groupYou => 'You';

  @override
  String get leaveTitle => 'Leave group';

  @override
  String get leaveHelp => 'Your expenses stay; you can join again with the link';

  @override
  String get leaveBody => 'The group disappears from your list. Your expenses and balance stay in the group.';

  @override
  String get leaveAction => 'Leave';

  @override
  String get tabExpenses => 'Expenses';

  @override
  String get heroWhoTitle => 'Who are you in this group?';

  @override
  String get heroWhoBody => 'Pick your name to see what you owe and are owed.';

  @override
  String get heroWhoAction => 'Choose';

  @override
  String get heroJoinTitle => 'You\'re viewing this group';

  @override
  String get heroJoinBody => 'Join to add expenses and see what you owe.';

  @override
  String get joinAction => 'Join';

  @override
  String get heroOwed => 'You\'re owed';

  @override
  String get heroOwe => 'You owe';

  @override
  String get heroSettled => 'You\'re settled up';

  @override
  String heroYouAre(String name) {
    return 'You are $name';
  }

  @override
  String get expenseAdd => 'Add expense';

  @override
  String get expensesEmptyTitle => 'No expenses yet';

  @override
  String get expensesEmptyBody => 'Add the first one, and Balnana will work out who owes whom.';

  @override
  String get expensesSearchHint => 'Search titles, notes and places';

  @override
  String get searchClear => 'Clear search';

  @override
  String get expensesNoMatchTitle => 'Nothing matches';

  @override
  String get expensesNoMatchBody => 'Try other words, or fewer filters.';

  @override
  String get filterAnyone => 'Anyone';

  @override
  String get filterAnyCategory => 'Any category';

  @override
  String get filterPayments => 'Payments';

  @override
  String get filterClear => 'Clear filters';

  @override
  String get periodAll => 'All time';

  @override
  String get periodThisMonth => 'This month';

  @override
  String get periodLastMonth => 'Last month';

  @override
  String get periodThisYear => 'This year';

  @override
  String get periodPickDays => 'Pick dates…';

  @override
  String get statsTitle => 'Spending';

  @override
  String get statsTotal => 'Total spent';

  @override
  String statsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
    );
    return '$_temp0';
  }

  @override
  String get statsByCategory => 'By category';

  @override
  String get statsByMember => 'Paid and share per person';

  @override
  String get statsPaid => 'Paid';

  @override
  String get statsShare => 'Share';

  @override
  String get statsByMonth => 'By month';

  @override
  String get statsNoCategory => 'No category';

  @override
  String get statsEmptyTitle => 'Nothing spent';

  @override
  String get statsEmptyBody => 'There are no expenses in this period.';

  @override
  String get statsShowExpenses => 'Show these expenses';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String paymentTitle(String from, String to) {
    return '$from paid $to';
  }

  @override
  String expensePaidBy(String name, String amount) {
    return '$name paid $amount';
  }

  @override
  String expensePaidByMany(int count, String amount) {
    return '$count people paid $amount';
  }

  @override
  String expenseReceivedBy(String name, String amount) {
    return '$name received $amount';
  }

  @override
  String expenseReceivedByMany(int count, String amount) {
    return '$count people received $amount';
  }

  @override
  String get transactionRefund => 'Refund';

  @override
  String get transactionIncome => 'Income';

  @override
  String effectYouPaid(String amount) {
    return 'you paid $amount';
  }

  @override
  String effectYouReceived(String amount) {
    return 'you received $amount';
  }

  @override
  String effectForYou(String amount) {
    return '$amount for you';
  }

  @override
  String get effectEven => 'even';

  @override
  String get effectNotInvolved => 'not involved';

  @override
  String get paymentDelete => 'Delete payment';

  @override
  String get paymentDeleted => 'Payment deleted';

  @override
  String expenseDeleted(String title) {
    return 'Deleted “$title”';
  }

  @override
  String get expenseNew => 'New expense';

  @override
  String get expenseEdit => 'Edit expense';

  @override
  String get expenseDelete => 'Delete';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expenseTitle => 'What was it for?';

  @override
  String get expenseTitleHint => 'Dinner, tickets, taxi…';

  @override
  String get expenseNote => 'Note';

  @override
  String get expenseNoteHint => 'Optional';

  @override
  String get expenseLocation => 'Location';

  @override
  String get expenseLocationHint => 'Where was it? (optional)';

  @override
  String get locationPickOnMap => 'Pick on map';

  @override
  String get locationUseCurrent => 'Use current location';

  @override
  String get locationFinding => 'Finding where you are…';

  @override
  String get locationChange => 'Change on map';

  @override
  String get locationRemovePin => 'Remove pin';

  @override
  String get locationOpenInMaps => 'Open in maps';

  @override
  String get locationPickTitle => 'Pick a location';

  @override
  String get locationPickHint => 'Tap the map to drop a pin';

  @override
  String get locationPickDone => 'Done';

  @override
  String get locationDenied =>
      'Balnana may not use your location. You can allow it in your device or browser settings.';

  @override
  String get locationOff => 'Location is turned off on this device.';

  @override
  String get locationUnavailable => 'Couldn\'t find where you are. Try again, or drop a pin on the map.';

  @override
  String get expenseReceipt => 'Receipt';

  @override
  String get expenseHasReceipt => 'Has a receipt photo';

  @override
  String get expenseHasLocation => 'Has a location';

  @override
  String get receiptTakePhoto => 'Take a photo';

  @override
  String get receiptChoose => 'Choose a picture';

  @override
  String get receiptRemove => 'Remove';

  @override
  String get receiptView => 'Receipt photo';

  @override
  String receiptNotSaved(String reason) {
    return 'The expense was saved, but not its receipt photo. $reason';
  }

  @override
  String get expensePaidByLabel => 'Paid by';

  @override
  String get expenseReceivedForLabel => 'Received for';

  @override
  String get expenseReceivedByLabel => 'Received by';

  @override
  String get expenseMultiplePayers => 'Several people';

  @override
  String get expenseSplit => 'Split';

  @override
  String get splitEqual => 'Equally';

  @override
  String get splitExact => 'Amounts';

  @override
  String get splitShares => 'Shares';

  @override
  String splitLeft(String amount) {
    return '$amount left to assign';
  }

  @override
  String splitOver(String amount) {
    return '$amount too much';
  }

  @override
  String get conflictTitle => 'Changed elsewhere';

  @override
  String get conflictReload => 'Reload';

  @override
  String get expenseChangedElsewhere =>
      'Someone else changed this expense. Reloading shows their version and drops your changes here.';

  @override
  String get suggestedPayments => 'Suggested payments';

  @override
  String get allSettled => 'Everyone is settled up.';

  @override
  String transferYouPay(String name) {
    return 'You pay $name';
  }

  @override
  String transferPaysYou(String name) {
    return '$name pays you';
  }

  @override
  String transferPays(String from, String to) {
    return '$from pays $to';
  }

  @override
  String get recordPayment => 'Record';

  @override
  String get recordPaymentTitle => 'Record a payment';

  @override
  String get recordPaymentHelp => 'Only record money that was actually paid, outside Balnana.';

  @override
  String get paymentRecorded => 'Payment recorded';

  @override
  String activityGroupCreated(String who, String group) {
    return '$who created $group';
  }

  @override
  String activityGroupUpdated(String who) {
    return '$who changed the group details';
  }

  @override
  String activityLinkReset(String who) {
    return '$who reset the group link';
  }

  @override
  String activityMemberAdded(String who, String name) {
    return '$who added $name';
  }

  @override
  String activityMemberRenamed(String who, String oldName, String name) {
    return '$who renamed $oldName to $name';
  }

  @override
  String activityMemberRemoved(String who, String name) {
    return '$who removed $name';
  }

  @override
  String activityCategoryAdded(String who, String name) {
    return '$who added the category $name';
  }

  @override
  String activityCategoryUpdated(String who) {
    return '$who changed the categories';
  }

  @override
  String activityCategoryDeleted(String who, String name) {
    return '$who deleted the category $name';
  }

  @override
  String activityMemberJoined(String name) {
    return '$name joined';
  }

  @override
  String activityExpenseAdded(String who, String title, String amount) {
    return '$who added “$title” ($amount)';
  }

  @override
  String activityExpenseUpdated(String who, String title, String amount) {
    return '$who edited “$title” ($amount)';
  }

  @override
  String activityExpenseDeleted(String who, String title) {
    return '$who deleted “$title”';
  }

  @override
  String activityExpenseRestored(String who, String title) {
    return '$who restored “$title”';
  }

  @override
  String activityPaymentAdded(String who, String from, String to, String amount) {
    return '$who recorded that $from paid $to $amount';
  }

  @override
  String activityPaymentDeleted(String who, String amount) {
    return '$who deleted a payment of $amount';
  }

  @override
  String activityPaymentRestored(String who, String amount) {
    return '$who restored a payment of $amount';
  }

  @override
  String activityGroupImported(String who, int count, String source) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count entries', one: '1 entry');
    return '$who imported $_temp0 from $source';
  }

  @override
  String activityReceiptAdded(String who, String title) {
    return '$who added a receipt photo to “$title”';
  }

  @override
  String activityReceiptRemoved(String who, String title) {
    return '$who removed the receipt photo from “$title”';
  }

  @override
  String activityOther(String who) {
    return '$who made a change';
  }

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
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBody => 'This address doesn\'t lead anywhere in Balnana.';

  @override
  String get notFoundAction => 'Go to groups';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAccount => 'Account';

  @override
  String get accountRename => 'Change name';

  @override
  String get passwordChange => 'Change password';

  @override
  String get passwordChanged => 'Password changed. Other devices are signed out.';

  @override
  String get passwordSet => 'Set a password';

  @override
  String get passwordSetHelp => 'Sign in with your email or username and a password too';

  @override
  String get passwordSetDone => 'Password set. Other devices are signed out.';

  @override
  String get passwordCurrent => 'Current password';

  @override
  String get passwordNew => 'New password';

  @override
  String get signOut => 'Sign out';

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
  String get settingsWallpaperGroups => 'Wallpaper colors in groups';

  @override
  String get settingsWallpaperGroupsSubtitle => 'Groups use your device colors too, instead of their own';

  @override
  String get settingsPureBlack => 'Pure black';

  @override
  String get settingsPureBlackSubtitle => 'A darker dark theme for OLED screens';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'When someone adds, changes or deletes an expense you are in';

  @override
  String get pushChannel => 'Expenses';

  @override
  String get pushChannelDescription => 'When someone adds, changes or deletes an expense you are in';

  @override
  String pushExpenseAdded(String who, String title, String amount) {
    return '$who added $title · $amount';
  }

  @override
  String pushExpenseEdited(String who, String title, String amount) {
    return '$who changed $title · $amount';
  }

  @override
  String pushExpenseDeleted(String who, String title, String amount) {
    return '$who deleted $title · $amount';
  }

  @override
  String pushExpenseAddedAnon(String title, String amount) {
    return '$title was added · $amount';
  }

  @override
  String pushExpenseEditedAnon(String title, String amount) {
    return '$title was changed · $amount';
  }

  @override
  String pushExpenseDeletedAnon(String title, String amount) {
    return '$title was deleted · $amount';
  }

  @override
  String pushPaymentAdded(String payer, String payee, String amount) {
    return '$payer paid $payee $amount';
  }

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

  @override
  String get signIn => 'Sign in';

  @override
  String get groupSignInTitle => 'Sign in to open this group';

  @override
  String get groupSignInBody => 'This group is only for its members. Sign in to see it or to join.';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInBody => 'Sign in to see your groups.';

  @override
  String get signInNoPassword => 'This server signs people in another way. Ask whoever runs it.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerBody => 'Keep your groups on every device.';

  @override
  String get registerAction => 'Create account';

  @override
  String get registerHaveAccount => 'I already have an account';

  @override
  String get signInNoAccount => 'Create an account';

  @override
  String get accountName => 'Your name';

  @override
  String get accountNameHelp => 'What people in your groups will see';

  @override
  String get accountEmail => 'Email';

  @override
  String get accountPassword => 'Password';

  @override
  String get accountPasswordHelp => 'At least 8 characters';

  @override
  String get passwordShow => 'Show password';

  @override
  String get passwordHide => 'Hide password';

  @override
  String get joinPickName => 'Pick another name';

  @override
  String joinTitle(String name) {
    return 'Join $name';
  }

  @override
  String get joinBody => 'Are you one of these people? Pick yourself to take over their expenses.';

  @override
  String get joinBodyNew => 'Join to add expenses and see your balance.';

  @override
  String get joinAsNew => 'I\'m someone new';

  @override
  String joinAsName(String name) {
    return 'Join as $name';
  }

  @override
  String joinTaken(String names) {
    return 'Already joined: $names';
  }

  @override
  String joinTakenCount(int count) {
    return '$count people have already joined.';
  }

  @override
  String get commonContinue => 'Continue';

  @override
  String get errorEmailOff => 'This server doesn\'t send email.';

  @override
  String get errorInvalidToken => 'This link has expired or was already used.';

  @override
  String get forgotPasswordTitle => 'Forgot password?';

  @override
  String get forgotPasswordBody => 'We\'ll email you a link to choose a new password.';

  @override
  String get forgotPasswordAction => 'Send link';

  @override
  String get forgotPasswordSent => 'If there\'s an account for that address, a link is on its way.';

  @override
  String get resetPasswordTitle => 'Choose a new password';

  @override
  String get resetPasswordBody =>
      'You\'ll be signed out everywhere, then you can sign in with the new password.';

  @override
  String get resetPasswordAction => 'Save password';

  @override
  String get resetPasswordDone => 'Password changed. Sign in with your new password.';

  @override
  String get verifyEmailTitle => 'Confirm your email';

  @override
  String get verifyEmailHelp => 'So you can reset your password if you forget it';

  @override
  String verifyEmailSent(String email) {
    return 'Check $email for a link.';
  }

  @override
  String get verifyEmailDone => 'Email confirmed';

  @override
  String get verifyEmailDoneBody => 'Thanks! Your address is confirmed.';

  @override
  String get verifyEmailFailed => 'Couldn\'t confirm your email';

  @override
  String get inviteByEmail => 'Invite by email';

  @override
  String get inviteByEmailHelp => 'Send someone a link to join';

  @override
  String get inviteAs => 'Join as';

  @override
  String get inviteAsHelp => 'They can take over this person\'s expenses';

  @override
  String get inviteAsAnyone => 'Someone new';

  @override
  String get inviteSend => 'Send invite';

  @override
  String inviteSent(String email) {
    return 'Invite sent to $email.';
  }

  @override
  String inviteTitle(String name, String group) {
    return '$name invited you to $group';
  }

  @override
  String inviteTitleAnonymous(String group) {
    return 'You\'re invited to $group';
  }

  @override
  String inviteBody(String email) {
    return 'Create an account with $email to join, or sign in if you have one.';
  }

  @override
  String get inviteBodySignedIn => 'Join to add expenses and see your balance.';

  @override
  String get inviteAction => 'Open invitation';

  @override
  String get inviteMissingTitle => 'This invitation doesn\'t work';

  @override
  String get inviteMissingBody => 'It may have expired or been used. Ask for a new one.';

  @override
  String get joinInvitedAs => 'You were invited as this person';

  @override
  String signInWith(String provider) {
    return 'Continue with $provider';
  }

  @override
  String get signInOr => 'or';

  @override
  String get oauthFailedTitle => 'Couldn\'t sign you in';

  @override
  String get oauthEmailTaken =>
      'There\'s already an account with this email. Sign in with your password and confirm your email in Settings, then this way of signing in works too.';

  @override
  String get oauthOtherServer =>
      'This sign-in was started on another server than the one chosen now. Sign in again.';

  @override
  String get oauthBackToSignIn => 'Back to sign in';

  @override
  String get errorOAuthFailed => 'Signing in didn\'t work. Try again.';

  @override
  String get errorOAuthCancelled => 'Signing in was cancelled.';

  @override
  String get importTitle => 'Import from Settle Up';

  @override
  String get importAction => 'Import';

  @override
  String get importIntro =>
      'In Settle Up, export the group as a CSV file, then choose the file here. Expenses, payments and everyone in the group come along, and balances stay the same.';

  @override
  String get importChooseFile => 'Choose CSV file';

  @override
  String get importChooseOther => 'Choose another file';

  @override
  String get importReading => 'Reading the file…';

  @override
  String importSummary(int expenses, int payments) {
    String _temp0 = intl.Intl.pluralLogic(
      expenses,
      locale: localeName,
      other: '$expenses expenses',
      one: '1 expense',
    );
    String _temp1 = intl.Intl.pluralLogic(
      payments,
      locale: localeName,
      other: '$payments payments',
      one: '1 payment',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String importDates(String from, String to) {
    return '$from to $to';
  }

  @override
  String importCurrency(String currency) {
    return 'Currency: $currency. Entries in other currencies use the amounts Settle Up converted.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries of zero are left out.',
      one: '1 entry of zero is left out.',
    );
    return '$_temp0';
  }

  @override
  String get importWhoAreYou => 'Which one are you?';

  @override
  String get importUntitled => 'Untitled';

  @override
  String get errorImportFile => 'This doesn\'t look like a Settle Up CSV export.';

  @override
  String get errorImportCurrency =>
      'The file has no entries without an exchange rate, so the group\'s currency is unclear.';

  @override
  String get errorImportTooBig => 'This file is too big to import.';

  @override
  String get errorBadImage => 'That picture can\'t be used. Choose a JPEG, PNG or WebP image.';

  @override
  String get errorReceiptTooBig => 'That picture is too big. Choose one under 10 MB.';

  @override
  String get errorImportMe => 'Choose which person you are.';

  @override
  String errorImportRow(int line, String reason) {
    return 'Line $line of the file can\'t be imported: $reason';
  }

  @override
  String get errorImportAmount => 'an amount can\'t be read.';

  @override
  String get errorImportCounts => 'the names and amounts don\'t match up.';

  @override
  String get errorImportDate => 'the date can\'t be read.';

  @override
  String get errorImportType => 'the type isn\'t expense, transfer or income.';

  @override
  String get errorImportTransfer => 'a transfer needs one person paying someone else.';

  @override
  String get errorImportRowCurrency => 'it\'s in another currency without an exchange rate.';

  @override
  String get adminSetupTitle => 'Set up this server';

  @override
  String get adminSetupBody =>
      'Choose a password for the administrator. It guards this page, where the server\'s settings live. There is no username: whoever knows the password can change the settings.';

  @override
  String get adminSetupCode => 'Setup code';

  @override
  String get adminSetupCodeHelp =>
      'This server already holds data, so it printed a setup code in its log when it started. With Docker: docker compose logs balnana';

  @override
  String get adminSetupAction => 'Set password';

  @override
  String get adminPassword => 'Administrator password';

  @override
  String get adminPasswordRepeat => 'Repeat the password';

  @override
  String get adminPasswordMismatch => 'The passwords don\'t match.';

  @override
  String get adminLoginTitle => 'Administration';

  @override
  String get adminLoginBody => 'Enter the administrator password to change this server\'s settings.';

  @override
  String get adminLoginAction => 'Sign in';

  @override
  String get adminSettingsTitle => 'Server settings';

  @override
  String get adminSaved => 'Settings saved. They apply right away.';

  @override
  String get adminSaveFailed => 'Nothing was saved. Check the highlighted settings.';

  @override
  String get adminChangePassword => 'Change administrator password';

  @override
  String get adminPasswordCurrent => 'Current password';

  @override
  String get adminPasswordNew => 'New password';

  @override
  String get adminPasswordChanged => 'Password changed. Other administrator sessions are signed out.';

  @override
  String get adminSignOut => 'Sign out of administration';

  @override
  String get adminBackHome => 'Back to Balnana';

  @override
  String get adminRequireEmail => 'Require an email address';

  @override
  String get adminRequireEmailHelp =>
      'When off, people sign up with a username and may leave the email address out. They sign in with either.';

  @override
  String get accountUsername => 'Username';

  @override
  String get accountUsernameHelp =>
      '3 to 32 letters, digits, dots, dashes or underscores. You sign in with it.';

  @override
  String get accountEmailOptional => 'Email (optional)';

  @override
  String get accountEmailOptionalHelp => 'Lets you get group invitations and reset a forgotten password.';

  @override
  String get accountLogin => 'Email or username';

  @override
  String get errorInvalidUsername =>
      'Use 3 to 32 letters, digits, dots, dashes or underscores, starting with a letter or digit.';

  @override
  String get errorUsernameTaken => 'Someone already has that username.';

  @override
  String get adminDiscardTitle => 'Discard changes?';

  @override
  String get adminDiscardBody => 'Your changes to the settings haven\'t been saved.';

  @override
  String get adminDiscard => 'Discard';

  @override
  String adminLocked(String key) {
    return 'Set on the server by $key';
  }

  @override
  String adminDefault(String value) {
    return 'Default: $value';
  }

  @override
  String get adminSecretSaved => 'Saved. Type a new one to replace it.';

  @override
  String get adminSecretRemoved => 'Will be removed when you save.';

  @override
  String get adminSecretRemove => 'Remove saved value';

  @override
  String get adminSectionGeneral => 'General';

  @override
  String get adminSectionAccess => 'Access';

  @override
  String get adminSectionAccounts => 'Accounts';

  @override
  String get adminSectionAccountsBody => 'These apply when access is set to accounts.';

  @override
  String get adminSectionEmail => 'Email (SMTP)';

  @override
  String get adminSectionEmailBody =>
      'Lets the server send email: address verification, password resets and invitations. Leave the mail server empty to turn email off.';

  @override
  String get adminSectionGoogle => 'Sign in with Google';

  @override
  String adminSectionGoogleBody(String url) {
    return 'Register $url as the redirect URI in the Google Cloud console. Leave the client ID empty to turn it off.';
  }

  @override
  String get adminSectionOidc => 'Sign in with OpenID Connect';

  @override
  String adminSectionOidcBody(String url) {
    return 'Any OpenID Connect provider, such as Authentik, Keycloak or Dex. Register $url as the redirect URI. Leave the issuer empty to turn it off.';
  }

  @override
  String get adminSectionAndroid => 'Android app links';

  @override
  String get adminSectionAndroidBody =>
      'Android builds made for this server open its links in the app. To skip asking, list the SHA-256 fingerprints of the certificates those builds are signed with.';

  @override
  String get adminSectionAdmin => 'Administrator';

  @override
  String get adminPublicUrl => 'Public address';

  @override
  String get adminPublicUrlHelp =>
      'The address people use to reach this server. Group links and email links are built from it.';

  @override
  String get adminSourceUrl => 'Source code link';

  @override
  String get adminSourceUrlHelp =>
      'Where people can get this server\'s source code, as its license (AGPL-3.0) asks when you run a changed version.';

  @override
  String get adminAuthMode => 'Access';

  @override
  String get adminAuthModeLink => 'Group links';

  @override
  String get adminAuthModeLinkHelp => 'No sign-in: a group\'s private link is all anyone needs.';

  @override
  String get adminAuthModeAccounts => 'Accounts';

  @override
  String get adminAuthModeAccountsHelp =>
      'People sign in, and a link only lets signed-in people join a group.';

  @override
  String get adminPasswordLogin => 'Email and password sign-in';

  @override
  String get adminSignup => 'Who may create an account';

  @override
  String get adminSignupOpen => 'Anyone';

  @override
  String get adminSignupInvite => 'Invited people';

  @override
  String get adminSignupClosed => 'Nobody';

  @override
  String get adminSignupHelp => 'The first account can always be created.';

  @override
  String get adminLinkGroups => 'Groups may be opened by link';

  @override
  String get adminLinkGroupsHelp => 'Group owners may let anyone with the link in, without signing in.';

  @override
  String get adminSmtpHost => 'Mail server';

  @override
  String get adminSmtpPort => 'Port';

  @override
  String get adminSmtpUser => 'User name';

  @override
  String get adminSmtpPassword => 'Password';

  @override
  String get adminSmtpFrom => 'Sender';

  @override
  String get adminSmtpFromHint => 'Balnana <balnana@example.com>';

  @override
  String get adminClientId => 'Client ID';

  @override
  String get adminClientSecret => 'Client secret';

  @override
  String get adminOidcIssuer => 'Issuer URL';

  @override
  String get adminOidcName => 'Button name';

  @override
  String get adminOidcNameHelp => 'Shown as \"Continue with …\" on the sign-in page.';

  @override
  String get adminFingerprints => 'Certificate fingerprints';

  @override
  String get adminFingerprintsHelp =>
      'SHA-256, separated by commas. keytool -list -v and apksigner verify --print-certs show them.';

  @override
  String get adminInvalidValue => 'This value isn\'t valid.';

  @override
  String get adminInvalidUrl => 'Enter a full address starting with https:// or http://.';

  @override
  String get adminInvalidFrom => 'Enter a sender such as Balnana <balnana@example.com>; email needs one.';

  @override
  String get adminInvalidPort => 'Enter a port number from 1 to 65535.';

  @override
  String get adminInvalidRequired => 'This sign-in provider needs it.';

  @override
  String get adminInvalidFingerprint =>
      'Enter SHA-256 fingerprints: 64 hexadecimal digits each, colons allowed.';

  @override
  String get adminNeedsSignIn =>
      'Accounts need a way to sign in: turn on email and password, or set up a provider.';

  @override
  String get adminLockedChange => 'This is set on the server and can\'t be changed here.';

  @override
  String get errorAdminRequired => 'Your administrator session has ended. Sign in again.';

  @override
  String get errorAdminWrongPassword => 'That password isn\'t right.';

  @override
  String get errorInvalidSetupCode => 'That setup code isn\'t right. Look for it in the server\'s log.';

  @override
  String get errorAlreadySetUp =>
      'This server has been set up already. Sign in with its administrator password.';

  @override
  String get linkOpening => 'Opening link…';

  @override
  String get linkForeignTitle => 'This link is for another server';

  @override
  String linkForeignBody(String server) {
    return 'This app is connected to $server, and the link belongs to a different server. Change the server in Settings to open it.';
  }

  @override
  String get linkInvalidTitle => 'This link can\'t be opened';

  @override
  String get linkInvalidBody => 'It isn\'t a Balnana link this app knows.';

  @override
  String get linkGoHome => 'Go to groups';

  @override
  String get privacyTitle => 'Privacy policy';

  @override
  String get privacyIntro =>
      'Balnana is open-source software. Whoever runs the server this app is connected to (its operator) decides where your data is kept and is responsible for it. This page describes what the software itself stores and does.';

  @override
  String get privacyStoredTitle => 'What is stored';

  @override
  String get privacyStoredBody =>
      'The groups you create or join: their names, the members\' names, expenses, payments, notes, any receipt photos and the places you add to expenses. With an account, also your name, your email address or username, a hash of your password (never the password itself) and which sign-in provider you use, such as Google. If notifications are on, an identifier for your device and the address its push service gave it.';

  @override
  String get privacyUseTitle => 'How it is used';

  @override
  String get privacyUseBody =>
      'Only to run the app: to show each group to its members, work out balances, and send the emails and notifications the app needs, such as address verification, password resets and invitations. The app has no ads and no analytics, and nothing is sold.';

  @override
  String get privacySharedTitle => 'Who can see it';

  @override
  String get privacySharedBody =>
      'Everyone in a group sees its members, expenses and history. When a group is open by link, anyone with the link can open it. Sign-in with Google goes through Google, and notifications, when the operator turns them on, go through the push service your phone uses: Google\'s Firebase Cloud Messaging, or another UnifiedPush service you installed, such as ntfy. The notification\'s content is encrypted on the way. Maps load their pictures from the map provider the operator chose, OpenStreetMap unless they changed it, which sees your network address and which area you look at. Your own location is read only when you tap \"Use current location\", and only the point you then keep is saved.';

  @override
  String get privacyDeviceTitle => 'On this device';

  @override
  String get privacyDeviceBody =>
      'The app keeps the server\'s address, your settings and a copy of your groups for when you\'re offline. Uninstalling the app removes them.';

  @override
  String get privacyDeleteTitle => 'Deleting your data';

  @override
  String get privacyDeleteBody =>
      'You can delete your account in Settings. Your name then stays in your groups as a member nobody has claimed, so their balances still add up, and groups nobody else can reach are deleted with it. A group\'s owner can delete the whole group in its settings. For anything else, contact the server\'s operator.';

  @override
  String get privacyOperatorPolicy => 'The operator\'s privacy policy';

  @override
  String get privacyLink => 'Privacy';

  @override
  String get accountEmailAdd => 'Add email address';

  @override
  String get accountEmailChange => 'Change email address';

  @override
  String get accountEmailNew => 'Email address';

  @override
  String get accountEmailVerifyNote =>
      'You\'ll get a link to confirm the new address. Your current address stays until then.';

  @override
  String get accountEmailPendingTitle => 'Confirm your new email';

  @override
  String accountEmailPendingHelp(String email) {
    return '$email takes your current address\'s place once you open the link sent to it. Tap to send it again.';
  }

  @override
  String get accountEmailRemoveNote =>
      'Leave it empty to remove your address. You keep signing in with your username.';

  @override
  String get accountEmailSaved => 'Email address saved';

  @override
  String get accountEmailRemoved => 'Email address removed';

  @override
  String get accountConfirmPassword => 'Your password';

  @override
  String get accountConfirmPasswordHelp => 'To confirm it\'s you.';

  @override
  String get errorEmailNeeded => 'You sign in with your email address, so it can\'t be removed.';

  @override
  String get accountDelete => 'Delete account';

  @override
  String get accountDeleteHelp => 'Remove your account from this server';

  @override
  String get accountDeleteTitle => 'Delete your account?';

  @override
  String get accountDeleteBody =>
      'Your account is deleted for good, and you\'re signed out. In your groups your name stays as a member nobody has claimed, so balances still add up. Groups nobody else is in are deleted.';

  @override
  String get accountDeleteAction => 'Delete for good';

  @override
  String get accountDeleted => 'Your account has been deleted.';

  @override
  String get accountDeletePageSignedOut => 'Sign in to delete your account on this server.';

  @override
  String get accountDeletePageLinkMode =>
      'This server has no accounts: a group\'s link is all anyone needs. To delete a group with everything in it, open the group\'s settings and choose Delete group.';

  @override
  String get groupDelete => 'Delete group';

  @override
  String get groupDeleteHelp => 'Delete it with all its expenses, for everyone';

  @override
  String groupDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get groupDeleteBody =>
      'The group and all its expenses, payments and history are deleted for everyone. This can\'t be undone. Type the group\'s name to confirm.';

  @override
  String get groupDeleteName => 'Group name';

  @override
  String get groupDeleteAction => 'Delete for good';

  @override
  String get groupDeleted => 'Group deleted';

  @override
  String get groupDeleteOwnerOnly => 'Only the group\'s owner can delete it.';

  @override
  String get expenseDiscardTitle => 'Discard changes?';

  @override
  String get expenseDiscardBody => 'Your changes to this expense haven\'t been saved.';

  @override
  String get expenseDiscard => 'Discard';

  @override
  String get adminPrivacyUrl => 'Privacy policy link';

  @override
  String get adminPrivacyUrlHelp =>
      'Your privacy policy, which app stores ask for. When empty, the app shows a general one about what Balnana stores.';

  @override
  String get adminMapTiles => 'Map tiles';

  @override
  String get adminMapTilesHelp =>
      'Where maps load their pictures from, as a tile URL template like the default one, or \"off\" to turn maps off. OpenStreetMap\'s own servers are only for light use; a busy server should use a tile provider.';

  @override
  String get adminMapAttribution => 'Map credit';

  @override
  String get adminMapAttributionHelp => 'Shown on every map, as the tile provider asks.';

  @override
  String get adminInvalidMapTiles => 'Enter an http(s) URL template with z, x and y in braces, or \"off\".';

  @override
  String get adminUsers => 'Accounts';

  @override
  String get adminUsersSearch => 'Search by name, email or username';

  @override
  String adminUsersShown(int shown, int total) {
    return '$shown of $total accounts';
  }

  @override
  String adminUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
    );
    return '$_temp0';
  }

  @override
  String get adminUsersEmpty => 'No accounts match.';

  @override
  String adminUserGroups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
      zero: 'No groups',
    );
    return '$_temp0';
  }

  @override
  String get adminUserUnverified => 'not verified';

  @override
  String adminUserDeleteTitle(String name) {
    return 'Delete $name\'s account?';
  }

  @override
  String get adminUserDeleteBody =>
      'The account is deleted for good and signed out everywhere. Its name stays in its groups as a member nobody has claimed; groups nobody else is in are deleted.';

  @override
  String get adminUserDeleted => 'Account deleted';

  @override
  String get commonDone => 'Done';

  @override
  String get crowdSearch => 'Search people';

  @override
  String get crowdNoMatch => 'No one matches.';

  @override
  String get crowdAll => 'All';

  @override
  String get crowdNone => 'None';

  @override
  String crowdChosen(int count, int total) {
    return '$count of $total chosen';
  }

  @override
  String crowdShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count more', one: '1 more');
    return '$_temp0';
  }

  @override
  String get crowdShowFewer => 'Show fewer';

  @override
  String get crowdSort => 'Sort';

  @override
  String crowdShowAll(int count) {
    return 'Show all $count';
  }

  @override
  String get crowdBalances => 'Everyone\'s balance';

  @override
  String get crowdSomeoneElse => 'Someone else';

  @override
  String get crowdChoosePayers => 'Choose payers';

  @override
  String get crowdFilterTitle => 'Whose expenses?';
}
