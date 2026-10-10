import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';
import 'package:popover/src/apple_popover_path.dart';

// Mask paths of UIPopoverPresentationController popovers, dumped from an
// iOS 26 simulator (iPhone 17 Pro) with CGPath.applyWithBlock.
const _fixture = 'test/fixtures/uikit_popover_paths.txt';

final class _Recorder implements PopoverPathSink {
  final elements = <String>[];

  String _p(double x, double y) =>
      '(${x.toStringAsFixed(3)},${y.toStringAsFixed(3)})';

  @override
  void moveTo(double x, double y) => elements.add('M ${_p(x, y)}');

  @override
  void lineTo(double x, double y) => elements.add('L ${_p(x, y)}');

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => elements.add('C ${_p(x1, y1)} ${_p(x2, y2)} ${_p(x3, y3)}');

  @override
  void close() => elements.add('Z');
}

List<double> _numbers(String element) => RegExp(
  r'-?\d+\.\d+',
).allMatches(element).map((match) => double.parse(match.group(0)!)).toList();

void main() {
  final lines = File(_fixture).readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    if (!lines[i].startsWith('case ')) continue;
    final [_, name, width, height, direction, tip] = lines[i].split(' ');
    final expected = [
      for (
        var j = i + 1;
        j < lines.length && !lines[j].startsWith('case ');
        j++
      )
        lines[j],
    ];

    test('matches UIKit: $name', () {
      final recorder = _Recorder();
      const ApplePopoverPath(arrowWidth: 26, arrowHeight: 13, radius: 34).build(
        recorder,
        frame: Rect.fromLTWH(0, 0, double.parse(width), double.parse(height)),
        direction: PopoverDirection.values.byName(direction),
        tip: double.parse(tip),
      );

      expect(recorder.elements, hasLength(expected.length));
      for (var k = 0; k < expected.length; k++) {
        final actual = recorder.elements[k];
        expect(actual[0], expected[k][0], reason: 'element $k: $actual');
        final a = _numbers(actual);
        final e = _numbers(expected[k]);
        expect(a, hasLength(e.length), reason: 'element $k');
        for (var c = 0; c < e.length; c++) {
          expect(
            a[c],
            moreOrLessEquals(e[c], epsilon: 0.002),
            reason: 'element $k: $actual, UIKit ${expected[k]}',
          );
        }
      }
    });
  }
}
