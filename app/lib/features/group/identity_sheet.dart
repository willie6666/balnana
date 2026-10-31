import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/known_groups.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/member_picker.dart';

/// "Who are you?": lets this device pick the member it acts as in [group],
/// or join as someone new. The choice stays on this device.
Future<void> showIdentitySheet(BuildContext context, Group group) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => _IdentitySheet(group: group),
);

class _IdentitySheet extends ConsumerStatefulWidget {
  const _IdentitySheet({required this.group});

  final Group group;

  @override
  ConsumerState<_IdentitySheet> createState() => _IdentitySheetState();
}

class _IdentitySheetState extends ConsumerState<_IdentitySheet> {
  bool _busy = false;
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _pick(String memberId) {
    _remember(ProviderScope.containerOf(context, listen: false), memberId);
    Navigator.of(context).pop();
  }

  void _remember(ProviderContainer container, String memberId) {
    container.read(knownGroupsProvider.notifier).setMember(widget.group.token, memberId);
    container.invalidate(summariesProvider);
  }

  Future<void> _join() async {
    final l10n = context.l10n;
    final name = await askForName(context, title: l10n.identityNewTitle, action: l10n.identityJoin);
    if (name == null || !mounted) return;
    setState(() => _busy = true);
    // Swiping the sheet away takes its ref along; the member was still added.
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      final member = await groupApiOf(ref, widget.group.token).addMember(name, digits: widget.group.minorDigits);
      refreshGroupIn(container, widget.group.token);
      _remember(container, member.id);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final current = ref.watch(knownGroupsProvider.select((list) {
      for (final g in list) {
        if (g.token == widget.group.token) return g.memberId;
      }
      return null;
    }));
    final members = widget.group.activeMembers;
    final crowd = isCrowd(members.length);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(
            BSpace.s16,
            0,
            BSpace.s16,
            BSpace.s16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: [
            Text(l10n.identityTitle, style: text.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: BSpace.s8),
            Text(
              l10n.identityBody,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: BSpace.s16),
            if (crowd) ...[
              MemberSearchField(controller: _query, onChanged: () => setState(() {})),
              const SizedBox(height: BSpace.s8),
            ],
            for (final m in members)
              if (!crowd || nameMatches(m.name, _query.text))
                ListTile(
                  enabled: !_busy,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.md))),
                  selected: m.id == current,
                  leading: MemberAvatar(member: m),
                  title: Text(m.name, style: text.titleMedium),
                  trailing: m.id == current ? const Icon(Icons.check) : null,
                  onTap: () => _pick(m.id),
                ),
            ListTile(
              enabled: !_busy,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.md))),
              leading: CircleAvatar(
                backgroundColor: scheme.secondaryContainer,
                foregroundColor: scheme.onSecondaryContainer,
                child: const Icon(Icons.person_add_alt),
              ),
              title: Text(l10n.identityNew, style: text.titleMedium),
              onTap: _join,
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks for a person's name; returns it trimmed, or null when cancelled.
Future<String?> askForName(BuildContext context, {required String title, required String action, String? initial}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _NameDialog(title: title, action: action, initial: initial),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.action, this.initial});

  final String title;
  final String action;
  final String? initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        inputFormatters: [LengthLimitingTextInputFormatter(100)],
        decoration: InputDecoration(labelText: l10n.memberName),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _submit, child: Text(widget.action)),
      ],
    );
  }
}
