import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/group_keys.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';

/// The longest group password the server takes.
const _maxGroupPassword = 200;

/// Asks for the password of a group this device may not open without it.
/// Once it is right, the device keeps the key it gives and [onUnlocked] is
/// told; the group loads again with it.
class GroupUnlock extends ConsumerStatefulWidget {
  const GroupUnlock({super.key, required this.token, this.onUnlocked});

  final String token;
  final VoidCallback? onUnlocked;

  @override
  ConsumerState<GroupUnlock> createState() => _GroupUnlockState();
}

class _GroupUnlockState extends ConsumerState<GroupUnlock> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_busy || !_form.currentState!.validate()) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final key = await groupApiOf(ref, widget.token).unlock(_password.text);
      if (!mounted) return;
      ref.read(groupKeysProvider.notifier).set(widget.token, key);
      refreshGroup(ref, widget.token);
      ref
        ..invalidate(summariesProvider)
        ..invalidate(activityFeedProvider);
      widget.onUnlocked?.call();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.code == 'wrong_password' ? l10n.groupPasswordWrong : errorMessage(l10n, e);
      });
      return;
    }
    // Stays on the screen until the group has loaded in its place.
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
              child: Icon(Icons.lock_outline, size: 44, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: BSpace.s24),
            Text(l10n.groupPasswordTitle, style: text.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: BSpace.s8),
            Text(
              l10n.groupPasswordBody,
              style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: BSpace.s24),
            TextFormField(
              controller: _password,
              autofocus: true,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.go,
              decoration: InputDecoration(labelText: l10n.groupPassword, errorText: _error, errorMaxLines: 3),
              validator: (v) => (v ?? '').isEmpty ? l10n.errorRequired : null,
              onFieldSubmitted: (_) => _unlock(),
            ),
            const SizedBox(height: BSpace.s16),
            FilledButton(onPressed: _busy ? null : _unlock, child: Text(l10n.groupUnlock)),
          ],
        ),
      ),
    );
  }
}

/// Sets, changes or removes [group]'s password.
Future<void> showGroupPasswordDialog(BuildContext context, Group group, {required bool accounts}) =>
    showDialog<void>(
      context: context,
      builder: (_) => _GroupPasswordDialog(group: group, accounts: accounts),
    );

class _GroupPasswordDialog extends ConsumerStatefulWidget {
  const _GroupPasswordDialog({required this.group, required this.accounts});

  final Group group;
  final bool accounts;

  @override
  ConsumerState<_GroupPasswordDialog> createState() => _GroupPasswordDialogState();
}

class _GroupPasswordDialogState extends ConsumerState<_GroupPasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  String get _token => widget.group.token;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String> Function() change) async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final done = await change();
      if (!mounted) return;
      refreshGroup(ref, _token);
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorMessage(l10n, e);
      });
    }
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    final l10n = context.l10n;
    final keys = ref.read(groupKeysProvider.notifier);
    await _run(() async {
      // This device stays in: the key comes with the new password.
      keys.set(_token, await groupApiOf(ref, _token).setPassword(_password.text));
      return l10n.groupPasswordSetDone;
    });
  }

  Future<void> _remove() async {
    if (_busy) return;
    final l10n = context.l10n;
    final keys = ref.read(groupKeysProvider.notifier);
    await _run(() async {
      await groupApiOf(ref, _token).removePassword();
      keys.remove(_token);
      return l10n.groupPasswordRemoved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final has = widget.group.hasPassword;
    return AlertDialog(
      scrollable: true,
      title: Text(has ? l10n.groupPasswordChange : l10n.groupPasswordSet),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.groupPasswordHelp),
            if (widget.accounts) ...[const SizedBox(height: BSpace.s8), Text(l10n.groupPasswordMembersHelp)],
            const SizedBox(height: BSpace.s16),
            TextFormField(
              controller: _password,
              autofocus: true,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              inputFormatters: [LengthLimitingTextInputFormatter(_maxGroupPassword)],
              decoration: InputDecoration(
                labelText: has ? l10n.groupPasswordNew : l10n.groupPassword,
                errorText: _error,
                errorMaxLines: 3,
              ),
              validator: (v) => (v ?? '').isEmpty ? l10n.errorRequired : null,
              onFieldSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        if (has) TextButton(onPressed: _busy ? null : _remove, child: Text(l10n.groupPasswordRemove)),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.commonSave)),
      ],
    );
  }
}
