import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';

void main() {
  testWidgets('Popover dialog control test', (tester) async {
    var didDelete = false;

    await tester.pumpWidget(
      createAppWithButtonThatLaunchesDialog(
        dialogBuilder: (context) {
          return InkWell(
            onTap: () {
              didDelete = true;
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          );
        },
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.pump();

    expect(didDelete, isFalse);

    await tester.tap(find.text('Delete'));
    await tester.pump();

    expect(didDelete, isTrue);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('Popover is barrier dismissible by default', (tester) async {
    await tester.pumpWidget(createAppWithCenteredButton(const Text('Go')));

    final BuildContext context = tester.element(find.text('Go'));

    showPopover(
      context: context,
      bodyBuilder: (context) {
        return Container(
          width: 100.0,
          height: 100.0,
          alignment: Alignment.center,
          child: const Text('Dialog'),
        );
      },
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Dialog'), findsOneWidget);

    // Tap off the barrier.
    await tester.tapAt(const Offset(10.0, 10.0));

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Dialog'), findsNothing);
  });

  testWidgets('Popover configurable to be not barrier dismissible',
      (tester) async {
    await tester.pumpWidget(createAppWithCenteredButton(const Text('Go')));

    final BuildContext context = tester.element(find.text('Go'));

    showPopover(
      context: context,
      bodyBuilder: (context) {
        return Container(
          width: 100.0,
          height: 100.0,
          alignment: Alignment.center,
          child: const Text('Dialog'),
        );
      },
      barrierDismissible: false,
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Dialog'), findsOneWidget);

    // Tap on the barrier, which shouldn't do anything this time.
    await tester.tapAt(const Offset(10.0, 10.0));

    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Dialog'), findsOneWidget);
  });

  testWidgets('onPop is called after tap on barrier', (tester) async {
    var didPop = false;

    await tester.pumpWidget(createAppWithCenteredButton(const Text('Go')));

    final BuildContext context = tester.element(find.text('Go'));

    showPopover(
      context: context,
      bodyBuilder: (context) {
        return Container(
          width: 100.0,
          height: 100.0,
          alignment: Alignment.center,
          child: const Text('Dialog'),
        );
      },
      onPop: () => didPop = true,
    );

    await tester.tap(find.text('Go'));
    await tester.pump();

    expect(didPop, isFalse);

    // Tap off the barrier.
    await tester.tapAt(const Offset(10.0, 10.0));

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(didPop, isTrue);
  });

  // testWidgets('Context can not be null', (tester) async {
  //   await tester.pumpWidget(createAppWithCenteredButton(const Text('Go')));

  //   expect(
  //     () => showPopover(
  //       context: null,
  //       bodyBuilder: (context) => null as Widget Function(BuildContext),
  //     ),
  //     throwsAssertionError,
  //   );
  // });

  // testWidgets('BodyBuilder can not be null', (tester) async {
  //   await tester.pumpWidget(createAppWithCenteredButton(const Text('Go')));
  //   final BuildContext context = tester.element(find.text('Go'));

  //   expect(
  //     () => showPopover(context: context, bodyBuilder: null),
  //     throwsAssertionError,
  //   );
  // });
}

Widget createAppWithButtonThatLaunchesDialog({
  required WidgetBuilder dialogBuilder,
}) {
  return MaterialApp(
    home: Material(
      child: Center(
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showPopover(
                  context: context,
                  bodyBuilder: dialogBuilder,
                );
              },
              child: const Text('Go'),
            );
          },
        ),
      ),
    ),
  );
}

Widget boilerplate(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: child,
  );
}

Widget createAppWithCenteredButton(Widget child) {
  return MaterialApp(
    home: Material(
      child: Center(
        child: ElevatedButton(onPressed: null, child: child),
      ),
    ),
  );
}
