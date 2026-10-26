import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';

/// The largest photo the server takes.
const maxReceiptBytes = 10 << 20;

/// A photo picked in the editor and not yet uploaded.
typedef PickedReceipt = ({Uint8List bytes, String type});

/// The media type of a JPEG, PNG or WebP picture, read from its first bytes,
/// or null for anything else.
String? receiptType(Uint8List b) {
  bool at(int offset, List<int> magic) =>
      b.length >= offset + magic.length && listEquals(b.sublist(offset, offset + magic.length), magic);
  if (at(0, [0xff, 0xd8, 0xff])) return 'image/jpeg';
  if (at(0, [0x89, 0x50, 0x4e, 0x47])) return 'image/png';
  if (at(0, 'RIFF'.codeUnits) && at(8, 'WEBP'.codeUnits)) return 'image/webp';
  return null;
}

/// The receipt part of the expense editor: the photo there is, or buttons to
/// add one. Changes wait for the expense to be saved.
class ReceiptField extends ConsumerWidget {
  const ReceiptField({
    super.key,
    required this.token,
    required this.expenseId,
    required this.saved,
    required this.picked,
    required this.onPicked,
    required this.onRemoved,
  });

  final String token;
  final String? expenseId;

  /// Whether the server has a photo that is still meant to stay.
  final bool saved;
  final PickedReceipt? picked;
  final ValueChanged<PickedReceipt> onPicked;
  final VoidCallback onRemoved;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final XFile? file;
    try {
      file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
        requestFullMetadata: false,
      );
    } on PlatformException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      return;
    }
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final type = receiptType(bytes);
    if (type == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorBadImage)));
    } else if (bytes.length > maxReceiptBytes) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorReceiptTooBig)));
    } else {
      onPicked((bytes: bytes, type: type));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final picked = this.picked;
    final id = expenseId;
    final AsyncValue<Uint8List>? photo = picked != null
        ? AsyncData(picked.bytes)
        : saved && id != null
        ? ref.watch(receiptProvider((token: token, id: id)))
        : null;

    if (photo == null) {
      return Wrap(
        spacing: BSpace.s8,
        runSpacing: BSpace.s8,
        children: [
          OutlinedButton.icon(
            onPressed: () => _pick(context, ImageSource.camera),
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(l10n.receiptTakePhoto),
          ),
          OutlinedButton.icon(
            onPressed: () => _pick(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(l10n.receiptChoose),
          ),
        ],
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(BSpace.s12),
          child: Container(
            width: 120,
            height: 160,
            color: scheme.surfaceContainerHighest,
            child: switch (photo) {
              AsyncData(:final value) => Semantics(
                button: true,
                label: l10n.receiptView,
                child: InkWell(
                  onTap: () => showReceipt(context, value),
                  child: Image.memory(value, fit: BoxFit.cover, gaplessPlayback: true),
                ),
              ),
              AsyncError() => Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
        const SizedBox(width: BSpace.s8),
        TextButton.icon(
          onPressed: onRemoved,
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.receiptRemove),
        ),
      ],
    );
  }
}

/// Shows a receipt photo over the whole screen, to zoom into.
Future<void> showReceipt(BuildContext context, Uint8List bytes) => showDialog<void>(
  context: context,
  builder: (context) => Dialog.fullscreen(
    backgroundColor: Colors.black,
    child: Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            maxScale: 6,
            child: Center(child: Image.memory(bytes, semanticLabel: context.l10n.receiptView)),
          ),
        ),
        const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(BSpace.s8),
            child: CloseButton(color: Colors.white),
          ),
        ),
      ],
    ),
  ),
);
