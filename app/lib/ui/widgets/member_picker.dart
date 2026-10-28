import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../data/models.dart';
import '../tokens.dart';
import 'member_avatar.dart';

/// Up to this many people, every list shows everyone at once. Larger groups
/// get search, pickers and "Show all" in their place.
const crowdSize = 12;

/// Whether [count] people are too many to show all at once.
bool isCrowd(int count) => count > crowdSize;

/// Whether [name] holds what was typed in a search, ignoring case.
bool nameMatches(String name, String query) {
  final q = query.trim().toLowerCase();
  return q.isEmpty || name.toLowerCase().contains(q);
}

/// A search field for a list of people.
class MemberSearchField extends StatelessWidget {
  const MemberSearchField({super.key, required this.controller, required this.onChanged, this.onSubmitted});

  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SearchBar(
      controller: controller,
      hintText: l10n.crowdSearch,
      leading: const Icon(Icons.search),
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surfaceContainerHigh),
      onChanged: (_) => onChanged(),
      onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
      trailing: [
        if (controller.text.isNotEmpty)
          IconButton(
            tooltip: l10n.searchClear,
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.clear();
              onChanged();
            },
          ),
      ],
    );
  }
}

/// A searchable sheet to pick one of [members]. Returns the pick, with a null
/// id when [anyone] (shown first when set) was picked, or null when closed.
Future<({String? id})?> pickMember(
  BuildContext context, {
  required String title,
  required List<Member> members,
  String? selected,
  String? anyone,
}) => showModalBottomSheet<({String? id})>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) => _MemberPicker(title: title, members: members, selected: {?selected}, anyone: anyone),
);

/// A searchable sheet to tick any of [members]. Returns who is ticked when
/// done, or null when closed.
Future<Set<String>?> pickMembers(
  BuildContext context, {
  required String title,
  required List<Member> members,
  required Set<String> selected,
}) => showModalBottomSheet<Set<String>>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) => _MemberPicker(title: title, members: members, selected: selected, multiple: true),
);

class _MemberPicker extends StatefulWidget {
  const _MemberPicker({
    required this.title,
    required this.members,
    required this.selected,
    this.anyone,
    this.multiple = false,
  });

  final String title;
  final List<Member> members;
  final Set<String> selected;
  final String? anyone;
  final bool multiple;

  @override
  State<_MemberPicker> createState() => _MemberPickerState();
}

class _MemberPickerState extends State<_MemberPicker> {
  final _query = TextEditingController();
  late final _ticked = {...widget.selected};

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _tap(Member m) {
    if (!widget.multiple) {
      Navigator.of(context).pop((id: m.id));
      return;
    }
    setState(() => _ticked.contains(m.id) ? _ticked.remove(m.id) : _ticked.add(m.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final shown = [
      for (final m in widget.members)
        if (nameMatches(m.name, _query.text)) m,
    ];
    final anyone = widget.anyone != null && _query.text.trim().isEmpty ? widget.anyone : null;

    Widget tile(Member m) {
      final on = widget.multiple ? _ticked.contains(m.id) : widget.selected.contains(m.id);
      return ListTile(
        selected: !widget.multiple && on,
        leading: MemberAvatar(member: m),
        title: Text(m.name, style: text.titleMedium, overflow: TextOverflow.ellipsis),
        trailing: widget.multiple
            ? Checkbox(value: on, onChanged: (_) => _tap(m))
            : (on ? const Icon(Icons.check) : null),
        onTap: () => _tap(m),
      );
    }

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BSpace.s16),
              child: Text(widget.title, style: text.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s12, BSpace.s16, BSpace.s8),
              child: MemberSearchField(
                controller: _query,
                onChanged: () => setState(() {}),
                onSubmitted: shown.length == 1 && !widget.multiple ? () => _tap(shown.single) : null,
              ),
            ),
            if (widget.multiple)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: BSpace.s16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.crowdChosen(_ticked.length, widget.members.length),
                        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    // Both act on the people the search shows.
                    TextButton(
                      onPressed: () => setState(() => _ticked.addAll(shown.map((m) => m.id))),
                      child: Text(l10n.crowdAll),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _ticked.removeAll(shown.map((m) => m.id))),
                      child: Text(l10n.crowdNone),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  if (anyone != null)
                    SliverToBoxAdapter(
                      child: ListTile(
                        selected: widget.selected.isEmpty,
                        leading: CircleAvatar(
                          backgroundColor: scheme.secondaryContainer,
                          foregroundColor: scheme.onSecondaryContainer,
                          child: const Icon(Icons.groups_outlined),
                        ),
                        title: Text(anyone, style: text.titleMedium),
                        trailing: widget.selected.isEmpty ? const Icon(Icons.check) : null,
                        onTap: () => Navigator.of(context).pop((id: null)),
                      ),
                    ),
                  SliverList.builder(itemCount: shown.length, itemBuilder: (context, i) => tile(shown[i])),
                  if (shown.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(BSpace.s24),
                        child: Text(l10n.crowdNoMatch, textAlign: TextAlign.center, style: text.bodyMedium),
                      ),
                    ),
                ],
              ),
            ),
            if (widget.multiple)
              Padding(
                padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s8, BSpace.s16, BSpace.s16),
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_ticked),
                  child: Text(l10n.commonDone),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The first [limit] of [children], then a button that shows the rest.
class ShowMore extends StatefulWidget {
  const ShowMore({super.key, required this.children, this.limit = crowdSize});

  final List<Widget> children;
  final int limit;

  @override
  State<ShowMore> createState() => _ShowMoreState();
}

class _ShowMoreState extends State<ShowMore> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hidden = widget.children.length - widget.limit;
    if (hidden <= 0) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.children);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...(_open ? widget.children : widget.children.take(widget.limit)),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => setState(() => _open = !_open),
            icon: Icon(_open ? Icons.expand_less : Icons.expand_more),
            label: Text(_open ? l10n.crowdShowFewer : l10n.crowdShowMore(hidden)),
          ),
        ),
      ],
    );
  }
}
