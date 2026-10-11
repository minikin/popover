import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';
import 'package:popover/src/popover_context.dart';
import 'package:popover/src/popover_position_render_object.dart';
import 'package:popover/src/popover_position_widget.dart';
import 'package:popover/src/popover_render_shifted_box.dart';

const _anchor = Key('anchor');

Future<void> _open(
  WidgetTester tester, {
  bool allowClicksOnBackground = false,
  PopoverDirection direction = PopoverDirection.bottom,
}) async {
  const anchor = SizedBox(key: _anchor, width: 80, height: 40);
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: Center(child: anchor)),
    ),
  );
  showPopover(
    context: tester.element(find.byKey(_anchor)),
    allowClicksOnBackground: allowClicksOnBackground,
    direction: direction,
    bodyBuilder: (_) => const SizedBox(width: 120, height: 80),
  );
  await tester.pumpAndSettle();
}

PopoverRenderShiftedBox _box(WidgetTester tester) =>
    tester.renderObject(find.byType(PopoverContext));

void main() {
  testWidgets('Esc leaves a popover that lets clicks through open', (
    tester,
  ) async {
    await _open(tester, allowClicksOnBackground: true);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.byType(PopoverContext), findsOneWidget);
  });

  testWidgets('a new arrow height lays the popover out again', (tester) async {
    await _open(tester);
    final box = _box(tester);
    final position = tester.renderObject<PopoverPositionRenderObject>(
      find.byType(PopoverPositionWidget),
    );
    final height = box.size.height;

    box.arrowHeight = box.arrowHeight + 10;
    position.arrowHeight = position.arrowHeight + 10;
    expect(box.debugNeedsLayout, isTrue);
    expect(position.debugNeedsLayout, isTrue);
    await tester.pump();

    expect(box.size.height, height + 10);
  });

  testWidgets('a new arrow width repaints without a layout', (tester) async {
    await _open(tester);
    final box = _box(tester);

    box.arrowWidth = 40;

    expect(box.debugNeedsPaint, isTrue);
    expect(box.debugNeedsLayout, isFalse);
  });

  testWidgets('color, radius and shadows only repaint', (tester) async {
    await _open(tester);
    final box = _box(tester);

    box.color = const Color(0xFF123456);
    expect(box.debugNeedsPaint, isTrue);
    expect(box.debugNeedsLayout, isFalse);
    await tester.pump();

    box.radius = 3;
    expect(box.debugNeedsPaint, isTrue);
    expect(box.debugNeedsLayout, isFalse);
    await tester.pump();

    box.boxShadow = [const BoxShadow(blurRadius: 4)];
    expect(box.debugNeedsPaint, isTrue);
    expect(box.debugNeedsLayout, isFalse);
    await tester.pump();

    box.boxShadow = [const BoxShadow(blurRadius: 4)];
    expect(box.debugNeedsPaint, isFalse);
  });

  testWidgets('a popover with no height keeps its outline while it grows', (
    tester,
  ) async {
    await _open(tester);
    final box = _box(tester);
    box.layout(const BoxConstraints.tightFor(width: 120, height: 0));
    box.reveal = 0.5;

    final frame = box.revealed(PopoverDirection.left, 0);

    expect(frame, Offset.zero & box.size);
    expect(frame.top.isNaN, isFalse);
  });

  testWidgets('an anchor without a render box still opens the popover', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(key: _anchor, child: SizedBox(height: 40)),
          ],
        ),
      ),
    );

    showPopover(
      context: tester.element(find.byKey(_anchor)),
      bodyBuilder: (_) => const SizedBox(width: 120, height: 80),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(PopoverContext), findsOneWidget);
  });

  testWidgets('taps and geometry follow the scale while the popover opens', (
    tester,
  ) async {
    var bodyTaps = 0;
    const anchor = SizedBox(key: _anchor, width: 80, height: 40);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: anchor)),
      ),
    );
    showPopover(
      context: tester.element(find.byKey(_anchor)),
      bodyBuilder: (_) => GestureDetector(
        key: const Key('body'),
        behavior: HitTestBehavior.opaque,
        onTap: () => bodyTaps++,
        child: const SizedBox(width: 200, height: 200),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    final box = _box(tester);
    final scale = box.scale!;
    expect(scale, inExclusiveRange(0.1, 0.95));
    final painted = tester.getRect(find.byKey(const Key('body')));
    expect(painted.width, moreOrLessEquals(200 * scale, epsilon: 0.5));

    // Inside the unscaled body, outside the painted one.
    final unscaledCorner = box.localToGlobal(
      (box.child!.parentData! as BoxParentData).offset + const Offset(195, 195),
    );
    expect(painted.contains(unscaledCorner), isFalse);
    await tester.tapAt(painted.center);
    expect(bodyTaps, 1);
    await tester.tapAt(unscaledCorner);
    expect(bodyTaps, 1);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
