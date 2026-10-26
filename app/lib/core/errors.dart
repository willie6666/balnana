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
    'invalid_currency' => l10n.errorInvalidCurrency,
    'invalid_title' => l10n.errorInvalidTitle,
    'member_has_balance' => l10n.errorMemberHasBalance,
    'expense_version_conflict' => l10n.errorVersionConflict,
    'sign_in_required' => l10n.errorSignInRequired,
    'rate_limited' => l10n.errorRateLimited,
    final code => MoneyError.values.where((e) => e.code == code).map((e) => moneyErrorMessage(l10n, e)).firstOrNull ??
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
  MoneyError.percentTotal => l10n.errorPercentTotal,
};
