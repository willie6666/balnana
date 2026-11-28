import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/router.dart';
import '../../core/server.dart';
import '../../data/api.dart';

/// Says why something failed, as [message] or [errorMessage] would put it. A
/// plan's limit also leads to the plans, on a server that has them.
///
/// Takes the [messenger] rather than a context, as what failed may have closed
/// the page it started on.
void showError(ScaffoldMessengerState messenger, AppLocalizations l10n, ApiException error, {String? message}) {
  final container = ProviderScope.containerOf(messenger.context, listen: false);
  final plans = error.code == 'plan_limit' && (container.read(serverInfoProvider).value?.billing ?? false);
  messenger.showSnackBar(
    SnackBar(
      content: Text(message ?? errorMessage(l10n, error)),
      // With a button it would otherwise stay until pressed.
      persist: false,
      action: plans
          ? SnackBarAction(
              label: l10n.planView,
              onPressed: () => container.read(routerProvider).push('/settings/plan'),
            )
          : null,
    ),
  );
}
