import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/errors.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/grouped_list.dart';
import '../../ui/widgets/page.dart';

/// "3 of 20", or just what is used when there is no limit.
String planUsage(AppLocalizations l10n, PlanUsage usage) {
  final limit = usage.limit;
  return limit == null ? l10n.planUsed(usage.used) : l10n.planUsage(usage.used, limit);
}

/// The account's plan, what it allows, and where to get one.
class PlanPage extends ConsumerWidget {
  const PlanPage({super.key});

  Future<void> _openKofi(BuildContext context, Uri url) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (await launchUrl(url, mode: LaunchMode.externalApplication)) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(myPlanProvider);
    final plan = async.value;
    if (plan == null) {
      return BPage(
        title: l10n.planTitle,
        fillRemaining: true,
        children: [
          if (async.hasError && !async.isLoading)
            EmptyState(
              icon: Icons.cloud_off_outlined,
              title: l10n.planTitle,
              body: errorMessage(l10n, async.error!),
              action: FilledButton.tonal(
                onPressed: () => ref.invalidate(myPlanProvider),
                child: Text(l10n.commonRetry),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
        ],
      );
    }
    final info = ref.watch(serverInfoProvider).value;
    final kofi = externalPayments ? info?.kofiUrl : null;
    final expires = plan.expiresAt;
    String limit(int? n) => n?.toString() ?? l10n.planUnlimited;
    return BPage(
      title: l10n.planTitle,
      children: [
        GroupedList(
          children: [
            GroupedTile(
              icon: Icons.workspace_premium_outlined,
              title: plan.planName,
              subtitle: expires == null
                  ? l10n.planIntro
                  : l10n.planUntil(
                      DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
                          .format(expires.toLocal()),
                    ),
            ),
          ],
        ),
        GroupedList(
          title: l10n.planLimits,
          children: [
            GroupedTile(
              icon: Icons.group_outlined,
              title: l10n.planLimitOwnGroups,
              subtitle: planUsage(l10n, plan.ownGroups),
            ),
            GroupedTile(
              icon: Icons.volunteer_activism_outlined,
              title: l10n.planLimitSponsored,
              subtitle: planUsage(l10n, plan.sponsoredGroups),
            ),
            GroupedTile(
              icon: Icons.receipt_outlined,
              title: l10n.planLimitReceipts,
              subtitle: limit(plan.receiptsPerGroup),
            ),
            GroupedTile(
              icon: Icons.repeat,
              title: l10n.planLimitRecurring,
              subtitle: limit(plan.recurringPerGroup),
            ),
          ],
        ),
        if (kofi != null)
          GroupedList(
            title: l10n.planGet,
            children: [
              GroupedTile(
                icon: Icons.coffee_outlined,
                title: l10n.planKofi,
                subtitle: l10n.planKofiHelp,
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openKofi(context, kofi),
              ),
              for (final email in plan.paymentEmails)
                GroupedTile(icon: Icons.mail_outline, title: email, subtitle: l10n.planPaymentEmailConfirmed),
              if (info?.email ?? false)
                GroupedTile(
                  icon: Icons.add,
                  title: l10n.planPaymentEmailAdd,
                  subtitle: l10n.planPaymentEmailHelp,
                  onTap: () =>
                      showDialog<void>(context: context, builder: (_) => const _PaymentEmailDialog()),
                ),
            ],
          ),
      ],
    );
  }
}

class _PaymentEmailDialog extends ConsumerStatefulWidget {
  const _PaymentEmailDialog();

  @override
  ConsumerState<_PaymentEmailDialog> createState() => _PaymentEmailDialogState();
}

class _PaymentEmailDialogState extends ConsumerState<_PaymentEmailDialog> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final email = _email.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(balnanaApiProvider)!.sendPaymentEmail(email);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.verifyEmailSent(email))));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorMessage(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.planPaymentEmailAdd),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              enabled: !_busy,
              autofocus: true,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(labelText: l10n.accountEmail),
              validator: (v) => (v ?? '').trim().isEmpty ? l10n.errorRequired : null,
            ),
            if (_error case final error?) ...[
              const SizedBox(height: BSpace.s16),
              Text(error, style: TextStyle(color: scheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l10n.commonCancel)),
        TextButton(onPressed: _busy ? null : _submit, child: Text(l10n.forgotPasswordAction)),
      ],
    );
  }
}
