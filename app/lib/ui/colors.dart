import 'package:material_ui/material_ui.dart';

/// The brand color: ripe banana.
const brandSeed = Color(0xFFE8A800);

/// Colors the Material scheme has no role for. Widgets read them with
/// `context.bColors`, never as literals.
@immutable
class BalnanaColors extends ThemeExtension<BalnanaColors> {
  const BalnanaColors({
    required this.owed,
    required this.onOwed,
    required this.owedContainer,
    required this.onOwedContainer,
    required this.owe,
    required this.onOwe,
    required this.oweContainer,
    required this.onOweContainer,
    required this.settled,
  });

  /// Money coming to the viewer: they are owed, or a balance is positive.
  final Color owed;
  final Color onOwed;
  final Color owedContainer;
  final Color onOwedContainer;

  /// Money the viewer owes, or a negative balance.
  final Color owe;
  final Color onOwe;
  final Color oweContainer;
  final Color onOweContainer;

  /// A zero balance.
  final Color settled;

  static const light = BalnanaColors(
    owed: Color(0xFF1E7A46),
    onOwed: Color(0xFFFFFFFF),
    owedContainer: Color(0xFFB4F1C8),
    onOwedContainer: Color(0xFF00210F),
    owe: Color(0xFFB42318),
    onOwe: Color(0xFFFFFFFF),
    oweContainer: Color(0xFFFFDAD4),
    onOweContainer: Color(0xFF410001),
    settled: Color(0xFF6B6559),
  );

  static const dark = BalnanaColors(
    owed: Color(0xFF7FD8A0),
    onOwed: Color(0xFF00391C),
    owedContainer: Color(0xFF00522B),
    onOwedContainer: Color(0xFFB4F1C8),
    owe: Color(0xFFFFB4A8),
    onOwe: Color(0xFF690003),
    oweContainer: Color(0xFF930F0A),
    onOweContainer: Color(0xFFFFDAD4),
    settled: Color(0xFFB8B0A2),
  );

  /// Colors a group, person or category can pick. The server stores the RGB
  /// value, so this list may grow but entries keep their value.
  static const palette = <Color>[
    Color(0xFFF07C2E),
    Color(0xFF3C9D6B),
    Color(0xFF3E8EDE),
    Color(0xFF1F9E9A),
    Color(0xFF8E5BC8),
    Color(0xFF8A5A3C),
    Color(0xFFE8A800),
    Color(0xFFD2486A),
    Color(0xFFB57EDC),
    Color(0xFF2E7D5B),
    Color(0xFFC2415B),
    Color(0xFF5D6B82),
  ];

  /// A color from the 0xRRGGBB integer the server stores.
  static Color fromRgb(int rgb) => Color(0xFF000000 | (rgb & 0xFFFFFF));

  @override
  BalnanaColors copyWith({
    Color? owed,
    Color? onOwed,
    Color? owedContainer,
    Color? onOwedContainer,
    Color? owe,
    Color? onOwe,
    Color? oweContainer,
    Color? onOweContainer,
    Color? settled,
  }) {
    return BalnanaColors(
      owed: owed ?? this.owed,
      onOwed: onOwed ?? this.onOwed,
      owedContainer: owedContainer ?? this.owedContainer,
      onOwedContainer: onOwedContainer ?? this.onOwedContainer,
      owe: owe ?? this.owe,
      onOwe: onOwe ?? this.onOwe,
      oweContainer: oweContainer ?? this.oweContainer,
      onOweContainer: onOweContainer ?? this.onOweContainer,
      settled: settled ?? this.settled,
    );
  }

  @override
  BalnanaColors lerp(BalnanaColors? other, double t) {
    if (other == null) return this;
    return BalnanaColors(
      owed: Color.lerp(owed, other.owed, t)!,
      onOwed: Color.lerp(onOwed, other.onOwed, t)!,
      owedContainer: Color.lerp(owedContainer, other.owedContainer, t)!,
      onOwedContainer: Color.lerp(onOwedContainer, other.onOwedContainer, t)!,
      owe: Color.lerp(owe, other.owe, t)!,
      onOwe: Color.lerp(onOwe, other.onOwe, t)!,
      oweContainer: Color.lerp(oweContainer, other.oweContainer, t)!,
      onOweContainer: Color.lerp(onOweContainer, other.onOweContainer, t)!,
      settled: Color.lerp(settled, other.settled, t)!,
    );
  }
}

extension BalnanaColorsX on BuildContext {
  BalnanaColors get bColors => Theme.of(this).extension<BalnanaColors>()!;
}
