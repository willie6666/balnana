import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../ui/layout.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import 'admin_page.dart';

/// The server's accounts, for finding one and deleting it.
class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final _query = TextEditingController();
  Timer? _debounce;
  List<AdminUser>? _users;
  int _total = 0;
  Object? _error;

  /// Answers to older searches are dropped.
  int _generation = 0;

  AdminApi get _api => ref.read(adminApiProvider)!;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    try {
      final (users, total) = await _api.users(widget.token, query: _query.text.trim());
      if (!mounted || generation != _generation) return;
      setState(() {
        _users = users;
        _total = total;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() => _error = e);
    }
  }

  void _search(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _load);
  }

  Future<void> _delete(AdminUser user) async {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_forever_outlined),
        title: Text(l10n.adminUserDeleteTitle(user.name)),
        content: Text(l10n.adminUserDeleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.accountDeleteAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _api.deleteUser(widget.token, user.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminUserDeleted)));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
    }
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final users = _users;

    Widget body;
    if (users == null && _error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(BSpace.s16),
          child: EmptyState(
            icon: Icons.cloud_off_outlined,
            title: l10n.adminUsers,
            body: errorMessage(l10n, _error!),
            action: FilledButton(onPressed: _load, child: Text(l10n.commonRetry)),
          ),
        ),
      );
    } else if (users == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = LayoutBuilder(
        builder: (context, constraints) {
          final side = math.max(BSpace.s16, (constraints.maxWidth - contentMaxWidth) / 2);
          return ListView(
            padding: EdgeInsets.fromLTRB(side, BSpace.s8, side, BSpace.s32),
            children: [
              TextField(
                controller: _query,
                onChanged: _search,
                autocorrect: false,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  labelText: l10n.adminUsersSearch,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: BSpace.s12),
                // A search that failed says so; the list is from the last one that worked.
                child: _error != null
                    ? Text(errorMessage(l10n, _error!), style: text.bodyMedium?.copyWith(color: scheme.error))
                    : Text(
                        users.length < _total
                            ? l10n.adminUsersShown(users.length, _total)
                            : l10n.adminUsersCount(_total),
                        style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
              ),
              if (users.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: BSpace.s24),
                  child: Text(l10n.adminUsersEmpty, textAlign: TextAlign.center, style: text.bodyLarge),
                ),
              for (final u in users)
                ListTile(
                  contentPadding: const EdgeInsetsDirectional.only(start: BSpace.s4, end: 0),
                  title: Text(u.name),
                  subtitle: Text(
                    [
                      ?u.username,
                      if (u.email != null) u.emailVerified ? u.email! : '${u.email} (${l10n.adminUserUnverified})',
                      ...u.oauth,
                      l10n.adminUserGroups(u.groups),
                      DateFormat.yMMMd(locale).format(u.createdAt.toLocal()),
                    ].join(' · '),
                  ),
                  trailing: IconButton(
                    tooltip: l10n.accountDelete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(u),
                  ),
                ),
            ],
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminUsers)),
      body: body,
    );
  }
}
