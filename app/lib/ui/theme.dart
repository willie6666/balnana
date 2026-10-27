import 'package:material_ui/material_ui.dart';

import 'colors.dart';
import 'tokens.dart';

const _font = 'PlusJakartaSans';

/// The brand scheme. Fidelity keeps the seed's yellow recognizable in the
/// primary container instead of washing it out.
ColorScheme brandScheme(Brightness brightness) => ColorScheme.fromSeed(
  seedColor: brandSeed,
  brightness: brightness,
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
);

ThemeData buildTheme(ColorScheme scheme, {bool pureBlack = false}) {
  final dark = scheme.brightness == Brightness.dark;
  if (dark && pureBlack) {
    scheme = scheme.copyWith(
      surface: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: scheme.surfaceContainerLowest,
      surfaceContainer: scheme.surfaceContainerLow,
    );
  }

  final base = ThemeData(colorScheme: scheme, useMaterial3: true, fontFamily: _font);
  final text = _textTheme(base.textTheme);
  const stadium = StadiumBorder();
  const buttonSize = Size(64, 48);
  const buttonPadding = EdgeInsets.symmetric(horizontal: BSpace.s24);

  return base.copyWith(
    textTheme: text,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [dark ? BalnanaColors.dark : BalnanaColors.light],
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: buttonSize,
        padding: buttonPadding,
        shape: stadium,
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: buttonSize,
        padding: buttonPadding,
        shape: stadium,
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: stadium,
        textStyle: text.labelLarge,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.md))),
    ),
    // Filled fields keep their label inside the field; focus shows as an underline.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: const UnderlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(BShape.md)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(BShape.md)),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(BShape.md)),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainer,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(BShape.rLg)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.xl))),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      selectedLabelTextStyle: text.labelMedium?.copyWith(color: scheme.onSurface),
      unselectedLabelTextStyle: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.md))),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: PredictiveBackPageTransitionsBuilder()},
    ),
  );
}

/// Plus Jakarta Sans on the M3 scale: heavier, tighter headings; labels a step
/// bolder so buttons read clearly.
TextTheme _textTheme(TextTheme t) {
  TextStyle? w(TextStyle? s, FontWeight weight, [double? spacing]) =>
      s?.copyWith(fontWeight: weight, letterSpacing: spacing);
  return t.copyWith(
    displayLarge: w(t.displayLarge, FontWeight.w800, -1.5),
    displayMedium: w(t.displayMedium, FontWeight.w800, -1),
    displaySmall: w(t.displaySmall, FontWeight.w700, -0.5),
    headlineLarge: w(t.headlineLarge, FontWeight.w700, -0.5),
    headlineMedium: w(t.headlineMedium, FontWeight.w700, -0.25),
    headlineSmall: w(t.headlineSmall, FontWeight.w700),
    titleLarge: w(t.titleLarge, FontWeight.w700),
    titleMedium: w(t.titleMedium, FontWeight.w600),
    titleSmall: w(t.titleSmall, FontWeight.w600),
    labelLarge: w(t.labelLarge, FontWeight.w700),
    labelMedium: w(t.labelMedium, FontWeight.w600),
    labelSmall: w(t.labelSmall, FontWeight.w600),
  );
}

/// Money is set in tabular figures so columns of amounts line up.
extension MoneyTextTheme on TextTheme {
  /// The large balance at the top of a group.
  TextStyle get moneyHero => displayMedium!.copyWith(
    fontWeight: FontWeight.w800,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// A single amount that heads a sheet.
  TextStyle get moneyLarge => displaySmall!.copyWith(
    fontWeight: FontWeight.w800,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Amounts in list rows.
  TextStyle get moneyRow =>
      titleMedium!.copyWith(fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()]);

  /// Amounts in dense rows and supporting lines.
  TextStyle get moneySmall =>
      titleSmall!.copyWith(fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()]);
}

/// Whether group pages wear the app's wallpaper colors instead of their own.
class WallpaperColors extends InheritedWidget {
  const WallpaperColors({super.key, required this.on, required super.child});

  final bool on;

  static bool of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<WallpaperColors>()?.on ?? false;

  @override
  bool updateShouldNotify(WallpaperColors old) => old.on != on;
}
