import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

/// How iOS 26 opens and closes a popover, read from the `CASpringAnimation`
/// objects UIKit attaches to the layers of `_UIPopoverView`.
///
/// One spring drives everything: the popover scales from 1% about the arrow
/// tip, fades in, and its outline grows from [startHeight] to its full height
/// with the tip in place. Closing runs the same in reverse on a softer spring.
abstract final class IosPopoverMotion {
  static const presentDuration = Duration(microseconds: 493700);
  static const dismissDuration = Duration(microseconds: 515660);

  static const present = SpringCurve(
    SpringDescription(mass: 1, stiffness: 331.9007, damping: 29.1490),
    presentDuration,
  );

  /// Runs from 0 to 1 like [present]. Apply it flipped to a reversing route.
  static const dismiss = SpringCurve(
    SpringDescription(mass: 1, stiffness: 283.9735, damping: 28.6476),
    dismissDuration,
  );

  static const startScale = 0.01;

  /// The height of the outline, arrow included, when it starts to grow. A
  /// shorter popover keeps its height.
  static const startHeight = 100.0;
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
