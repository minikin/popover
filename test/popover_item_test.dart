import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/src/popover_direction.dart';
import 'package:popover/src/popover_item.dart';
import 'package:popover/src/utils/utils.dart';

void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    ui.window.onBeginFrame = null;
    ui.window.onDrawFrame = null;
  });

  testWidgets(
    'PopoverItem: direction top',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PopoverItem(
            attachRect: const Rect.fromLTWH(
              0,
              0,
              100,
              200,
            ),
            child: const SizedBox.shrink(),
            backgroundColor: Colors.white,
            boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
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
          ),
        ),
      );
    },
  );

  testWidgets(
    'PopoverItem: direction bottom',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PopoverItem(
            attachRect: const Rect.fromLTWH(
              0,
              0,
              100,
              200,
            ),
            child: const SizedBox.shrink(),
            backgroundColor: Colors.white,
            boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
            radius: 8,
            animation: Tween<double>(begin: 0, end: 300).animate(
              AnimationController(
                duration: const Duration(milliseconds: 500),
                vsync: const TestVSync(),
              ),
            ),
            direction: PopoverDirection.bottom,
            arrowWidth: 10,
            arrowHeight: 20,
          ),
        ),
      );
    },
  );

  testWidgets(
    'PopoverItem: direction right',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PopoverItem(
            attachRect: const Rect.fromLTWH(
              0,
              0,
              100,
              200,
            ),
            child: const SizedBox.shrink(),
            backgroundColor: Colors.white,
            boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
            radius: 8,
            animation: Tween<double>(begin: 0, end: 300).animate(
              AnimationController(
                duration: const Duration(milliseconds: 500),
                vsync: const TestVSync(),
              ),
            ),
            direction: PopoverDirection.right,
            arrowWidth: 10,
            arrowHeight: 20,
          ),
        ),
      );
    },
  );

  testWidgets(
    'PopoverItem: direction left',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PopoverItem(
            attachRect: const Rect.fromLTWH(
              0,
              0,
              100,
              200,
            ),
            child: const SizedBox.shrink(),
            backgroundColor: Colors.white,
            boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
            radius: 8,
            animation: Tween<double>(begin: 0, end: 300).animate(
              AnimationController(
                duration: const Duration(milliseconds: 500),
                vsync: const TestVSync(),
              ),
            ),
            direction: PopoverDirection.left,
            arrowWidth: 10,
            arrowHeight: 20,
          ),
        ),
      );
    },
  );

  testWidgets(
    'PopoverItem: has constraints',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PopoverItem(
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
            backgroundColor: Colors.white,
            boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
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
          ),
        ),
      );
    },
  );
}
