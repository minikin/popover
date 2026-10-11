import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';

const _arrowHeight = 13.0;
const _body = Key('body');
const _anchor = Key('anchor');

typedef _Case = ({
  String name,
  TargetPlatform platform,
  Size screen,
  EdgeInsets safeArea,
  double keyboard,
  Rect anchor,
  Size body,
  PopoverDirection direction,
  Rect expected,
});

// Popover frames with the arrow, measured with UIPopoverPresentationController
// on iOS 26 simulators (iPhone 17 Pro, iPhone SE, iPad Pro 11-inch) and with
// NSPopover on macOS 26.
final List<_Case> _cases = [
  (
    name: 'iPhone, slides off the right edge',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    keyboard: 0,
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
    keyboard: 0,
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
    keyboard: 0,
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
    keyboard: 0,
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
    keyboard: 0,
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
    keyboard: 0,
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
    keyboard: 0,
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
    keyboard: 0,
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
    keyboard: 0,
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
    keyboard: 0,
    safeArea: const EdgeInsets.only(top: 32, bottom: 25),
    anchor: const Rect.fromLTRB(8, 40, 88, 80),
    body: const Size(160, 100),
    direction: PopoverDirection.right,
    expected: const Rect.fromLTRB(88, 62, 261, 162),
  ),
  (
    name: 'iPhone, anchor partly below the bottom edge',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    keyboard: 0,
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(161, 854, 241, 894),
    body: const Size(160, 100),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(121, 717, 281, 830),
  ),
  (
    name: 'iPhone, anchor fully below the bottom edge',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    keyboard: 0,
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(161, 924, 241, 964),
    body: const Size(160, 100),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(121, 717, 281, 830),
  ),
  (
    name: 'iPhone, anchor partly off the left edge',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    keyboard: 0,
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(-40, 417, 40, 457),
    body: const Size(160, 100),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(10, 304, 170, 417),
  ),
  (
    name: 'iPhone, zero-size anchor',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    keyboard: 0,
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(201, 437, 201, 437),
    body: const Size(160, 100),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(121, 324, 281, 437),
  ),
  (
    name: 'iPhone, anchor covers most of the screen',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    keyboard: 0,
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(20, 60, 382, 814),
    body: const Size(160, 100),
    direction: PopoverDirection.bottom,
    expected: const Rect.fromLTRB(121, 814, 281, 830),
  ),
  (
    name: 'iPhone, body narrower than the arrow',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    keyboard: 0,
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(161, 417, 241, 457),
    body: const Size(20, 10),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(191, 394, 211, 417),
  ),
  (
    name: 'iPhone keyboard, shrinks above the anchor',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    keyboard: 335,
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(161, 393.3, 241, 433.3),
    body: const Size(200, 400),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(101, 72, 301, 393.3),
  ),
  (
    name: 'iPhone keyboard, anchor under the keyboard',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    keyboard: 335,
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(161, 742.9, 241, 782.9),
    body: const Size(160, 100),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(121, 416, 281, 529),
  ),
  (
    name: 'iPhone keyboard, shrinks down to the keyboard',
    platform: TargetPlatform.iOS,
    screen: const Size(402, 874),
    keyboard: 335,
    safeArea: const EdgeInsets.only(top: 62, bottom: 34),
    anchor: const Rect.fromLTRB(161, 262.2, 241, 302.2),
    body: const Size(160, 300),
    direction: PopoverDirection.bottom,
    expected: const Rect.fromLTRB(121, 302, 281, 529),
  ),
  (
    name: 'iPhone SE, anchor partly below the bottom edge',
    platform: TargetPlatform.iOS,
    screen: const Size(375, 667),
    keyboard: 0,
    safeArea: const EdgeInsets.only(top: 20),
    anchor: const Rect.fromLTRB(147.5, 647, 227.5, 687),
    body: const Size(160, 100),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(108, 534, 268, 647),
  ),
  (
    name: 'iPhone SE, anchor fully below the bottom edge',
    platform: TargetPlatform.iOS,
    screen: const Size(375, 667),
    keyboard: 0,
    safeArea: const EdgeInsets.only(top: 20),
    anchor: const Rect.fromLTRB(147.5, 717, 227.5, 757),
    body: const Size(160, 100),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(108, 544, 268, 657),
  ),
  (
    name: 'iPhone SE keyboard, shrinks above the anchor',
    platform: TargetPlatform.iOS,
    screen: const Size(375, 667),
    keyboard: 260,
    safeArea: const EdgeInsets.only(top: 20),
    anchor: const Rect.fromLTRB(147.5, 300.2, 227.5, 340.2),
    body: const Size(200, 400),
    direction: PopoverDirection.top,
    expected: const Rect.fromLTRB(88, 30, 288, 300.2),
  ),
  (
    name: 'macOS, fits on neither vertical side, goes right',
    platform: TargetPlatform.macOS,
    screen: const Size(800, 600),
    keyboard: 0,
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
    keyboard: 0,
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
    ..viewInsets = FakeViewPadding(bottom: c.keyboard)
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
            child: const SizedBox.expand(key: _anchor),
          ),
        ],
      ),
    ),
  );
  showPopover(
    context: tester.element(find.byKey(_anchor)),
    direction: c.direction,
    style: const PopoverStyle(arrowHeight: _arrowHeight),
    bodyBuilder: (_) => SizedBox.fromSize(key: _body, size: c.body),
  );
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
