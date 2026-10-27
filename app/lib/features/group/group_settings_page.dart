import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/api.dart';
import '../../data/home_group.dart';
import '../../data/known_groups.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/colors.dart';
import '../../ui/money.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/form_page.dart';
import '../../ui/widgets/grouped_list.dart';
import '../../ui/widgets/member_avatar.dart';
import '../../ui/widgets/page.dart';
import 'group_page.dart';
import 'identity_sheet.dart';
import 'invite_dialog.dart';

/// [name] made safe to use as a file name.
@visibleForTesting
String fileName(String name) {
  final safe = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '').trim();
  return safe.isEmpty ? 'balnana' : safe;
}

/// A group's name and look, its link, its people, and this device's place in it.
class GroupSettingsPage extends ConsumerWidget {
  const GroupSettingsPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watchCurrent(groupProvider(token));
    final group = async.value;
    if (group == null) {
      return BPage(
        title: l10n.groupSettings,
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
    return GroupTheme(
      group: group,
      child: _Settings(group: group),
    );
  }
}

class _Settings extends ConsumerWidget {
  const _Settings({required this.group});

  final Group group;

  void _snack(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(action)),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _resetLink(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    if (!await _confirm(
      context,
      title: l10n.resetLinkTitle,
      body: l10n.resetLinkBody,
      action: l10n.resetLinkAction,
    )) {
      return;
    }
    try {
      final updated = await groupApiOf(ref, group.token).resetLink();
      ref.read(knownGroupsProvider.notifier).replaceToken(group.token, updated.token);
      ref.invalidate(summariesProvider);
      ref.invalidate(activityFeedProvider);
      if (!context.mounted) return;
      _snack(context, l10n.resetLinkDone);
      context.go('/g/${updated.token}');
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, errorMessage(l10n, e));
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    try {
      final bytes = await groupApiOf(ref, group.token).exportCsv();
      final saved = await FilePicker.saveFile(
        fileName: '${fileName(group.name)}.csv',
        bytes: bytes,
        mimeType: 'text/csv',
      );
      if (saved != null && context.mounted) _snack(context, l10n.exportCsvDone);
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, errorMessage(l10n, e));
    }
  }

  Future<void> _addMember(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final name = await askForName(context, title: l10n.memberAddTitle, action: l10n.memberAdd);
    if (name == null || !context.mounted) return;
    try {
      await groupApiOf(ref, group.token).addMember(name, digits: group.minorDigits);
      refreshGroup(ref, group.token);
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, errorMessage(l10n, e));
    }
  }

  Future<void> _renameMember(BuildContext context, WidgetRef ref, Member member) async {
    final l10n = context.l10n;
    final name = await askForName(
      context,
      title: l10n.memberRenameTitle,
      action: l10n.commonSave,
      initial: member.name,
    );
    if (name == null || name == member.name || !context.mounted) return;
    try {
      await groupApiOf(
        ref,
        group.token,
      ).updateMember(member.id, name, color: member.color, digits: group.minorDigits);
      refreshGroup(ref, group.token);
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, errorMessage(l10n, e));
    }
  }

  Future<void> _removeMember(BuildContext context, WidgetRef ref, Member member) async {
    final l10n = context.l10n;
    final ok = await _confirm(
      context,
      title: l10n.memberRemoveTitle(member.name),
      body: l10n.memberRemoveBody,
      action: l10n.commonRemove,
    );
    if (!ok || !context.mounted) return;
    try {
      await groupApiOf(ref, group.token).removeMember(member.id);
      refreshGroup(ref, group.token);
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, errorMessage(l10n, e));
    }
  }

  Future<void> _setLinkAccess(BuildContext context, WidgetRef ref, bool open) async {
    final l10n = context.l10n;
    try {
      await groupApiOf(ref, group.token).update(linkAccess: open);
      refreshGroup(ref, group.token);
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, errorMessage(l10n, e));
    }
  }

  Future<void> _leave(BuildContext context, WidgetRef ref, Member me) async {
    final l10n = context.l10n;
    final ok = await _confirm(
      context,
      title: l10n.leaveTitle,
      body: l10n.leaveBody,
      action: l10n.leaveAction,
    );
    if (!ok || !context.mounted) return;
    try {
      await groupApiOf(ref, group.token).removeMember(me.id);
      refreshGroup(ref, group.token);
      ref.read(currentGroupProvider.notifier).set(null);
      if (context.mounted) context.go('/groups');
    } on ApiException catch (e) {
      if (context.mounted) _snack(context, errorMessage(l10n, e));
    }
  }

  Future<void> _forget(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await _confirm(
      context,
      title: l10n.forgetTitle,
      body: l10n.forgetBody,
      action: l10n.commonRemove,
    );
    if (!ok || !context.mounted) return;
    _dropLocally(ref);
    context.go('/groups');
  }

  /// Takes the group off this device's list and out of what shows it.
  void _dropLocally(WidgetRef ref) {
    ref.read(knownGroupsProvider.notifier).remove(group.token);
    ref.invalidate(summariesProvider);
    ref.invalidate(activityFeedProvider);
    ref.read(currentGroupProvider.notifier).set(null);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(context: context, builder: (_) => _DeleteGroupDialog(name: group.name));
    if (ok != true || !context.mounted) return;
    try {
      await groupApiOf(ref, group.token).delete();
    } on ApiException catch (e) {
      if (!context.mounted) return;
      _snack(context, e.code == 'owner_only' ? l10n.groupDeleteOwnerOnly : errorMessage(l10n, e));
      return;
    }
    _dropLocally(ref);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    context.go('/groups');
    messenger.showSnackBar(SnackBar(content: Text(l10n.groupDeleted)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final me = group.member(myMemberId(ref, group.token));
    final signedIn = ref.watch(signedInProvider);
    final accounts = ref.watch(accountsModeProvider);
    final linkGroups = ref.watch(serverInfoProvider.select((i) => i.value?.linkGroups ?? false));
    final email = ref.watch(serverInfoProvider.select((i) => i.value?.email ?? false));
    // In accounts mode a group is its members' business, and deleting it its
    // owner's (anyone's, once no owner is left; anyone the link opens it for,
    // once no account is in it).
    final member = !accounts || me != null;
    final canDelete =
        !accounts ||
        (me != null && (me.owner || !group.activeMembers.any((m) => m.owner))) ||
        (me == null && group.linkAccess && !group.activeMembers.any((m) => m.claimed));

    return BPage(
      title: l10n.groupSettings,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: BSpace.s24),
          child: Row(
            children: [
              GroupBadge(
                token: group.token,
                name: group.name,
                emoji: group.emoji,
                color: group.color,
                size: 64,
              ),
              const SizedBox(width: BSpace.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: text.headlineSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(
                      '${group.currency} · ${l10n.groupMemberCount(group.activeMembers.length)}',
                      style: text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: l10n.groupEdit,
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (_) => _EditGroupSheet(group: group),
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ),
        GroupedList(
          title: l10n.groupSharing,
          children: [
            GroupedTile(
              icon: Icons.link,
              title: l10n.groupCopyLink,
              subtitle: accounts && !group.linkAccess
                  ? l10n.groupCopyLinkHelpAccounts
                  : l10n.groupCopyLinkHelp,
              onTap: () => copyGroupLink(context, ref, group.token),
            ),
            if (signedIn && email && me != null)
              GroupedTile(
                icon: Icons.forward_to_inbox_outlined,
                title: l10n.inviteByEmail,
                subtitle: l10n.inviteByEmailHelp,
                onTap: () => showInviteDialog(context, group),
              ),
            if (accounts && linkGroups && me != null && me.owner)
              GroupedSwitchTile(
                icon: Icons.public,
                title: l10n.linkAccessTitle,
                subtitle: l10n.linkAccessHelp,
                value: group.linkAccess,
                onChanged: (open) => _setLinkAccess(context, ref, open),
              ),
            if (member)
              GroupedTile(
                icon: Icons.lock_reset,
                title: l10n.resetLinkTitle,
                subtitle: l10n.resetLinkHelp,
                onTap: () => _resetLink(context, ref),
              ),
          ],
        ),
        GroupedList(
          title: l10n.groupPeople,
          children: [
            for (final m in group.activeMembers)
              ListTile(
                minVerticalPadding: BSpace.s12,
                contentPadding: const EdgeInsetsDirectional.only(start: BSpace.s16, end: BSpace.s4),
                leading: MemberAvatar(member: m),
                title: Text(m.id == me?.id ? l10n.memberYou(m.name) : m.name),
                subtitle: Text(
                  formatMoney(context, m.balance, group.minorDigits, group.currency, signed: true),
                  style: TextStyle(color: balanceColor(context, m.balance)),
                ),
                onTap: () => _renameMember(context, ref, m),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) =>
                      action == 'rename' ? _renameMember(context, ref, m) : _removeMember(context, ref, m),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'rename', child: Text(l10n.memberRename)),
                    PopupMenuItem(value: 'remove', child: Text(l10n.commonRemove)),
                  ],
                ),
              ),
            GroupedTile(
              icon: Icons.person_add_alt,
              title: l10n.memberAdd,
              onTap: () => _addMember(context, ref),
            ),
          ],
        ),
        GroupedList(
          title: l10n.groupData,
          children: [
            GroupedTile(
              icon: Icons.category_outlined,
              title: l10n.categoriesTitle,
              subtitle: l10n.categoriesHelp,
              onTap: () => context.go('/g/${group.token}/settings/categories'),
            ),
            GroupedTile(
              icon: Icons.download_outlined,
              title: l10n.exportCsv,
              subtitle: l10n.exportCsvHelp,
              onTap: () => _exportCsv(context, ref),
            ),
            if (canDelete)
              GroupedTile(
                icon: Icons.delete_forever_outlined,
                title: l10n.groupDelete,
                subtitle: l10n.groupDeleteHelp,
                onTap: () => _delete(context, ref),
              ),
          ],
        ),
        if (signedIn && me != null)
          GroupedList(
            title: l10n.groupYou,
            children: [
              GroupedTile(
                icon: Icons.logout,
                title: l10n.leaveTitle,
                subtitle: l10n.leaveHelp,
                onTap: () => _leave(context, ref, me),
              ),
            ],
          )
        else if (!signedIn)
          GroupedList(
            title: l10n.groupThisDevice,
            children: [
              GroupedTile(
                icon: Icons.badge_outlined,
                title: l10n.identityChange,
                subtitle: me == null ? l10n.identityNone : l10n.heroYouAre(me.name),
                onTap: () => showIdentitySheet(context, group),
              ),
              GroupedTile(
                icon: Icons.logout,
                title: l10n.forgetTitle,
                subtitle: l10n.forgetHelp,
                onTap: () => _forget(context, ref),
              ),
            ],
          ),
      ],
    );
  }
}

class _EditGroupSheet extends ConsumerStatefulWidget {
  const _EditGroupSheet({required this.group});

  final Group group;

  @override
  ConsumerState<_EditGroupSheet> createState() => _EditGroupSheetState();
}

class _EditGroupSheetState extends ConsumerState<_EditGroupSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.group.name);
  late final _emoji = TextEditingController(text: widget.group.emoji ?? '');
  late Color _color = paletteColor(widget.group.color, widget.group.token);
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _emoji.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await groupApiOf(
        ref,
        widget.group.token,
      ).update(name: _name.text.trim(), emoji: _emoji.text.trim(), color: _color.toARGB32() & 0xFFFFFF);
      refreshGroup(ref, widget.group.token);
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
                  l10n.groupEdit,
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
                        decoration: InputDecoration(hintText: l10n.groupEmojiHint),
                      ),
                    ),
                    const SizedBox(width: BSpace.s12),
                    Expanded(
                      child: TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.sentences,
                        inputFormatters: [LengthLimitingTextInputFormatter(100)],
                        decoration: InputDecoration(labelText: l10n.groupName),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Confirms deleting a group by having its name typed.
class _DeleteGroupDialog extends StatefulWidget {
  const _DeleteGroupDialog({required this.name});

  final String name;

  @override
  State<_DeleteGroupDialog> createState() => _DeleteGroupDialogState();
}

class _DeleteGroupDialogState extends State<_DeleteGroupDialog> {
  final _typed = TextEditingController();

  bool get _matches => _typed.text.trim() == widget.name.trim();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: const Icon(Icons.delete_forever_outlined),
      title: Text(l10n.groupDeleteTitle(widget.name)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.groupDeleteBody),
          const SizedBox(height: BSpace.s16),
          TextField(
            controller: _typed,
            autofocus: true,
            autocorrect: false,
            decoration: InputDecoration(labelText: l10n.groupDeleteName, hintText: widget.name),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (_matches) Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
          onPressed: _matches ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.groupDeleteAction),
        ),
      ],
    );
  }
}
