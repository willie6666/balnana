import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/prefs.dart';
import 'core/push.dart';
import 'core/settings.dart';
import 'ui/smooth_wheel.dart';

Future<void> main(List<String> args) async {
  // Started by a push message while the app is closed: no screen to show.
  if (args.contains('--unifiedpush-bg')) return receivePushInBackground();
  // Clean URLs (`/g/<token>`), served by the server's single-page fallback.
  usePathUrlStrategy();
  // WidgetsFlutterBinding plus eased mouse-wheel scrolling in every scroll view.
  SmoothWheelBinding();
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Plus Jakarta Sans'], ofl);
  });
  // The web build draws on a canvas; without this, screen readers, browser
  // find and automated tests see an empty page until someone turns on
  // accessibility by hand.
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
  final prefs = await SharedPreferences.getInstance();
  final launched = await launchedFromNotification();
  // Also for a choice made before the splash screen followed it.
  unawaited(wallpaperSplash(SettingsNotifier.dynamicColorOn(prefs)));

  runApp(
    ProviderScope(
      // Requests are retried by the user, not silently in the background.
      retry: (retryCount, error) => null,
      overrides: [prefsProvider.overrideWithValue(prefs), launchTargetProvider.overrideWithValue(launched)],
      child: const BalnanaApp(),
    ),
  );
}
