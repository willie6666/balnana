import 'dart:async';

import 'package:balnana/core/l10n.dart';

/// Every translation is loaded before the tests, so a widget shows its text
/// in the first frame, as in the app once its language has loaded.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadTranslations(AppLocalizations.supportedLocales);
  await testMain();
}
