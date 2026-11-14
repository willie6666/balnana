import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/server.dart';
import '../../core/session.dart';
import '../providers.dart';
import 'balnana_api.dart';

// Keep handling delayed 401s from the current session across API wrapper refreshes.
final _sessionErrorHandlerProvider = Provider<void Function(Identity)>((ref) {
  return (who) => scheduleMicrotask(() {
    if (ref.mounted && ref.read(identityProvider) == who) {
      ref.read(sessionProvider.notifier).lost(who, signedIn: ref.container.read(signedInProvider));
    }
  });
});

/// The API of the chosen server, or null when none is set. Rebuilding this
/// reloads readers while keeping the HTTP client for requests already underway.
final balnanaApiProvider = Provider<BalnanaApi?>((ref) {
  final dio = ref.watch(apiProvider);
  if (dio == null) return null;
  final who = ref.watch(identityProvider);
  final onSessionError = ref.read(_sessionErrorHandlerProvider);
  return BalnanaApi(
    dio,
    // A session ended elsewhere, such as by a password change on another
    // device, ends here too, so the app stops showing it as signed in.
    onSignInRequired: () => onSessionError(who),
  );
});
