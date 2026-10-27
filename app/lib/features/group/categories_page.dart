import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/categories.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/colors.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/form_page.dart';
import '../../ui/widgets/grouped_list.dart';
import '../../ui/widgets/page.dart';
import 'group_page.dart';

/// The categories a group's expenses can have: its own, which it can change,
/// and the built-in ones, which it can hide.
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watchCurrent(groupProvider(token));
    final group = async.value;
    if (group == null) {
      return BPage(
        title: l10n.categoriesTitle,
        fillRemaining: true,
        children: [
          if (async.hasError && !async.isLoading)
            EmptyState(
              icon: Icons.cloud_off_outlined,
              title: l10n.groupsUnreachableTitle,
              body: errorMessage(l10n, async.error!),
              action: FilledButton.tonal(
                onPressed: () => ref.invalidate(groupProvider(token)),
                child: Text(l10n.commonRetry),
              ),
            )
          else
            const CircularProgressIndicator(),
        ],
      );
    }
    return GroupTheme(group: group, child: _Categories(group: group));
  }
}

class _Categories extends ConsumerWidget {
  const _Categories({required this.group});

  final Group group;

  Future<void> _setHidden(BuildContext context, WidgetRef ref, GroupCategory c, bool hidden) async {
    try {
      await groupApiOf(ref, group.token).updateCategory(c.id, hidden: hidden);
      refreshGroup(ref, group.token);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(context.l10n, e))));
      }
    }
  }

  void _edit(BuildContext context, [GroupCategory? category]) => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _CategorySheet(group: group, category: category),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final all = group.allCategories;
    final own = [for (final c in all) if (!c.builtIn) c];
    final builtIn = [for (final c in all) if (c.builtIn) c];
    return BPage(
      title: l10n.categoriesTitle,
      children: [
        GroupedList(
          title: l10n.categoriesOwn,
          children: [
            if (own.isEmpty)
              ListTile(
                title: Text(l10n.categoriesOwnEmpty, style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
            for (final c in own)
              ListTile(
                leading: CategoryBubble(category: c),
                title: Text(c.label(l10n)),
                trailing: Switch(
                  value: !c.hidden,
                  onChanged: (shown) => _setHidden(context, ref, c, !shown),
                ),
                onTap: () => _edit(context, c),
              ),
            GroupedTile(icon: Icons.add, title: l10n.categoryAdd, onTap: () => _edit(context)),
          ],
        ),
        GroupedList(
          title: l10n.categoriesBuiltIn,
          children: [
            for (final c in builtIn)
              SwitchListTile(
                secondary: CategoryBubble(category: c),
                title: Text(c.label(l10n)),
                value: !c.hidden,
                onChanged: (shown) => _setHidden(context, ref, c, !shown),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: BSpace.s16),
          child: Text(
            l10n.categoriesBuiltInHelp,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

/// A category's emoji in a soft circle of its color.
class CategoryBubble extends StatelessWidget {
  const CategoryBubble({super.key, required this.category, this.size = 40});

  final GroupCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.alphaBlend(category.color.withValues(alpha: 0.25), scheme.surface),
        shape: BoxShape.circle,
      ),
      child: Text(category.emoji, style: TextStyle(fontSize: size * 0.48)),
    );
  }
}

/// Adds a category of the group's own, or changes or deletes one.
class _CategorySheet extends ConsumerStatefulWidget {
  const _CategorySheet({required this.group, this.category});

  final Group group;

  /// Null to add one.
  final GroupCategory? category;

  @override
  ConsumerState<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends ConsumerState<_CategorySheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.category?.name ?? '');
  late final _emoji = TextEditingController(text: widget.category?.emoji ?? '');
  late Color _color = widget.category?.color ?? BalnanaColors.palette.first;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _emoji.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function(GroupApi api) action) async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await action(groupApiOf(ref, widget.group.token));
      refreshGroup(ref, widget.group.token);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      final message = e.code == 'duplicate_name' ? l10n.errorDuplicateCategory : errorMessage(l10n, e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final name = _name.text.trim(), emoji = _emoji.text.trim(), color = _color.toARGB32() & 0xFFFFFF;
    final c = widget.category;
    await _run(
      (api) => c == null
          ? api.addCategory(name: name, emoji: emoji, color: color)
          : api.updateCategory(c.id, name: name, emoji: emoji, color: color),
    );
  }

  Future<void> _delete(GroupCategory c) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.categoryDeleteTitle(c.label(l10n))),
        content: Text(l10n.categoryDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.categoryDeleteAction)),
        ],
      ),
    );
    if (ok ?? false) await _run((api) => api.deleteCategory(c.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = widget.category;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(BSpace.s16, 0, BSpace.s16, BSpace.s16),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  c == null ? l10n.categoryAdd : l10n.categoryEdit,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: BSpace.s16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 72,
                      child: TextFormField(
                        controller: _emoji,
                        textAlign: TextAlign.center,
                        inputFormatters: [LengthLimitingTextInputFormatter(16)],
                        decoration: InputDecoration(hintText: l10n.categoryEmojiHint),
                        validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
                      ),
                    ),
                    const SizedBox(width: BSpace.s12),
                    Expanded(
                      child: TextFormField(
                        controller: _name,
                        autofocus: c == null,
                        textCapitalization: TextCapitalization.sentences,
                        inputFormatters: [LengthLimitingTextInputFormatter(100)],
                        decoration: InputDecoration(labelText: l10n.categoryName),
                        validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
                      ),
                    ),
                  ],
                ),
                FormSection(l10n.groupColor),
                ColorPicker(
                  colors: BalnanaColors.palette,
                  selected: _color,
                  onSelected: (c) => setState(() => _color = c),
                ),
                const SizedBox(height: BSpace.s24),
                FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.commonSave)),
                if (c != null) ...[
                  const SizedBox(height: BSpace.s8),
                  TextButton.icon(
                    onPressed: _busy ? null : () => _delete(c),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.categoryDelete),
                    style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
