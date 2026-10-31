import 'dart:async';

import 'package:balnana/core/errors.dart';
import 'package:balnana/core/google_play.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/api.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/features/settings/plan_page.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:balnana/l10n/app_localizations_en.dart';
import 'package:balnana/ui/widgets/play_purchases.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _server = 'https://split.example.com';

const _plan = MyPlan(
  planName: 'Plus',
  paid: true,
  ownGroups: PlanUsage(limit: 50, used: 3),
  sponsoredGroups: PlanUsage(used: 2),
  receiptsPerGroup: 2000,
);

const _offer = PlayOffer(productId: 'plus_monthly', offerToken: 'offer', name: 'Plus', price: r'$3', period: 'P3M');

const _play = PlayBilling(accountId: 'hash', packageName: 'me.devvillie.balnana', products: ['plus_monthly']);

class _FakePlay extends GooglePlay {
  _FakePlay({this.held = const [], this.tokens = const [], this.owned = false, this.paying, this.unreachable = false});

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

Future<void> _pump(WidgetTester tester, MyPlan plan, {GooglePlay? store, BalnanaApi? api}) async {
  // Tall enough for the whole page: its lists only build what is on screen.
  tester.view.physicalSize = const Size(1200, 3000);
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
              kofiUrl: Uri.parse('https://ko-fi.com/example'),
            ),
          ),
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlanPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final l10n = AppLocalizationsEn();

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
    expect(message({'limit': 'own_groups', 'max': 5}), l10n.errorLimitOwnGroups(5));
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
      'ownGroups': {'used': 1, 'limit': 5},
      'sponsoredGroups': {'used': 0, 'limit': 0},
      'receiptsPerGroup': 20,
      'paymentCode': 'BAL-ABCD2345',
    });
    expect(plan.paid, isFalse);
    expect(plan.expiresAt, isNull);
    expect(plan.ownGroups.limit, 5);
    expect(plan.sponsoredGroups.limit, 0);
    expect(plan.receiptsPerGroup, 20);
    expect(plan.recurringPerGroup, isNull);
    expect(plan.paymentCode, 'BAL-ABCD2345');
  });

  testWidgets('the plan page shows the plan and how much of it is used', (tester) async {
    await _pump(tester, _plan);

    expect(find.text('Plus'), findsOneWidget);
    expect(find.text('3 of 50'), findsOneWidget);
    expect(find.text('2000'), findsOneWidget);
    expect(find.text(l10n.planUnlimited), findsOneWidget);
  });

  // Google Play doesn't allow pointing people elsewhere to pay.
  testWidgets('a build without external payments has no way to pay', (tester) async {
    expect(externalPayments, isFalse);
    await _pump(tester, _plan);

    expect(find.text(l10n.planKofi), findsNothing);
    expect(find.text(l10n.planGet), findsNothing);
    expect(find.text(l10n.planPaymentClaim), findsNothing);
  });

  // Runs with --dart-define=BALNANA_EXTERNAL_PAYMENTS=true.
  testWidgets('a build with external payments shows the code to pay with', (tester) async {
    Object? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'];
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await _pump(
      tester,
      const MyPlan(
        planName: 'Free',
        ownGroups: PlanUsage(used: 0),
        sponsoredGroups: PlanUsage(used: 0),
        paymentCode: 'BAL-ABCD2345',
      ),
      api: _FakeApi(),
    );

    expect(find.text(l10n.planKofiHelp), findsOneWidget);
    await tester.ensureVisible(find.text('BAL-ABCD2345'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BAL-ABCD2345'));
    await tester.pumpAndSettle();
    expect(copied, 'BAL-ABCD2345');
    expect(find.text(l10n.planPaymentCodeCopied), findsOneWidget);

    await tester.ensureVisible(find.text(l10n.planPaymentClaim));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.planPaymentClaim));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentClaimDialog), findsOneWidget);
  }, skip: !externalPayments);

  group('claiming a payment', () {
    Future<void> open(WidgetTester tester, BalnanaApi api, {Future<MyPlan> Function()? plan}) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            balnanaApiProvider.overrideWithValue(api),
            if (plan != null) myPlanProvider.overrideWith((ref) => plan()),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showDialog<void>(context: context, builder: (_) => const PaymentClaimDialog()),
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
      ownGroups: _plan.ownGroups,
      sponsoredGroups: _plan.sponsoredGroups,
      play: play,
    );

    testWidgets('sells what the server and Play both have, at the price Play shows', (tester) async {
      await _pump(tester, withPlay(_play), store: _FakePlay());

      expect(find.text(l10n.planGet), findsOneWidget);
      expect(find.text(l10n.planPlayPrice(3, r'$3')), findsOneWidget);
      expect(find.text(l10n.planPlayManage), findsNothing);
    });

    testWidgets('buying reports the purchase under the account it was made for', (tester) async {
      final store = _FakePlay(tokens: ['token']);
      final api = _FakeApi();
      await _pump(tester, withPlay(_play), store: store, api: api);

      await tester.tap(find.text(l10n.planPlayPrice(3, r'$3')));
      await tester.pumpAndSettle();

      expect(store.boughtFor, 'hash');
      expect(api.reported, ['token']);
    });

    testWidgets('a purchase is reported after the page has closed', (tester) async {
      final paying = Completer<void>();
      final api = _FakeApi();
      await _pump(tester, withPlay(_play), store: _FakePlay(tokens: ['token'], paying: paying), api: api);

      await tester.tap(find.text(l10n.planPlayPrice(3, r'$3')));
      await tester.pump();
      tester.state<NavigatorState>(find.byType(Navigator)).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const SizedBox()),
      );
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

      await tester.tap(find.text(l10n.planPlayPrice(3, r'$3')));
      await tester.pumpAndSettle();

      expect(api.reported, isEmpty);
    });

    testWidgets('a subscription someone else holds says so', (tester) async {
      final api = _FakeApi(failure: const ApiException('play_other_account'));
      await _pump(tester, withPlay(_play), store: _FakePlay(owned: true, held: ['theirs']), api: api);
      expect(api.reported, ['theirs']);

      await tester.tap(find.text(l10n.planPlayPrice(3, r'$3')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.errorPlayOtherAccount), findsOneWidget);
    });

    testWidgets('opening the page reports what Play holds', (tester) async {
      final api = _FakeApi();
      await _pump(tester, withPlay(_play), store: _FakePlay(held: ['renewed']), api: api);

      expect(api.reported, ['renewed']);
    });

    testWidgets('a subscriber can manage it and is not sold another', (tester) async {
      const play = PlayBilling(
        accountId: 'hash',
        packageName: 'me.devvillie.balnana',
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
        packageName: 'me.devvillie.balnana',
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
      expect(find.text(l10n.planPlayPrice(3, r'$3')), findsOneWidget);
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
