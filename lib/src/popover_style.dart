import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'popover_arrow_style.dart';
import 'popover_transition.dart';

/// How a popover looks and moves.
///
/// Every field is optional. A null field falls back to the [PopoverTheme]
/// above the popover, then to the default of the platform: the native look
/// of iOS 26 and macOS 26 on Apple platforms, a triangle elsewhere. The
/// defaults are listed on each field.
@immutable
class PopoverStyle with Diagnosticable {
  const PopoverStyle({
    this.arrowStyle,
    this.backgroundColor,
    this.brightness,
    this.barrierColor,
    this.radius,
    this.shadow,
    this.arrowWidth,
    this.arrowHeight,
    this.transition,
    this.transitionDuration,
  });

  /// The shape of the arrow and the corners.
  ///
  /// Defaults to [PopoverArrowStyle.adaptive]: the native shape on iOS,
  /// iPadOS and macOS, a triangle elsewhere. The web follows the host OS.
  final PopoverArrowStyle? arrowStyle;

  /// The color of the body.
  ///
  /// When null, the Apple shapes get the Liquid Glass of iOS 26 and macOS 26:
  /// the content behind is blurred and tinted. The triangle gets
  /// `Color(0xFFFFFFFF)`, or `Color(0xFF2C2C2E)` when dark.
  final Color? backgroundColor;

  /// Whether the background is light or dark.
  ///
  /// When null, the background contrasts with the text color the body
  /// inherits from the anchor: light behind dark text, dark behind light
  /// text. Without an inherited text color it follows the system setting.
  final Brightness? brightness;

  /// The color of the barrier behind the popover.
  ///
  /// Defaults to `Color(0x80000000)` for the triangle and to transparent for
  /// the Apple shapes, since iOS and macOS do not dim the screen behind a
  /// popover.
  final Color? barrierColor;

  /// The corner radius of the body.
  ///
  /// Defaults to 8 for the triangle, 34 on iOS and 20 on macOS.
  final double? radius;

  /// The shadows of the body.
  ///
  /// Defaults to `[BoxShadow(color: Color(0x1F000000), blurRadius: 5)]` for
  /// the triangle and to the shadows measured from iOS 26 and macOS 26 for
  /// the Apple shapes. Pass an empty list for no shadow.
  final List<BoxShadow>? shadow;

  /// The width of the arrow base.
  ///
  /// Defaults to 24 for the triangle, 26 on iOS and 25.42 on macOS.
  final double? arrowWidth;

  /// The height of the arrow.
  ///
  /// Defaults to 12 for the triangle and 13 for the Apple shapes.
  final double? arrowHeight;

  /// Whether the popover scales from the arrow while it opens.
  ///
  /// Defaults to [PopoverTransition.scale]. [PopoverTransition.other] only
  /// fades it.
  final PopoverTransition? transition;

  /// How long the popover takes to open and to close.
  ///
  /// When null, the Apple shapes with [PopoverTransition.scale] use the
  /// springs of iOS 26 and macOS 26: 494 milliseconds to open and 516 to
  /// close on iOS, 440 and 200 on macOS. Everything else takes 200
  /// milliseconds: the triangle fades and scales, and
  /// [PopoverTransition.other] only fades. A duration passed in applies to
  /// both directions.
  final Duration? transitionDuration;

  /// A copy with the given fields replaced.
  ///
  /// A null argument keeps the field, so a field cannot be reset to null
  /// here. Build a new [PopoverStyle] for that.
  PopoverStyle copyWith({
    PopoverArrowStyle? arrowStyle,
    Color? backgroundColor,
    Brightness? brightness,
    Color? barrierColor,
    double? radius,
    List<BoxShadow>? shadow,
    double? arrowWidth,
    double? arrowHeight,
    PopoverTransition? transition,
    Duration? transitionDuration,
  }) {
    return PopoverStyle(
      arrowStyle: arrowStyle ?? this.arrowStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      brightness: brightness ?? this.brightness,
      barrierColor: barrierColor ?? this.barrierColor,
      radius: radius ?? this.radius,
      shadow: shadow ?? this.shadow,
      arrowWidth: arrowWidth ?? this.arrowWidth,
      arrowHeight: arrowHeight ?? this.arrowHeight,
      transition: transition ?? this.transition,
      transitionDuration: transitionDuration ?? this.transitionDuration,
    );
  }

  /// This style with the non-null fields of [other] on top. A null field in
  /// [other] keeps the field of this style.
  PopoverStyle merge(PopoverStyle? other) {
    if (other == null) return this;
    return copyWith(
      arrowStyle: other.arrowStyle,
      backgroundColor: other.backgroundColor,
      brightness: other.brightness,
      barrierColor: other.barrierColor,
      radius: other.radius,
      shadow: other.shadow,
      arrowWidth: other.arrowWidth,
      arrowHeight: other.arrowHeight,
      transition: other.transition,
      transitionDuration: other.transitionDuration,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PopoverStyle &&
      other.arrowStyle == arrowStyle &&
      other.backgroundColor == backgroundColor &&
      other.brightness == brightness &&
      other.barrierColor == barrierColor &&
      other.radius == radius &&
      listEquals(other.shadow, shadow) &&
      other.arrowWidth == arrowWidth &&
      other.arrowHeight == arrowHeight &&
      other.transition == transition &&
      other.transitionDuration == transitionDuration;

  @override
  int get hashCode => Object.hash(
    arrowStyle,
    backgroundColor,
    brightness,
    barrierColor,
    radius,
    shadow == null ? null : Object.hashAll(shadow!),
    arrowWidth,
    arrowHeight,
    transition,
    transitionDuration,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty('arrowStyle', arrowStyle, defaultValue: null))
      ..add(
        ColorProperty('backgroundColor', backgroundColor, defaultValue: null),
      )
      ..add(EnumProperty('brightness', brightness, defaultValue: null))
      ..add(ColorProperty('barrierColor', barrierColor, defaultValue: null))
      ..add(DoubleProperty('radius', radius, defaultValue: null))
      ..add(IterableProperty('shadow', shadow, defaultValue: null))
      ..add(DoubleProperty('arrowWidth', arrowWidth, defaultValue: null))
      ..add(DoubleProperty('arrowHeight', arrowHeight, defaultValue: null))
      ..add(EnumProperty('transition', transition, defaultValue: null))
      ..add(
        DiagnosticsProperty(
          'transitionDuration',
          transitionDuration,
          defaultValue: null,
        ),
      );
  }
}

/// Sets the [PopoverStyle] of the popovers below it.
///
/// A style passed to `showPopover` or `Popover` is merged on top, and its
/// non-null fields win. Popovers opened from inside a popover see the same
/// theme.
///
/// ```dart
/// PopoverTheme(
///   data: const PopoverStyle(radius: 16),
///   child: MaterialApp(home: ...),
/// );
/// ```
class PopoverTheme extends InheritedTheme {
  const PopoverTheme({required this.data, required super.child, super.key});

  final PopoverStyle data;

  /// The style of the closest [PopoverTheme], or an empty style. [context]
  /// rebuilds when the theme changes.
  static PopoverStyle of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PopoverTheme>()?.data ??
      const PopoverStyle();

  /// The style of the closest [PopoverTheme], or an empty style, without a
  /// dependency on it.
  static PopoverStyle read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PopoverTheme>()?.data ??
      const PopoverStyle();

  @override
  Widget wrap(BuildContext context, Widget child) =>
      PopoverTheme(data: data, child: child);

  @override
  bool updateShouldNotify(PopoverTheme oldWidget) => data != oldWidget.data;
}
