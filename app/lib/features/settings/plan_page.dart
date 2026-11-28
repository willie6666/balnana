import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_store.dart';
import '../../core/errors.dart';
import '../../core/google_play.dart';
import '../../core/l10n.dart';
import '../../core/server.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets/app_store_purchases.dart';
import '../../ui/widgets/empty_state.dart';
import '../../ui/widgets/grouped_list.dart';
import '../../ui/widgets/page.dart';
import '../../ui/widgets/play_purchases.dart';
import '../../ui/widgets/usage_tile.dart';
import 'plan_comparison.dart';
import 'plan_offers.dart';
import 'privacy_page.dart';

/// "3 of 20", or just what is used when there is no limit.
String planUsage(AppLocalizations l10n, PlanUsage usage) {
  final limit = usage.limit;
  return limit == null ? l10n.planUsed(usage.used) : l10n.planUsage(usage.used, limit);
}

/// A row with a bar for how much of [usage] is used.
GroupedLimitTile planUsageTile(
  AppLocalizations l10n, {
  required IconData icon,
  required String title,
  required PlanUsage usage,
}) => GroupedLimitTile(
  icon: icon,
  title: title,
  label: planUsage(l10n, usage),
  used: usage.used,
  limit: usage.limit,
);

/// The account's plan, what it allows, and where to get one.
class PlanPage extends ConsumerStatefulWidget {
  const PlanPage({super.key, this.paypal});

  /// How a PayPal checkout went, as PayPal's way back says.
  final String? paypal;

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

  /// The same for the App Store.
  List<AppStoreOffer> _storeOffers = const [];
  bool _askedAppStore = false;
  bool _appStoreFailed = false;

  /// Whether a PayPal page was opened, so the plan is looked at again when
  /// the payer comes back.
  bool _checkedOut = false;
  late final AppLifecycleListener _lifecycle;

  /// The picked [PlanChoice.id]; null for the first. This and what is folded
  /// open are kept here, as the list drops what scrolls away.
  String? _selected;

  /// Null until tapped, when the page decides.
  bool? _comparing;
  bool _showUsage = false;

  @override
  void initState() {
    super.initState();
    // Listened to, as the plan may only load on a retry.
    ref.listenManual(myPlanProvider, fireImmediately: true, (_, next) {
      final play = next.value?.play;
      if (play != null && !_askedPlay) _loadPlay(play);
      final appStore = next.value?.appStore;
      if (appStore != null && !_askedAppStore) _loadAppStore(appStore);
    });
    _lifecycle = AppLifecycleListener(onShow: _cameBack);
    if (widget.paypal != null) WidgetsBinding.instance.addPostFrameCallback((_) => _tellPayPal());
  }

  @override
  void didUpdateWidget(PlanPage old) {
    super.didUpdateWidget(old);
    if (widget.paypal != null && widget.paypal != old.paypal) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tellPayPal());
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _cameBack() {
    if (!_checkedOut) return;
    _checkedOut = false;
    ref.invalidate(myPlanProvider);
  }

  void _tellPayPal() {
    if (!mounted) return;
    final l10n = context.l10n;
    final message = switch (widget.paypal) {
      'done' => l10n.planPayPalDone,
      'pending' => l10n.planPayPalPending,
      'cancelled' => l10n.planPayPalCancelled,
      _ => l10n.planPayPalFailed,
    };
    ref.invalidate(myPlanProvider);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

  Future<void> _loadAppStore(AppStoreBilling billing) async {
    _askedAppStore = true;
    final store = ref.read(appStoreProvider);
    final api = ref.read(balnanaApiProvider);
    try {
      final offers = await store.offers(billing.products);
      if (mounted) {
        setState(() {
          _storeOffers = offers;
          _appStoreFailed = false;
        });
      }
      // For a purchase that never reached the server, or a renewal on a server
      // without Apple's notifications. What fails is tried on the next visit.
      await _reportAppStore(api, await store.purchases());
    } on AppStoreException {
      if (mounted) setState(() => _appStoreFailed = true);
    } on ApiException {
      return;
    }
  }

  void _retryAppStore(AppStoreBilling billing) {
    setState(() => _appStoreFailed = false);
    _loadAppStore(billing);
  }

  /// Tells the server about App Store transactions, and returns whether any
  /// gave a plan.
  Future<bool> _reportAppStore(BalnanaApi? api, List<String> signed) async {
    if (signed.isEmpty || api == null) return false;
    try {
      return await reportAppStorePurchases(api, signed);
    } finally {
      if (mounted) ref.invalidate(myPlanProvider);
    }
  }

  Future<void> _buyAppStore(AppStoreOffer offer, AppStoreBilling billing) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final store = ref.read(appStoreProvider);
    final api = ref.read(balnanaApiProvider);
    void tell(String message) => messenger.showSnackBar(SnackBar(content: Text(message)));
    setState(() => _buying = true);
    try {
      final signed = await store.buy(offer, billing.accountToken);
      if (signed.isNotEmpty && !await _reportAppStore(api, signed)) tell(l10n.planAppStoreFailed);
    } on AppStoreException catch (e) {
      tell(e.pending ? l10n.planAppStorePending : l10n.planAppStoreFailed);
    } on ApiException catch (e) {
      tell(errorMessage(l10n, e));
    }
    if (mounted) setState(() => _buying = false);
  }

  /// Asks Apple again what this Apple ID holds, as App Review expects a
  /// restore button to.
  Future<void> _restore() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final store = ref.read(appStoreProvider);
    final api = ref.read(balnanaApiProvider);
    void tell(String message) => messenger.showSnackBar(SnackBar(content: Text(message)));
    setState(() => _buying = true);
    try {
      final held = await store.purchases(sync: true);
      if (held.isEmpty || !await _reportAppStore(api, held)) tell(l10n.planRestoreNone);
    } on AppStoreException {
      tell(l10n.planAppStoreUnavailable);
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

  Future<void> _payPal(PayPalOffer offer) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    void tell(String message) => messenger.showSnackBar(SnackBar(content: Text(message)));
    setState(() => _buying = true);
    try {
      final url = await ref
          .read(balnanaApiProvider)!
          .paypalCheckout(offer.product, kIsWeb ? 'web' : 'android');
      // On the web the page goes to PayPal, which sends it back here.
      _checkedOut = true;
      final opened = await launchUrl(
        url,
        mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
        webOnlyWindowName: '_self',
      );
      if (!opened) tell(l10n.errorGeneric);
    } on ApiException catch (e) {
      tell(errorMessage(l10n, e));
    } finally {
      // Not left disabled when opening PayPal fails some other way.
      if (mounted) setState(() => _buying = false);
    }
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
    final appStore = plan.appStore;
    final storeOffers = [
      for (final offer in _storeOffers)
        if (!(appStore?.subscribed.contains(offer.productId) ?? false)) offer,
    ];
    final paypal = externalPayments ? plan.paypal : null;
    final paypalOffers = [
      for (final offer in paypal?.offers ?? const <PayPalOffer>[])
        if (!offer.subscription || !paypal!.subscribed.contains(offer.product)) offer,
    ];
    final choices = sortedChoices([
      for (final offer in offers)
        _storeChoice(
          l10n,
          id: 'play:${offer.productId}:${offer.period}',
          name: offer.name,
          price: offer.price,
          months: offer.months,
          buy: () => _buy(offer, play!),
        ),
      for (final offer in storeOffers)
        _storeChoice(
          l10n,
          id: 'appstore:${offer.productId}',
          name: offer.name,
          price: offer.price,
          months: offer.months,
          buy: () => _buyAppStore(offer, appStore!),
        ),
      for (final offer in paypalOffers)
        PlanChoice(
          id: 'paypal:${offer.product}',
          planName: offer.planName,
          subscription: offer.subscription,
          days: offer.days,
          period: l10n.planPayPalDays(offer.days),
          price: switch ((offer.amount, offer.currency)) {
            (final amount?, final currency?) when !offer.subscription => '$amount $currency',
            _ => null,
          },
          note: offer.subscription
              ? '${l10n.planPayPalSubscription(offer.days)}\n${l10n.planPriceAtPayPal}'
              : l10n.planOnceNote,
          buy: () => _payPal(offer),
        ),
    ]);
    final selected = choices.where((c) => c.id == _selected).firstOrNull ?? choices.firstOrNull;

    final playDown = _playFailed && held.isEmpty;
    final buyable = choices.isNotEmpty || kofi != null || playDown || _appStoreFailed || appStore != null;
    final manage = [
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
      if (appStore != null && appStore.subscribed.isNotEmpty)
        GroupedTile(
          icon: Icons.manage_accounts_outlined,
          title: l10n.planPlayManage,
          subtitle: l10n.planAppStoreManageHelp,
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _open(Uri.https('apps.apple.com', '/account/subscriptions')),
        ),
      if (paypal != null && paypal.subscribed.isNotEmpty)
        GroupedTile(
          icon: Icons.manage_accounts_outlined,
          title: l10n.planPayPalManage,
          subtitle: l10n.planPayPalManageHelp,
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _open(Uri.https('www.paypal.com', '/myaccount/autopay/')),
        ),
    ];
    // Selling comes first only to someone who has nothing yet.
    final selling = buyable && !plan.paid && manage.isEmpty;
    final comparison = (plan.comparison?.plans.length ?? 0) > 1 ? plan.comparison : null;
    final target = planTarget(comparison, selected?.planName);

    final buy = buyable
        ? _buySection(
            context,
            choices: choices,
            selected: selected,
            kofi: kofi,
            play: play,
            playDown: playDown,
            appStore: appStore,
            paid: plan.paid,
            targetName: target?.name,
          )
        : const <Widget>[];
    final fine = [
      if (buyable)
        ..._finePrint(
          context,
          kofi: kofi,
          appStore: appStore,
          storeSells: storeOffers.isNotEmpty,
          selling: selected != null || kofi != null,
          termsUrl: info?.termsUrl,
        )
      else if (info?.termsUrl != null)
        GroupedList(children: [_termsTile(l10n)]),
    ];
    final limits = _limits(l10n, plan);
    Widget compare(PlanComparisonData data) {
      final open = _comparing ?? !buyable;
      return PlanFold(
        icon: Icons.table_chart_outlined,
        title: l10n.planCompare,
        open: open,
        onToggle: () => setState(() => _comparing = !open),
        child: PlanComparisonTable(comparison: data, titled: false),
      );
    }

    if (selling) {
      bool nearlyFull(PlanUsage usage) {
        final limit = usage.limit;
        return limit != null && limit > 0 && usage.used >= limit * 0.8;
      }

      return BPage(
        title: l10n.planTitle,
        children: [
          PlanHero(target: target),
          // What is about to run out is a reason to look further.
          if (nearlyFull(plan.joinedGroups))
            GroupedList(
              children: [
                planUsageTile(
                  l10n,
                  icon: Icons.group_outlined,
                  title: l10n.planLimitJoinedGroups,
                  usage: plan.joinedGroups,
                ),
              ],
            ),
          // The prices come before the details, to be seen without scrolling.
          ...buy,
          if (comparison != null && target != null) PlanBenefits(comparison: comparison, target: target),
          ...fine,
          if (comparison != null) compare(comparison),
          PlanFold(
            icon: Icons.data_usage,
            title: l10n.planUsageNow(plan.planName),
            open: _showUsage,
            onToggle: () => setState(() => _showUsage = !_showUsage),
            child: GroupedList(children: limits),
          ),
        ],
      );
    }
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
            ...manage,
            // A plan does nothing for a group until it is shared with it.
            if (plan.paid && plan.sponsoredGroups.limit != 0)
              GroupedTile(
                icon: Icons.upgrade,
                title: l10n.sharePlanTitle,
                subtitle: l10n.sharePlanSettingsHelp,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/sharing'),
              ),
          ],
        ),
        GroupedList(title: l10n.planLimits, children: limits),
        if (comparison != null) compare(comparison),
        ...buy,
        ...fine,
      ],
    );
  }

  PlanChoice _storeChoice(
    AppLocalizations l10n, {
    required String id,
    required String name,
    required String price,
    required int? months,
    required VoidCallback buy,
  }) => PlanChoice(
    id: id,
    planName: name,
    subscription: true,
    days: (months ?? 0) * 30,
    period: months == null ? null : planMonthsLabel(l10n, months),
    price: price,
    note: l10n.planAutoRenews,
    buy: buy,
  );

  List<Widget> _limits(AppLocalizations l10n, MyPlan plan) {
    String limit(int? n) => n?.toString() ?? l10n.planUnlimited;
    return [
      planUsageTile(
        l10n,
        icon: Icons.group_outlined,
        title: l10n.planLimitJoinedGroups,
        usage: plan.joinedGroups,
      ),
      planUsageTile(
        l10n,
        icon: Icons.upgrade,
        title: l10n.planLimitSponsored,
        usage: plan.sponsoredGroups,
      ),
      GroupedLimitTile(
        icon: Icons.groups_outlined,
        title: l10n.planLimitMembers,
        label: limit(plan.membersPerGroup),
      ),
      GroupedLimitTile(
        icon: Icons.receipt_outlined,
        title: l10n.planLimitReceipts,
        label: limit(plan.receiptsPerGroup),
      ),
      GroupedLimitTile(
        icon: Icons.repeat,
        title: l10n.planLimitRecurring,
        label: limit(plan.recurringPerGroup),
      ),
      GroupedLimitTile(
        icon: Icons.notifications_active_outlined,
        title: l10n.planLimitReminders,
        label: plan.reminders ? l10n.planIncluded : l10n.planNotIncluded,
      ),
      GroupedLimitTile(
        icon: Icons.visibility_outlined,
        title: l10n.planLimitViewLink,
        label: plan.viewLink ? l10n.planIncluded : l10n.planNotIncluded,
      ),
    ];
  }

  Widget _termsTile(AppLocalizations l10n) => GroupedTile(
    icon: Icons.gavel_outlined,
    title: l10n.termsTitle,
    subtitle: l10n.planTermsHelp,
    trailing: const Icon(Icons.open_in_new),
    onTap: () => openTermsOfService(context, ref),
  );

  Widget _note(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(BSpace.s16, BSpace.s8, BSpace.s16, 0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  /// The choices and the button that buys the picked one.
  List<Widget> _buySection(
    BuildContext context, {
    required List<PlanChoice> choices,
    required PlanChoice? selected,
    required Uri? kofi,
    required PlayBilling? play,
    required bool playDown,
    required AppStoreBilling? appStore,
    required bool paid,
    required String? targetName,
  }) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final severalPlans = {for (final c in choices) c.planName}.length > 1;
    final name = selected?.planName ?? targetName;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(BSpace.s16, 0, BSpace.s16, BSpace.s8),
        child: Text(l10n.planGet, style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary)),
      ),
      if (playDown || _appStoreFailed)
        GroupedList(
          children: [
            if (playDown)
              GroupedTile(
                icon: Icons.cloud_off_outlined,
                title: l10n.planPlayUnavailable,
                subtitle: l10n.commonRetry,
                onTap: () => _retryPlay(play!),
              ),
            if (_appStoreFailed)
              GroupedTile(
                icon: Icons.cloud_off_outlined,
                title: l10n.planAppStoreUnavailable,
                subtitle: l10n.commonRetry,
                onTap: () => _retryAppStore(appStore!),
              ),
          ],
        ),
      for (final choice in choices)
        PlanChoiceCard(
          choice: choice,
          selected: choice.id == selected?.id,
          showPlan: severalPlans,
          onTap: () => setState(() => _selected = choice.id),
        ),
      if (selected != null || kofi != null) ...[
        const SizedBox(height: BSpace.s8),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            textStyle: theme.textTheme.titleMedium,
          ),
          onPressed: _buying
              ? null
              : selected == null
              ? () => _open(kofi!)
              : kofi != null && selected.id.startsWith('paypal:')
              ? () => _chooseMethod(selected, kofi)
              : selected.buy,
          child: Text(
            selected == null
                ? l10n.planKofiBuy
                : paid
                ? l10n.planBuy(name!)
                : l10n.planUpgradeTo(name!),
          ),
        ),
        if (selected == null) _note(context, l10n.planKofiHelp),
        // Nothing renews a one-off payment, so there is nothing to cancel.
        _note(
          context,
          [
            if (selected?.subscription ?? false) l10n.planCancelAnytime,
            l10n.planFreeForever,
          ].join('\n'),
        ),
        const SizedBox(height: BSpace.s24),
      ],
    ];
  }

  /// What goes with a purchase: how it is charged, and the other ways in.
  List<Widget> _finePrint(
    BuildContext context, {
    required Uri? kofi,
    required AppStoreBilling? appStore,
    required bool storeSells,
    required bool selling,
    required Uri? termsUrl,
  }) {
    final l10n = context.l10n;
    return [
      if (selling) _note(context, l10n.planSupports),
      // How an auto-renewing subscription is charged, as Apple asks to say
      // where it is sold.
      if (storeSells) _note(context, l10n.planAppStoreRenewal),
      if (termsUrl != null) _note(context, l10n.planTermsHelp),
      Padding(
        padding: const EdgeInsets.only(top: BSpace.s8, bottom: BSpace.s24),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: BSpace.s8,
          children: [
            if (kofi != null)
              TextButton(
                onPressed: () => showDialog<void>(context: context, builder: (_) => const PaymentClaimDialog()),
                child: Text(l10n.planPaymentClaim),
              ),
            if (appStore != null) TextButton(onPressed: _buying ? null : _restore, child: Text(l10n.planRestore)),
            if (termsUrl != null)
              TextButton(onPressed: () => openTermsOfService(context, ref), child: Text(l10n.termsTitle)),
            // Apple wants the privacy policy next to what is sold, too.
            if (storeSells)
              TextButton(onPressed: () => openPrivacyPolicy(context, ref), child: Text(l10n.privacyTitle)),
          ],
        ),
      ),
    ];
  }

  /// Asks whether to pay for [choice] through PayPal or go to Ko-fi.
  Future<void> _chooseMethod(PlanChoice choice, Uri kofi) async {
    final l10n = context.l10n;
    final method = await showModalBottomSheet<VoidCallback>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: BSpace.s16),
          child: GroupedList(
            title: l10n.planPayWith,
            children: [
              GroupedTile(
                icon: Icons.payments_outlined,
                title: 'PayPal',
                subtitle: [?choice.period, ?choice.price].join(' · '),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => Navigator.pop(context, choice.buy),
              ),
              GroupedTile(
                icon: Icons.coffee_outlined,
                title: l10n.planKofi,
                subtitle: l10n.planKofiHelp,
                trailing: const Icon(Icons.open_in_new),
                onTap: () => Navigator.pop(context, () => _open(kofi)),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted) method?.call();
  }
}

/// Takes a Ko-fi payment by its transaction ID.
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
