import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/money.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/money.dart';
import '../../ui/theme.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/member_avatar.dart';
import 'group_page.dart';
import 'identity_sheet.dart';

/// The top of a group page: where this device's member stands, everyone's
/// balance and the payments that would settle them.
class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final myId = myMemberId(ref, group.token);
    final me = group.member(myId);
    final onHeader = scheme.onPrimaryContainer;

    Widget prompt(String title, String body, String action, VoidCallback onPressed) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.titleLarge?.copyWith(color: onHeader)),
        const SizedBox(height: BSpace.s4),
        Text(body, style: text.bodyMedium?.copyWith(color: onHeader)),
        const SizedBox(height: BSpace.s16),
        FilledButton(onPressed: onPressed, child: Text(action)),
      ],
    );

    final Widget header;
    if ((me == null || me.left) && ref.watch(signedInProvider)) {
      // An open group the account is not in yet.
      header = prompt(
        l10n.heroJoinTitle,
        l10n.heroJoinBody,
        l10n.joinAction,
        () => context.push('/g/${group.token}/join'),
      );
    } else if (me == null || me.left) {
      header = prompt(l10n.heroWhoTitle, l10n.heroWhoBody, l10n.heroWhoAction, () => showIdentitySheet(context, group));
    } else {
      final balance = me.balance;
      final label = switch (balance.sign) {
        1 => l10n.heroOwed,
        -1 => l10n.heroOwe,
        _ => l10n.heroSettled,
      };
      header = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.titleMedium?.copyWith(color: onHeader)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              formatMoney(context, balance.abs(), group.minorDigits, group.currency),
              style: text.moneyHero.copyWith(color: onHeader),
            ),
          ),
        ],
      );
    }

    // Members who left stay while they still owe or are owed something.
    final members = [
      for (final m in group.members)
        if (!m.left || m.balance != BigInt.zero) m,
    ];
    final largest = members.fold(BigInt.zero, (a, m) => m.balance.abs() > a ? m.balance.abs() : a);
    final balances = ref.watch(balancesProvider(group.token)).value;
    // Suggestions that involve this device's member first.
    final transfers = [
      ...?balances?.transfers.where((t) => t.from == myId || t.to == myId),
      ...?balances?.transfers.where((t) => t.from != myId && t.to != myId),
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(BShape.xl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: scheme.primaryContainer,
            child: Padding(padding: const EdgeInsets.all(BSpace.s24), child: header),
          ),
          ColoredBox(
            color: scheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s8, BSpace.s16, BSpace.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final m in members)
                    BalanceBeam(
                      member: m,
                      isMe: m.id == myId,
                      net: m.balance,
                      largest: largest,
                      amount: formatMoney(context, m.balance, group.minorDigits, group.currency, signed: true),
                    ),
                  if (transfers.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(BSpace.s4, BSpace.s12, BSpace.s4, BSpace.s8),
                      child: Text(l10n.suggestedPayments, style: text.labelLarge?.copyWith(color: scheme.primary)),
                    ),
                    for (final t in transfers) _TransferTile(group: group, transfer: t, me: myId),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One member's net balance as a bar from the center: right and green when
/// they are owed, left and red when they owe.
class BalanceBeam extends StatelessWidget {
  const BalanceBeam({
    super.key,
    required this.member,
    required this.isMe,
    required this.net,
    required this.largest,
    required this.amount,
  });

  final Member member;
  final bool isMe;
  final BigInt net;
  final BigInt largest;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final color = balanceColor(context, net);
    final fraction = largest == BigInt.zero ? 0.0 : (net.abs() * BigInt.from(1000) ~/ largest).toInt() / 1000;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BSpace.s8),
      child: Row(
        children: [
          MemberAvatar(member: member, size: 36),
          const SizedBox(width: BSpace.s12),
          SizedBox(
            width: 96,
            child: Text(
              isMe ? l10n.memberYou(member.name) : member.name,
              style: text.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: _Bar(fraction: net.isNegative ? fraction : 0, color: color, start: true),
                    ),
                  ),
                  Container(width: 2, color: scheme.outlineVariant),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _Bar(fraction: net > BigInt.zero ? fraction : 0, color: color, start: false),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: BSpace.s12),
          SizedBox(
            width: 104,
            child: Text(
              amount,
              textAlign: TextAlign.end,
              style: text.moneyRow.copyWith(color: color, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.color, required this.start});

  final double fraction;
  final Color color;

  /// Grows toward the start edge (left in left-to-right layouts).
  final bool start;

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(BShape.sm);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: fraction),
      duration: BMotion.long,
      curve: BMotion.emphasizedDecelerate,
      builder: (context, value, _) => FractionallySizedBox(
        widthFactor: value,
        child: Container(
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadiusDirectional.horizontal(
              start: start ? radius : Radius.zero,
              end: start ? Radius.zero : radius,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransferTile extends ConsumerWidget {
  const _TransferTile({required this.group, required this.transfer, required this.me});

  final Group group;
  final Transfer transfer;
  final String? me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final from = group.member(transfer.from), to = group.member(transfer.to);
    if (from == null || to == null) return const SizedBox.shrink();
    final involved = transfer.from == me || transfer.to == me;
    final label = transfer.from == me
        ? l10n.transferYouPay(to.name)
        : transfer.to == me
        ? l10n.transferPaysYou(from.name)
        : l10n.transferPays(from.name, to.name);

    return Padding(
      padding: const EdgeInsets.only(bottom: BSpace.tileGap * 2),
      child: Material(
        color: involved ? scheme.secondaryContainer : scheme.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(BShape.md))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(BSpace.s12, BSpace.s8, BSpace.s8, BSpace.s8),
          child: Row(
            children: [
              MemberAvatar(member: from, size: 32),
              Icon(Icons.arrow_forward, size: 18, color: scheme.onSurfaceVariant),
              MemberAvatar(member: to, size: 32),
              const SizedBox(width: BSpace.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(
                      formatMoney(context, transfer.amount, group.minorDigits, group.currency),
                      style: text.moneyRow,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => recordPayment(context, ref, group, transfer),
                child: Text(l10n.recordPayment),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirms a payment (the amount can be changed) and records it.
Future<void> recordPayment(BuildContext context, WidgetRef ref, Group group, Transfer suggested) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final amount = await showDialog<BigInt>(
    context: context,
    builder: (context) => _PaymentDialog(group: group, transfer: suggested),
  );
  if (amount == null || !context.mounted) return;
  try {
    await groupApiOf(ref, group.token).recordPayment(suggested.from, suggested.to, amount, group.minorDigits);
    refreshGroup(ref, group.token);
    messenger.showSnackBar(SnackBar(content: Text(l10n.paymentRecorded)));
  } on ApiException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
  }
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.group, required this.transfer});

  final Group group;
  final Transfer transfer;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late final _amount = TextEditingController(
    text: formatAmount(widget.transfer.amount, widget.group.minorDigits),
  );
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    try {
      final v = parseAmount(_amount.text.trim().replaceAll(',', '.'), widget.group.minorDigits);
      if (v <= BigInt.zero) throw const MoneyException(MoneyError.invalidAmount);
      Navigator.of(context).pop(v);
    } on MoneyException catch (e) {
      setState(() => _error = moneyErrorMessage(context.l10n, e.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final g = widget.group;
    final from = g.member(widget.transfer.from)!, to = g.member(widget.transfer.to)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return AlertDialog(
      title: Text(l10n.recordPaymentTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.paymentTitle(from.name, to.name)),
          const SizedBox(height: BSpace.s16),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))],
            decoration: InputDecoration(
              labelText: l10n.expenseAmount,
              prefixText: currencySymbol(locale, g.currency),
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: BSpace.s8),
          Text(l10n.recordPaymentHelp, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.recordPayment)),
      ],
    );
  }
}
