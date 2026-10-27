import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/layout.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/member_avatar.dart';
import 'identity_sheet.dart';

final _joinInfoProvider = FutureProvider.autoDispose.family<JoinInfo, String>(
  (ref, token) => ref.watch(balnanaApiProvider)!.group(token).joinInfo(),
);

/// Joining a group by its link (accounts mode): be one of the people already
/// in it, or join as someone new.
class JoinPage extends ConsumerStatefulWidget {
  const JoinPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends ConsumerState<JoinPage> {
  bool _busy = false;

  void _open() => context.go('/g/${widget.token}');

  Future<void> _join({String? claim, String? name}) async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await groupApiOf(ref, widget.token).join(claim: claim, name: name);
      refreshGroup(ref, widget.token);
      if (mounted) _open();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      if (e.code == 'duplicate_name') {
        // Someone in the group already goes by the account's name.
        final account = ref.read(currentAccountProvider).value;
        final other = await askForName(
          context,
          title: l10n.joinPickName,
          action: l10n.joinAction,
          initial: name ?? account?.name,
        );
        if (other != null && mounted) await _join(name: other);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
      if (e.code == 'member_claimed') ref.invalidate(_joinInfoProvider(widget.token));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(_joinInfoProvider(widget.token));
    final info = async.value;

    if (info != null && info.member) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _open();
      });
    }

    final Widget body;
    if (info == null || info.member) {
      final error = async.error;
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(BSpace.s16),
          child: error == null || async.isLoading
              ? const CircularProgressIndicator()
              : EmptyState(
                  icon: Icons.link_off,
                  title: error is ApiException && error.isNotFound
                      ? l10n.groupMissingTitle
                      : l10n.groupsUnreachableTitle,
                  body: error is ApiException && error.isNotFound
                      ? l10n.groupMissingBody
                      : errorMessage(l10n, error),
                  action: FilledButton.tonal(
                    onPressed: () => ref.invalidate(_joinInfoProvider(widget.token)),
                    child: Text(l10n.commonRetry),
                  ),
                ),
        ),
      );
    } else {
      final account = ref.watch(currentAccountProvider).value;
      // The member an invitation named comes first.
      final open = [
        for (final m in info.members)
          if (!m.claimed && m.id == info.invitedMemberId) m,
        for (final m in info.members)
          if (!m.claimed && m.id != info.invitedMemberId) m,
      ];
      final taken = [
        for (final m in info.members)
          if (m.claimed) m,
      ];
      body = LayoutBuilder(
        builder: (context, constraints) {
          final side = math.max(BSpace.s16, (constraints.maxWidth - formMaxWidth) / 2);
          return ListView(
            padding: EdgeInsets.fromLTRB(side, BSpace.s8, side, BSpace.s32),
            children: [
              Center(
                child: GroupBadge(
                  token: widget.token,
                  name: info.name,
                  emoji: info.emoji,
                  color: info.color,
                  size: 72,
                ),
              ),
              const SizedBox(height: BSpace.s16),
              Text(l10n.joinTitle(info.name), style: text.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: BSpace.s8),
              Text(
                open.isEmpty ? l10n.joinBodyNew : l10n.joinBody,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: BSpace.s16),
              for (final m in open)
                ListTile(
                  enabled: !_busy,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(BShape.md)),
                  ),
                  leading: MemberAvatar(member: _asMember(m)),
                  title: Text(m.name, style: text.titleMedium),
                  subtitle: m.id == info.invitedMemberId ? Text(l10n.joinInvitedAs) : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _join(claim: m.id),
                ),
              ListTile(
                enabled: !_busy,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(BShape.md)),
                ),
                leading: CircleAvatar(
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                  child: const Icon(Icons.person_add_alt),
                ),
                title: Text(open.isEmpty ? l10n.joinAction : l10n.joinAsNew, style: text.titleMedium),
                subtitle: account == null ? null : Text(l10n.joinAsName(account.name)),
                onTap: () => _join(),
              ),
              if (taken.isNotEmpty) ...[
                const SizedBox(height: BSpace.s16),
                Text(
                  l10n.joinTaken(taken.map((m) => m.name).join(', ')),
                  style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () => context.go('/groups')),
      ),
      body: body,
    );
  }
}

Member _asMember(JoinMember m) => Member(id: m.id, name: m.name, color: m.color, balance: BigInt.zero);
