import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';
import 'package:popover/src/popover_context.dart';
import 'package:popover/src/popover_motion.dart';
import 'package:popover/src/popover_render_shifted_box.dart';
import 'package:popover/src/popover_shape.dart';
import 'package:popover/src/resolved_popover_style.dart';

/// One style with every field set, and for each field a style that differs
/// from it in that field alone.
const _full = PopoverStyle(
  arrowStyle: PopoverArrowStyle.triangle,
  backgroundColor: Color(0xFF111111),
  brightness: Brightness.dark,
  barrierColor: Color(0x22000000),
  radius: 5,
  shadow: [BoxShadow(blurRadius: 1)],
  arrowWidth: 10,
  arrowHeight: 6,
  transition: PopoverTransition.other,
  transitionDuration: Duration(milliseconds: 100),
);

final _changes = <String, PopoverStyle Function(PopoverStyle)>{
  'arrowStyle': (s) => s.copyWith(arrowStyle: PopoverArrowStyle.apple),
  'backgroundColor': (s) =>
      s.copyWith(backgroundColor: const Color(0xFF222222)),
  'brightness': (s) => s.copyWith(brightness: Brightness.light),
  'barrierColor': (s) => s.copyWith(barrierColor: const Color(0x33000000)),
  'radius': (s) => s.copyWith(radius: 6),
  'shadow': (s) => s.copyWith(shadow: const [BoxShadow(blurRadius: 2)]),
  'arrowWidth': (s) => s.copyWith(arrowWidth: 11),
  'arrowHeight': (s) => s.copyWith(arrowHeight: 7),
  'transition': (s) => s.copyWith(transition: PopoverTransition.scale),
  'transitionDuration': (s) =>
      s.copyWith(transitionDuration: const Duration(milliseconds: 200)),
};

Object? _field(PopoverStyle s, String name) => switch (name) {
  'arrowStyle' => s.arrowStyle,
  'backgroundColor' => s.backgroundColor,
  'brightness' => s.brightness,
  'barrierColor' => s.barrierColor,
  'radius' => s.radius,
  'shadow' => s.shadow,
  'arrowWidth' => s.arrowWidth,
  'arrowHeight' => s.arrowHeight,
  'transition' => s.transition,
  'transitionDuration' => s.transitionDuration,
  _ => throw ArgumentError(name),
};

/// [_full] with only [name] set.
PopoverStyle _only(String name) =>
    const PopoverStyle().merge(_changes[name]!(const PopoverStyle()));

void main() {
  group('PopoverStyle', () {
    for (final MapEntry(key: name, value: change) in _changes.entries) {
      test('copyWith changes $name and nothing else', () {
        final changed = change(_full);
        for (final other in _changes.keys) {
          if (other == name) {
            expect(_field(changed, other), isNot(_field(_full, other)));
          } else {
            expect(_field(changed, other), _field(_full, other));
          }
        }
      });

      test('two styles that differ in $name are unequal', () {
        final changed = change(_full);
        expect(changed, isNot(_full));
        expect(changed.hashCode, isNot(_full.hashCode));
      });

      test('merge takes $name from the override', () {
        final override = _only(name);
        expect(_field(_full.merge(override), name), _field(override, name));
      });

      test('merge keeps $name when the override leaves it null', () {
        final other = _changes.keys.firstWhere((n) => n != name);
        expect(_field(_full.merge(_only(other)), name), _field(_full, name));
      });
    }

    test('equal styles have equal hashes, shadows by value', () {
      final a = _full.copyWith(shadow: [const BoxShadow(blurRadius: 1)]);
      expect(a, _full);
      expect(a.hashCode, _full.hashCode);
      expect(const PopoverStyle(), const PopoverStyle());
      expect(_full, isNot(Object()));
    });

    test('merge with null is the same style', () {
      expect(_full.merge(null), same(_full));
    });

    test('lists every field in its diagnostics', () {
      final builder = DiagnosticPropertiesBuilder();
      _full.debugFillProperties(builder);
      expect(builder.properties.map((p) => p.name), _changes.keys.toList());
      final empty = DiagnosticPropertiesBuilder();
      const PopoverStyle().debugFillProperties(empty);
      expect(
        empty.properties.where((p) => !p.isFiltered(DiagnosticLevel.info)),
        isEmpty,
      );
    });
  });

  group('ResolvedPopoverStyle', () {
    ResolvedPopoverStyle resolve(TargetPlatform platform, [PopoverStyle? s]) =>
        ResolvedPopoverStyle.of(s ?? const PopoverStyle(), platform);

    test('defaults to the triangle off Apple platforms', () {
      final r = resolve(TargetPlatform.android);
      expect(r.shape, PopoverShape.triangle);
      expect(r.arrowWidth, 24);
      expect(r.arrowHeight, 12);
      expect(r.radius, 8);
      expect(r.shadow, const [
        BoxShadow(color: Color(0x1F000000), blurRadius: 5),
      ]);
      expect(r.barrierColor, const Color(0x80000000));
      expect(r.transition, PopoverTransition.scale);
      expect(r.motion, isNull);
      expect(r.presentDuration, const Duration(milliseconds: 200));
      expect(r.dismissDuration, const Duration(milliseconds: 200));
      expect(r.solidColor(Brightness.light), const Color(0xFFFFFFFF));
      expect(r.solidColor(Brightness.dark), const Color(0xFF2C2C2E));
    });

    test('defaults to the iOS 26 popover on iOS', () {
      final r = resolve(TargetPlatform.iOS);
      expect(r.shape, PopoverShape.ios);
      expect(r.arrowWidth, 26);
      expect(r.arrowHeight, 13);
      expect(r.radius, 34);
      expect(r.shadow, const [
        BoxShadow(color: Color(0x6B000000), blurRadius: 210),
      ]);
      expect(r.barrierColor, const Color(0x00000000));
      expect(r.motion, same(PopoverMotion.ios));
      expect(r.presentDuration, PopoverMotion.ios.presentDuration);
      expect(r.dismissDuration, PopoverMotion.ios.dismissDuration);
    });

    test('defaults to the macOS 26 popover on macOS', () {
      final r = resolve(TargetPlatform.macOS);
      expect(r.shape, PopoverShape.macos);
      expect(r.arrowWidth, 25.42);
      expect(r.arrowHeight, 13);
      expect(r.radius, 20);
      expect(r.shadow, const [
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 12,
          offset: Offset(0, 3.6),
        ),
      ]);
      expect(r.motion, same(PopoverMotion.macos));
    });

    test('apple picks the iOS shape everywhere but macOS', () {
      const apple = PopoverStyle(arrowStyle: PopoverArrowStyle.apple);
      expect(resolve(TargetPlatform.android, apple).shape, PopoverShape.ios);
      expect(resolve(TargetPlatform.macOS, apple).shape, PopoverShape.macos);
    });

    test('takes every field set on the style', () {
      final r = resolve(TargetPlatform.iOS, _full);
      expect(r.shape, PopoverShape.triangle);
      expect(r.arrowWidth, 10);
      expect(r.arrowHeight, 6);
      expect(r.radius, 5);
      expect(r.shadow, _full.shadow);
      expect(r.backgroundColor, _full.backgroundColor);
      expect(r.brightness, Brightness.dark);
      expect(r.barrierColor, _full.barrierColor);
      expect(r.transition, PopoverTransition.other);
      expect(r.presentDuration, const Duration(milliseconds: 100));
      expect(r.dismissDuration, const Duration(milliseconds: 100));
      expect(r.solidColor(Brightness.light), _full.backgroundColor);
    });

    test('only springs with the scale transition', () {
      const fade = PopoverStyle(transition: PopoverTransition.other);
      final r = resolve(TargetPlatform.iOS, fade);
      expect(r.motion, isNull);
      expect(r.presentDuration, const Duration(milliseconds: 200));
    });
  });

  group('PopoverTheme', () {
    Future<PopoverRenderShiftedBox> open(
      WidgetTester tester, {
      PopoverStyle? theme,
      PopoverStyle? style,
    }) async {
      final anchor = Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => showPopover(
            context: context,
            style: style,
            bodyBuilder: (_) => const SizedBox(width: 100, height: 60),
          ),
          child: const SizedBox(key: Key('anchor'), width: 80, height: 40),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: theme == null
                ? anchor
                : PopoverTheme(data: theme, child: anchor),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('anchor')));
      await tester.pumpAndSettle();
      return tester.renderObject(find.byType(PopoverContext));
    }

    testWidgets('sets the style of the popovers below it', (tester) async {
      final box = await open(tester, theme: const PopoverStyle(radius: 3));

      expect(box.radius, 3);
    });

    testWidgets('gives way to the style at the call', (tester) async {
      final box = await open(
        tester,
        theme: const PopoverStyle(radius: 3, arrowHeight: 9),
        style: const PopoverStyle(radius: 4),
      );

      expect(box.radius, 4);
      expect(box.arrowHeight, 9);
    });

    testWidgets('of is empty without a theme', (tester) async {
      late PopoverStyle style;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            style = PopoverTheme.of(context);
            return const SizedBox();
          },
        ),
      );

      expect(style, const PopoverStyle());
    });

    testWidgets('reaches the body of a popover', (tester) async {
      late PopoverStyle inBody;
      await tester.pumpWidget(
        MaterialApp(
          home: PopoverTheme(
            data: const PopoverStyle(radius: 7),
            child: Center(
              child: Builder(
                builder: (context) => GestureDetector(
                  onTap: () => showPopover(
                    context: context,
                    bodyBuilder: (context) {
                      inBody = PopoverTheme.of(context);
                      return const SizedBox(width: 10, height: 10);
                    },
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(inBody.radius, 7);
    });

    testWidgets('read finds the theme without depending on it', (tester) async {
      final style = ValueNotifier(const PopoverStyle(radius: 1));
      addTearDown(style.dispose);
      var builds = 0;
      late PopoverStyle read;
      final reader = Builder(
        builder: (context) {
          builds++;
          read = PopoverTheme.read(context);
          return const SizedBox();
        },
      );
      await tester.pumpWidget(
        ValueListenableBuilder<PopoverStyle>(
          valueListenable: style,
          builder: (_, value, child) =>
              PopoverTheme(data: value, child: child!),
          child: reader,
        ),
      );
      expect(read.radius, 1);

      style.value = const PopoverStyle(radius: 2);
      await tester.pump();

      expect(builds, 1);
    });

    testWidgets('read is empty without a theme', (tester) async {
      late PopoverStyle read;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            read = PopoverTheme.read(context);
            return const SizedBox();
          },
        ),
      );

      expect(read, const PopoverStyle());
    });

    test('notifies only when the style changes', () {
      const a = PopoverTheme(data: PopoverStyle(radius: 1), child: SizedBox());
      const b = PopoverTheme(data: PopoverStyle(radius: 1), child: SizedBox());
      const c = PopoverTheme(data: PopoverStyle(radius: 2), child: SizedBox());
      expect(a.updateShouldNotify(b), isFalse);
      expect(a.updateShouldNotify(c), isTrue);
    });
  });
}
