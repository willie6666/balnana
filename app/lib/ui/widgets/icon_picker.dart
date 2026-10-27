import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../tokens.dart';

/// What the icons are grouped under while nothing is searched for.
enum _Section { travel, food, activities, home, people, nature, objects, symbols }

/// The icons to choose from: emoji, each with English words to find it by.
/// Any other emoji can be typed into the search field.
const _icons = <_Section, List<(String, String)>>{
  _Section.travel: [
    ('✈️', 'plane flight travel trip airport'),
    ('🏝️', 'island beach vacation holiday'),
    ('🏖️', 'beach sand sea summer'),
    ('🗺️', 'map trip travel'),
    ('🧳', 'luggage suitcase travel bag'),
    ('🏨', 'hotel lodging stay accommodation'),
    ('⛺', 'tent camping camp'),
    ('🏕️', 'campsite camping outdoors'),
    ('🚗', 'car drive road trip'),
    ('🚕', 'taxi cab ride'),
    ('🚌', 'bus coach transport'),
    ('🚆', 'train rail transport'),
    ('🚇', 'metro subway underground transport'),
    ('🚲', 'bike bicycle cycle'),
    ('🛵', 'scooter motorbike'),
    ('⛽', 'fuel gas petrol'),
    ('🅿️', 'parking park'),
    ('🚢', 'ship cruise boat'),
    ('🗼', 'tower tokyo japan'),
    ('🗻', 'fuji mountain japan'),
    ('🗽', 'statue liberty new york usa'),
    ('🏰', 'castle'),
    ('⛰️', 'mountain hike'),
    ('🏔️', 'mountain snow ski'),
    ('🏙️', 'city town skyline'),
    ('🎡', 'ferris wheel fair amusement'),
    ('🎢', 'roller coaster theme park'),
    ('🌍', 'world globe earth international'),
    ('🧭', 'compass explore'),
    ('📍', 'pin location place'),
    ('🎫', 'ticket pass'),
    ('🛂', 'passport visa border'),
  ],
  _Section.food: [
    ('🍔', 'burger hamburger food fast'),
    ('🍕', 'pizza food'),
    ('🍜', 'noodles ramen soup'),
    ('🍣', 'sushi japanese'),
    ('🍱', 'bento lunch box'),
    ('🍚', 'rice meal'),
    ('🍛', 'curry rice'),
    ('🍝', 'pasta spaghetti italian'),
    ('🥗', 'salad healthy'),
    ('🌮', 'taco mexican'),
    ('🥟', 'dumpling'),
    ('🍲', 'hot pot stew soup'),
    ('🍳', 'cooking breakfast egg'),
    ('🥐', 'croissant bakery breakfast'),
    ('🍞', 'bread bakery'),
    ('🥩', 'meat steak barbecue bbq'),
    ('🍗', 'chicken'),
    ('🍤', 'shrimp seafood tempura'),
    ('🦞', 'lobster seafood'),
    ('🍦', 'ice cream dessert'),
    ('🍰', 'cake dessert'),
    ('🎂', 'birthday cake party'),
    ('🍩', 'donut doughnut'),
    ('🍪', 'cookie snack'),
    ('🍫', 'chocolate candy snack'),
    ('🍿', 'popcorn movie snack'),
    ('🍎', 'apple fruit'),
    ('🍓', 'strawberry fruit'),
    ('🍌', 'banana fruit'),
    ('🥑', 'avocado'),
    ('🥕', 'carrot vegetable'),
    ('🛒', 'groceries shopping cart supermarket'),
    ('🧺', 'basket picnic laundry'),
    ('☕', 'coffee cafe'),
    ('🍵', 'tea'),
    ('🧋', 'bubble tea boba milk'),
    ('🥤', 'drink soda soft'),
    ('🧃', 'juice'),
    ('🍺', 'beer bar drink'),
    ('🍻', 'cheers beers drinks'),
    ('🍷', 'wine'),
    ('🍸', 'cocktail bar'),
    ('🥂', 'champagne celebrate toast'),
    ('🍶', 'sake'),
    ('🍽️', 'restaurant dinner meal eat food'),
    ('🥢', 'chopsticks asian'),
  ],
  _Section.activities: [
    ('🎉', 'party celebration'),
    ('🎁', 'gift present'),
    ('🎈', 'balloon party'),
    ('🎄', 'christmas xmas'),
    ('🎃', 'halloween pumpkin'),
    ('🎮', 'games gaming video'),
    ('🎲', 'board game dice'),
    ('🃏', 'cards poker'),
    ('🎳', 'bowling'),
    ('🎯', 'darts target goal'),
    ('🎤', 'karaoke sing microphone'),
    ('🎵', 'music song'),
    ('🎸', 'guitar music band'),
    ('🎹', 'piano keyboard music'),
    ('🎬', 'movie film cinema'),
    ('🎭', 'theater show'),
    ('🎨', 'art paint'),
    ('📸', 'photo camera'),
    ('🎟️', 'tickets event concert entertainment'),
    ('🎪', 'circus festival'),
    ('⚽', 'football soccer'),
    ('🏀', 'basketball'),
    ('⚾', 'baseball'),
    ('🎾', 'tennis'),
    ('🏸', 'badminton'),
    ('🏐', 'volleyball'),
    ('🏓', 'ping pong table tennis'),
    ('⛳', 'golf'),
    ('🏊', 'swimming swim pool'),
    ('🏄', 'surfing surf'),
    ('⛷️', 'ski skiing'),
    ('🏂', 'snowboard'),
    ('🧗', 'climbing bouldering'),
    ('🚴', 'cycling'),
    ('🏃', 'running run'),
    ('🥾', 'hiking boots'),
    ('🎣', 'fishing'),
    ('🏋️', 'gym workout fitness'),
    ('🧘', 'yoga meditation'),
    ('🏆', 'trophy win prize'),
    ('🎓', 'graduation school university'),
  ],
  _Section.home: [
    ('🏠', 'home house rent'),
    ('🏡', 'house garden'),
    ('🏢', 'office building work'),
    ('🛋️', 'furniture couch sofa living'),
    ('🛏️', 'bed bedroom'),
    ('🛁', 'bath bathroom'),
    ('🧹', 'cleaning broom chores'),
    ('🧼', 'soap cleaning'),
    ('🧻', 'toilet paper supplies'),
    ('🔑', 'keys rent deposit'),
    ('💡', 'electricity light utilities bills'),
    ('🔥', 'gas heating fire'),
    ('💧', 'water utilities'),
    ('📶', 'wifi internet'),
    ('📱', 'phone mobile'),
    ('💻', 'laptop computer'),
    ('📺', 'tv television streaming'),
    ('🔌', 'power plug electric'),
    ('🧾', 'receipt bill invoice'),
    ('🛠️', 'repair tools maintenance'),
    ('🪴', 'plant pot'),
    ('🧸', 'toys kids'),
    ('🍼', 'baby bottle'),
    ('🗑️', 'trash garbage bin'),
    ('📦', 'package delivery box moving other'),
    ('🚚', 'moving truck delivery'),
  ],
  _Section.people: [
    ('👥', 'group people friends'),
    ('👫', 'couple friends'),
    ('👪', 'family'),
    ('💑', 'couple love date'),
    ('💍', 'wedding ring engagement'),
    ('👶', 'baby child'),
    ('🤝', 'deal handshake'),
    ('🙌', 'hooray celebrate'),
    ('🙏', 'thanks please'),
    ('💪', 'strong muscle'),
    ('👍', 'ok thumbs up'),
    ('👋', 'hello wave'),
    ('😀', 'smile happy'),
    ('😎', 'cool sunglasses'),
    ('🥳', 'party celebration'),
    ('🤗', 'hug'),
    ('❤️', 'love heart'),
    ('💖', 'heart sparkle'),
  ],
  _Section.nature: [
    ('🐶', 'dog pet puppy'),
    ('🐱', 'cat pet kitten'),
    ('🐰', 'rabbit bunny'),
    ('🐻', 'bear'),
    ('🐼', 'panda'),
    ('🦊', 'fox'),
    ('🐯', 'tiger'),
    ('🦁', 'lion'),
    ('🐸', 'frog'),
    ('🐧', 'penguin'),
    ('🐦', 'bird'),
    ('🐟', 'fish'),
    ('🐢', 'turtle'),
    ('🦋', 'butterfly'),
    ('🐝', 'bee'),
    ('🌸', 'flower blossom spring sakura'),
    ('🌻', 'sunflower'),
    ('🌹', 'rose'),
    ('🌲', 'tree forest'),
    ('🌴', 'palm tree tropical'),
    ('🌵', 'cactus desert'),
    ('🍀', 'clover luck'),
    ('🍁', 'autumn fall leaf maple'),
    ('☀️', 'sun sunny summer'),
    ('🌙', 'moon night'),
    ('⭐', 'star'),
    ('🌈', 'rainbow'),
    ('❄️', 'snow winter cold'),
    ('☔', 'rain umbrella'),
    ('🌊', 'wave ocean sea'),
  ],
  _Section.objects: [
    ('💰', 'money bag cash savings'),
    ('💵', 'cash dollar money'),
    ('💳', 'card credit payment'),
    ('🏦', 'bank'),
    ('🪙', 'coin'),
    ('📈', 'investment stocks chart'),
    ('🛍️', 'shopping bags'),
    ('👕', 'clothes shirt clothing'),
    ('👗', 'dress fashion'),
    ('👟', 'shoes sneakers'),
    ('👜', 'handbag purse'),
    ('🕶️', 'sunglasses'),
    ('💄', 'makeup cosmetics beauty'),
    ('💇', 'haircut hair salon'),
    ('💊', 'medicine pharmacy health'),
    ('🏥', 'hospital health doctor'),
    ('🦷', 'dentist teeth'),
    ('🩺', 'doctor checkup'),
    ('📚', 'books study'),
    ('✏️', 'stationery pencil school'),
    ('📝', 'notes memo'),
    ('💼', 'work business briefcase'),
    ('✉️', 'mail post letter'),
    ('🎒', 'backpack school'),
    ('🧴', 'lotion toiletries'),
    ('⌚', 'watch'),
    ('🎧', 'headphones audio'),
    ('📷', 'camera'),
  ],
  _Section.symbols: [
    ('🏷️', 'tag label category'),
    ('📌', 'pin pinned'),
    ('🔖', 'bookmark'),
    ('🔔', 'bell notification'),
    ('✅', 'done check'),
    ('❗', 'important'),
    ('❓', 'question unknown misc'),
    ('💯', 'hundred perfect'),
    ('♻️', 'recycle'),
    ('⚡', 'lightning energy'),
    ('🎗️', 'ribbon charity donation'),
    ('🔴', 'red circle'),
    ('🟠', 'orange circle'),
    ('🟡', 'yellow circle'),
    ('🟢', 'green circle'),
    ('🔵', 'blue circle'),
    ('🟣', 'purple circle'),
    ('⚫', 'black circle'),
    ('⚪', 'white circle'),
  ],
};

String _sectionName(AppLocalizations l10n, _Section section) => switch (section) {
  _Section.travel => l10n.iconSectionTravel,
  _Section.food => l10n.iconSectionFood,
  _Section.activities => l10n.iconSectionActivities,
  _Section.home => l10n.iconSectionHome,
  _Section.people => l10n.iconSectionPeople,
  _Section.nature => l10n.iconSectionNature,
  _Section.objects => l10n.iconSectionObjects,
  _Section.symbols => l10n.iconSectionSymbols,
};

/// Whether every word of [query] starts one of [words].
bool _matches(String words, List<String> query) {
  final all = words.split(' ');
  return query.every((q) => all.any((w) => w.startsWith(q)));
}

/// An icon for something called [name], when one of its words names one.
String? suggestIcon(String name) {
  final words = name.toLowerCase().split(RegExp(r'[^a-z]+')).where((w) => w.length > 2).toList();
  if (words.isEmpty) return null;
  for (final word in words) {
    for (final icons in _icons.values) {
      for (final (icon, keywords) in icons) {
        if (keywords.split(' ').contains(word)) return icon;
      }
    }
  }
  return null;
}

/// Asks for an icon. Returns the one chosen, an empty string for none when
/// [allowNone], or null when dismissed.
Future<String?> showIconPicker(BuildContext context, {required String current, bool allowNone = false}) =>
    showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _IconPicker(current: current, allowNone: allowNone),
    );

/// A group's or category's icon in a circle of [color]; tapping it opens
/// [showIconPicker].
class IconField extends StatelessWidget {
  const IconField({
    super.key,
    required this.icon,
    required this.color,
    required this.onChanged,
    this.allowNone = false,
  });

  /// Empty for none.
  final String icon;
  final Color color;
  final ValueChanged<String> onChanged;
  final bool allowNone;

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: context.l10n.iconChoose,
      value: icon,
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: iconBackground(color, scheme),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                final picked = await showIconPicker(context, current: icon, allowNone: allowNone);
                if (picked != null) onChanged(picked);
              },
              child: SizedBox.square(
                dimension: size,
                child: Center(
                  child: icon.isEmpty
                      ? Icon(Icons.add_reaction_outlined, color: scheme.onSurfaceVariant)
                      : Text(icon, style: const TextStyle(fontSize: 28)),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: -2,
            bottom: -2,
            child: IgnorePointer(
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.surfaceContainerLow, width: 2),
                ),
                child: Icon(Icons.edit, size: 12, color: scheme.onPrimaryContainer),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconPicker extends StatefulWidget {
  const _IconPicker({required this.current, required this.allowNone});

  final String current;
  final bool allowNone;

  @override
  State<_IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<_IconPicker> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _pick(String icon) => Navigator.of(context).pop(icon);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final typed = _query.text.trim();
    final words = typed.toLowerCase().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    // Text with no letters that isn't plain ASCII is taken as an emoji typed in, if the server takes it.
    final custom =
        typed.isNotEmpty &&
            typed.runes.length <= 16 &&
            !RegExp(r'^[\x00-\x7F]*$').hasMatch(typed) &&
            !RegExp(r'\p{L}', unicode: true).hasMatch(typed)
        ? typed
        : null;
    final sections = [
      for (final MapEntry(key: section, value: icons) in _icons.entries)
        (
          words.isEmpty ? _sectionName(l10n, section) : null,
          [
            for (final (icon, keywords) in icons)
              if (words.isEmpty || _matches(keywords, words)) icon,
          ],
        ),
    ].where((s) => s.$2.isNotEmpty).toList();

    Widget grid(List<String> icons) => SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 56),
      itemCount: icons.length,
      itemBuilder: (context, i) {
        final icon = icons[i];
        final selected = icon == widget.current;
        return Semantics(
          selected: selected,
          button: true,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Material(
              color: selected ? scheme.secondaryContainer : Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _pick(icon),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
              ),
            ),
          ),
        );
      },
    );

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BSpace.s16),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.iconChoose, style: text.titleLarge)),
                  if (widget.allowNone && widget.current.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _pick(''),
                      icon: const Icon(Icons.block),
                      label: Text(l10n.iconNone),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s12, BSpace.s16, BSpace.s8),
              child: SearchBar(
                controller: _query,
                hintText: l10n.iconSearchHint,
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  if (custom != null) _pick(custom);
                },
                trailing: [
                  if (_query.text.isNotEmpty)
                    IconButton(
                      tooltip: l10n.commonClear,
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(_query.clear),
                    ),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  if (custom != null)
                    SliverToBoxAdapter(
                      child: ListTile(
                        leading: Text(custom, style: const TextStyle(fontSize: 28)),
                        title: Text(l10n.iconUseTyped),
                        onTap: () => _pick(custom),
                      ),
                    ),
                  if (sections.isEmpty && custom == null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(BSpace.s24),
                        child: Text(
                          l10n.iconNoMatch,
                          textAlign: TextAlign.center,
                          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  for (final (title, icons) in sections) ...[
                    if (title != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s16, BSpace.s16, BSpace.s4),
                          child: Text(title, style: text.titleSmall?.copyWith(color: scheme.primary)),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: BSpace.s12),
                      sliver: grid(icons),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: BSpace.s16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The circle behind an icon: its color, softened over the surface.
Color iconBackground(Color color, ColorScheme scheme) =>
    Color.alphaBlend(color.withValues(alpha: 0.25), scheme.surface);
