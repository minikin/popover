import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'popover_arrow_style.dart';
import 'popover_motion.dart';
import 'popover_shape.dart';
import 'popover_style.dart';
import 'popover_transition.dart';

/// A [PopoverStyle] with every field filled in for a platform. All defaults of
/// the package live here.
final class ResolvedPopoverStyle {
  const ResolvedPopoverStyle._({
    required this.shape,
    required this.arrowWidth,
    required this.arrowHeight,
    required this.radius,
    required this.shadow,
    required this.backgroundColor,
    required this.brightness,
    required this.barrierColor,
    required this.transition,
    required this.motion,
    required this.presentDuration,
    required this.dismissDuration,
  });

  factory ResolvedPopoverStyle.of(PopoverStyle style, TargetPlatform platform) {
    final shape = _shape(style.arrowStyle, platform);
    final transition = style.transition ?? PopoverTransition.scale;
    // iOS 26 and macOS 26 open a popover on one spring and close it on
    // another.
    final motion = transition == PopoverTransition.scale
        ? PopoverMotion.of(shape)
        : null;
    final duration = style.transitionDuration;
    return ResolvedPopoverStyle._(
      shape: shape,
      arrowWidth: style.arrowWidth ?? _arrowWidth(shape),
      arrowHeight:
          style.arrowHeight ?? (shape == PopoverShape.triangle ? 12 : 13),
      radius: style.radius ?? _radius(shape),
      shadow: style.shadow ?? _shadow(shape),
      backgroundColor: style.backgroundColor,
      brightness: style.brightness,
      barrierColor: style.barrierColor ?? _barrierColor(shape),
      transition: transition,
      motion: motion,
      presentDuration: duration ?? motion?.presentDuration ?? _fadeDuration,
      dismissDuration: duration ?? motion?.dismissDuration ?? _fadeDuration,
    );
  }

  static PopoverShape _shape(
    PopoverArrowStyle? style,
    TargetPlatform platform,
  ) {
    final apple = platform == TargetPlatform.macOS
        ? PopoverShape.macos
        : PopoverShape.ios;
    return switch (style ?? PopoverArrowStyle.adaptive) {
      PopoverArrowStyle.triangle => PopoverShape.triangle,
      PopoverArrowStyle.apple => apple,
      PopoverArrowStyle.adaptive =>
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
            ? apple
            : PopoverShape.triangle,
    };
  }

  static double _arrowWidth(PopoverShape shape) => switch (shape) {
    PopoverShape.triangle => 24,
    PopoverShape.ios => 26,
    PopoverShape.macos => 25.42,
  };

  static double _radius(PopoverShape shape) => switch (shape) {
    PopoverShape.triangle => 8,
    PopoverShape.ios => 34,
    PopoverShape.macos => 20,
  };

  static List<BoxShadow> _shadow(PopoverShape shape) => switch (shape) {
    PopoverShape.triangle => _triangleShadow,
    PopoverShape.ios => _iosShadow,
    PopoverShape.macos => _macosShadow,
  };

  /// iOS and macOS do not dim the screen behind a popover.
  static Color _barrierColor(PopoverShape shape) =>
      shape == PopoverShape.triangle
      ? const Color(0x80000000)
      : const Color(0x00000000);

  final PopoverShape shape;
  final double arrowWidth;
  final double arrowHeight;
  final double radius;
  final List<BoxShadow> shadow;

  /// Null for glass on the Apple shapes, see [PopoverStyle.backgroundColor].
  final Color? backgroundColor;

  /// Null until the popover reads the text color it inherits.
  final Brightness? brightness;
  final Color barrierColor;
  final PopoverTransition transition;

  /// The springs of an Apple shape that scales in, null otherwise.
  final PopoverMotion? motion;
  final Duration presentDuration;
  final Duration dismissDuration;

  /// The solid body color when there is no glass.
  Color solidColor(Brightness brightness) =>
      backgroundColor ??
      (brightness == Brightness.dark
          ? const Color(0xFF2C2C2E)
          : const Color(0xFFFFFFFF));
}

const _fadeDuration = Duration(milliseconds: 200);

const _triangleShadow = [BoxShadow(color: Color(0x1F000000), blurRadius: 5)];

/// The wide, soft shadow of iOS 26 popovers, measured from a simulator.
const _iosShadow = [BoxShadow(color: Color(0x6B000000), blurRadius: 210)];

/// The shadow of macOS 26 popovers, measured from a screenshot of NSPopover.
const _macosShadow = [
  BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 3.6)),
];
