import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';
import 'package:popover/src/popover_context.dart';
import 'package:popover/src/popover_render_shifted_box.dart';

Future<void> _pump(
  WidgetTester tester,
  PopoverController controller, {
  String content = 'Hello',
  VoidCallback? onPop,
  bool show = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: show
              ? Popover(
                  controller: controller,
                  onPop: onPop,
                  content: (_) => Text(content),
                  child: const SizedBox(width: 80, height: 40),
                )
              : const SizedBox(),
        ),
      ),
    ),
  );
}

void main() {
  late PopoverController controller;
  setUp(() => controller = PopoverController());
  tearDown(() => controller.dispose());

  testWidgets('show and hide open and close the popover', (tester) async {
    await _pump(tester, controller);
    expect(find.text('Hello'), findsNothing);

    controller.show();
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect(controller.isOpen, isTrue);

    controller.hide();
    // Popped, so it animates out instead of vanishing.
    await tester.pump();
    expect(find.text('Hello'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);
    expect(controller.isOpen, isFalse);
  });

  testWidgets('opens again after it closed', (tester) async {
    await _pump(tester, controller);
    controller.show();
    await tester.pumpAndSettle();
    controller.hide();
    await tester.pumpAndSettle();

    controller.show();
    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('show then hide in one turn leaves it closed', (tester) async {
    await _pump(tester, controller);

    controller
      ..show()
      ..hide();
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);

    controller.show();
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('hide then show in one turn leaves it open', (tester) async {
    await _pump(tester, controller);
    controller.show();
    await tester.pumpAndSettle();

    controller
      ..hide()
      ..show();
    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
    expect(controller.isOpen, isTrue);
  });

  testWidgets('toggle flips the popover', (tester) async {
    await _pump(tester, controller);

    controller.toggle();
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);

    controller.toggle();
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);
  });

  testWidgets('points at its child', (tester) async {
    await _pump(tester, controller);
    controller.show();
    await tester.pumpAndSettle();

    final anchor = tester.getRect(find.byType(SizedBox).first);
    final body = tester.getRect(find.text('Hello'));
    expect(body.top, greaterThan(anchor.bottom));
    expect(body.center.dx, moreOrLessEquals(anchor.center.dx, epsilon: 1));
  });

  testWidgets('a barrier tap closes it and the controller follows', (
    tester,
  ) async {
    var dismissed = 0;
    await _pump(tester, controller, onPop: () => dismissed++);
    controller.show();
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsNothing);
    expect(controller.isOpen, isFalse);
    expect(dismissed, 1);
  });

  testWidgets('Esc closes it and the controller follows', (tester) async {
    await _pump(tester, controller);
    controller.show();
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(controller.isOpen, isFalse);
  });

  testWidgets('opens on the first frame when the controller starts open', (
    tester,
  ) async {
    final open = PopoverController(isOpen: true);
    addTearDown(open.dispose);
    await _pump(tester, open);
    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('a new content rebuilds the open popover', (tester) async {
    await _pump(tester, controller);
    controller.show();
    await tester.pumpAndSettle();

    await _pump(tester, controller, content: 'World');
    await tester.pump();

    expect(find.text('World'), findsOneWidget);
  });

  testWidgets('closes when the widget leaves the tree', (tester) async {
    await _pump(tester, controller);
    controller.show();
    await tester.pumpAndSettle();

    await _pump(tester, controller, show: false);
    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsNothing);
  });

  testWidgets('hide removes the popover from under another route', (
    tester,
  ) async {
    await _pump(tester, controller);
    controller.show();
    await tester.pumpAndSettle();
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(MaterialPageRoute<void>(builder: (_) => const Text('Top')));
    await tester.pumpAndSettle();

    controller.hide();
    await tester.pumpAndSettle();
    expect(find.text('Top'), findsOneWidget);
    expect(controller.isOpen, isFalse);

    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);
    expect(find.byType(Popover), findsOneWidget);
  });

  testWidgets('follows a new controller', (tester) async {
    await _pump(tester, controller);
    final other = PopoverController(isOpen: true);
    addTearDown(other.dispose);

    await _pump(tester, other);
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);

    controller.hide();
    other.hide();
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);
  });

  testWidgets('takes a style on top of the theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PopoverTheme(
          data: const PopoverStyle(radius: 3, arrowHeight: 9),
          child: Center(
            child: Popover(
              controller: controller,
              style: const PopoverStyle(radius: 4),
              content: (_) => const Text('Hello'),
              child: const SizedBox(width: 80, height: 40),
            ),
          ),
        ),
      ),
    );
    controller.show();
    await tester.pumpAndSettle();

    final box = tester.renderObject<PopoverRenderShiftedBox>(
      find.byType(PopoverContext),
    );
    expect(box.radius, 4);
    expect(box.arrowHeight, 9);
  });

  test('notifies only on a change', () {
    var calls = 0;
    controller.addListener(() => calls++);

    controller.hide();
    controller.show();
    controller.show();
    controller.toggle();

    expect(calls, 2);
    expect(controller.isOpen, isFalse);
  });
}
