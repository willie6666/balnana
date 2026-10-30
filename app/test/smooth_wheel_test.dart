import 'package:balnana/ui/smooth_wheel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late WheelGlide glide;
  late ScrollController scroll;
  late TestPointer mouse;

  Future<void> pumpList(WidgetTester tester) async {
    glide = WheelGlide(tester.binding);
    scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ListView(controller: scroll, children: const [SizedBox(height: 5000)]),
      ),
    );
    mouse = TestPointer(1, PointerDeviceKind.mouse)..hover(tester.getCenter(find.byType(ListView)));
  }

  bool wheel(double dy) => glide.handle(mouse.scroll(Offset(0, dy)));

  testWidgets('a mouse wheel step eases to its target', (tester) async {
    await pumpList(tester);
    expect(wheel(100), isTrue);
    expect(wheel(100), isTrue);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(scroll.offset, inExclusiveRange(0, 200));
    await tester.pumpAndSettle();
    expect(scroll.offset, moreOrLessEquals(200));
  });

  testWidgets('a spinning wheel moves every frame instead of pausing between steps', (tester) async {
    await pumpList(tester);
    var previous = scroll.offset;
    for (var frame = 0; frame < 30; frame++) {
      if (frame % 4 == 0) wheel(100);
      await tester.pump(const Duration(milliseconds: 16));
      expect(scroll.offset, greaterThan(previous), reason: 'frame $frame');
      previous = scroll.offset;
    }
    await tester.pumpAndSettle();
    expect(scroll.offset, moreOrLessEquals(800));
  });

  testWidgets('steps past an edge are dropped, so turning back moves at once', (tester) async {
    await pumpList(tester);
    final end = scroll.position.maxScrollExtent;
    scroll.jumpTo(end - 50);
    for (var i = 0; i < 10; i++) {
      wheel(100);
    }
    await tester.pumpAndSettle();
    expect(scroll.offset, end);
    wheel(-100);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(scroll.offset, lessThan(end));
    await tester.pumpAndSettle();
    expect(scroll.offset, moreOrLessEquals(end - 100));
  });

  testWidgets('trackpads and ctrl-wheel pass through; a press stops the glide', (tester) async {
    await pumpList(tester);
    final trackpad = TestPointer(2, PointerDeviceKind.trackpad)
      ..hover(tester.getCenter(find.byType(ListView)));
    expect(glide.handle(trackpad.scroll(const Offset(0, 30))), isFalse);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    expect(wheel(100), isFalse);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    wheel(400);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    final stopped = scroll.offset;
    expect(glide.handle(mouse.down(mouse.location!)), isFalse);
    await tester.pumpAndSettle();
    expect(scroll.offset, stopped);
  });
}
