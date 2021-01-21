import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';
import 'package:popover/src/popover_direction.dart';
import 'package:popover/src/popover_item.dart';
import 'package:popover/src/utils/build_context_extension.dart';
import 'package:popover/src/utils/utils.dart';

void main() {
  testWidgets(
    'Popover: can be initialized',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Popover(
            width: 200,
            child: Container(
              width: 80,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: const Center(child: Text('Click Me')),
            ),
            bodyBuilder: (context) {
              return Scrollbar(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 50,
                          color: Colors.amber[100],
                          child: const Center(child: Text('Entry A')),
                        ),
                      ),
                      const Divider(),
                      Container(
                        height: 50,
                        color: Colors.amber[200],
                        child: const Center(child: Text('Entry B')),
                      ),
                      const Divider(),
                      Container(
                        height: 50,
                        color: Colors.amber[300],
                        child: const Center(child: Text('Entry C')),
                      ),
                      const Divider(),
                      Container(
                        height: 50,
                        color: Colors.amber[400],
                        child: const Center(child: Text('Entry D')),
                      ),
                      const Divider(),
                      Container(
                        height: 50,
                        color: Colors.amber[500],
                        child: const Center(child: Text('Entry E')),
                      ),
                      const Divider(),
                      Container(
                        height: 50,
                        color: Colors.amber[600],
                        child: const Center(child: Text('Entry F')),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(tester.widget<Popover>(find.byType(Popover)), isNotNull);
    },
  );

  testWidgets(
    'Popover: can be initialized with parameters',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Popover(
            width: 200,
            direction: PopoverDirection.bottom,
            arrowWidth: 30,
            arrowHeight: 15,
            child: Container(
              width: 80,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: const Center(child: Text('Click Me')),
            ),
            bodyBuilder: (context) {
              return PopoverItem(
                attachRect: Rect.fromLTWH(
                  0,
                  0,
                  Utils().screenHeight / 3,
                  Utils().screenHeight / 3,
                ),
                child: const SizedBox.shrink(),
                constraints: BoxConstraints(
                  maxHeight: Utils().screenHeight / 3,
                  maxWidth: Utils().screenHeight / 3,
                ),
                backgroundColor: Colors.red,
                boxShadow: [
                  const BoxShadow(color: Colors.black12, blurRadius: 5)
                ],
                radius: 8,
                animation: Tween<double>(begin: 0, end: 300).animate(
                  AnimationController(
                    duration: const Duration(milliseconds: 500),
                    vsync: const TestVSync(),
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(
        tester.widget<Popover>(find.byType(Popover)).direction,
        PopoverDirection.bottom,
      );
      expect(tester.widget<Popover>(find.byType(Popover)).width, 200);
      expect(tester.widget<Popover>(find.byType(Popover)).radius, 8);
      expect(tester.widget<Popover>(find.byType(Popover)).arrowWidth, 30);
      expect(tester.widget<Popover>(find.byType(Popover)).arrowHeight, 15);
    },
  );

  testWidgets('Popover: has a child', (tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          final offset = BuildContextExtension.getWidgetLocalToGlobal(context);
          final bounds = BuildContextExtension.getWidgetBounds(context);

          return MaterialApp(
            home: Popover(
              width: 200,
              child: Container(
                width: 80,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: const Center(child: Text('Click Me')),
              ),
              bodyBuilder: (context) {
                return PopoverItem(
                  attachRect: Rect.fromLTWH(
                    offset.dx,
                    offset.dy,
                    bounds.width,
                    bounds.height,
                  ),
                  child: const SizedBox.shrink(),
                  constraints: BoxConstraints(
                    maxHeight: Utils().screenHeight / 3,
                    maxWidth: Utils().screenHeight / 3,
                  ),
                  backgroundColor: Colors.white,
                  boxShadow: [
                    const BoxShadow(color: Colors.black12, blurRadius: 5)
                  ],
                  radius: 8,
                  animation: Tween<double>(begin: 0, end: 300).animate(
                    AnimationController(
                      duration: const Duration(milliseconds: 500),
                      vsync: const TestVSync(),
                    ),
                  ),
                  direction: PopoverDirection.top,
                  arrowWidth: 10,
                  arrowHeight: 20,
                );
              },
            ),
          );
        },
      ),
    );

    expect(tester.widget<Popover>(find.byType(Popover)).child, isNotNull);
  });

  testWidgets('Popover: is shown', (tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          final offset = BuildContextExtension.getWidgetLocalToGlobal(context);
          final bounds = BuildContextExtension.getWidgetBounds(context);

          return MaterialApp(
            home: Popover(
              width: 200,
              child: Container(
                width: 80,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: const Center(child: Text('Click Me')),
              ),
              bodyBuilder: (context) {
                return PopoverItem(
                  attachRect: Rect.fromLTWH(
                    offset.dx,
                    offset.dy,
                    bounds.width,
                    bounds.height,
                  ),
                  child: const SizedBox.shrink(),
                  constraints: BoxConstraints(
                    maxHeight: Utils().screenHeight / 3,
                    maxWidth: Utils().screenHeight / 3,
                  ),
                  backgroundColor: Colors.white,
                  boxShadow: [
                    const BoxShadow(color: Colors.black12, blurRadius: 5)
                  ],
                  radius: 8,
                  animation: Tween<double>(begin: 0, end: 300).animate(
                    AnimationController(
                      duration: const Duration(milliseconds: 500),
                      vsync: const TestVSync(),
                    ),
                  ),
                  direction: PopoverDirection.top,
                  arrowWidth: 10,
                  arrowHeight: 20,
                );
              },
            ),
          );
        },
      ),
    );

    await tester.tap(find.byType(Popover).first);
  });
}
