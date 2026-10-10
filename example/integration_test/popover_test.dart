import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:popover_example/main.dart';
import 'package:popover_example/roadmap.dart';

const _screen = Key('screen');
const _arrowHeight = 15.0;

final _screenshots = <String, String>{};

final _canRotate =
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDownAll(() => binding.reportData = {'screenshots': _screenshots});

  Future<void> start(WidgetTester tester, {bool playground = true}) async {
    await tester.pumpWidget(
      const RepaintBoundary(key: _screen, child: PopoverExample()),
    );
    await tester.pumpAndSettle();
    if (playground) {
      await tester.tap(find.byKey(playgroundTab));
      await tester.pumpAndSettle();
    }
  }

  Future<void> screenshot(WidgetTester tester, String name) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(_screen),
    );
    final pixelRatio = tester.view.devicePixelRatio;
    final png = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return bytes!.buffer.asUint8List();
    });
    _screenshots['${_device(tester)}_$name'] = base64Encode(png!);
  }

  Future<void> open(WidgetTester tester, int button) async {
    await tester.tap(find.byType(Button).at(button));
    await tester.pumpAndSettle();
  }

  Future<void> dismiss(WidgetTester tester) async {
    final body = tester.getRect(find.byType(ListItems));
    final size = tester.getSize(find.byKey(_screen));
    final corner = [
      const Offset(2, 2),
      Offset(size.width - 2, 2),
      Offset(2, size.height - 2),
      Offset(size.width - 2, size.height - 2),
    ].firstWhere((point) => !body.contains(point));
    await tester.tapAt(corner);
    await tester.pumpAndSettle();
  }

  void expectNextToButton(WidgetTester tester, int button) {
    final screen = Offset.zero & tester.getSize(find.byKey(_screen));
    final launcher = tester.getRect(find.byType(Button).at(button));
    final body = tester.getRect(find.byType(ListItems));

    expect(screen.intersect(body), body, reason: 'body is on screen');
    expect(
      body.inflate(_arrowHeight + 1).overlaps(launcher),
      isTrue,
      reason: 'body $body is next to the button $launcher',
    );
  }

  testWidgets('opens next to every button and dismisses', (tester) async {
    await start(tester);

    for (var button = 0; button < 9; button++) {
      await open(tester, button);
      expect(find.byType(ListItems), findsOneWidget);
      expectNextToButton(tester, button);
      if (button == 0 || button == 4 || button == 8) {
        await screenshot(tester, 'button_$button');
      }

      await dismiss(tester);
      expect(find.byType(ListItems), findsNothing);
    }
  });

  testWidgets('demo', (tester) async {
    await start(tester, playground: false);
    final anchor = switch (_device(tester)) {
      'macOS' || 'web' => shareAnchor,
      'iOS_phone' || 'windows' => statusAnchor('POP-116'),
      _ => filterAnchor,
    };
    await tester.tap(find.byKey(anchor));
    await tester.pumpAndSettle();
    await screenshot(tester, 'demo');
  });

  testWidgets('item tap closes the popover and opens a route', (tester) async {
    await start(tester);
    await open(tester, 4);

    await tester.tap(find.text('Entry A'));
    await tester.pumpAndSettle();
    expect(find.byType(ListItems), findsNothing);
    expect(find.text('Second Route'), findsOneWidget);
    await screenshot(tester, 'second_route');

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(PlaygroundPage), findsOneWidget);
  });

  testWidgets('follows the button on rotation', (tester) async {
    addTearDown(() => SystemChrome.setPreferredOrientations([]));
    // Android 16 ignores orientation requests on screens of 600 dp and wider.
    if (defaultTargetPlatform == TargetPlatform.android && _isTablet(tester)) {
      return;
    }
    await start(tester);
    await open(tester, 7);

    await _rotate(tester, landscape: true);
    expectNextToButton(tester, 7);
    await screenshot(tester, 'rotated_landscape');

    await _rotate(tester, landscape: false);
    expectNextToButton(tester, 7);
    await screenshot(tester, 'rotated_portrait');
  }, skip: !_canRotate);
}

/// The platform, plus phone or tablet on iOS and Android, so iPhone and iPad
/// screenshots do not overwrite each other.
String _device(WidgetTester tester) {
  if (kIsWeb) return 'web';
  final platform = defaultTargetPlatform.name;
  if (!_canRotate) return platform;
  return '${platform}_${_isTablet(tester) ? 'tablet' : 'phone'}';
}

bool _isTablet(WidgetTester tester) {
  final view = tester.view;
  return view.physicalSize.shortestSide / view.devicePixelRatio >= 600;
}

Future<void> _rotate(WidgetTester tester, {required bool landscape}) async {
  await SystemChrome.setPreferredOrientations([
    if (landscape)
      DeviceOrientation.landscapeLeft
    else
      DeviceOrientation.portraitUp,
  ]);
  for (var i = 0; i < 150; i++) {
    final size = tester.view.physicalSize;
    if ((size.width > size.height) == landscape) break;
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();

  final size = tester.view.physicalSize;
  expect(size.width > size.height, landscape, reason: 'device rotated');
}
