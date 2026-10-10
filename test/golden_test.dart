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
            bodyBuilder: (_) => const SizedBox(
              key: _body,
              width: 160,
              height: 100,
              child: Center(child: Text('Body')),
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
