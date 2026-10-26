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
  String get errorInvalidCurrency => 'Enter a three-letter currency code, such as USD.';

  @override
  String get errorInvalidTitle => 'Enter a title of up to 200 characters.';

  @override
  String get errorMemberHasBalance => 'Settle this person\'s balance before removing them.';

  @override
  String get errorVersionConflict =>
      'Someone else changed this expense while you were editing it. Reload to see their changes.';

  @override
  String get errorSignInRequired => 'Sign in to do this.';

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
  String get groupCreate => 'Create group';

  @override
  String groupMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count people', one: '1 person');
    return '$_temp0';
  }

  @override
  String get totalOwed => 'You\'re owed';

  @override
  String get totalOwe => 'You owe';

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
  String get groupEmojiHint => '🏝️';

  @override
  String get groupName => 'Group name';

  @override
  String get groupNameHint => 'Trip to Lisbon';

  @override
  String get groupCurrency => 'Currency';

  @override
  String get groupCurrencyHelp => 'All expenses in this group use this currency. It can\'t be changed later.';

  @override
  String get groupColor => 'Color';

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
  String get groupShare => 'Copy link';

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
  String get forgetTitle => 'Remove from this device';

  @override
  String get forgetHelp => 'The group stays on the server for everyone else';

  @override
  String get forgetBody => 'You can open it again with the link.';

  @override
  String get tabExpenses => 'Expenses';

  @override
  String get tabBalances => 'Balances';

  @override
  String get heroWhoTitle => 'Who are you in this group?';

  @override
  String get heroWhoBody => 'Pick your name to see what you owe and are owed.';

  @override
  String get heroWhoAction => 'Choose';

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
  String get settleUp => 'Settle up';

  @override
  String get expenseAdd => 'Add expense';

  @override
  String get expensesEmptyTitle => 'No expenses yet';

  @override
  String get expensesEmptyBody => 'Add the first one, and Balnana will work out who owes whom.';

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
  String effectYouPaid(String amount) {
    return 'you paid $amount';
  }

  @override
  String effectYouReceived(String amount) {
    return 'you received $amount';
  }

  @override
  String effectYouLent(String amount) {
    return 'you lent $amount';
  }

  @override
  String effectYouBorrowed(String amount) {
    return 'you borrowed $amount';
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
  String get expensePaidByLabel => 'Paid by';

  @override
  String get expenseMultiplePayers => 'Several people';

  @override
  String get expenseSplit => 'Split';

  @override
  String get splitEqual => 'Equally';

  @override
  String get splitExact => 'Amounts';

  @override
  String get splitPercent => 'Percent';

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
  String splitPercentLeft(String percent) {
    return '$percent% left to assign';
  }

  @override
  String splitPercentOver(String percent) {
    return '$percent% too much';
  }

  @override
  String get conflictTitle => 'Changed elsewhere';

  @override
  String get conflictReload => 'Reload';

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
