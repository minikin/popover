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
  List<BoxShadow> shadow = const [
    BoxShadow(color: Color(0x1F000000), blurRadius: 5),
  ],
  PopoverArrowStyle arrowStyle = PopoverArrowStyle.triangle,
  Size body = const Size(160, 100),
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
  await tester.pumpAndSettle();
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
