import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';

/// Whether this device may change how [member] is paid. In accounts mode it
/// takes being them, so nobody can send their debtors to another account.
bool mayEditPayment(Member member, {required bool accounts, String? me}) =>
    !accounts || (member.claimed && member.id == me);

/// Opens the sheet where how [member] is paid in [group] is entered.
Future<void> showPaymentDetailsSheet(BuildContext context, Group group, Member member) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PaymentDetailsSheet(group: group, member: member),
    );

/// Names offered for a way to pay; anything else can be typed.
List<String> _suggestions(AppLocalizations l10n) => [l10n.paymentDetailBank, 'PayPal', 'LINE Pay', 'JKO Pay'];

class _PaymentDetailsSheet extends ConsumerStatefulWidget {
  const _PaymentDetailsSheet({required this.group, required this.member});

  final Group group;
  final Member member;

  @override
  ConsumerState<_PaymentDetailsSheet> createState() => _PaymentDetailsSheetState();
}

class _Entry {
  _Entry([PaymentDetail? d])
    : label = TextEditingController(text: d?.label),
      value = TextEditingController(text: d?.value);

  final TextEditingController label, value;

  bool get blank => label.text.trim().isEmpty && value.text.trim().isEmpty;

  void dispose() {
    label.dispose();
    value.dispose();
  }
}

class _PaymentDetailsSheetState extends ConsumerState<_PaymentDetailsSheet> {
  final _form = GlobalKey<FormState>();
  late final List<_Entry> _entries = [
    for (final d in widget.member.paymentDetails) _Entry(d),
    if (widget.member.paymentDetails.isEmpty) _Entry(),
  ];
  bool _busy = false;

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final l10n = context.l10n;
    final m = widget.member;
    setState(() => _busy = true);
    try {
      await groupApiOf(ref, widget.group.token).updateMember(
        m.id,
        m.name,
        color: m.color,
        paymentDetails: [
          for (final e in _entries)
            if (!e.blank) PaymentDetail(label: e.label.text.trim(), value: e.value.text.trim()),
        ],
        digits: widget.group.minorDigits,
      );
      refreshGroup(ref, widget.group.token);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
    }
  }

  String? _required(_Entry e, String? v) =>
      !e.blank && (v ?? '').trim().isEmpty ? context.l10n.errorRequired : null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(BSpace.s16, 0, BSpace.s16, BSpace.s16),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.memberPaymentDetails, style: text.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: BSpace.s8),
                Text(
                  l10n.paymentDetailsHelp(widget.member.name),
                  style: text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                for (final (i, e) in _entries.indexed) ...[
                  const SizedBox(height: BSpace.s16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: e.label,
                              textCapitalization: TextCapitalization.words,
                              inputFormatters: [LengthLimitingTextInputFormatter(PaymentDetail.maxLabel)],
                              decoration: InputDecoration(
                                labelText: l10n.paymentDetailLabel,
                                suffixIcon: PopupMenuButton<String>(
                                  tooltip: l10n.paymentDetailSuggestions,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  onSelected: (s) => setState(() => e.label.text = s),
                                  itemBuilder: (_) => [
                                    for (final s in _suggestions(l10n))
                                      PopupMenuItem(value: s, child: Text(s)),
                                  ],
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                              validator: (v) => _required(e, v),
                            ),
                            const SizedBox(height: BSpace.s8),
                            TextFormField(
                              controller: e.value,
                              keyboardType: TextInputType.url,
                              autocorrect: false,
                              inputFormatters: [LengthLimitingTextInputFormatter(PaymentDetail.maxValue)],
                              decoration: InputDecoration(labelText: l10n.paymentDetailValue),
                              onChanged: (_) => setState(() {}),
                              validator: (v) => _required(e, v),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.commonRemove,
                        onPressed: () => setState(() => _entries.removeAt(i).dispose()),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
                if (_entries.length < PaymentDetail.max) ...[
                  const SizedBox(height: BSpace.s8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _entries.add(_Entry())),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.paymentDetailAdd),
                    ),
                  ),
                ],
                const SizedBox(height: BSpace.s16),
                FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.commonSave)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// How [member] can be paid, each with a button to copy it and, for a web
/// address, one to open it.
class PaymentDetailList extends StatelessWidget {
  const PaymentDetailList({super.key, required this.member});

  final Member member;

  Future<void> _copy(BuildContext context, PaymentDetail d) async {
    final messenger = ScaffoldMessenger.of(context);
    final copied = context.l10n.paymentDetailCopied(d.label);
    await Clipboard.setData(ClipboardData(text: d.value));
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final d in member.paymentDetails)
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${d.label}  ',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      TextSpan(text: d.value),
                    ],
                  ),
                  style: text.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (d.link case final link?)
                IconButton(
                  tooltip: l10n.paymentDetailOpen,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => launchUrl(link, mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new, size: 20),
                ),
              IconButton(
                tooltip: l10n.paymentDetailCopy,
                visualDensity: VisualDensity.compact,
                onPressed: () => _copy(context, d),
                icon: const Icon(Icons.copy, size: 20),
              ),
            ],
          ),
      ],
    );
  }
}
