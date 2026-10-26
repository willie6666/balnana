import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/prefs.dart';

Future<void> main() async {
  // Clean URLs (`/g/<token>`), served by the server's single-page fallback.
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Plus Jakarta Sans'], ofl);
  });
  // The web build draws on a canvas; without this, screen readers, browser
  // find and automated tests see an empty page until someone turns on
  // accessibility by hand.
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // Requests are retried by the user, not silently in the background.
      retry: (retryCount, error) => null,
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const BalnanaApp(),
    ),
  );
}
