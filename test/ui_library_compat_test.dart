import 'package:flutter/material.dart' as legacy;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:popover/popover.dart';

const _bodyColor = Color(0xFFAA0000);

typedef _AppBuilder = Widget Function(WidgetBuilder launcherBuilder);

Widget _legacyApp(WidgetBuilder launcherBuilder) {
  return legacy.MaterialApp(
    theme: legacy.ThemeData(
      textTheme: const legacy.TextTheme(
        bodyMedium: TextStyle(color: _bodyColor),
      ),
    ),
    home: legacy.Scaffold(
      body: Center(child: Builder(builder: launcherBuilder)),
    ),
  );
}

Widget _materialUiApp(WidgetBuilder launcherBuilder) {
  return mui.MaterialApp(
    theme: mui.ThemeData(
      textTheme: const mui.TextTheme(bodyMedium: TextStyle(color: _bodyColor)),
    ),
    home: mui.Scaffold(
      body: Center(child: Builder(builder: launcherBuilder)),
    ),
  );
}

Future<void> _open(
  WidgetTester tester,
  _AppBuilder app, {
  required WidgetBuilder bodyBuilder,
  String? barrierLabel,
}) async {
  await tester.pumpWidget(
    app(
      (context) => GestureDetector(
        onTap: () => showPopover(
          context: context,
          bodyBuilder: bodyBuilder,
          barrierLabel: barrierLabel,
        ),
        child: const Text('Go'),
      ),
    ),
  );
  await tester.tap(find.text('Go'));
  await tester.pumpAndSettle();
}

void main() {
  final apps = <String, _AppBuilder>{
    'flutter/material': _legacyApp,
    'material_ui': _materialUiApp,
  };

  for (final MapEntry(key: name, value: app) in apps.entries) {
    group('$name app', () {
      testWidgets('opens without barrierLabel', (tester) async {
        await _open(tester, app, bodyBuilder: (_) => const Text('Body'));

        expect(find.text('Body'), findsOneWidget);
        expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
      });

      testWidgets('uses the given barrierLabel', (tester) async {
        await _open(
          tester,
          app,
          bodyBuilder: (_) => const Text('Body'),
          barrierLabel: 'Close',
        );

        expect(find.bySemanticsLabel('Close'), findsOneWidget);
      });

      testWidgets('tap on empty body area keeps the popover open', (
        tester,
      ) async {
        await _open(
          tester,
          app,
          bodyBuilder: (_) => const SizedBox(
            key: Key('body'),
            width: 200,
            height: 200,
            child: Align(alignment: Alignment.topLeft, child: Text('Body')),
          ),
        );

        final body = tester.getRect(find.byKey(const Key('body')));
        await tester.tapAt(body.bottomRight - const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(find.text('Body'), findsOneWidget);
      });

      testWidgets('applies the caller text style to the body', (tester) async {
        late TextStyle bodyStyle;
        await _open(
          tester,
          app,
          bodyBuilder: (context) {
            bodyStyle = DefaultTextStyle.of(context).style;
            return const Text('Body');
          },
        );

        expect(bodyStyle.color, _bodyColor);
      });
    });
  }

  testWidgets('flutter/material ListTile works inside its own Material', (
    tester,
  ) async {
    await _open(
      tester,
      _legacyApp,
      bodyBuilder: (_) =>
          const legacy.Material(child: legacy.ListTile(title: Text('Tile'))),
    );

    expect(find.text('Tile'), findsOneWidget);
  });

  testWidgets('material_ui ListTile works inside its own Material', (
    tester,
  ) async {
    await _open(
      tester,
      _materialUiApp,
      bodyBuilder: (_) =>
          const mui.Material(child: mui.ListTile(title: Text('Tile'))),
    );

    expect(find.text('Tile'), findsOneWidget);
  });
}
