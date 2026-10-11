import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

import 'popover_shape.dart';

/// How iOS 26 and macOS 26 open and close a popover.
///
/// One spring drives everything while the popover opens: it scales up about
/// the arrow tip and fades in. Closing runs the same in reverse on a softer
/// spring.
final class PopoverMotion {
  const PopoverMotion._({
    required this.present,
    required this.dismiss,
    required this.startScale,
    required this.grows,
  });

  final SpringCurve present;

  /// Runs from 0 to 1 like [present]. Apply it flipped to a reversing route.
  final SpringCurve dismiss;

  /// The scale the popover opens from and closes to.
  final double startScale;

  /// Whether the outline also grows from [startHeight] to its full height
  /// with the arrow tip in place.
  final bool grows;

  Duration get presentDuration => present.duration;
  Duration get dismissDuration => dismiss.duration;

  /// The height of the outline, arrow included, when it starts to grow. A
  /// shorter popover keeps its height.
  static const startHeight = 100.0;

  /// The motion of [shape], or null for [PopoverShape.triangle].
  static PopoverMotion? of(PopoverShape shape) => switch (shape) {
    PopoverShape.triangle => null,
    PopoverShape.ios => ios,
    PopoverShape.macos => macos,
  };

  /// Read from the `CASpringAnimation` objects UIKit attaches to the layers
  /// of `_UIPopoverView`.
  static const ios = PopoverMotion._(
    present: SpringCurve(
      SpringDescription(mass: 1, stiffness: 331.9007, damping: 29.1490),
      Duration(microseconds: 493700),
    ),
    dismiss: SpringCurve(
      SpringDescription(mass: 1, stiffness: 283.9735, damping: 28.6476),
      Duration(microseconds: 515660),
    ),
    startScale: 0.01,
    grows: true,
  );

  /// Fitted to `NSPopover` recorded at 120 frames per second. AppKit removes
  /// the closing popover 200 milliseconds in, at about 5% of its size.
  static const macos = PopoverMotion._(
    present: SpringCurve(
      SpringDescription(mass: 1, stiffness: 372.4, damping: 30.77),
      Duration(milliseconds: 440),
    ),
    dismiss: SpringCurve(
      SpringDescription(mass: 1, stiffness: 339.4, damping: 31.52),
      Duration(milliseconds: 200),
    ),
    startScale: 0,
    grows: false,
  );
}

/// A spring from 0 to 1 at rest, sampled over [duration]. It overshoots 1
/// like the spring does, and ends on exactly 1, as Core Animation does when a
/// spring animation runs out of time before it settles.
final class SpringCurve extends Curve {
  const SpringCurve(this.spring, this.duration);

  final SpringDescription spring;
  final Duration duration;

  @override
  double transformInternal(double t) => SpringSimulation(
    spring,
    0,
    1,
    0,
  ).x(t * duration.inMicroseconds / Duration.microsecondsPerSecond);
}
