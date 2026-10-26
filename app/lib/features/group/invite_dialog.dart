import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';

/// Emails someone a link to join [group], optionally as one of the people
/// already in it who has no account yet.
Future<void> showInviteDialog(BuildContext context, Group group) =>
    showDialog<void>(context: context, builder: (_) => _InviteDialog(group: group));

class _InviteDialog extends ConsumerStatefulWidget {
  const _InviteDialog({required this.group});

  final Group group;

  @override
  ConsumerState<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<_InviteDialog> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _member;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    final l10n = context.l10n;
    final email = _email.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await groupApiOf(ref, widget.group.token).invite(email, member: _member);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.inviteSent(email))));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorMessage(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final open = [
      for (final m in widget.group.activeMembers)
        if (!m.claimed) m,
    ];
    return AlertDialog(
      title: Text(l10n.inviteByEmail),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(labelText: l10n.accountEmail, errorText: _error, errorMaxLines: 3),
              validator: (v) => (v ?? '').contains('@') ? null : l10n.errorInvalidEmail,
              onFieldSubmitted: (_) => _send(),
            ),
            if (open.isNotEmpty) ...[
              const SizedBox(height: BSpace.s16),
              DropdownButtonFormField<String?>(
                initialValue: _member,
                decoration: InputDecoration(
                  labelText: l10n.inviteAs,
                  helperText: l10n.inviteAsHelp,
                  helperMaxLines: 2,
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.inviteAsAnyone)),
                  for (final m in open) DropdownMenuItem(value: m.id, child: Text(m.name)),
                ],
                onChanged: _busy ? null : (id) => setState(() => _member = id),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _busy ? null : _send, child: Text(l10n.inviteSend)),
      ],
    );
  }
}
