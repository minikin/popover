import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';

const _arrowHeight = 13.0;
const _body = Key('body');

typedef _Case = ({
  String name,
  TargetPlatform platform,
  Size screen,
  EdgeInsets safeArea,
  Rect anchor,
  Size body,
  PopoverDirection direction,
  Rect expected,
});

// Popover frames with the arrow, measured on iOS 26 simulators (iPhone 17
// Pro, iPad Pro 11-inch) with UIPopoverPresentationController and on macOS 26
// with NSPopover.
final List<_Case> _cases = [
  (
    name: 'iPhone, slides off the right edge',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(314, 417, 394, 457),
    body: const Size(160, 100),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(232, 304, 392, 417),
  ),
  (
    name: 'iPhone, fits nowhere, takes the larger side and shrinks',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(161, 417, 241, 457),
    body: const Size(200, 400),
    direction: PopoverDirection.bottom,
    expected: const Rect.fromLTRB(101, 457, 301, 830),
  ),
  (
    name: 'iPhone, side popover covers the anchor up to its center',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(161, 417, 241, 457),
    body: const Size(400, 150),
    direction: PopoverDirection.right,
    expected: const Rect.fromLTRB(201, 362, 392, 512),
  ),
  (
    name: 'iPhone, shrinks to the screen width',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(161, 792, 241, 832),
    body: const Size(600, 900),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(10, 72, 392, 792),
  ),
  (
    name: 'iPhone landscape, right of a corner anchor',
    platform: TargetPlatform.iOS,
    screen: const Size(874, 402),
    safeArea: const EdgeInsets.fromLTRB(62, 0, 62, 20),
    anchor: const Rect.fromLTRB(70, 8, 150, 48),
    body: const Size(160, 100),
    direction: PopoverDirection.right,
    expected: const Rect.fromLTRB(150, 10, 323, 110),
  ),
  (
    name: 'iPhone landscape, fits nowhere, shrinks above',
    platform: TargetPlatform.iOS,
    screen: const Size(874, 402),
    safeArea: const EdgeInsets.fromLTRB(62, 0, 62, 20),
    anchor: const Rect.fromLTRB(397, 181, 477, 221),
    body: const Size(200, 400),
    direction: PopoverDirection.bottom,
    expected: const Rect.fromLTRB(337, 10, 537, 181),
  ),
  (
    name: 'iPad, slides off the right edge',
    platform: TargetPlatform.iOS,
    screen: const Size(834, 1210),
    safeArea: const EdgeInsets.only(top: 32, bottom: 25),
    anchor: const Rect.fromLTRB(746, 585, 826, 625),
    body: const Size(160, 100),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(655, 472, 815, 585),
  ),
  (
    name: 'iPad, side popover covers the anchor up to its center',
    platform: TargetPlatform.iOS,
    screen: const Size(834, 1210),
    safeArea: const EdgeInsets.only(top: 32, bottom: 25),
    anchor: const Rect.fromLTRB(377, 585, 457, 625),
    body: const Size(400, 150),
    direction: PopoverDirection.right,
    expected: const Rect.fromLTRB(417, 530, 815, 680),
  ),
  (
    name: 'iPad, shrinks below the top margin',
    platform: TargetPlatform.iOS,
    screen: const Size(834, 1210),
    safeArea: const EdgeInsets.only(top: 32, bottom: 25),
    anchor: const Rect.fromLTRB(377, 1137, 457, 1177),
    body: const Size(600, 900),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(117, 224, 717, 1137),
  ),
  (
    name: 'iPad landscape, keeps the top margin',
    platform: TargetPlatform.iOS,
    screen: const Size(1210, 834),
    safeArea: const EdgeInsets.only(top: 32, bottom: 25),
    anchor: const Rect.fromLTRB(8, 40, 88, 80),
    body: const Size(160, 100),
    direction: PopoverDirection.right,
    expected: const Rect.fromLTRB(88, 62, 261, 162),
  ),
  (
    name: 'macOS, fits on neither vertical side, goes right',
    platform: TargetPlatform.macOS,
    screen: const Size(800, 600),
    safeArea: EdgeInsets.zero,
    anchor: const Rect.fromLTRB(100, 280, 180, 320),
    body: const Size(200, 400),
    direction: PopoverDirection.bottom,
    expected: const Rect.fromLTRB(180, 100, 393, 500),
  ),
  (
    name: 'macOS, right is full, goes left',
    platform: TargetPlatform.macOS,
    screen: const Size(800, 600),
    safeArea: EdgeInsets.zero,
    anchor: const Rect.fromLTRB(620, 280, 700, 320),
    body: const Size(200, 400),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(407, 100, 620, 500),
  ),
];

Future<Rect> _popoverRect(WidgetTester tester, _Case c) async {
  tester.view
    ..physicalSize = c.screen
    ..devicePixelRatio = 1
    ..padding = FakeViewPadding(
      left: c.safeArea.left,
      top: c.safeArea.top,
      right: c.safeArea.right,
      bottom: c.safeArea.bottom,
    );
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Stack(
        children: [
          Positioned.fromRect(
            rect: c.anchor,
            child: Builder(
              builder: (context) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => showPopover(
                  context: context,
                  direction: c.direction,
                  arrowHeight: _arrowHeight,
                  bodyBuilder: (_) =>
                      SizedBox.fromSize(key: _body, size: c.body),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  await tester.tapAt(c.anchor.center);
  await tester.pumpAndSettle();

  final body = tester.getRect(find.byKey(_body));
  if (body.top >= c.anchor.bottom - 1) {
    return Rect.fromLTRB(
      body.left,
      body.top - _arrowHeight,
      body.right,
      body.bottom,
    );
  }
  if (body.bottom <= c.anchor.top + 1) {
    return Rect.fromLTRB(
      body.left,
      body.top,
      body.right,
      body.bottom + _arrowHeight,
    );
  }
  return body.center.dx > c.anchor.center.dx
      ? Rect.fromLTRB(
          body.left - _arrowHeight,
          body.top,
          body.right,
          body.bottom,
        )
      : Rect.fromLTRB(
          body.left,
          body.top,
          body.right + _arrowHeight,
          body.bottom,
        );
}

void main() {
  for (final c in _cases) {
    testWidgets(c.name, (tester) async {
      final rect = await _popoverRect(tester, c);

      expect(rect.left, moreOrLessEquals(c.expected.left, epsilon: 1));
      expect(rect.top, moreOrLessEquals(c.expected.top, epsilon: 1));
      expect(rect.right, moreOrLessEquals(c.expected.right, epsilon: 1));
      expect(rect.bottom, moreOrLessEquals(c.expected.bottom, epsilon: 1));
    }, variant: TargetPlatformVariant.only(c.platform));
  }
}
