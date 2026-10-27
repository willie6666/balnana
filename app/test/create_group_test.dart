import 'dart:async';
import 'dart:convert';

import 'package:balnana/core/prefs.dart';
import 'package:balnana/core/server.dart';
import 'package:balnana/core/settings.dart';
import 'package:balnana/data/providers.dart';
import 'package:balnana/features/groups/create_group_page.dart';
import 'package:balnana/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget host(ProviderContainer container, Widget home) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
    supportedLocales: AppLocalizations.supportedLocales,
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
