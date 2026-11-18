import 'package:balnana/core/l10n.dart';
import 'package:balnana/core/offline_cache.dart';
import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/features/account/sign_in_page.dart';
import 'package:balnana/features/settings/privacy_page.dart';
import 'package:balnana/l10n/app_localizations_en.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('localizedPolicyUrl', () {
    const en = Locale('en');
    const hant = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW');
    const hans = Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN');
    final terms = Uri.parse('https://balnana.com/terms');

    test('picks the official site page in the app language', () {
      expect(localizedPolicyUrl(terms, en), terms);
      expect(localizedPolicyUrl(terms, const Locale('ja')), terms);
      expect(localizedPolicyUrl(terms, hant).toString(), 'https://balnana.com/zh-Hant/terms');
      expect(localizedPolicyUrl(terms, hans).toString(), 'https://balnana.com/zh/terms');
    });

    test('replaces a language the operator already chose', () {
      final zh = Uri.parse('https://balnana.com/zh-Hant/terms');
      expect(localizedPolicyUrl(zh, en).toString(), 'https://balnana.com/terms');
      expect(localizedPolicyUrl(zh, hans).toString(), 'https://balnana.com/zh/terms');
    });

    test('leaves other sites alone', () {
      final other = Uri.parse('https://example.com/terms');
      expect(localizedPolicyUrl(other, hant), other);
    });
  });

  group('ServerInfo.fromJson', () {
    Map<String, Object?> json([Map<String, Object?> extra = const {}]) => {
      'name': 'balnana',
      'version': '1.0.0',
      'authMode': 'accounts',
      'publicUrl': 'https://split.example.com',
      ...extra,
    };

    test('reads an optional terms link, only to open in a browser', () {
      expect(ServerInfo.fromJson(json()).termsUrl, isNull);
      expect(
        ServerInfo.fromJson(json({'termsUrl': 'https://balnana.com/terms'})).termsUrl,
        Uri.parse('https://balnana.com/terms'),
      );
      for (final bad in ['javascript:alert(1)', 'balnana.com/terms', 42]) {
        expect(ServerInfo.fromJson(json({'termsUrl': bad})).termsUrl, isNull, reason: '$bad');
      }
    });
  });

  group('the sign-in page', () {
    Future<void> pump(WidgetTester tester, {Uri? terms, SignupPolicy signup = SignupPolicy.open}) async {
      // Tall enough for the whole form: the page only builds what is on screen.
      tester.view.physicalSize = const Size(1200, 3600);
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({'settings.server': 'https://a.example'});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prefsProvider.overrideWithValue(prefs),
            cacheDbProvider.overrideWithValue(null),
            serverInfoProvider.overrideWithValue(
              AsyncData(
                ServerInfo(
                  version: 'test',
                  authMode: AuthMode.accounts,
                  password: true,
                  signup: signup,
                  publicUrl: 'https://a.example',
                  termsUrl: terms,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: l10nDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SignInPage(prefill: SignInPrefill(register: true)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('says signing up agrees to the terms and privacy policy', (tester) async {
      await pump(tester, terms: Uri.parse('https://balnana.com/terms'));
      expect(find.text(l10n.termsAgreement), findsOneWidget);
      expect(find.widgetWithText(TextButton, l10n.termsTitle), findsOneWidget);
      expect(find.widgetWithText(TextButton, l10n.privacyTitle), findsOneWidget);
    });

    testWidgets('links only the privacy policy without terms', (tester) async {
      await pump(tester);
      expect(find.text(l10n.termsAgreement), findsNothing);
      expect(find.widgetWithText(TextButton, l10n.privacyLink), findsOneWidget);
    });

    testWidgets('asks no agreement when nobody can sign up', (tester) async {
      await pump(tester, terms: Uri.parse('https://balnana.com/terms'), signup: SignupPolicy.closed);
      expect(find.text(l10n.termsAgreement), findsNothing);
      expect(find.widgetWithText(TextButton, l10n.privacyLink), findsOneWidget);
    });
  });
}
