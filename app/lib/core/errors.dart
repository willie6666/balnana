import '../data/api.dart';
import 'l10n.dart';
import 'money.dart';

/// A sentence for the person about what went wrong.
String errorMessage(AppLocalizations l10n, Object error) {
  if (error is MoneyException) return moneyErrorMessage(l10n, error.error);
  if (error is! ApiException) return l10n.errorGeneric;
  return switch (error.code) {
    ApiException.network => l10n.errorNetwork,
    'not_found' => l10n.errorNotFound,
    'invalid_name' => l10n.errorInvalidName,
    'duplicate_name' => l10n.errorDuplicateName,
    'too_many_members' => l10n.errorTooManyMembers,
    'too_many_categories' => l10n.errorTooManyCategories,
    'invalid_currency' => l10n.errorInvalidCurrency,
    'invalid_title' => l10n.errorInvalidTitle,
    'invalid_location' => l10n.errorInvalidLocation,
    'invalid_symbol' => l10n.errorInvalidSymbol,
    'invalid_emoji' => l10n.errorInvalidEmoji,
    'member_has_balance' => l10n.errorMemberHasBalance,
    'expense_version_conflict' => l10n.errorVersionConflict,
    'recurring_version_conflict' => l10n.errorRecurringConflict,
    'too_many_due' => l10n.errorTooManyDue,
    'invalid_end' => l10n.errorInvalidEnd,
    'invalid_repeat' => l10n.errorInvalidRepeat,
    'sign_in_required' => l10n.errorSignInRequired,
    'not_a_member' => l10n.errorNotAMember,
    'not_allowed' || 'owner_only' => l10n.errorNotAllowed,
    'link_groups_off' => l10n.errorLinkGroupsOff,
    'member_claimed' => l10n.errorMemberClaimed,
    'member_left' => l10n.errorMemberLeft,
    'invalid_email' => l10n.errorInvalidEmail,
    'invalid_password' => l10n.errorInvalidPassword,
    'email_taken' => l10n.errorEmailTaken,
    'username_taken' => l10n.errorUsernameTaken,
    'invalid_username' => l10n.errorInvalidUsername,
    'signup_closed' => l10n.errorSignupClosed,
    'invalid_credentials' => l10n.errorInvalidCredentials,
    'wrong_password' => l10n.errorWrongPassword,
    'email_needed' => l10n.errorEmailNeeded,
    'accounts_off' || 'password_off' => l10n.errorAccountsOff,
    'email_off' => l10n.errorEmailOff,
    'invalid_token' => l10n.errorInvalidToken,
    'oauth_failed' => l10n.errorOAuthFailed,
    'oauth_cancelled' => l10n.errorOAuthCancelled,
    'email_has_account' => l10n.errorEmailHasAccount,
    'identity_taken' => l10n.errorIdentityTaken,
    'last_sign_in_method' => l10n.errorLastSignInMethod,
    'email_unverified' => l10n.errorEmailUnverified,
    'rate_limited' => l10n.errorRateLimited,
    'admin_required' => l10n.errorAdminRequired,
    'invalid_setup_code' => l10n.errorInvalidSetupCode,
    'already_set_up' => l10n.errorAlreadySetUp,
    'import_file' when error.params['problem'] == 'currency' => l10n.errorImportCurrency,
    'import_file' when error.params['problem'] == 'too_many_rows' => l10n.errorImportTooBig,
    'import_file' => l10n.errorImportFile,
    'import_row' => l10n.errorImportRow(
      (error.params['line'] as num?)?.toInt() ?? 0,
      _importProblem(l10n, '${error.params['problem']}'),
    ),
    'import_me' => l10n.errorImportMe,
    'too_large' => l10n.errorImportTooBig,
    'bad_image' => l10n.errorBadImage,
    final code =>
      MoneyError.values.where((e) => e.code == code).map((e) => moneyErrorMessage(l10n, e)).firstOrNull ??
          l10n.errorGeneric,
  };
}

String moneyErrorMessage(AppLocalizations l10n, MoneyError error) => switch (error) {
  MoneyError.invalidAmount => l10n.errorInvalidAmount,
  MoneyError.tooManyDecimals => l10n.errorTooManyDecimals,
  MoneyError.amountTooLarge => l10n.errorAmountTooLarge,
  MoneyError.noMembers || MoneyError.noShares => l10n.errorNoShares,
  MoneyError.duplicateMember || MoneyError.unbalanced => l10n.errorGeneric,
  MoneyError.invalidShare => l10n.errorInvalidShare,
  MoneyError.exactTotal => l10n.errorExactTotal,
};

/// Why one row of an imported file was refused.
String _importProblem(AppLocalizations l10n, String problem) => switch (problem) {
  'amount' => l10n.errorImportAmount,
  'counts' => l10n.errorImportCounts,
  'date' => l10n.errorImportDate,
  'type' => l10n.errorImportType,
  'transfer' => l10n.errorImportTransfer,
  'currency' => l10n.errorImportRowCurrency,
  _ => errorMessage(l10n, ApiException(problem)),
};
