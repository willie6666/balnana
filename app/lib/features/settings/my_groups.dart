import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/known_groups.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/grouped_list.dart';
import '../group/group_page.dart';
import '../groups/open_link.dart';

/// Every group token in [text]: links or bare tokens, separated by spaces,
/// lines or commas, in order and without repeats.
List<String> tokensIn(String text, {required String? serverUrl, String? publicUrl}) => {
  for (final word in text.split(RegExp(r'[\s,;]+')))
    ?tokenFromLink(word, serverUrl: serverUrl, publicUrl: publicUrl),
}.toList();

/// Link mode keeps the list of groups on the device only, so it can be copied
/// out and pasted into another device.
class MyGroupsSection extends ConsumerWidget {
  const MyGroupsSection({super.key});

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final known = ref.read(knownGroupsProvider);
    if (known.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.myGroupsNone)));
      return;
    }
    // Oldest first, so importing them elsewhere keeps the order at home.
    final links = [for (final g in known.reversed) groupLink(ref, g.token)];
    await Clipboard.setData(ClipboardData(text: '${links.join('\n')}\n'));
    messenger.showSnackBar(SnackBar(content: Text(l10n.myGroupsExported(links.length))));
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final server = ref.read(serverUrlProvider);
    final tokens = await showDialog<List<String>>(
      context: context,
      builder: (context) => const _ImportDialog(),
    );
    if (tokens == null) return;
    if (server != ref.read(serverUrlProvider)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.groupLinkOtherServer)));
      return;
    }
    final known = ref.read(knownGroupsProvider.notifier);
    final added = [
      for (final t in tokens)
        if (known.byToken(t) == null) t,
    ];
    for (final t in added) {
      known.add(t);
    }
    ref.invalidate(summariesProvider);
    ref.invalidate(activityFeedProvider);
    messenger.showSnackBar(SnackBar(content: Text(l10n.myGroupsImported(added.length))));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return GroupedList(
      title: l10n.myGroups,
      children: [
        GroupedTile(
          icon: Icons.ios_share,
          title: l10n.myGroupsExport,
          subtitle: l10n.myGroupsExportHelp,
          onTap: () => _export(context, ref),
        ),
        GroupedTile(
          icon: Icons.playlist_add,
          title: l10n.myGroupsImport,
          subtitle: l10n.myGroupsImportHelp,
          onTap: () => _import(context, ref),
        ),
      ],
    );
  }
}

class _ImportDialog extends ConsumerStatefulWidget {
  const _ImportDialog();

  @override
  ConsumerState<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<_ImportDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final List<String> tokens;
    try {
      tokens = tokensIn(
        _controller.text,
        serverUrl: ref.read(serverUrlProvider),
        publicUrl: ref.read(serverPublicUrlProvider),
      );
    } on ForeignGroupLink {
      setState(() => _error = context.l10n.groupLinkOtherServer);
      return;
    }
    if (tokens.isEmpty) {
      setState(() => _error = context.l10n.myGroupsImportInvalid);
      return;
    }
    Navigator.of(context).pop(tokens);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.myGroupsImport),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.myGroupsImportBody),
          const SizedBox(height: BSpace.s16),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 3,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(labelText: l10n.myGroupsImportLabel, errorText: _error),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.myGroupsImportAction)),
      ],
    );
  }
}
