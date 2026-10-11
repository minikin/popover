import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';
import 'package:popover/src/popover_context.dart';
import 'package:popover/src/popover_render_shifted_box.dart';
import 'package:popover/src/popover_shape.dart';

const _anchor = Key('anchor');

Future<PopoverShape> _shapeFor(
  WidgetTester tester,
  PopoverArrowStyle? style,
) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Center(child: SizedBox(key: _anchor, width: 80, height: 40)),
    ),
  );
  final context = tester.element(find.byKey(_anchor));
  if (style == null) {
    showPopover(context: context, bodyBuilder: (_) => const SizedBox());
  } else {
    showPopover(
      context: context,
      arrowStyle: style,
      bodyBuilder: (_) => const SizedBox(),
    );
  }
  await tester.pumpAndSettle();
  return tester
      .renderObject<PopoverRenderShiftedBox>(find.byType(PopoverContext))
      .shape;
}

void main() {
  const expected = {
    TargetPlatform.iOS: PopoverShape.ios,
    TargetPlatform.macOS: PopoverShape.macos,
    TargetPlatform.android: PopoverShape.triangle,
    TargetPlatform.fuchsia: PopoverShape.triangle,
    TargetPlatform.linux: PopoverShape.triangle,
    TargetPlatform.windows: PopoverShape.triangle,
  };

  testWidgets('adaptive is the default and follows the platform', (
    tester,
  ) async {
    expect(await _shapeFor(tester, null), expected[defaultTargetPlatform]);
  }, variant: TargetPlatformVariant.all());

  testWidgets('apple draws the macOS shape on macOS, the iOS one elsewhere', (
    tester,
  ) async {
    expect(
      await _shapeFor(tester, PopoverArrowStyle.apple),
      defaultTargetPlatform == TargetPlatform.macOS
          ? PopoverShape.macos
          : PopoverShape.ios,
    );
  }, variant: TargetPlatformVariant.all());

  testWidgets('triangle draws the triangle everywhere', (tester) async {
    expect(
      await _shapeFor(tester, PopoverArrowStyle.triangle),
      PopoverShape.triangle,
    );
  }, variant: TargetPlatformVariant.all());
}
