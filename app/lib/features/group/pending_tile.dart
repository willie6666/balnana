import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/money.dart';
import '../../core/offline_cache.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/pending_writes.dart';
import '../../ui/money.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';

/// A new expense or payment made offline that is not on the server yet. It
/// is not in the balances until it is.
class PendingTile extends ConsumerWidget {
  const PendingTile({super.key, required this.write, required this.group});

  final PendingWrite write;
  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (:title, :amount) = _describe(context, write, group);
    final error = write.error;
    final muted = text.bodyMedium?.copyWith(color: error == null ? scheme.onSurfaceVariant : scheme.error);
    return Material(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.md))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showPendingSheet(context, write, group),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: BSpace.s8, vertical: BSpace.s8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: error == null ? scheme.surfaceContainerHighest : scheme.errorContainer,
                child: Icon(
                  error == null ? Icons.cloud_upload_outlined : Icons.error_outline,
                  size: 20,
                  color: error == null ? scheme.onSurfaceVariant : scheme.onErrorContainer,
                ),
              ),
              const SizedBox(width: BSpace.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: BSpace.s8),
                        Text(amount, style: text.moneyRow.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                    Text(
                      error == null ? l10n.pendingWaiting : l10n.pendingRefused(errorMessage(l10n, ApiException(error))),
                      style: muted,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The title and amount [w] will have in [group].
({String title, String amount}) _describe(BuildContext context, PendingWrite w, Group group) {
  final l10n = context.l10n;
  final body = w.decodeBody() ?? const {};
  String name(Object? id) => (id is String ? group.member(id)?.name : null) ?? l10n.someone;
  final title = w.path == PendingPath.payments
      ? l10n.paymentTitle(name(body['fromMemberId']), name(body['toMemberId']))
      : switch (body['title']) {
          final String title => title,
          _ => l10n.someone,
        };
  String amount;
  try {
    final minor = parseAmount(body['amount'] as String? ?? '', group.minorDigits);
    amount = formatMoney(context, minor, group.minorDigits, group.currency, symbol: group.symbol);
  } on Object {
    amount = '';
  }
  return (title: title, amount: amount);
}

Future<void> _showPendingSheet(BuildContext context, PendingWrite w, Group group) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  showDragHandle: true,
  builder: (context) => Consumer(
    builder: (context, ref, _) {
      final l10n = context.l10n;
      final sender = ref.read(pendingSenderProvider.notifier);
      final (:title, :amount) = _describe(context, w, group);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(BSpace.s24, 0, BSpace.s24, BSpace.s8),
              child: Text('$title · $amount', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: Text(l10n.commonRetry),
              onTap: () {
                Navigator.of(context).pop();
                sender.retry(w);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n.pendingDiscard),
              onTap: () {
                Navigator.of(context).pop();
                sender.discard(w);
              },
            ),
            const SizedBox(height: BSpace.s8),
          ],
        ),
      );
    },
  ),
);
