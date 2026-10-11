import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';

import 'helpers/apps.dart';

const _screen = Key('screen');
const _launcher = Key('launcher');
const _body = Key('body');

const _devices = {'phone': Size(360, 640), 'tablet': Size(768, 1024)};

const _awayFromSide = {
  PopoverDirection.top: Alignment.topCenter,
  PopoverDirection.bottom: Alignment.bottomCenter,
  PopoverDirection.left: Alignment.centerLeft,
  PopoverDirection.right: Alignment.centerRight,
};

Future<void> _show(
  WidgetTester tester, {
  required Widget Function(WidgetBuilder launcherBuilder) app,
  Size size = const Size(360, 640),
  PopoverDirection direction = PopoverDirection.bottom,
  List<BoxShadow>? shadow,
  PopoverArrowStyle arrowStyle = PopoverArrowStyle.triangle,
  Brightness? brightness,
  Color? backgroundColor,
  Size body = const Size(160, 100),
  Duration? openFor,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    RepaintBoundary(
      key: _screen,
      child: app(
        (context) => GestureDetector(
          onTap: () => showPopover(
            context: context,
            direction: direction,
            shadow: shadow,
            arrowStyle: arrowStyle,
            brightness: brightness,
            backgroundColor: backgroundColor,
            bodyBuilder: (_) => SizedBox(
              key: _body,
              width: body.width,
              height: body.height,
              child: const Center(child: Text('Body')),
            ),
          ),
          child: const ColoredBox(
            key: _launcher,
            color: Color(0xFF2962FF),
            child: SizedBox(width: 80, height: 40),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(_launcher));
  if (openFor == null) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(openFor);
  }
}

/// Stripes behind the popover, so the goldens show what the glass blurs.
Widget _stripedApp(WidgetBuilder launcherBuilder) => legacyApp(
  (context) => CustomPaint(
    painter: const _Stripes(),
    child: Center(child: Builder(builder: launcherBuilder)),
  ),
);

class _Stripes extends CustomPainter {
  const _Stripes();

  @override
  void paint(Canvas canvas, Size size) {
    const colors = [Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFFE53935)];
    var i = 0;
    for (var x = 0.0; x < size.width; x += 12, i++) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, 12, size.height),
        Paint()..color = colors[i % colors.length],
      );
    }
  }

  @override
  bool shouldRepaint(_Stripes oldDelegate) => false;
}

void main() {
  group(
    'golden',
    () {
      for (final MapEntry(key: device, value: portrait) in _devices.entries) {
        final orientations = {
          'portrait': portrait,
          'landscape': portrait.flipped,
        };
        for (final MapEntry(key: orientation, value: size)
            in orientations.entries) {
          for (final direction in PopoverDirection.values) {
            final name = '${device}_${orientation}_${direction.name}';
            testWidgets(name, (tester) async {
              await _show(
                tester,
                app: legacyApp,
                size: size,
                direction: direction,
              );

              await expectLater(
                find.byKey(_screen),
                matchesGoldenFile('goldens/$name.png'),
              );
            });
          }
        }
      }

      for (final MapEntry(key: direction, value: alignment)
          in _awayFromSide.entries) {
        final name = 'flips_from_${direction.name}';
        testWidgets(name, (tester) async {
          await _show(
            tester,
            app: (launcher) => legacyApp(launcher, alignment: alignment),
            direction: direction,
          );

          final launcher = tester.getRect(find.byKey(_launcher));
          final body = tester.getRect(find.byKey(_body));
          switch (direction) {
            case PopoverDirection.top:
              expect(body.top, greaterThanOrEqualTo(launcher.bottom));
            case PopoverDirection.bottom:
              expect(body.bottom, lessThanOrEqualTo(launcher.top));
            case PopoverDirection.left:
              expect(body.left, greaterThanOrEqualTo(launcher.right));
            case PopoverDirection.right:
              expect(body.right, lessThanOrEqualTo(launcher.left));
          }
          await expectLater(
            find.byKey(_screen),
            matchesGoldenFile('goldens/$name.png'),
          );
        });
      }

      for (final direction in PopoverDirection.values) {
        final name = 'apple_${direction.name}';
        testWidgets(name, (tester) async {
          await _show(
            tester,
            app: legacyApp,
            direction: direction,
            arrowStyle: PopoverArrowStyle.apple,
            shadow: const [],
          );

          await expectLater(
            find.byKey(_screen),
            matchesGoldenFile('goldens/$name.png'),
          );
        });
      }

      for (final (name, alignment) in [
        ('macos_center', Alignment.center),
        ('macos_near_corner', const Alignment(-0.98, -0.5)),
      ]) {
        testWidgets(name, (tester) async {
          await _show(
            tester,
            app: (launcher) => legacyApp(launcher, alignment: alignment),
            arrowStyle: PopoverArrowStyle.apple,
          );

          await expectLater(
            find.byKey(_screen),
            matchesGoldenFile('goldens/$name.png'),
          );
        }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
      }

      testWidgets('apple_default_shadow', (tester) async {
        await _show(
          tester,
          app: legacyApp,
          arrowStyle: PopoverArrowStyle.apple,
        );

        await expectLater(
          find.byKey(_screen),
          matchesGoldenFile('goldens/apple_default_shadow.png'),
        );
      });

      testWidgets('apple_squashed_corner', (tester) async {
        await _show(
          tester,
          app: (launcher) =>
              legacyApp(launcher, alignment: const Alignment(-0.98, -0.5)),
          arrowStyle: PopoverArrowStyle.apple,
          shadow: const [],
        );

        await expectLater(
          find.byKey(_screen),
          matchesGoldenFile('goldens/apple_squashed_corner.png'),
        );
      });

      testWidgets('apple_tiny_body', (tester) async {
        await _show(
          tester,
          app: legacyApp,
          arrowStyle: PopoverArrowStyle.apple,
          body: const Size(40, 20),
        );

        await expectLater(
          find.byKey(_screen),
          matchesGoldenFile('goldens/apple_tiny_body.png'),
        );
      });

      for (final brightness in Brightness.values) {
        for (final (shape, platform) in [
          ('ios', TargetPlatform.iOS),
          ('macos', TargetPlatform.macOS),
        ]) {
          final name = 'glass_${shape}_${brightness.name}';
          testWidgets(name, (tester) async {
            await _show(
              tester,
              app: _stripedApp,
              arrowStyle: PopoverArrowStyle.apple,
              brightness: brightness,
            );

            await expectLater(
              find.byKey(_screen),
              matchesGoldenFile('goldens/$name.png'),
            );
          }, variant: TargetPlatformVariant.only(platform));
        }
      }

      testWidgets('glass_opening', (tester) async {
        await _show(
          tester,
          app: _stripedApp,
          arrowStyle: PopoverArrowStyle.apple,
          openFor: const Duration(milliseconds: 100),
        );

        await expectLater(
          find.byKey(_screen),
          matchesGoldenFile('goldens/glass_opening.png'),
        );
      }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

      // The outline grows about the arrow tip, so the tip stays on the
      // anchor while the popover opens.
      for (final MapEntry(key: direction, value: alignment)
          in _awayFromSide.entries) {
        final name = 'ios_opening_${direction.name}';
        testWidgets(name, (tester) async {
          await _show(
            tester,
            app: (launcher) => legacyApp(
              launcher,
              alignment: Alignment(-alignment.x * 0.5, -alignment.y * 0.5),
            ),
            direction: direction,
            arrowStyle: PopoverArrowStyle.apple,
            backgroundColor: const Color(0xFFFFFFFF),
            body: const Size(160, 240),
            openFor: const Duration(milliseconds: 60),
          );

          await expectLater(
            find.byKey(_screen),
            matchesGoldenFile('goldens/$name.png'),
          );
        }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
      }

      testWidgets('triangle_dark', (tester) async {
        await _show(tester, app: _stripedApp, brightness: Brightness.dark);

        await expectLater(
          find.byKey(_screen),
          matchesGoldenFile('goldens/triangle_dark.png'),
        );
      });

      testWidgets('two_shadows', (tester) async {
        await _show(
          tester,
          app: (launcher) =>
              legacyApp(launcher, alignment: const Alignment(0.6, -0.6)),
          shadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
            BoxShadow(color: Color(0x40000000), blurRadius: 2),
          ],
        );

        await expectLater(
          find.byKey(_screen),
          matchesGoldenFile('goldens/two_shadows.png'),
        );
      });

      for (final MapEntry(key: library, value: app) in appsByLibrary.entries) {
        final name = 'library_${library.replaceAll('/', '_')}';
        testWidgets(name, (tester) async {
          await _show(tester, app: app);

          await expectLater(
            find.byKey(_screen),
            matchesGoldenFile('goldens/$name.png'),
          );
        });
      }
    },
    skip: Platform.isLinux
        ? false
        : 'Goldens are rendered on Linux, see CONTRIBUTING.md',
  );
}
