import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';
import 'package:popover/src/popover_context.dart';
import 'package:popover/src/popover_motion.dart';
import 'package:popover/src/popover_render_shifted_box.dart';
import 'package:popover/src/popover_shape.dart';

import 'helpers/apps.dart';

const _launcher = Key('launcher');
const _body = Key('body');

Future<void> _open(
  WidgetTester tester, {
  PopoverTransition transition = PopoverTransition.scale,
  Duration? transitionDuration,
  PopoverDirection direction = PopoverDirection.bottom,
}) async {
  await tester.pumpWidget(
    legacyApp(
      (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showPopover(
          context: context,
          style: PopoverStyle(
            arrowStyle: PopoverArrowStyle.adaptive,
            transition: transition,
            transitionDuration: transitionDuration,
          ),
          direction: direction,
          bodyBuilder: (_) =>
              const SizedBox(key: _body, width: 160, height: 300),
        ),
        child: const SizedBox(key: _launcher, width: 80, height: 40),
      ),
    ),
  );
  await tester.tap(find.byKey(_launcher));
  await tester.pump();
}

PopoverRenderShiftedBox _box(WidgetTester tester) =>
    tester.renderObject(find.byType(PopoverContext));

ModalRoute<Object?> _route(WidgetTester tester) =>
    ModalRoute.of(tester.element(find.byKey(_body)))!;

List<double> _samples(Curve curve) => [
  for (var i = 0; i <= 1000; i++) curve.transform(i / 1000),
];

final _ios = TargetPlatformVariant.only(TargetPlatform.iOS);

void main() {
  group('PopoverMotion.ios', () {
    test('starts at 0 and ends at 1', () {
      for (final curve in [
        PopoverMotion.ios.present,
        PopoverMotion.ios.dismiss,
      ]) {
        expect(curve.transform(0), 0);
        expect(curve.transform(1), 1);
      }
    });

    // UIKit's opacity peaked at 1.0151 while presenting and dipped to
    // -0.0063 while dismissing, sampled once a frame on an iOS 26 simulator.
    test('overshoots like the measured springs', () {
      expect(
        _samples(PopoverMotion.ios.present).reduce((a, b) => a > b ? a : b),
        moreOrLessEquals(1.0151, epsilon: 0.001),
      );
      expect(
        _samples(
          PopoverMotion.ios.dismiss.flipped,
        ).reduce((a, b) => a < b ? a : b),
        moreOrLessEquals(-0.0063, epsilon: 0.001),
      );
    });

    // UIKit's presented opacity, 82 and 182 milliseconds after the first
    // sample of the spring at 0.0011.
    test('follows the measured presentation', () {
      final spring = PopoverMotion.ios.present;
      final start = PopoverMotion.ios.presentDuration.inMicroseconds;
      double at(double seconds) => spring.transform(seconds * 1e6 / start);
      final offset = [
        for (var t = 0.0; t < 0.05; t += 0.0001) t,
      ].firstWhere((t) => at(t) >= 0.0011);

      expect(at(offset + 0.0821), moreOrLessEquals(0.5152, epsilon: 0.03));
      expect(at(offset + 0.1821), moreOrLessEquals(0.9479, epsilon: 0.03));
    });
  });

  test('picks the motion per shape', () {
    expect(PopoverMotion.of(PopoverShape.triangle), isNull);
    expect(PopoverMotion.of(PopoverShape.ios), same(PopoverMotion.ios));
    expect(PopoverMotion.of(PopoverShape.macos), same(PopoverMotion.macos));
    expect(PopoverMotion.ios.startScale, 0.01);
    expect(PopoverMotion.ios.grows, isTrue);
    expect(PopoverMotion.macos.startScale, 0);
    expect(PopoverMotion.macos.grows, isFalse);
  });

  group('PopoverMotion.macos', () {
    double at(SpringCurve curve, double seconds) => curve.transform(
      seconds * Duration.microsecondsPerSecond / curve.duration.inMicroseconds,
    );

    // NSPopover recorded at 120 frames per second: 94.5% of its size 172 ms
    // into opening, 39.5% left 100 ms into closing.
    test('follows the recorded NSPopover', () {
      expect(
        at(PopoverMotion.macos.present, 0.172),
        moreOrLessEquals(0.945, epsilon: 0.03),
      );
      expect(
        1 - at(PopoverMotion.macos.dismiss, 0.1),
        moreOrLessEquals(0.395, epsilon: 0.03),
      );
      expect(
        _samples(PopoverMotion.macos.present).reduce((a, b) => a > b ? a : b),
        moreOrLessEquals(1.015, epsilon: 0.002),
      );
    });

    testWidgets('scales the whole popover without growing the outline', (
      tester,
    ) async {
      await _open(tester);
      expect(
        _route(tester).transitionDuration,
        const Duration(milliseconds: 440),
      );
      expect(
        _route(tester).reverseTransitionDuration,
        const Duration(milliseconds: 200),
      );

      await tester.pump(const Duration(milliseconds: 60));
      final box = _box(tester);
      expect(box.scale, inExclusiveRange(0, 1));
      expect(box.reveal, 1);
      expect(box.opacity, moreOrLessEquals(box.scale!));
    }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
  });

  group('on iOS', () {
    testWidgets('opens and closes with the measured durations', (tester) async {
      await _open(tester);

      expect(
        _route(tester).transitionDuration,
        PopoverMotion.ios.presentDuration,
      );
      expect(
        _route(tester).reverseTransitionDuration,
        PopoverMotion.ios.dismissDuration,
      );
    }, variant: _ios);

    testWidgets('a given duration applies both ways', (tester) async {
      await _open(tester, transitionDuration: const Duration(seconds: 1));

      expect(_route(tester).transitionDuration, const Duration(seconds: 1));
      expect(
        _route(tester).reverseTransitionDuration,
        const Duration(seconds: 1),
      );
    }, variant: _ios);

    testWidgets('scales from the tip while the outline grows', (tester) async {
      await _open(tester);
      await tester.pump(const Duration(milliseconds: 60));

      final box = _box(tester);
      expect(box.reveal, inExclusiveRange(0, 1));
      expect(box.scale, moreOrLessEquals(0.01 + 0.99 * box.reveal));

      await tester.pumpAndSettle();
      expect(box.reveal, 1);
      expect(box.scale, 1);
    }, variant: _ios);

    testWidgets('fades and shrinks back when it closes', (tester) async {
      await _open(tester);
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byKey(_body))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      final box = _box(tester);
      expect(box.reveal, inExclusiveRange(0, 1));
      expect(box.opacity, moreOrLessEquals(box.reveal));

      await tester.pumpAndSettle();
      expect(find.byKey(_body), findsNothing);
    }, variant: _ios);

    testWidgets('only fades with PopoverTransition.other', (tester) async {
      await _open(tester, transition: PopoverTransition.other);
      await tester.pump(const Duration(milliseconds: 60));

      expect(_box(tester).scale, 1);
      expect(_box(tester).reveal, 1);
      expect(
        _route(tester).transitionDuration,
        const Duration(milliseconds: 200),
      );
    }, variant: _ios);
  });

  testWidgets('elsewhere scales linearly over 200 milliseconds', (
    tester,
  ) async {
    await _open(tester);
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      _route(tester).transitionDuration,
      const Duration(milliseconds: 200),
    );
    expect(
      _route(tester).reverseTransitionDuration,
      const Duration(milliseconds: 200),
    );
    expect(_box(tester).scale, moreOrLessEquals(0.25));
    expect(_box(tester).reveal, 1);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  test('a route without a reverse duration reverses as fast', () {
    final route = PopoverRoute<void>(
      pageBuilder: (_, _, _) => const SizedBox(),
      transitionDuration: const Duration(milliseconds: 300),
    );
    addTearDown(route.dispose);

    expect(route.reverseTransitionDuration, const Duration(milliseconds: 300));
  });

  group('the growing outline', () {
    Future<PopoverRenderShiftedBox> settled(
      WidgetTester tester,
      PopoverDirection direction,
    ) async {
      await _open(tester, direction: direction);
      await tester.pumpAndSettle();
      return _box(tester);
    }

    testWidgets('keeps the arrow edge of a popover below its anchor', (
      tester,
    ) async {
      final box = await settled(tester, PopoverDirection.bottom);
      final size = box.size;
      box.reveal = 0;

      expect(
        box.revealed(PopoverDirection.bottom, 50),
        Rect.fromLTWH(0, 0, size.width, 100),
      );
      box.reveal = 0.5;
      expect(
        box.revealed(PopoverDirection.bottom, 50).height,
        moreOrLessEquals((100 + size.height) / 2),
      );
    }, variant: _ios);

    testWidgets('keeps the arrow edge of a popover above its anchor', (
      tester,
    ) async {
      final box = await settled(tester, PopoverDirection.top);
      final size = box.size;
      box.reveal = 0;

      expect(
        box.revealed(PopoverDirection.top, 50),
        Rect.fromLTRB(0, size.height - 100, size.width, size.height),
      );
    }, variant: _ios);

    testWidgets('grows about the tip of a side arrow', (tester) async {
      final box = await settled(tester, PopoverDirection.right);
      final size = box.size;
      final k = 100 / size.height;
      box.reveal = 0;

      expect(
        box.revealed(PopoverDirection.right, 100),
        rectMoreOrLessEquals(
          Rect.fromLTRB(
            0,
            100 - 100 * k,
            size.width,
            100 + (size.height - 100) * k,
          ),
        ),
      );
      box.reveal = 1;
      expect(box.revealed(PopoverDirection.right, 100), Offset.zero & size);
    }, variant: _ios);

    testWidgets('keeps a popover shorter than the start height', (
      tester,
    ) async {
      final box = await settled(tester, PopoverDirection.bottom);
      box.reveal = 0;
      box.layout(const BoxConstraints.tightFor(width: 160, height: 60));

      expect(box.revealed(PopoverDirection.bottom, 50).height, 60);
    }, variant: _ios);
  });
}
