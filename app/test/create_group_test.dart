import 'dart:async';
import 'dart:convert';

import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/core/settings.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/features/groups/create_group_page.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:balnana/ui/widgets/currency_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget host(ProviderContainer container, Widget home, {Locale locale = const Locale('en', 'US')}) =>
    UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    localeResolutionCallback: (locale, _) => locale,
    home: home,
  ),
);

const _created = {
  'token': 'AAAAAAAAAAAAAAAAAAAAAA',
  'name': 'Trip',
  'currency': 'USD',
  'minorDigits': 2,
  'createdAt': '2026-10-27T00:00:00Z',
  'members': [
    {'id': 'ana', 'name': 'Ana', 'balance': '0.00'},
  ],
};

void main() {
  testWidgets('without a region nothing is taken for the currency', (tester) async {
    SharedPreferences.setMockInitialValues({'settings.server': 'https://a.example'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [prefsProvider.overrideWithValue(prefs), accountProvider.overrideWithValue(const AsyncData(null))],
    );
    addTearDown(container.dispose);
    String currency() => tester.widget<CurrencyField>(find.byType(CurrencyField)).controller.text;
    await tester.pumpWidget(host(container, const CreateGroupPage(), locale: const Locale('en')));
    await tester.pumpAndSettle();
    expect(currency(), isEmpty);
    await tester.pumpWidget(const SizedBox());

    await tester.pumpWidget(host(container, const CreateGroupPage(), locale: const Locale('ar', 'SA')));
    await tester.pumpAndSettle();
    expect(currency(), 'SAR');
    await tester.pumpWidget(const SizedBox());
  });

  // Closing the page, or choosing another server, while the group is being
  // created must not lose its link: in link mode nothing else leads to it.
  for (final switchServer in [false, true]) {
    testWidgets('a group created as its page closes keeps its link (server switch: $switchServer)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'settings.server': 'https://a.example'});
      final prefs = await SharedPreferences.getInstance();
      final answer = Completer<Response<Object?>>();
      RequestOptions? asked;
      final dio = Dio(BaseOptions(baseUrl: 'https://a.example/api/v1'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (o, h) async {
            asked = o;
            h.resolve(await answer.future);
          },
        ),
      );
      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          apiProvider.overrideWithValue(dio),
          accountProvider.overrideWithValue(const AsyncData(null)),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(host(container, const CreateGroupPage()));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Group name'), 'Trip');
      await tester.enterText(find.widgetWithText(TextFormField, 'Your name'), 'Ana');
      final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Create group'));
      final pending = Function.apply(button.onPressed!, []) as Future<void>;
      await tester.pump(const Duration(milliseconds: 300));
      expect(asked?.path, '/groups');
      await tester.pumpWidget(host(container, const SizedBox()));
      await tester.pump();
      if (switchServer) container.read(settingsProvider.notifier).setServerUrl('https://b.example');
      answer.complete(Response(requestOptions: asked!, data: _created));
      await tester.pumpAndSettle();
      await pending;
      final known = (jsonDecode(prefs.getString('groups.known') ?? '[]') as List).cast<Map<String, Object?>>();
      expect(known.map((g) => (g['server'], g['token'], g['memberId'])), [
        ('https://a.example', 'AAAAAAAAAAAAAAAAAAAAAA', 'ana'),
      ]);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
