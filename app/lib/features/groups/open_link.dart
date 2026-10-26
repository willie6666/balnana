import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../ui/tokens.dart';

final _token = RegExp(r'^[A-Za-z0-9_-]{22}$');

/// The group token in a pasted link (`https://host/g/<token>`) or a bare
/// token, or null.
String? tokenFromLink(String input) {
  final text = input.trim();
  if (_token.hasMatch(text)) return text;
  final uri = Uri.tryParse(text);
  if (uri == null) return null;
  final segments = uri.pathSegments;
  final i = segments.lastIndexOf('g');
  if (i < 0 || i + 1 >= segments.length) return null;
  final token = segments[i + 1];
  return _token.hasMatch(token) ? token : null;
}

/// Asks for a group link and opens it.
Future<void> showOpenLinkDialog(BuildContext context) async {
  final token = await showDialog<String>(context: context, builder: (context) => const _OpenLinkDialog());
  if (token != null && context.mounted) await context.push('/g/$token');
}

class _OpenLinkDialog extends StatefulWidget {
  const _OpenLinkDialog();

  @override
  State<_OpenLinkDialog> createState() => _OpenLinkDialogState();
}

class _OpenLinkDialogState extends State<_OpenLinkDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final token = tokenFromLink(_controller.text);
    if (token == null) {
      setState(() => _error = context.l10n.openLinkInvalid);
      return;
    }
    Navigator.of(context).pop(token);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
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
