import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';

final _anchorFocus = FocusNode(debugLabel: 'anchor');

Future<void> _open(
  WidgetTester tester, {
  String? semanticsLabel,
  bool? requestFocus,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => TextButton(
              focusNode: _anchorFocus,
              onPressed: () => showPopover(
                context: context,
                semanticsLabel: semanticsLabel,
                requestFocus: requestFocus,
                bodyBuilder: (_) => Material(
                  type: MaterialType.transparency,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('One')),
                      TextButton(onPressed: () {}, child: const Text('Two')),
                    ],
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  _anchorFocus.requestFocus();
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
}

String? _focused() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return null;
  String? label;
  context.visitChildElements((element) {
    final text = find
        .descendant(
          of: find.byElementPredicate((e) => e == element),
          matching: find.byType(Text),
        )
        .evaluate();
    if (text.isNotEmpty) label = (text.first.widget as Text).data;
  });
  return label;
}

void main() {
  tearDownAll(_anchorFocus.dispose);

  testWidgets('Esc closes the popover, as NSPopover does', (tester) async {
    await _open(tester);
    expect(find.text('One'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('One'), findsNothing);
  }, variant: TargetPlatformVariant.all());

  testWidgets('Tab cycles through the popover only', (tester) async {
    await _open(tester);

    final order = <String?>[];
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      order.add(_focused());
    }

    expect(order, ['One', 'Two', 'One', 'Two']);
  });

  testWidgets('focus returns to the anchor when the popover closes', (
    tester,
  ) async {
    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(FocusManager.instance.primaryFocus, _anchorFocus);
  });

  testWidgets('requestFocus: false leaves focus on the anchor', (tester) async {
    await _open(tester, requestFocus: false);

    expect(find.text('One'), findsOneWidget);
    expect(FocusManager.instance.primaryFocus, _anchorFocus);
  });

  group('screen readers', () {
    testWidgets('see only the popover and the barrier', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(tester);

      expect(find.semantics.byLabel('One'), findsOne);
      expect(find.semantics.byLabel('Open'), findsNothing);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Dismiss')),
        matchesSemantics(
          label: 'Dismiss',
          hasTapAction: true,
          hasDismissAction: true,
          textDirection: TextDirection.ltr,
        ),
      );
      handle.dispose();
    });

    testWidgets('reach the barrier after the popover', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(tester);

      final popover = tester.getSemantics(find.text('One')).parent!;
      final barrier = tester.getSemantics(find.bySemanticsLabel('Dismiss'));
      final keys = [
        for (final node in [popover, barrier])
          _sortKey(node),
      ];
      expect(keys[0]!.compareTo(keys[1]!), lessThan(0));
      handle.dispose();
    });

    testWidgets('hear semanticsLabel as the name of the popover', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _open(tester, semanticsLabel: 'Share');

      final node = tester.getSemantics(find.bySemanticsLabel('Share'));
      expect(node.getSemanticsData().flagsCollection.namesRoute, isTrue);
      expect(
        find.semantics.descendant(
          of: find.semantics.byLabel('Share'),
          matching: find.semantics.byLabel('One'),
        ),
        findsOne,
      );
      handle.dispose();
    });

    testWidgets('get no name without semanticsLabel', (tester) async {
      final handle = tester.ensureSemantics();
      await _open(tester);

      expect(
        tester
            .getSemantics(find.text('One'))
            .parent!
            .getSemanticsData()
            .flagsCollection
            .namesRoute,
        isFalse,
      );
      handle.dispose();
    });
  });
}

SemanticsSortKey? _sortKey(SemanticsNode node) {
  for (SemanticsNode? n = node; n != null; n = n.parent) {
    final key = n.sortKey;
    if (key != null) return key;
  }
  return null;
}
