import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../ui/tokens.dart';

final _token = RegExp(r'^[A-Za-z0-9_-]{22}$');

/// A valid group link whose server is not one of the current server's aliases.
class ForeignGroupLink implements Exception {
  const ForeignGroupLink();
}

/// The page a bare token or a link opens: a group's, also from the link that
/// joins it, or an invite's, which holds a token of its own. Only links
/// belonging to the current server's configured or advertised URL count. A
/// different server, including a different subpath on the same origin, is
/// rejected before its token can be used.
String? pathFromLink(String input, {required String? serverUrl, String? publicUrl}) {
  final text = input.trim();
  if (_token.hasMatch(text)) return serverUrl == null ? null : '/g/$text';
  final uri = Uri.tryParse(text);
  if (uri == null ||
      !(uri.isScheme('http') || uri.isScheme('https')) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return null;
  }
  final segments = uri.pathSegments.toList();
  if (segments.isNotEmpty && segments.last.isEmpty) segments.removeLast();
  final join = segments.isNotEmpty && segments.last == 'join';
  if (join) segments.removeLast();
  if (segments.length < 2) return null;
  final kind = segments[segments.length - 2];
  if (kind != 'g' && (kind != 'invite' || join)) return null;
  final token = segments.last;
  if (!_token.hasMatch(token)) return null;
  final base = normalizeServerUrl(
    uri.replace(pathSegments: segments.take(segments.length - 2), query: '', fragment: '').toString(),
  );
  final aliases = {
    if (serverUrl != null) normalizeServerUrl(serverUrl),
    if (publicUrl != null) normalizeServerUrl(publicUrl),
  }..remove(null);
  if (serverUrl == null || !aliases.contains(base)) throw const ForeignGroupLink();
  return '/$kind/$token';
}

/// The group token of a bare token or a group link. An invite is not one.
String? tokenFromLink(String input, {required String? serverUrl, String? publicUrl}) {
  final path = pathFromLink(input, serverUrl: serverUrl, publicUrl: publicUrl);
  return path != null && path.startsWith('/g/') ? path.substring('/g/'.length) : null;
}

/// Validates the whole list before any of its secrets may be saved or sent.
/// Repeated links are kept once, in their original order.
List<String> tokensFromLinks(String input, {required String? serverUrl, String? publicUrl}) {
  final tokens = <String>{};
  for (final text in input.trim().split(RegExp(r'\s+'))) {
    if (text.isEmpty) continue;
    final token = tokenFromLink(text, serverUrl: serverUrl, publicUrl: publicUrl);
    if (token == null) throw const FormatException('invalid_group_link');
    tokens.add(token);
  }
  if (tokens.isEmpty) throw const FormatException('invalid_group_link');
  return tokens.toList();
}

/// Asks for a group link and opens it.
Future<void> showOpenLinkDialog(BuildContext context) async {
  final path = await showDialog<String>(context: context, builder: (context) => const _OpenLinkDialog());
  if (path != null && context.mounted) context.go(path);
}

class _OpenLinkDialog extends ConsumerStatefulWidget {
  const _OpenLinkDialog();

  @override
  ConsumerState<_OpenLinkDialog> createState() => _OpenLinkDialogState();
}

class _OpenLinkDialogState extends ConsumerState<_OpenLinkDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String? path;
    try {
      path = pathFromLink(
        _controller.text,
        serverUrl: ref.read(serverUrlProvider),
        publicUrl: ref.read(serverPublicUrlProvider),
      );
    } on ForeignGroupLink {
      setState(() => _error = context.l10n.groupLinkOtherServer);
      return;
    }
    if (path == null) {
      setState(() => _error = context.l10n.openLinkInvalid);
      return;
    }
    Navigator.of(context).pop(path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.openLinkTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.openLinkBody),
          const SizedBox(height: BSpace.s16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(labelText: l10n.openLinkLabel, errorText: _error),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.openLinkAction)),
      ],
    );
  }
}
