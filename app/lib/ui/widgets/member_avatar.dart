import 'package:material_ui/material_ui.dart';

import '../../data/models.dart';
import '../colors.dart';

/// The color a member, group or other id is shown in: its own, or one picked
/// from the palette by [id] so it stays the same everywhere.
Color paletteColor(int? rgb, String id) {
  if (rgb != null) return BalnanaColors.fromRgb(rgb);
  var hash = 0;
  for (final unit in id.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return BalnanaColors.palette[hash % BalnanaColors.palette.length];
}

/// Black or white, whichever reads better on [background].
Color onColor(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark ? Colors.white : Colors.black;

/// Up to two letters from a name: "Alex Chen" is "AC", "alex" is "A".
String initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '?';
  String first(String w) => String.fromCharCodes(w.runes.take(1)).toUpperCase();
  return words.length == 1 ? first(words[0]) : first(words[0]) + first(words[1]);
}

/// A member's initials on their color.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.member, this.size = 40});

  final Member member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = paletteColor(member.color, member.id);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        initials(member.name),
        style: TextStyle(color: onColor(color), fontWeight: FontWeight.w700, fontSize: size * 0.38),
      ),
    );
  }
}

/// A group's emoji (or initial) in a circle of its color.
class GroupBadge extends StatelessWidget {
  const GroupBadge({super.key, required this.token, required this.name, this.emoji, this.color, this.size = 48});

  final String token;
  final String name;
  final String? emoji;
  final int? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final background = paletteColor(color, token);
    final fill = Color.alphaBlend(background.withValues(alpha: 0.28), Theme.of(context).colorScheme.surface);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: emoji == null ? background : fill, shape: BoxShape.circle),
      child: emoji == null
          ? Text(
              initials(name),
              style: TextStyle(color: onColor(background), fontWeight: FontWeight.w800, fontSize: size * 0.36),
            )
          : Text(emoji!, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}
