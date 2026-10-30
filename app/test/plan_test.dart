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
import 'package:dio/dio.dart';
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
  _FakePlay({this.held = const [], this.bought = const [], this.owned = false, this.paying});

  final List<String> held;
  final List<String> bought;
  final bool owned;

  /// Holds a purchase in Play's own sheet until it completes.
  final Completer<void>? paying;
  String? boughtFor;

  @override
  Future<List<PlayOffer>> offers(List<String> products) async => [
    if (products.contains(_offer.productId)) _offer,
  ];

  @override
  Future<List<String>> purchases() async => held;

  @override
  Future<List<String>> buy(PlayOffer offer, String account) async {
    if (owned) throw const PlayException(owned: true);
    boughtFor = account;
    await paying?.future;
    return bought;
  }
}

class _FakeApi extends BalnanaApi {
  _FakeApi({this.failure}) : super(Dio());

  final ApiException? failure;
  final reported = <String>[];

  @override
  Future<MyPlan> reportPlayPurchase(String token) async {
    reported.add(token);
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
      'paymentEmails': ['me@example.com', 42],
    });
    expect(plan.paid, isFalse);
    expect(plan.expiresAt, isNull);
    expect(plan.ownGroups.limit, 5);
    expect(plan.sponsoredGroups.limit, 0);
    expect(plan.receiptsPerGroup, 20);
    expect(plan.recurringPerGroup, isNull);
    expect(plan.paymentEmails, ['me@example.com']);
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
    expect(find.text(l10n.planPaymentEmailAdd), findsNothing);
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
      final store = _FakePlay(bought: ['token']);
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
      await _pump(tester, withPlay(_play), store: _FakePlay(bought: ['token'], paying: paying), api: api);

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

    testWidgets('a server without it asks nothing of Play', (tester) async {
      await _pump(tester, withPlay(null), store: _FakePlay(held: ['token']));

      expect(find.text(l10n.planGet), findsNothing);
      expect(find.text(l10n.planPlayManage), findsNothing);
    });
  });
}
