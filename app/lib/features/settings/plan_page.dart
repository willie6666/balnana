import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/errors.dart';
import '../../core/google_play.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/grouped_list.dart';
import '../../ui/widgets/page.dart';
import '../../ui/widgets/play_purchases.dart';

/// "3 of 20", or just what is used when there is no limit.
String planUsage(AppLocalizations l10n, PlanUsage usage) {
  final limit = usage.limit;
  return limit == null ? l10n.planUsed(usage.used) : l10n.planUsage(usage.used, limit);
}

/// The account's plan, what it allows, and where to get one.
class PlanPage extends ConsumerStatefulWidget {
  const PlanPage({super.key});

  @override
  ConsumerState<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends ConsumerState<PlanPage> {
  List<PlayOffer> _offers = const [];
  bool _buying = false;

  /// Whether Google Play has been asked since the plan first came, so
  /// reloading the plan after a report doesn't ask again.
  bool _askedPlay = false;
  bool _playFailed = false;

  @override
  void initState() {
    super.initState();
    // Listened to, as the plan may only load on a retry.
    ref.listenManual(myPlanProvider, fireImmediately: true, (_, next) {
      final play = next.value?.play;
      if (play != null && !_askedPlay) _loadPlay(play);
    });
  }

  Future<void> _loadPlay(PlayBilling play) async {
    _askedPlay = true;
    final store = ref.read(googlePlayProvider);
    final api = ref.read(balnanaApiProvider);
    try {
      final offers = await store.offers(play.products);
      if (mounted) {
        setState(() {
          _offers = offers;
          _playFailed = false;
        });
      }
      // For a purchase that never reached the server, or a renewal on a server
      // without Google's notifications. What fails is tried on the next visit.
      await _report(api, await store.purchases());
    } on PlayException {
      if (mounted) setState(() => _playFailed = true);
    } on ApiException {
      return;
    }
  }

  void _retryPlay(PlayBilling play) {
    setState(() => _playFailed = false);
    _loadPlay(play);
  }

  /// Tells the server about purchases, and returns whether any gave a plan.
  /// [api] is read before waiting for Play: the page may close meanwhile, and
  /// what was bought still has to be reported.
  Future<bool> _report(BalnanaApi? api, List<String> tokens) async {
    if (tokens.isEmpty || api == null) return false;
    try {
      return await reportPlayPurchases(api, tokens);
    } finally {
      if (mounted) ref.invalidate(myPlanProvider);
    }
  }

  Future<void> _buy(PlayOffer offer, PlayBilling play) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final store = ref.read(googlePlayProvider);
    final api = ref.read(balnanaApiProvider);
    void tell(String message) => messenger.showSnackBar(SnackBar(content: Text(message)));
    setState(() => _buying = true);
    try {
      final tokens = await store.buy(offer, play.accountId);
      if (tokens.isNotEmpty && !await _report(api, tokens)) tell(l10n.planPlayPending);
    } on PlayException catch (e) {
      if (e.owned) {
        // Held but not known here: likely another account's, which the server says.
        try {
          final held = await store.purchases();
          if (!await _report(api, held)) tell(l10n.planPlayHeldElsewhere);
        } on ApiException catch (e) {
          tell(errorMessage(l10n, e));
        } on PlayException {
          tell(l10n.planPlayFailed);
        }
      } else {
        tell(l10n.planPlayFailed);
      }
    } on ApiException catch (e) {
      tell(errorMessage(l10n, e));
    }
    if (mounted) setState(() => _buying = false);
  }

  Future<void> _open(Uri url) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (await launchUrl(url, mode: LaunchMode.externalApplication)) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
  }

  Future<void> _copyCode(String code) async {
    final message = context.l10n.planPaymentCodeCopied;
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: code));
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
    final play = plan.play;
    final held = play?.held ?? const <String>[];
    // A second subscription would pay twice for one plan.
    final offers = held.isNotEmpty ? const <PlayOffer>[] : _offers;
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
            if (play != null && held.isNotEmpty)
              GroupedTile(
                icon: Icons.manage_accounts_outlined,
                title: l10n.planPlayManage,
                subtitle: play.subscribed.isEmpty ? l10n.planPlayOnHold : l10n.planPlayManageHelp,
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _open(
                  Uri.https('play.google.com', '/store/account/subscriptions', {
                    'sku': held.first,
                    'package': play.packageName,
                  }),
                ),
              ),
          ],
        ),
        GroupedList(
          title: l10n.planLimits,
          children: [
            GroupedTile(
              icon: Icons.group_outlined,
              title: l10n.planLimitJoinedGroups,
              subtitle: planUsage(l10n, plan.joinedGroups),
            ),
            GroupedTile(
              icon: Icons.volunteer_activism_outlined,
              title: l10n.planLimitSponsored,
              subtitle: planUsage(l10n, plan.sponsoredGroups),
            ),
            GroupedTile(
              icon: Icons.groups_outlined,
              title: l10n.planLimitMembers,
              subtitle: limit(plan.membersPerGroup),
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
        if (offers.isNotEmpty || kofi != null || (_playFailed && held.isEmpty))
          GroupedList(
            title: l10n.planGet,
            children: [
              if (_playFailed && held.isEmpty)
                GroupedTile(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.planPlayUnavailable,
                  subtitle: l10n.commonRetry,
                  onTap: () => _retryPlay(play!),
                ),
              for (final offer in offers)
                GroupedTile(
                  icon: Icons.shop_outlined,
                  title: offer.name,
                  subtitle: switch (offer.months) {
                    final months? => l10n.planPlayPrice(months, offer.price),
                    null => offer.price,
                  },
                  onTap: _buying ? null : () => _buy(offer, play!),
                ),
              if (kofi != null) ...[
                GroupedTile(
                  icon: Icons.coffee_outlined,
                  title: l10n.planKofi,
                  subtitle: plan.paymentCode == null ? null : l10n.planKofiHelp,
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _open(kofi),
                ),
                if (plan.paymentCode case final code?) ...[
                  GroupedTile(
                    icon: Icons.tag,
                    title: code,
                    subtitle: l10n.planPaymentCodeHelp,
                    trailing: const Icon(Icons.copy),
                    onTap: () => _copyCode(code),
                  ),
                  GroupedTile(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.planPaymentClaim,
                    subtitle: l10n.planPaymentClaimHelp,
                    onTap: () => showDialog<void>(context: context, builder: (_) => const PaymentClaimDialog()),
                  ),
                ],
              ],
            ],
          ),
      ],
    );
  }
}

/// Takes a Ko-fi payment made without the account's code.
class PaymentClaimDialog extends ConsumerStatefulWidget {
  const PaymentClaimDialog({super.key});

  @override
  ConsumerState<PaymentClaimDialog> createState() => _PaymentClaimDialogState();
}

class _PaymentClaimDialogState extends ConsumerState<PaymentClaimDialog> {
  final _form = GlobalKey<FormState>();
  final _reference = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    // The dialog can be dismissed while this runs, and the plan still changes.
    final container = ProviderScope.containerOf(context, listen: false);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(balnanaApiProvider)!.claimPayment(_reference.text.trim());
      container.invalidate(myPlanProvider);
      if (mounted) navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.planPaymentClaimed)));
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
      title: Text(l10n.planPaymentClaim),
      scrollable: true,
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _reference,
              enabled: !_busy,
              autofocus: true,
              autocorrect: false,
              keyboardType: TextInputType.url,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(labelText: l10n.planPaymentClaimField),
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
        TextButton(onPressed: _busy ? null : _submit, child: Text(l10n.planPaymentClaimAction)),
      ],
    );
  }
}
