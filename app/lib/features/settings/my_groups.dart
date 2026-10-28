import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/known_groups.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/grouped_list.dart';
import '../groups/open_link.dart';

/// Link-mode backups for the current server. The links carry access, so a
/// foreign server's token must never enter this server's catalog.
class MyGroupsSection extends ConsumerWidget {
  const MyGroupsSection({super.key});

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final server = ref.read(serverUrlProvider);
    if (server == null) return;
    final base = ref.read(serverPublicUrlProvider) ?? server;
    final links = ref.read(knownGroupsProvider).map((g) => '$base/g/${g.token}').join('\n');
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.myGroupsExport),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.myGroupsPrivate),
              const SizedBox(height: BSpace.s16),
              Flexible(child: SingleChildScrollView(child: SelectableText(links))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: links));
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.copy),
            label: Text(l10n.myGroupsCopy),
          ),
        ],
      ),
    );
  }

  Future<void> _import(BuildContext context) async {
    final added = await showDialog<int>(context: context, builder: (_) => const _ImportGroupsDialog());
    if (added != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.myGroupsImported(added))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final empty = ref.watch(knownGroupsProvider).isEmpty;
    return GroupedList(
      title: l10n.myGroupsTitle,
      children: [
        GroupedTile(
          icon: Icons.file_download_outlined,
          title: l10n.myGroupsExport,
          subtitle: l10n.myGroupsExportHelp,
          onTap: empty ? null : () => _export(context, ref),
        ),
        GroupedTile(
          icon: Icons.file_upload_outlined,
          title: l10n.myGroupsImport,
          subtitle: l10n.myGroupsImportHelp,
          onTap: () => _import(context),
        ),
      ],
    );
  }
}

class _ImportGroupsDialog extends ConsumerStatefulWidget {
  const _ImportGroupsDialog();

  @override
  ConsumerState<_ImportGroupsDialog> createState() => _ImportGroupsDialogState();
}

class _ImportGroupsDialogState extends ConsumerState<_ImportGroupsDialog> {
  final _text = TextEditingController();
  late final String? _server;
  String? _error;

  @override
  void initState() {
    super.initState();
    _server = ref.read(serverUrlProvider);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    if (_server == null || ref.read(serverUrlProvider) != _server) {
      setState(() => _error = l10n.myGroupsServerChanged);
      return;
    }
    try {
      final tokens = tokensFromLinks(
        _text.text,
        serverUrl: _server,
        publicUrl: ref.read(serverPublicUrlProvider),
      );
      final added = ref.read(knownGroupsProvider.notifier).importOn(_server, tokens);
      Navigator.pop(context, added);
    } on ForeignGroupLink {
      setState(() => _error = l10n.groupLinkOtherServer);
    } on FormatException catch (e) {
      setState(
        () => _error = e.message == 'too_many_groups'
            ? l10n.myGroupsLimit(maxKnownGroups)
            : l10n.myGroupsInvalid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.myGroupsImport),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.myGroupsImportHelp),
            const SizedBox(height: BSpace.s16),
            TextField(
              controller: _text,
              autofocus: true,
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(labelText: l10n.myGroupsLinks, errorText: _error, errorMaxLines: 3),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.myGroupsImportAction)),
      ],
    );
  }
}
