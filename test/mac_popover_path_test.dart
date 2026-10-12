import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:popover/popover.dart';
import 'package:popover/src/apple_popover_path.dart';

import 'helpers/numbers.dart';

// Mask paths of NSPopover frames, dumped from macOS 26.7. AppKit starts the
// path elsewhere than MacPopoverPath does, so the test compares the outlines,
// not the elements.
const _fixture = 'test/fixtures/appkit_popover_paths.txt';

Path _parse(List<String> elements) {
  final path = Path();
  for (final element in elements) {
    final n = numbersIn(element);
    switch (element[0]) {
      case 'M':
        path.moveTo(n[0], n[1]);
      case 'L':
        path.lineTo(n[0], n[1]);
      case 'C':
        path.cubicTo(n[0], n[1], n[2], n[3], n[4], n[5]);
    }
  }
  return path..close();
}

List<Offset> _sample(Path path, double step) => [
  for (final metric in path.computeMetrics())
    for (var d = 0.0; d <= metric.length; d += step)
      metric.getTangentForOffset(d)!.position,
];

/// The largest distance from a point of [a] to the outline [b].
double _farthest(List<Offset> a, List<Offset> b) {
  final grid = <(int, int), List<Offset>>{};
  for (final p in b) {
    grid.putIfAbsent((p.dx.floor(), p.dy.floor()), () => []).add(p);
  }
  var worst = 0.0;
  for (final p in a) {
    var best = double.infinity;
    for (var dx = -2; dx <= 2; dx++) {
      for (var dy = -2; dy <= 2; dy++) {
        final cell = (p.dx.floor() + dx, p.dy.floor() + dy);
        for (final q in grid[cell] ?? const <Offset>[]) {
          best = math.min(best, (p - q).distance);
        }
      }
    }
    worst = math.max(worst, best);
  }
  return worst;
}

void main() {
  final lines = File(_fixture).readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    if (!lines[i].startsWith('case ')) continue;
    final [_, name, l, t, r, b, direction, tip] = lines[i].split(' ');
    final elements = [
      for (
        var j = i + 1;
        j < lines.length && !lines[j].startsWith('case ');
        j++
      )
        lines[j],
    ];

    test('matches AppKit: $name', () {
      final ours =
          const MacPopoverPath(
            arrowWidth: 25.42,
            arrowHeight: 13,
            radius: 20,
          ).toPath(
            frame: Rect.fromLTRB(
              double.parse(l),
              double.parse(t),
              double.parse(r),
              double.parse(b),
            ),
            direction: PopoverDirection.values.byName(direction),
            tip: double.parse(tip),
          );
      final appKit = _parse(elements);

      final distance = math.max(
        _farthest(_sample(ours, 0.25), _sample(appKit, 0.02)),
        _farthest(_sample(appKit, 0.25), _sample(ours, 0.02)),
      );
      expect(distance, lessThan(0.05), reason: 'outline differs by $distance');
    });
  }
}
