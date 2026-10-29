import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr/qr.dart';

import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/models.dart';
import '../../ui/tokens.dart';
import 'group_page.dart';

/// Who [group]'s link lets in: anyone in link mode, or people who sign in
/// and ask to join once its link access is off in accounts mode.
String groupLinkHelp(AppLocalizations l10n, {required bool accounts, required Group group}) =>
    accounts && !group.linkAccess ? l10n.groupCopyLinkHelpAccounts : l10n.groupCopyLinkHelp;

/// Shows [group]'s link as a QR code to scan, with ways to share or copy it.
Future<void> showShareSheet(BuildContext context, Group group) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) => _ShareSheet(group: group),
);

class _ShareSheet extends ConsumerWidget {
  const _ShareSheet({required this.group});

  final Group group;

  /// Closes the sheet first: a snack bar would show behind it.
  Future<void> _copy(BuildContext context, String link) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.groupLinkCopied;
    Navigator.of(context).pop();
    await Clipboard.setData(ClipboardData(text: link));
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final accounts = ref.watch(accountsModeProvider);
    final link = groupLink(ref, group.token);
    // Big enough to scan from across a table, but leaving room for the
    // buttons on a phone held sideways.
    final size = math.min(240.0, math.max(160.0, MediaQuery.sizeOf(context).height * 0.4));
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(BSpace.s24, 0, BSpace.s24, BSpace.s24),
      children: [
        Text(group.name, style: text.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: BSpace.s8),
        Text(
          groupLinkHelp(l10n, accounts: accounts, group: group),
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: BSpace.s16),
        Center(
          child: QrCodeView(data: link, size: size, semanticLabel: l10n.groupQrLabel(group.name)),
        ),
        const SizedBox(height: BSpace.s16),
        SelectableText(
          link,
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: BSpace.s16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: BSpace.s8,
          runSpacing: BSpace.s8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _copy(context, link),
              icon: const Icon(Icons.copy),
              label: Text(l10n.groupCopyLink),
            ),
            // The web has no share sheet that works everywhere.
            if (!kIsWeb)
              FilledButton.icon(
                onPressed: () => shareGroupLink(context, ref, group),
                icon: const Icon(Icons.share_outlined),
                label: Text(l10n.groupShare),
              ),
          ],
        ),
      ],
    );
  }
}

/// [data] as a QR code, always dark on white with its quiet zone around it:
/// many scanners give up on inverted codes, so the dark theme keeps it too.
class QrCodeView extends StatelessWidget {
  const QrCodeView({super.key, required this.data, required this.size, this.semanticLabel});

  final String data;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(BShape.md)),
        child: CustomPaint(size: Size.square(size), painter: _QrPainter(data)),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.data) : image = QrImage(QrCode(payload: QrPayload.fromString(data)));

  final String data;
  final QrImage image;

  /// The four blank modules the QR standard asks for on every side.
  static const _quiet = 4;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final count = image.moduleCount;
    final module = size.width / (count + 2 * _quiet);
    final dark = Path();
    for (var row = 0; row < count; row++) {
      for (var col = 0; col < count; col++) {
        if (image.isDark(row, col)) {
          dark.addRect(Rect.fromLTWH((col + _quiet) * module, (row + _quiet) * module, module, module));
        }
      }
    }
    // Without anti-aliasing, neighboring modules meet without hairline gaps.
    canvas.drawPath(
      dark,
      Paint()
        ..color = Colors.black
        ..isAntiAlias = false,
    );
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.data != data;
}
