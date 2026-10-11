import 'dart:ui' show ImageFilter;

import 'package:cupertino_ui/cupertino_ui.dart' as cui;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as legacy;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:popover/popover.dart';
import 'package:popover/src/popover_context.dart';
import 'package:popover/src/popover_glass.dart';
import 'package:popover/src/popover_render_shifted_box.dart';
import 'package:popover/src/popover_shape.dart';

const _launcher = Key('launcher');

typedef _ThemedApp = Widget Function(Brightness theme, Widget home);

final _apps = <String, _ThemedApp>{
  'flutter/material': (theme, home) => legacy.MaterialApp(
    theme: legacy.ThemeData(brightness: theme),
    home: legacy.Scaffold(body: home),
  ),
  'material_ui': (theme, home) => mui.MaterialApp(
    theme: mui.ThemeData(brightness: theme),
    home: mui.Scaffold(body: home),
  ),
  'flutter/cupertino': (theme, home) => cupertino.CupertinoApp(
    theme: cupertino.CupertinoThemeData(brightness: theme),
    home: cupertino.CupertinoPageScaffold(child: home),
  ),
  'cupertino_ui': (theme, home) => cui.CupertinoApp(
    theme: cui.CupertinoThemeData(brightness: theme),
    home: cui.CupertinoPageScaffold(child: home),
  ),
};

Widget _bareApp(Brightness _, Widget home) => WidgetsApp(
  color: const Color(0xFF000000),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, _, _) => builder(context),
  ),
  home: home,
);

Future<PopoverRenderShiftedBox> _open(
  WidgetTester tester, {
  _ThemedApp app = _bareApp,
  Brightness theme = Brightness.light,
  Brightness system = Brightness.light,
  Brightness? brightness,
  Color? backgroundColor,
  Color? barrierColor,
  PopoverArrowStyle arrowStyle = PopoverArrowStyle.adaptive,
  Color? textColor,
  bool settle = true,
}) async {
  tester.platformDispatcher.platformBrightnessTestValue = system;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  await tester.pumpWidget(
    app(
      theme,
      DefaultTextStyle.merge(
        style: TextStyle(color: textColor),
        child: Center(
          child: Builder(
            builder: (context) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showPopover(
                context: context,
                brightness: brightness,
                backgroundColor: backgroundColor,
                barrierColor: barrierColor,
                arrowStyle: arrowStyle,
                bodyBuilder: (_) => const SizedBox(width: 120, height: 80),
              ),
              child: const SizedBox(key: _launcher, width: 80, height: 40),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(_launcher));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }
  return tester.renderObject(find.byType(PopoverContext));
}

Color? _barrierColor(WidgetTester tester) =>
    tester.widgetList<ModalBarrier>(find.byType(ModalBarrier)).last.color;

final _ios = TargetPlatformVariant.only(TargetPlatform.iOS);
const _apple = TargetPlatformVariant({
  TargetPlatform.iOS,
  TargetPlatform.macOS,
});

void main() {
  group('PopoverGlass.of', () {
    test('has no glass for the triangle', () {
      for (final brightness in Brightness.values) {
        expect(PopoverGlass.of(PopoverShape.triangle, brightness), isNull);
      }
    });

    test('picks the measured glass per shape and brightness', () {
      expect(
        PopoverGlass.of(PopoverShape.ios, Brightness.light),
        same(PopoverGlass.iosLight),
      );
      expect(
        PopoverGlass.of(PopoverShape.ios, Brightness.dark),
        same(PopoverGlass.iosDark),
      );
      expect(
        PopoverGlass.of(PopoverShape.macos, Brightness.light),
        same(PopoverGlass.macosLight),
      );
      expect(
        PopoverGlass.of(PopoverShape.macos, Brightness.dark),
        same(PopoverGlass.macosDark),
      );
    });

    test('keeps the popover opaque and tints dark glass darker', () {
      for (final glass in [
        PopoverGlass.iosLight,
        PopoverGlass.iosDark,
        PopoverGlass.macosLight,
        PopoverGlass.macosDark,
      ]) {
        expect(glass.matrix, hasLength(20));
        expect(glass.matrix.sublist(15), [0, 0, 0, 0, 255]);
        expect(glass.sigma, greaterThan(0));
        expect(glass.filter, isA<ImageFilter>());
      }
      expect(PopoverGlass.iosDark.matrix[4], lessThan(50));
      expect(PopoverGlass.iosLight.matrix[4], greaterThan(150));
      expect(PopoverGlass.macosDark.matrix[4], lessThan(50));
      expect(PopoverGlass.macosLight.matrix[4], greaterThan(150));
    });
  });

  group('the default background', () {
    for (final MapEntry(key: name, value: app) in _apps.entries) {
      for (final theme in Brightness.values) {
        final system = theme == Brightness.light
            ? Brightness.dark
            : Brightness.light;
        testWidgets(
          'follows a forced ${theme.name} $name theme, not the system',
          (tester) async {
            final box = await _open(
              tester,
              app: app,
              theme: theme,
              system: system,
            );

            expect(box.glass, same(PopoverGlass.of(PopoverShape.ios, theme)));
          },
          variant: _ios,
        );
      }
    }

    testWidgets('follows the system without an inherited text color', (
      tester,
    ) async {
      for (final system in Brightness.values) {
        final box = await _open(tester, system: system);
        final shape = defaultTargetPlatform == TargetPlatform.macOS
            ? PopoverShape.macos
            : PopoverShape.ios;

        expect(box.glass, same(PopoverGlass.of(shape, system)));
        await tester.tapAt(Offset.zero);
        await tester.pumpAndSettle();
      }
    }, variant: _apple);

    for (final (text, expected) in [
      (const Color(0xFF767676), Brightness.light),
      (const Color(0xFFA0A0A0), Brightness.dark),
    ]) {
      testWidgets('is ${expected.name} behind $text text', (tester) async {
        final box = await _open(
          tester,
          textColor: text,
          system: expected == Brightness.light
              ? Brightness.dark
              : Brightness.light,
        );

        expect(box.glass, same(PopoverGlass.of(PopoverShape.ios, expected)));
      }, variant: _ios);
    }

    testWidgets('takes brightness over the theme and the system', (
      tester,
    ) async {
      final box = await _open(
        tester,
        app: _apps['flutter/material']!,
        system: Brightness.light,
        brightness: Brightness.dark,
      );

      expect(box.glass, same(PopoverGlass.iosDark));
    }, variant: _ios);

    testWidgets('is a solid color when backgroundColor is given', (
      tester,
    ) async {
      final box = await _open(tester, backgroundColor: const Color(0xFF123456));

      expect(box.glass, isNull);
      expect(box.color, const Color(0xFF123456));
      expect(box.alwaysNeedsCompositing, isFalse);
    }, variant: _ios);

    testWidgets('is white or dark gray for the triangle', (tester) async {
      final light = await _open(tester, system: Brightness.light);
      expect(light.glass, isNull);
      expect(light.color, const Color(0xFFFFFFFF));
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      final dark = await _open(tester, system: Brightness.dark);
      expect(dark.glass, isNull);
      expect(dark.color, const Color(0xFF2C2C2E));
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  });

  group('glass', () {
    testWidgets('blurs the backdrop inside the outline', (tester) async {
      final box = await _open(tester);

      expect(box.alwaysNeedsCompositing, isTrue);
      final layers = <Layer>[];
      void collect(Layer? layer) {
        for (; layer != null; layer = layer.nextSibling) {
          layers.add(layer);
          if (layer is ContainerLayer) collect(layer.firstChild);
        }
      }

      collect(tester.layers.first);
      final backdrop = layers.whereType<BackdropFilterLayer>().single;
      expect(backdrop.filter, isNotNull);
      expect(
        layers.indexOf(layers.whereType<ClipPathLayer>().last),
        lessThan(layers.indexOf(backdrop)),
      );
    }, variant: _apple);

    testWidgets('scales before it clips while the popover opens', (
      tester,
    ) async {
      await _open(tester, settle: false);

      Layer? layer = tester.layers.whereType<BackdropFilterLayer>().single;
      final ancestors = <Type>[];
      for (; layer != null; layer = layer.parent) {
        ancestors.add(layer.runtimeType);
      }
      final clip = ancestors.indexOf(ClipPathLayer);
      expect(clip, greaterThan(0));
      expect(ancestors.indexOf(TransformLayer, clip), greaterThan(clip));
    }, variant: _ios);

    testWidgets('drops the backdrop layer for a solid color', (tester) async {
      final box = await _open(tester);
      expect(box.alwaysNeedsCompositing, isTrue);

      box.glass = null;
      box.color = const Color(0xFFFFFFFF);
      await tester.pump();

      expect(box.alwaysNeedsCompositing, isFalse);
      expect(tester.layers.whereType<BackdropFilterLayer>(), isEmpty);
    }, variant: _ios);
  });

  group('the default barrier', () {
    testWidgets('is clear for the Apple shapes', (tester) async {
      await _open(tester, arrowStyle: PopoverArrowStyle.apple);

      // ModalRoute leaves a fully transparent barrier unpainted.
      expect(_barrierColor(tester), isNull);
    });

    testWidgets('dims for the triangle', (tester) async {
      await _open(tester, arrowStyle: PopoverArrowStyle.triangle);

      expect(_barrierColor(tester), const Color(0x80000000));
    });

    testWidgets('gives way to barrierColor', (tester) async {
      await _open(
        tester,
        arrowStyle: PopoverArrowStyle.apple,
        barrierColor: const Color(0x33000000),
      );

      expect(_barrierColor(tester), const Color(0x33000000));
    });
  });
}
