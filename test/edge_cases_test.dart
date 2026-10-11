import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';

const _body = Key('body');
const _anchor = Key('anchor');

Future<void> _open(
  WidgetTester tester, {
  required Widget Function(Widget anchor) app,
  PopoverDirection direction = PopoverDirection.bottom,
  Size body = const Size(160, 100),
}) async {
  tester.view
    ..physicalSize = const Size(400, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    app(const ColoredBox(key: _anchor, color: Color(0xFF2962FF))),
  );
  showPopover(
    context: tester.element(find.byKey(_anchor)),
    direction: direction,
    bodyBuilder: (_) => SizedBox.fromSize(key: _body, size: body),
  );
  await tester.pumpAndSettle();
}

Widget _at(Rect rect, Widget anchor, {TextDirection? textDirection}) {
  return MaterialApp(
    builder: textDirection == null
        ? null
        : (_, child) =>
              Directionality(textDirection: textDirection, child: child!),
    home: Stack(
      children: [Positioned.fromRect(rect: rect, child: anchor)],
    ),
  );
}

void main() {
  testWidgets('follows an anchor that moves while open', (tester) async {
    final top = ValueNotifier<double>(100);
    addTearDown(top.dispose);
    await _open(
      tester,
      app: (anchor) => MaterialApp(
        home: ValueListenableBuilder<double>(
          valueListenable: top,
          builder: (_, value, _) => Stack(
            children: [
              Positioned(
                left: 160,
                top: value,
                width: 80,
                height: 40,
                child: anchor,
              ),
            ],
          ),
        ),
      ),
    );

    top.value = 300;
    await tester.pump();
    await tester.pump();

    final anchor = tester.getRect(find.byKey(_anchor));
    final body = tester.getRect(find.byKey(_body));
    expect(anchor.top, 300);
    expect(body.top, anchor.bottom + 12);
  });

  for (final direction in [PopoverDirection.left, PopoverDirection.right]) {
    testWidgets('keeps ${direction.name} physical in a right-to-left app', (
      tester,
    ) async {
      await _open(
        tester,
        app: (anchor) => _at(
          const Rect.fromLTWH(160, 380, 80, 40),
          anchor,
          textDirection: TextDirection.rtl,
        ),
        direction: direction,
        body: const Size(120, 100),
      );

      final anchor = tester.getRect(find.byKey(_anchor));
      final body = tester.getRect(find.byKey(_body));
      expect(
        Directionality.of(tester.element(find.byKey(_body))),
        TextDirection.rtl,
      );
      if (direction == PopoverDirection.right) {
        expect(body.left, greaterThanOrEqualTo(anchor.right));
      } else {
        expect(body.right, lessThanOrEqualTo(anchor.left));
      }
    });
  }

  testWidgets('stays open and rebuilds after its anchor leaves the tree', (
    tester,
  ) async {
    final shown = ValueNotifier(true);
    addTearDown(shown.dispose);
    await _open(
      tester,
      app: (anchor) => MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: shown,
            builder: (_, value, _) => value
                ? Center(child: SizedBox(width: 80, height: 40, child: anchor))
                : const SizedBox(),
          ),
        ),
      ),
    );
    final before = tester.getRect(find.byKey(_body));

    final route = ModalRoute.of(tester.element(find.byKey(_body)))!;
    shown.value = false;
    await tester.pumpAndSettle();
    route.changedExternalState();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(_body), findsOneWidget);
    expect(tester.getRect(find.byKey(_body)).size, before.size);
  });

  testWidgets('re-places the popover when the window shrinks', (tester) async {
    await _open(
      tester,
      app: (anchor) => MaterialApp(
        home: Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(width: 80, height: 40, child: anchor),
        ),
      ),
      direction: PopoverDirection.top,
    );

    tester.view.physicalSize = const Size(300, 500);
    await tester.pump();
    await tester.pump();

    final screen = Offset.zero & const Size(300, 500);
    final anchor = tester.getRect(find.byKey(_anchor));
    final body = tester.getRect(find.byKey(_body));
    expect(anchor.bottomRight, screen.bottomRight);
    expect(screen.deflate(10).intersect(body), body);
    expect(body.bottom, anchor.top - 12);
  });

  testWidgets('a large text scale grows the body within the screen', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _at(
        const Rect.fromLTWH(160, 600, 80, 40),
        const ColoredBox(key: _anchor, color: Color(0xFF2962FF)),
      ),
    );
    showPopover(
      context: tester.element(find.byKey(_anchor)),
      bodyBuilder: (_) => SingleChildScrollView(
        key: _body,
        child: Text('Copy Share Delete Rename Move Duplicate ' * 8),
      ),
    );
    await tester.pumpAndSettle();

    final body = tester.getRect(find.byKey(_body));
    expect(
      (Offset.zero & const Size(400, 800)).deflate(10).intersect(body),
      body,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('an anchor that fills the screen keeps the arrow', (
    tester,
  ) async {
    await _open(tester, app: (anchor) => MaterialApp(home: anchor));

    expect(tester.getSize(find.byKey(_body)).height, 0);
    expect(tester.takeException(), isNull);
  });
}
