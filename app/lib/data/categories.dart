import 'package:material_ui/material_ui.dart';

import '../core/l10n.dart';
import '../ui/colors.dart';

/// The built-in categories. Ids, emoji and colors match the server's seed
/// (server/migrations/00001_init.sql).
enum Category {
  food('🍔', 0xF07C2E),
  groceries('🛒', 0x3C9D6B),
  transport('🚌', 0x3E8EDE),
  travel('✈️', 0x1F9E9A),
  lodging('🏨', 0x8E5BC8),
  rent('🏠', 0x8A5A3C),
  utilities('💡', 0xE8A800),
  entertainment('🎟️', 0xD2486A),
  shopping('🛍️', 0xB57EDC),
  health('💊', 0x2E7D5B),
  gifts('🎁', 0xC2415B),
  other('📦', 0x5D6B82);

  const Category(this.emoji, this.rgb);

  final String emoji;
  final int rgb;

  String get id => name;
  Color get color => BalnanaColors.fromRgb(rgb);

  static Category? byId(String? id) => id == null ? null : values.asNameMap()[id];

  String label(AppLocalizations l10n) => switch (this) {
    food => l10n.categoryFood,
    groceries => l10n.categoryGroceries,
    transport => l10n.categoryTransport,
    travel => l10n.categoryTravel,
    lodging => l10n.categoryLodging,
    rent => l10n.categoryRent,
    utilities => l10n.categoryUtilities,
    entertainment => l10n.categoryEntertainment,
    shopping => l10n.categoryShopping,
    health => l10n.categoryHealth,
    gifts => l10n.categoryGifts,
    other => l10n.categoryOther,
  };
}
