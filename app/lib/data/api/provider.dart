import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/server.dart';
import '../../core/session.dart';
import '../providers.dart';
import 'balnana_api.dart';

/// The API of the chosen server, or null when none is set.
final balnanaApiProvider = Provider<BalnanaApi?>((ref) {
  final dio = ref.watch(apiProvider);
  if (dio == null) return null;
  final who = ref.watch(identityProvider);
  return BalnanaApi(
    dio,
    // A session ended elsewhere, such as by a password change on another
    // device, ends here too, so the app stops showing it as signed in.
    onSignInRequired: () => scheduleMicrotask(() {
      if (ref.mounted) {
        ref.read(sessionProvider.notifier).lost(who, signedIn: ref.container.read(signedInProvider));
      }
    }),
  );
});
