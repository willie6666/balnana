import 'dart:async';

import 'package:balnana/core/errors.dart';
import 'package:balnana/core/google_play.dart';
import 'package:balnana/core/l10n.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/api.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/features/settings/plan_comparison.dart';
import 'package:balnana/features/settings/plan_offers.dart';
import 'package:balnana/features/settings/plan_page.dart';
import 'package:balnana/l10n/app_localizations_en.dart';
import 'package:balnana/ui/widgets/play_purchases.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _server = 'https://split.example.com';

const _plan = MyPlan(
  planName: 'Plus',
  paid: true,
  joinedGroups: PlanUsage(limit: 50, used: 3),
  sponsoredGroups: PlanUsage(used: 2),
  receiptsPerGroup: 2000,
  membersPerGroup: 100,
);

const _offer = PlayOffer(
  productId: 'plus_monthly',
  offerToken: 'offer',
  name: 'Plus',
  price: r'$3',
  period: 'P3M',
);

const _play = PlayBilling(accountId: 'hash', packageName: 'com.balnana.app', products: ['plus_monthly']);

class _FakePlay extends GooglePlay {
  _FakePlay({
    this.held = const [],
    this.tokens = const [],
    this.owned = false,
    this.paying,
    this.unreachable = false,
  });

  final List<String> held;
  final List<String> tokens;
  final bool owned;

  /// Play can't be reached, until this is turned off.
  bool unreachable;

  /// Holds a purchase in Play's own sheet until it completes.
  final Completer<void>? paying;
  String? boughtFor;

  @override
  Future<List<PlayOffer>> offers(List<String> products) async {
    if (unreachable) throw const PlayException();
    return [if (products.contains(_offer.productId)) _offer];
  }

  @override
  Future<List<String>> purchases() async => held;

  @override
  Future<List<String>> buy(PlayOffer offer, String account) async {
    if (owned) throw const PlayException(owned: true);
    boughtFor = account;
    await paying?.future;
    return tokens;
  }
}

class _FakeApi extends BalnanaApi {
  _FakeApi({this.failure, this.claiming}) : super(Dio());

  final ApiException? failure;

  /// Holds a claim on its way to the server until it completes.
  final Completer<void>? claiming;
  final reported = <String>[];

  /// Tokens the server turns down, for all others to go through.
  final refused = <String>{};
  final claimed = <String>[];

  @override
  Future<MyPlan> claimPayment(String reference) async {
    claimed.add(reference);
    await claiming?.future;
    if (failure case final failure?) throw failure;
    return _plan;
  }

  @override
  Future<MyPlan> reportPlayPurchase(String token) async {
    reported.add(token);
    if (refused.contains(token)) throw const ApiException('play_other_account');
    if (failure case final failure?) throw failure;
    return _plan;
  }
}

Future<void> _pump(
  WidgetTester tester,
  MyPlan plan, {
  GooglePlay? store,
  BalnanaApi? api,
  String? paypal,
  bool externalLinks = false,
  Uri? termsUrl,
}) async {
  // Tall enough for the whole page: its lists only build what is on screen.
  tester.view.physicalSize = const Size(1200, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myPlanProvider.overrideWith((ref) async => plan),
        if (store != null) googlePlayProvider.overrideWithValue(store),
        balnanaApiProvider.overrideWithValue(api),
        serverInfoProvider.overrideWithValue(
          AsyncValue.data(
            ServerInfo(
              version: '1',
              authMode: AuthMode.accounts,
              publicUrl: _server,
              billing: true,
              kofiUrl: externalLinks ? Uri.parse('https://ko-fi.com/example') : null,
              termsUrl: termsUrl,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: l10nDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlanPage(paypal: paypal),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final l10n = AppLocalizationsEn();

  test('external payments follow the distribution and explicit override', () {
    expect(externalPaymentsFor(web: false, flavor: 'foss'), isTrue);
    expect(externalPaymentsFor(web: false, flavor: 'foss', enabled: false), isFalse);
    expect(externalPaymentsFor(web: false, flavor: 'play'), isFalse);
    expect(externalPaymentsFor(web: false, flavor: 'play', enabled: true), isFalse);
    expect(externalPaymentsFor(web: false, flavor: null), isFalse);
    expect(externalPaymentsFor(web: false, flavor: null, enabled: true), isTrue);
    expect(externalPaymentsFor(web: true, flavor: 'play', enabled: false), isTrue);
    // The iOS app sells through the App Store alone, whatever the build says.
    expect(externalPaymentsFor(web: false, flavor: 'appstore'), isFalse);
    expect(externalPaymentsFor(web: false, flavor: 'appstore', enabled: true), isFalse);
  });

  test('a plan reads comparison limits and automatic eligibility', () {
    final plan = MyPlan.fromJson({
      'planName': 'Free',
      'joinedGroups': {'used': 0},
      'sponsoredGroups': {'used': 0},
      'comparison': {
        'currentPlanId': 'free',
        'unverifiedPlanId': 'unverified',
        'verifiedPlanId': 'free',
        'plans': [
          {
            'id': 'free',
            'name': 'Free',
            'limits': {'receiptsPerGroup': 0, 'reminders': false},
          },
          {
            'id': 'plus',
            'name': 'Plus',
            'limits': {'reminders': true},
          },
        ],
      },
    });
    final comparison = plan.comparison!;
    expect(comparison.currentPlanId, 'free');
    expect(comparison.unverifiedPlanId, 'unverified');
    expect(comparison.verifiedPlanId, 'free');
    expect(comparison.plans.first.limits.receiptsPerGroup, 0);
    expect(comparison.plans.last.limits.receiptsPerGroup, isNull);
    expect(comparison.plans.last.limits.reminders, isTrue);
  });

  group('server info', () {
    Map<String, Object?> json([Map<String, Object?> extra = const {}]) => {
      'name': 'balnana',
      'version': '1',
      'authMode': 'accounts',
      'publicUrl': _server,
      ...extra,
    };

    test('has no plans unless the server says so', () {
      final info = ServerInfo.fromJson(json());
      expect(info.billing, isFalse);
      expect(info.kofiUrl, isNull);
    });

    test('reads the Ko-fi page', () {
      final info = ServerInfo.fromJson(
        json({
          'billing': {'kofiUrl': 'https://ko-fi.com/example'},
        }),
      );
      expect(info.billing, isTrue);
      expect(info.kofiUrl, Uri.parse('https://ko-fi.com/example'));
    });

    test('plans can have no page to pay on', () {
      final info = ServerInfo.fromJson(json({'billing': <String, Object?>{}}));
      expect(info.billing, isTrue);
      expect(info.kofiUrl, isNull);
    });
  });

  test('a limit says which limit it is', () {
    String message(Map<String, Object?> params) =>
        errorMessage(l10n, ApiException('plan_limit', status: 402, params: params));

    expect(message({'limit': 'receipts', 'max': 20}), l10n.errorLimitReceipts(20));
    expect(message({'limit': 'recurring', 'max': 2}), l10n.errorLimitRecurring(2));
    expect(message({'limit': 'joined_groups', 'max': 10}), l10n.errorLimitJoinedGroups(10));
    expect(message({'limit': 'members', 'max': 15}), l10n.errorLimitMembers(15));
    expect(message({'limit': 'sponsored_groups', 'max': 10}), l10n.errorLimitSponsored(10));
    expect(message({'limit': 'something_new'}), l10n.errorLimitOther);
  });

  test('usage shows the limit only when there is one', () {
    expect(planUsage(l10n, const PlanUsage(limit: 50, used: 3)), '3 of 50');
    expect(planUsage(l10n, const PlanUsage(used: 3)), l10n.planUsed(3));
  });

  test('a plan is read with empty limits as none', () {
    final plan = MyPlan.fromJson({
      'planName': 'Free',
      'joinedGroups': {'used': 1, 'limit': 5},
      'sponsoredGroups': {'used': 0, 'limit': 0},
      'receiptsPerGroup': 20,
      'membersPerGroup': 15,
    });
    expect(plan.paid, isFalse);
    expect(plan.expiresAt, isNull);
    expect(plan.joinedGroups.limit, 5);
    expect(plan.membersPerGroup, 15);
    expect(plan.sponsoredGroups.limit, 0);
    expect(plan.receiptsPerGroup, 20);
    expect(plan.recurringPerGroup, isNull);
    expect(plan.paypal, isNull);
    expect(plan.comparison, isNull);
  });

  test('a plan reads what PayPal sells', () {
    final plan = MyPlan.fromJson({
      'planName': 'Free',
      'joinedGroups': {'used': 0},
      'sponsoredGroups': {'used': 0},
      'paypal': {
        'offers': [
          {'product': 'P-ABC', 'planName': 'Plus', 'days': 30, 'subscription': true},
          {
            'product': 'plus90',
            'planName': 'Plus',
            'days': 90,
            'subscription': false,
            'amount': '9.00',
            'currency': 'USD',
          },
        ],
        'subscribed': ['P-ABC'],
      },
    });
    final paypal = plan.paypal!;
    expect(paypal.subscribed, ['P-ABC']);
    expect(paypal.offers.map((o) => (o.product, o.days, o.subscription, o.amount)), [
      ('P-ABC', 30, true, null),
      ('plus90', 90, false, '9.00'),
    ]);
  });

  testWidgets('the plan page shows the plan and how much of it is used', (tester) async {
    await _pump(tester, _plan);

    expect(find.text('Plus'), findsOneWidget);
    expect(find.text('3 of 50'), findsOneWidget);
    expect(find.text('2000'), findsOneWidget);
    expect(find.text(l10n.planUnlimited), findsOneWidget);
  });

  testWidgets('the plan page shows the server comparison alongside its limits', (tester) async {
    await _pump(
      tester,
      const MyPlan(
        planName: 'Free',
        joinedGroups: PlanUsage(used: 0),
        sponsoredGroups: PlanUsage(used: 0),
        comparison: PlanComparisonData(
          currentPlanId: 'free',
          plans: [
            Plan(id: 'free', name: 'Free'),
            Plan(id: 'plus', name: 'Plus'),
          ],
        ),
      ),
    );
    // With nothing to buy there is nothing to put ahead of it.
    expect(find.byType(PlanComparisonTable), findsOneWidget);
    expect(find.text(l10n.planCurrent), findsOneWidget);
    expect(find.text(l10n.planLimits), findsOneWidget);
    expect(find.byType(PlanHero), findsNothing);
  });

  group('selling', () {
    const free = Plan(
      id: 'free',
      name: 'Free',
      limits: PlanLimits(joinedGroups: 5, sponsoredGroups: 0, receiptsPerGroup: 20, membersPerGroup: 15),
    );
    const plus = Plan(
      id: 'plus',
      name: 'Plus',
      limits: PlanLimits(sponsoredGroups: 10, receiptsPerGroup: 2000, membersPerGroup: 15, reminders: true),
    );
    MyPlan selling({bool paid = false, int joined = 1}) => MyPlan(
      planName: paid ? 'Plus' : 'Free',
      paid: paid,
      joinedGroups: PlanUsage(limit: 5, used: joined),
      sponsoredGroups: const PlanUsage(limit: 0),
      comparison: const PlanComparisonData(currentPlanId: 'free', plans: [free, plus]),
      play: _play,
    );

    testWidgets('leads with what a plan adds and folds the rest away', (tester) async {
      await _pump(tester, selling(), store: _FakePlay());

      expect(find.text(l10n.planHeroShare), findsOneWidget);
      expect(find.text(l10n.planHeroShareCount(10)), findsOneWidget);
      expect(find.text(l10n.planBenefits('Plus')), findsOneWidget);
      expect(find.text('20 → 2,000'), findsOneWidget);
      // What stays the same is no reason to pay.
      expect(find.text(l10n.planLimitMembers), findsNothing);
      expect(find.text(l10n.planUpgradeTo('Plus')), findsOneWidget);
      expect(find.byType(PlanComparisonTable), findsNothing);
      expect(find.text(l10n.planLimitSponsored), findsNothing);

      await tester.tap(find.text(l10n.planCompare));
      await tester.pumpAndSettle();
      expect(find.byType(PlanComparisonTable), findsOneWidget);

      await tester.tap(find.text(l10n.planUsageNow('Free')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.planUsage(1, 5)), findsOneWidget);
    });

    testWidgets('the button that buys is on a phone’s first screen', (tester) async {
      await _pump(tester, selling(), store: _FakePlay());
      tester.view.physicalSize = const Size(390, 700);
      await tester.pumpAndSettle();

      expect(tester.getBottomLeft(find.byType(FilledButton)).dy, lessThan(700));
    });

    testWidgets('shows a limit that is about to run out', (tester) async {
      await _pump(tester, selling(joined: 4), store: _FakePlay());

      expect(find.text(l10n.planUsage(4, 5)), findsOneWidget);
    });

    testWidgets('someone who pays sees their plan first', (tester) async {
      await _pump(tester, selling(paid: true), store: _FakePlay());

      expect(find.byType(PlanHero), findsNothing);
      expect(find.text(l10n.planLimits), findsOneWidget);
      expect(find.text(l10n.planBuy('Plus')), findsOneWidget);
    });

    test('the plan shown is never one that comes without paying', () {
      const verified = Plan(id: 'verified', name: 'Verified', limits: PlanLimits(reminders: true));
      const comparison = PlanComparisonData(
        currentPlanId: 'free',
        verifiedPlanId: 'verified',
        plans: [free, verified, plus],
      );
      expect(planTarget(comparison, null), same(plus));
      expect(planTarget(comparison, 'Verified'), same(plus));
    });
  });

  testWidgets('the longest choice is picked, and a server silent on Ko-fi still leads there', (tester) async {
    if (!externalPayments) return;
    await _pump(
      tester,
      const MyPlan(
        planName: 'Free',
        joinedGroups: PlanUsage(used: 0),
        sponsoredGroups: PlanUsage(used: 0),
        paypal: PayPalBilling(
          offers: [
            PayPalOffer(product: 'plus91', planName: 'Plus', days: 91, amount: '5.00', currency: 'USD'),
            PayPalOffer(product: 'plus365', planName: 'Plus', days: 365, amount: '18.00', currency: 'USD'),
          ],
        ),
      ),
      api: _FakeApi(),
      externalLinks: true,
    );

    final cards = tester.widgetList<PlanChoiceCard>(find.byType(PlanChoiceCard)).toList();
    expect([for (final c in cards) c.choice.price], ['18.00 USD', '5.00 USD']);
    expect([for (final c in cards) c.selected], [true, false]);
    // Nothing renews a one-off payment.
    expect(find.textContaining(l10n.planCancelAnytime), findsNothing);
    expect(find.text('PayPal'), findsOneWidget);
    expect(find.text(l10n.planKofi), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, l10n.planKofiBuy), findsOneWidget);
    expect(find.widgetWithText(FilledButton, l10n.planUpgradeTo('Plus')), findsOneWidget);
  });

  testWidgets('choices sit two to a row where there is room', (tester) async {
    PlanChoice choice(String id, int days) =>
        PlanChoice(id: id, planName: 'Plus', subscription: false, days: days, period: id, price: '1', buy: () {});
    Future<List<Offset>> places(List<PlanChoice> choices, double width) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: PlanChoiceGrid(choices: sortedChoices(choices), selected: null, onSelect: (_) {}),
              ),
            ),
          ),
        ),
      );
      return [for (final c in choices) tester.getTopLeft(find.text(c.id))];
    }

    final four = [choice('a', 365), choice('b', 91), choice('c', 365), choice('d', 91)];
    var [a, b, c, d] = await places(four, 360);
    // A row for each length, with the first given on the left.
    expect([c.dy, d.dy], [a.dy, b.dy]);
    expect(a.dx, lessThan(c.dx));
    expect([b.dx, d.dx], [a.dx, c.dx]);
    expect(b.dy, greaterThan(a.dy));

    [a, b, c, d] = await places(four, 270);
    expect({a.dx, b.dx, c.dx, d.dx}, hasLength(1));

    final [year, quarter, month] = await places([choice('y', 365), choice('q', 91), choice('m', 30)], 360);
    expect(quarter.dy, month.dy);
    expect(year.dy, lessThan(quarter.dy));
    expect(tester.takeException(), isNull);
  });

  group('Ko-fi prices', () {
    MyPlan plan({List<PayPalOffer> paypal = const [], required List<KofiOffer> kofi}) => MyPlan(
      planName: 'Free',
      joinedGroups: const PlanUsage(used: 0),
      sponsoredGroups: const PlanUsage(used: 0),
      paypal: paypal.isEmpty ? null : PayPalBilling(offers: paypal),
      kofi: kofi,
    );
    Future<void> show(WidgetTester tester, MyPlan plan) =>
        _pump(tester, plan, api: _FakeApi(), externalLinks: true);
    const once = PayPalOffer(product: 'plus91', planName: 'Plus', days: 91, amount: '5.00', currency: 'USD');

    test('are read from the server', () {
      final read = MyPlan.fromJson({
        'planName': 'Free',
        'joinedGroups': {'used': 0},
        'sponsoredGroups': {'used': 0},
        'kofi': {
          'offers': [
            {'planName': 'Plus', 'days': 91, 'amount': '5.00', 'currency': 'USD'},
            {'planName': 'Plus', 'days': 365, 'amount': '18.00', 'currency': 'USD', 'displayPrice': r'US$18'},
          ],
        },
      });
      expect([for (final o in read.kofi!) o.price], ['5.00 USD', r'US$18']);
    });

    testWidgets('sit in a box of their own beside PayPal’s', (tester) async {
      if (!externalPayments) return;
      await show(
        tester,
        plan(
          paypal: const [
            PayPalOffer(product: 'P-A', planName: 'Plus', days: 91, subscription: true, displayPrice: r'US$5'),
            PayPalOffer(product: 'P-B', planName: 'Plus', days: 365, subscription: true, displayPrice: r'US$18'),
          ],
          kofi: const [
            KofiOffer(planName: 'Plus', days: 91, amount: '5.00', currency: 'USD'),
            KofiOffer(planName: 'Plus', days: 365, amount: '18.00', currency: 'USD'),
          ],
        ),
      );

      Offset at(String text) => tester.getTopLeft(find.text(text));
      expect(at('PayPal').dy, at(l10n.planKofi).dy);
      expect(at('PayPal').dx, lessThan(at(l10n.planKofi).dx));
      // The same length is level across the two, under each box's own words.
      expect(at(r'US$18').dy, at('18.00 USD').dy);
      expect(at(r'US$5').dy, at('5.00 USD').dy);
      expect(at(r'US$18').dx, lessThan(at('18.00 USD').dx));
      // How each is charged is said once, for the box.
      expect(find.text(l10n.planAutoRenews), findsOneWidget);
      expect(find.text(l10n.planOnceNote), findsOneWidget);
      // What to do after paying on Ko-fi is said under the button, whichever
      // is picked.
      expect(find.text(l10n.planKofiHelp), findsOneWidget);
      expect(at(l10n.planKofiHelp).dy, greaterThan(tester.getBottomLeft(find.byType(FilledButton)).dy));
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.widgetWithText(FilledButton, l10n.planUpgradeTo('Plus')), findsOneWidget);

      await tester.tap(find.text('5.00 USD'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, l10n.planKofiBuy), findsOneWidget);
      expect(find.textContaining(l10n.planCancelAnytime), findsNothing);

      // One under the other where two would be too narrow.
      tester.view.physicalSize = const Size(320, 2400);
      await tester.pumpAndSettle();
      expect(at('PayPal').dx, at(l10n.planKofi).dx);
      expect(tester.takeException(), isNull);
    });

    testWidgets('say on each card how they differ', (tester) async {
      if (!externalPayments) return;
      await show(
        tester,
        plan(
          paypal: const [
            once,
            PayPalOffer(product: 'P-ABC', planName: 'Plus', days: 30, subscription: true),
          ],
          kofi: const [KofiOffer(planName: 'Plus', days: 365)],
        ),
      );

      // Both ways of charging in one box, and no price for the app to show.
      expect(find.text(l10n.planAutoRenews), findsOneWidget);
      // On PayPal's one-off card, and over Ko-fi's box.
      expect(find.text(l10n.planOnceNote), findsNWidgets(2));
      expect(find.text(l10n.planPriceAtPayPal), findsOneWidget);
      expect(find.text(l10n.planPriceAtKofi), findsOneWidget);
    });

    testWidgets('show without PayPal', (tester) async {
      if (!externalPayments) return;
      await show(tester, plan(kofi: const [KofiOffer(planName: 'Plus', days: 91)]));

      expect(find.text('PayPal'), findsNothing);
      expect(find.text(l10n.planKofi), findsOneWidget);
      expect(find.widgetWithText(FilledButton, l10n.planKofiBuy), findsOneWidget);
    });
  });

  testWidgets('coming back from PayPal says how it went', (tester) async {
    await _pump(tester, _plan, paypal: 'cancelled');

    expect(find.text(l10n.planPayPalCancelled), findsOneWidget);
  });

  testWidgets('returning from PayPal updates an already open plan page', (tester) async {
    final outcome = ValueNotifier<String?>(null);
    addTearDown(outcome.dispose);
    var loads = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myPlanProvider.overrideWith((ref) async {
            loads++;
            return _plan;
          }),
          balnanaApiProvider.overrideWithValue(null),
        ],
        child: MaterialApp(
          localizationsDelegates: l10nDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: ValueListenableBuilder<String?>(
            valueListenable: outcome,
            builder: (_, value, _) => PlanPage(paypal: value),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final page = tester.state(find.byType(PlanPage));
    final before = loads;
    outcome.value = 'done';
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.state(find.byType(PlanPage)), same(page));
    expect(find.text(l10n.planPayPalDone), findsOneWidget);
    expect(loads, before + 1);
  });

  group('claiming a payment', () {
    Future<void> open(WidgetTester tester, BalnanaApi api, {Future<MyPlan> Function()? plan}) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            balnanaApiProvider.overrideWithValue(api),
            if (plan != null) myPlanProvider.overrideWith((ref) => plan()),
          ],
          child: MaterialApp(
            localizationsDelegates: l10nDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () =>
                      showDialog<void>(context: context, builder: (_) => const PaymentClaimDialog()),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('sends what was pasted and closes', (tester) async {
      final api = _FakeApi();
      await open(tester, api);

      await tester.enterText(find.byType(TextFormField), '  00000000-1111-2222-3333-444444444444\n');
      await tester.tap(find.text(l10n.planPaymentClaimAction));
      await tester.pumpAndSettle();

      expect(api.claimed, ['00000000-1111-2222-3333-444444444444']);
      expect(find.byType(PaymentClaimDialog), findsNothing);
      expect(find.text(l10n.planPaymentClaimed), findsOneWidget);
    });

    testWidgets('a claim that lands after the dialog was dismissed still refreshes the plan', (tester) async {
      final claiming = Completer<void>();
      var loads = 0;
      await open(
        tester,
        _FakeApi(claiming: claiming),
        plan: () async {
          loads++;
          return _plan;
        },
      );
      final context = tester.element(find.text('open'));
      final container = ProviderScope.containerOf(context);
      final plans = container.listen(myPlanProvider, (_, _) {});
      addTearDown(plans.close);
      await tester.pump();
      expect(loads, 1);

      await tester.enterText(find.byType(TextFormField), 'tx');
      await tester.tap(find.text(l10n.planPaymentClaimAction));
      await tester.pump();
      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      expect(find.byType(PaymentClaimDialog), findsNothing);

      claiming.complete();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('open'), findsOneWidget, reason: 'the page under the dialog stays');
      expect(find.text(l10n.planPaymentClaimed), findsOneWidget);
      expect(loads, 2);
    });

    testWidgets('needs something to send', (tester) async {
      final api = _FakeApi();
      await open(tester, api);

      await tester.tap(find.text(l10n.planPaymentClaimAction));
      await tester.pumpAndSettle();

      expect(api.claimed, isEmpty);
      expect(find.text(l10n.errorRequired), findsOneWidget);
    });

    testWidgets('stays open and says why when the server refuses', (tester) async {
      await open(tester, _FakeApi(failure: const ApiException('payment_not_found', status: 404)));

      await tester.enterText(find.byType(TextFormField), 'nothing');
      await tester.tap(find.text(l10n.planPaymentClaimAction));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentClaimDialog), findsOneWidget);
      expect(find.text(l10n.errorPaymentNotFound), findsOneWidget);
    });
  });

  group('Google Play', () {
    MyPlan withPlay(PlayBilling? play) => MyPlan(
      planName: _plan.planName,
      paid: false,
      joinedGroups: _plan.joinedGroups,
      sponsoredGroups: _plan.sponsoredGroups,
      play: play,
    );

    testWidgets('sells what the server and Play both have, at the price Play shows', (tester) async {
      await _pump(tester, withPlay(_play), store: _FakePlay());

      expect(find.text(l10n.planGet), findsOneWidget);
      expect(find.text(r'$3'), findsOneWidget);
      expect(find.text(l10n.planPlayManage), findsNothing);
      // Without terms from the server there is nothing to agree to.
      expect(find.text(l10n.planTermsHelp), findsNothing);
    });

    testWidgets('the terms of service show beside the ways to buy', (tester) async {
      await _pump(
        tester,
        withPlay(_play),
        store: _FakePlay(),
        termsUrl: Uri.parse('https://balnana.com/terms'),
      );

      expect(find.text(l10n.termsTitle), findsOneWidget);
      expect(find.text(l10n.planTermsHelp), findsOneWidget);
    });

    testWidgets('buying reports the purchase under the account it was made for', (tester) async {
      final store = _FakePlay(tokens: ['token']);
      final api = _FakeApi();
      await _pump(tester, withPlay(_play), store: store, api: api);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(store.boughtFor, 'hash');
      expect(api.reported, ['token']);
    });

    testWidgets('a purchase is reported after the page has closed', (tester) async {
      final paying = Completer<void>();
      final api = _FakeApi();
      await _pump(
        tester,
        withPlay(_play),
        store: _FakePlay(tokens: ['token'], paying: paying),
        api: api,
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushReplacement(MaterialPageRoute<void>(builder: (_) => const SizedBox()));
      await tester.pumpAndSettle();
      expect(find.byType(PlanPage), findsNothing);

      paying.complete();
      await tester.pumpAndSettle();

      expect(api.reported, ['token']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('changing your mind reports nothing', (tester) async {
      final api = _FakeApi();
      await _pump(tester, withPlay(_play), store: _FakePlay(), api: api);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(api.reported, isEmpty);
    });

    testWidgets('a subscription someone else holds says so', (tester) async {
      final api = _FakeApi(failure: const ApiException('play_other_account'));
      await _pump(
        tester,
        withPlay(_play),
        store: _FakePlay(owned: true, held: ['theirs']),
        api: api,
      );
      expect(api.reported, ['theirs']);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text(l10n.errorPlayOtherAccount), findsOneWidget);
    });

    testWidgets('opening the page reports what Play holds', (tester) async {
      final api = _FakeApi();
      await _pump(
        tester,
        withPlay(_play),
        store: _FakePlay(held: ['renewed']),
        api: api,
      );

      expect(api.reported, ['renewed']);
    });

    testWidgets('a subscriber can manage it and is not sold another', (tester) async {
      const play = PlayBilling(
        accountId: 'hash',
        packageName: 'com.balnana.app',
        products: ['plus_monthly'],
        subscribed: ['plus_monthly'],
      );
      await _pump(tester, withPlay(play), store: _FakePlay());

      expect(find.text(l10n.planPlayManage), findsOneWidget);
      expect(find.text(l10n.planGet), findsNothing);
    });

    testWidgets('a subscription that stopped being charged says how to fix it', (tester) async {
      const play = PlayBilling(
        accountId: 'hash',
        packageName: 'com.balnana.app',
        products: ['plus_monthly'],
        onHold: ['plus_monthly'],
      );
      await _pump(tester, withPlay(play), store: _FakePlay());

      expect(find.text(l10n.planPlayOnHold), findsOneWidget);
      expect(find.text(l10n.planPlayManage), findsOneWidget);
      expect(find.text(l10n.planGet), findsNothing);
    });

    testWidgets('Play out of reach can be tried again', (tester) async {
      final store = _FakePlay(unreachable: true);
      await _pump(tester, withPlay(_play), store: store, api: _FakeApi());
      expect(find.text(l10n.planPlayUnavailable), findsOneWidget);

      store.unreachable = false;
      await tester.tap(find.text(l10n.planPlayUnavailable));
      await tester.pumpAndSettle();
      expect(find.text(l10n.planPlayUnavailable), findsNothing);
      expect(find.text(r'$3'), findsOneWidget);
    });

    test('one purchase the server refuses does not stop the rest', () async {
      final api = _FakeApi()..refused.add('theirs');
      expect(await reportPlayPurchases(api, ['theirs', 'mine']), isTrue);
      expect(api.reported, ['theirs', 'mine']);

      api.refused.add('mine');
      await expectLater(reportPlayPurchases(api, ['theirs', 'mine']), throwsA(isA<ApiException>()));
    });

    testWidgets('a server without it asks nothing of Play', (tester) async {
      await _pump(tester, withPlay(null), store: _FakePlay(held: ['token']));

      expect(find.text(l10n.planGet), findsNothing);
      expect(find.text(l10n.planPlayManage), findsNothing);
    });
  });
}
