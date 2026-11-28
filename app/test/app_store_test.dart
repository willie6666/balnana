import 'package:balnana/core/app_store.dart';
import 'package:balnana/core/errors.dart';
import 'package:balnana/core/l10n.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/data/api.dart';
import 'package:balnana/data/models.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/features/settings/plan_page.dart';
import 'package:balnana/l10n/app_localizations_en.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _server = 'https://split.example.com';

const _offer = AppStoreOffer(productId: 'plus_monthly', name: 'Plus', price: r'$4.99', period: 'P1M');

const _billing = AppStoreBilling(accountToken: 'token-uuid', products: ['plus_monthly']);

MyPlan _withAppStore(AppStoreBilling? appStore) => MyPlan(
  planName: 'Free',
  joinedGroups: const PlanUsage(limit: 5, used: 1),
  sponsoredGroups: const PlanUsage(used: 0),
  appStore: appStore,
);

class _FakeAppStore extends AppStore {
  _FakeAppStore({this.held = const [], this.signed = const [], this.pending = false, this.unreachable = false});

  final List<String> held;
  final List<String> signed;
  final bool pending;
  bool unreachable;
  String? boughtFor;
  bool synced = false;

  @override
  Future<List<AppStoreOffer>> offers(List<String> products) async {
    if (unreachable) throw const AppStoreException();
    return [if (products.contains(_offer.productId)) _offer];
  }

  @override
  Future<List<String>> purchases({bool sync = false}) async {
    synced = synced || sync;
    return held;
  }

  @override
  Future<List<String>> buy(AppStoreOffer offer, String accountToken) async {
    if (pending) throw const AppStoreException(pending: true);
    boughtFor = accountToken;
    return signed;
  }
}

class _FakeApi extends BalnanaApi {
  _FakeApi() : super(Dio());

  final reported = <String>[];

  @override
  Future<MyPlan> reportAppStorePurchase(String signedTransaction) async {
    reported.add(signedTransaction);
    return MyPlan(
      planName: 'Plus',
      paid: true,
      joinedGroups: const PlanUsage(limit: 50, used: 1),
      sponsoredGroups: const PlanUsage(used: 0),
      appStore: _billing,
    );
  }
}

Future<void> _pump(WidgetTester tester, MyPlan plan, {AppStore? store, BalnanaApi? api}) async {
  tester.view.physicalSize = const Size(1200, 3600);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myPlanProvider.overrideWith((ref) async => plan),
        if (store != null) appStoreProvider.overrideWithValue(store),
        balnanaApiProvider.overrideWithValue(api),
        serverInfoProvider.overrideWithValue(
          const AsyncValue.data(
            ServerInfo(version: '1', authMode: AuthMode.accounts, publicUrl: _server, billing: true),
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: l10nDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PlanPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final l10n = AppLocalizationsEn();

  test('an offer says how many months it charges for', () {
    expect(_offer.months, 1);
    expect(const AppStoreOffer(productId: 'y', name: 'Y', price: '1', period: 'P1Y').months, 12);
    expect(const AppStoreOffer(productId: 'w', name: 'W', price: '1', period: 'P1W').months, isNull);
  });

  test('a plan reads what the App Store sells', () {
    final plan = MyPlan.fromJson({
      'planName': 'Free',
      'joinedGroups': {'used': 0},
      'sponsoredGroups': {'used': 0},
      'appStore': {
        'accountToken': 'abc',
        'products': ['plus_monthly'],
        'subscribed': ['plus_monthly'],
      },
    });
    expect(plan.appStore?.accountToken, 'abc');
    expect(plan.appStore?.products, ['plus_monthly']);
    expect(plan.appStore?.subscribed, ['plus_monthly']);
    expect(MyPlan.fromJson({'planName': 'Free', 'joinedGroups': {'used': 0}, 'sponsoredGroups': {'used': 0}}).appStore,
        isNull);
  });

  test('server info says whether the iOS app can sign in with Apple', () {
    final base = {'name': 'balnana', 'version': '1', 'authMode': 'accounts', 'publicUrl': _server};
    expect(ServerInfo.fromJson({...base, 'appleSignIn': true}).appleSignIn, isTrue);
    expect(ServerInfo.fromJson(base).appleSignIn, isFalse);
  });

  test('signing in with Apple comes to a code, a pending sign-in or a link', () {
    expect(AppleSignInResult.fromJson({'code': 'c'}).code, 'c');
    expect(AppleSignInResult.fromJson({'pending': 'p'}).pending, 'p');
    expect(AppleSignInResult.fromJson({'linked': true}).linked, isTrue);
  });

  test('a subscription of another account says so', () {
    expect(errorMessage(l10n, const ApiException('appstore_other_account')), l10n.errorAppStoreOtherAccount);
  });

  testWidgets('sells what the server and the App Store both have, with what Apple asks to say', (tester) async {
    await _pump(tester, _withAppStore(_billing), store: _FakeAppStore());

    expect(find.text(l10n.planGet), findsOneWidget);
    expect(find.text(r'$4.99'), findsOneWidget);
    expect(find.text(l10n.planRestore), findsOneWidget);
    expect(find.text(l10n.planAppStoreManageHelp), findsNothing);
    // The page builds what is on screen: the end of it is further down.
    await tester.scrollUntilVisible(find.text(l10n.planAppStoreRenewal), 300);
    expect(find.text(l10n.planAppStoreRenewal), findsOneWidget);
    expect(find.text(l10n.privacyTitle), findsOneWidget);
  });

  testWidgets('buying reports the signed transaction under the account it was made for', (tester) async {
    final store = _FakeAppStore(signed: ['jws']);
    final api = _FakeApi();
    await _pump(tester, _withAppStore(_billing), store: store, api: api);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(store.boughtFor, 'token-uuid');
    expect(api.reported, ['jws']);
  });

  testWidgets('a purchase waiting for approval says so', (tester) async {
    await _pump(tester, _withAppStore(_billing), store: _FakeAppStore(pending: true), api: _FakeApi());

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.planAppStorePending), findsOneWidget);
  });

  testWidgets('opening the page reports what the Apple ID holds', (tester) async {
    final api = _FakeApi();
    await _pump(tester, _withAppStore(_billing), store: _FakeAppStore(held: ['held']), api: api);

    expect(api.reported, ['held']);
  });

  testWidgets('restoring asks Apple again, and says when there is nothing', (tester) async {
    final store = _FakeAppStore();
    await _pump(tester, _withAppStore(_billing), store: store, api: _FakeApi());

    await tester.tap(find.text(l10n.planRestore));
    await tester.pumpAndSettle();

    expect(store.synced, isTrue);
    expect(find.text(l10n.planRestoreNone), findsOneWidget);
  });

  testWidgets('a subscriber can manage it and is not sold it again', (tester) async {
    const subscribed = AppStoreBilling(
      accountToken: 'token-uuid',
      products: ['plus_monthly'],
      subscribed: ['plus_monthly'],
    );
    await _pump(tester, _withAppStore(subscribed), store: _FakeAppStore());

    expect(find.text(l10n.planAppStoreManageHelp), findsOneWidget);
    expect(find.text(r'$4.99'), findsNothing);
  });

  testWidgets('the App Store out of reach can be tried again', (tester) async {
    final store = _FakeAppStore(unreachable: true);
    await _pump(tester, _withAppStore(_billing), store: store);

    expect(find.text(l10n.planAppStoreUnavailable), findsOneWidget);
    store.unreachable = false;
    await tester.tap(find.text(l10n.planAppStoreUnavailable));
    await tester.pumpAndSettle();

    expect(find.text(r'$4.99'), findsOneWidget);
  });

  testWidgets('a server that sells nothing there shows none of it', (tester) async {
    await _pump(tester, _withAppStore(null), store: _FakeAppStore());

    expect(find.text(l10n.planRestore), findsNothing);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text(l10n.planAppStoreRenewal), findsNothing);
  });
}
