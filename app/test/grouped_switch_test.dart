import 'dart:async';

import 'package:balnana/ui/widgets/grouped_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> show(WidgetTester tester, bool value, Future<void> Function(bool) save) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GroupedSwitchTile.saving(icon: Icons.link_off, title: 'Block', value: value, onSave: save),
      ),
    ),
  );

  bool shown(WidgetTester tester) => tester.widget<Switch>(find.byType(Switch)).value;

  testWidgets('a saving switch moves at once and keeps still while it saves', (tester) async {
    var saving = Completer<void>();
    final asked = <bool>[];
    Future<void> save(bool on) {
      asked.add(on);
      return saving.future;
    }

    await show(tester, false, save);
    await tester.tap(find.text('Block'));
    await tester.pump();
    expect(shown(tester), isTrue);
    // Another tap while it saves sends nothing.
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(asked, [true]);
    expect(shown(tester), isTrue);

    // Saved: the value from the parent shows.
    await show(tester, true, save);
    saving.complete();
    await tester.pump();
    expect(shown(tester), isTrue);

    // A save that failed leaves the old value.
    saving = Completer<void>();
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(shown(tester), isFalse);
    saving.complete();
    await tester.pump();
    expect(shown(tester), isTrue);
    expect(asked, [true, false]);
  });
}
