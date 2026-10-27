import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/l10n.dart';
import 'core/router.dart';
import 'core/settings.dart';
import 'ui/theme.dart';
import 'ui/widgets/offline_bar.dart';
import 'ui/widgets/push_handler.dart';

class BalnanaApp extends ConsumerWidget {
  const BalnanaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        var light = brandScheme(Brightness.light), dark = brandScheme(Brightness.dark);
        final wallpaper = settings.dynamicColor && lightDynamic != null && darkDynamic != null;
        if (wallpaper) (light, dark) = (lightDynamic, darkDynamic);
        return MaterialApp.router(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(light),
          darkTheme: buildTheme(dark, pureBlack: settings.pureBlack),
          themeMode: settings.themeMode,
          locale: settings.locale,
          // Material's own delegates cover the widgets and Cupertino strings too.
          localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) => WallpaperColors(
            on: wallpaper && settings.wallpaperGroups,
            child: PushHandler(child: OfflineBar(child: child ?? const SizedBox())),
          ),
        );
      },
    );
  }
}
