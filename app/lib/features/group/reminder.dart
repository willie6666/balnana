import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/money.dart';
import '../../core/server.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/money.dart';
import '../../ui/tokens.dart';
import 'group_page.dart';

enum _Way { notify, share }

/// Reminds whoever owes this device's member [transfer]: by a notification,
/// when the server sends them and the group's plan allows it, or by a message
/// to share, which is always free.
Future<void> remind(BuildContext context, WidgetRef ref, Group group, Transfer transfer) async {
  final way = await showModalBottomSheet<_Way>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (context) => _ReminderSheet(group: group, debtor: group.member(transfer.from)!),
  );
  if (!context.mounted) return;
  switch (way) {
    case _Way.notify:
      await _notify(context, ref, group, transfer);
    case _Way.share:
      await _share(context, ref, group, transfer);
    case null:
      break;
  }
}

Future<void> _notify(BuildContext context, WidgetRef ref, Group group, Transfer transfer) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final name = group.member(transfer.from)?.name ?? '';
  try {
    final devices = await groupApiOf(ref, group.token).remindMember(transfer.from);
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(devices > 0 ? l10n.remindSent(name) : l10n.remindNoDevices(name)),
        // Nobody would see it: a message reaches them some other way.
        action: devices > 0
            ? null
            : SnackBarAction(
                label: l10n.remindShare,
                onPressed: () {
                  if (context.mounted) _share(context, ref, group, transfer);
                },
              ),
      ),
    );
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
  }
}

/// Hands the reminder to the system share sheet. The web has no sheet that
/// works everywhere, so there it is copied instead.
Future<void> _share(BuildContext context, WidgetRef ref, Group group, Transfer transfer) async {
  final l10n = context.l10n;
  final payee = group.member(transfer.to);
  if (payee == null) return;
  final amount = formatMoney(context, transfer.amount, group.minorDigits, group.currency, symbol: group.symbol);
  final text = reminderText(l10n, group, payee, amount, groupLink(ref, group.token));
  if (!kIsWeb) {
    await SharePlus.instance.share(ShareParams(text: text, subject: group.name));
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  await Clipboard.setData(ClipboardData(text: text));
  messenger.showSnackBar(SnackBar(content: Text(l10n.remindCopied)));
}

/// The message reminding someone to pay [payee] [amount], with how to and
/// the group's [link].
@visibleForTesting
String reminderText(AppLocalizations l10n, Group group, Member payee, String amount, String link) => [
  l10n.reminderMessage(payee.name, amount, group.name),
  if (payee.paymentDetails.isNotEmpty) ...[
    '',
    l10n.reminderHowToPay,
    for (final d in payee.paymentDetails) '${d.label}: ${d.value}',
  ],
  '',
  link,
].join('\n');

class _ReminderSheet extends ConsumerWidget {
  const _ReminderSheet({required this.group, required this.debtor});

  final Group group;
  final Member debtor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final info = ref.watch(serverInfoProvider).value;
    // Without billing any group may; with it, the group's plan says.
    final plan = info?.billing == true ? ref.watch(groupPlanProvider(group.token)) : null;
    final allowed = plan == null || plan.value?.reminders == true;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(BSpace.s24, 0, BSpace.s24, BSpace.s8),
            child: Text(l10n.remindTitle(debtor.name), style: Theme.of(context).textTheme.titleLarge),
          ),
          if (info?.push == true)
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(l10n.remindNotify),
              subtitle: plan?.hasValue == true && !allowed ? Text(l10n.remindNeedsPlan) : null,
              enabled: allowed,
              onTap: () => Navigator.of(context).pop(_Way.notify),
            ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(l10n.remindShare),
            onTap: () => Navigator.of(context).pop(_Way.share),
          ),
          const SizedBox(height: BSpace.s8),
        ],
      ),
    );
  }
}
