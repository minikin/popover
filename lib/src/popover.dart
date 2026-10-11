import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'popover_arrow_style.dart';
import 'popover_direction.dart';
import 'popover_item.dart';
import 'popover_motion.dart';
import 'popover_route.dart';
import 'popover_shape.dart';
import 'popover_transition.dart';
import 'utils/popover_utils.dart';

/// A popover is a transient view that appears above other content onscreen
/// when you tap a control or in an area.
///
/// Note that when [allowClicksOnBackground] is set to true,
/// [barrierDismissible] is ignored (will behave as if it was set to false).
///
/// This function allows for customization of aspects of the popover.
///
/// `bodyBuilder` argument is builder which builds body/content of popover.
///
/// The `direction` is the preferred side of the popover. It opens on another
/// side when it does not fit, the way iOS and macOS popovers do.
/// This argument defaults to `PopoverDirection.bottom`.
///
/// The `transition` is desired Popover's transition behavior.
/// This argument defaults to `PopoverTransition.scale`.
///
/// The `backgroundColor` is background [Color] of popover. When it is null,
/// the default, iOS and macOS shapes get the Liquid Glass of iOS 26 and
/// macOS 26: the content behind is blurred and tinted. The triangle gets
/// `Color(0xFFFFFFFF)`, or `Color(0xFF2C2C2E)` when `brightness` is dark.
///
/// The `brightness` picks the light or dark background. When it is null,
/// the background contrasts with the text color the body inherits from
/// `context`: light behind dark text, dark behind light text. Without an
/// inherited text color it follows the system setting,
/// [MediaQuery.platformBrightnessOf].
///
/// The `barrierColor` is barrier [Color] of screen when popover is presented.
/// This argument defaults to `Color(0x80000000)` for
/// [PopoverArrowStyle.triangle] and to transparent for
/// [PopoverArrowStyle.apple], since iOS and macOS do not dim the screen
/// behind a popover.
///
/// The `transitionDuration` argument is used to determine how long it takes
/// for the route to arrive on or leave off the screen. With the iOS shape and
/// [PopoverTransition.scale] it defaults to the springs of iOS 26: the
/// popover scales up from the arrow tip and its outline grows over 494
/// milliseconds, and it shrinks back over 516. Otherwise it defaults to a
/// 200 millisecond fade. A duration passed in applies to both directions.
///
/// The `radius` of popover's body.
/// This argument defaults to 8 for [PopoverArrowStyle.triangle], and for
/// [PopoverArrowStyle.apple] to 34 on iOS and 20 on macOS, the corner radii
/// of iOS 26 and macOS 26 popovers.
///
/// The `shadow` is [BoxShadow] of popover body.
/// This argument defaults to
/// `[BoxShadow(color: Color(0x1F000000), blurRadius: 5)]` for
/// [PopoverArrowStyle.triangle]. [PopoverArrowStyle.apple] uses the shadows
/// measured from iOS 26 and macOS 26: a wide, soft one on iOS and a compact
/// one offset downward on macOS.
///
/// The `arrowWidth` is width of arrow.
/// This argument defaults to 24 for [PopoverArrowStyle.triangle], and for
/// [PopoverArrowStyle.apple] to 26 on iOS and 25.42 on macOS.
///
/// The `arrowHeight` is height of arrow.
/// This argument defaults to 12 for [PopoverArrowStyle.triangle] and 13 for
/// [PopoverArrowStyle.apple].
///
/// The `arrowStyle` picks the shape of the arrow and the corners. It defaults
/// to [PopoverArrowStyle.adaptive]: the native shape on iOS, iPadOS and
/// macOS, a triangle elsewhere.
///
/// The `arrowDxOffset` offsets arrow position on X axis.
/// It can be positive or negative number.
/// This argument defaults to 0.
///
/// The `arrowDyOffset` offsets arrow position on Y axis.
/// It can be positive or negative number.
/// This argument defaults to 0.
///
/// The `contentDyOffset` offsets the popover body on Y axis.
/// It can be positive or negative number.
/// This argument defaults to 0.
///
/// The `contentDxOffset` offsets the popover body on X axis.
/// It can be positive or negative number.
/// This argument defaults to 0.
///
/// The `barrierDismissible` argument is used to determine whether this route
/// can be dismissed by tapping the modal barrier. This argument defaults
/// to true.
///
/// The `width` is popover's body/content widget width.
///
/// The `height` is popover's body/content widget height.
///
/// `width`, `height` and `constraints` are capped by the room on the side the
/// popover opens on. See the README for how the side is picked.
///
/// The `onPop` runs when the popover pops, by a barrier tap, a back gesture
/// or `Navigator.pop`. It cannot cancel the dismissal.
///
/// The `constraints` is popover's constraints.
///
/// The `routeSettings` is data that might be useful in constructing a [Route].
///
/// The `barrierLabel` is semantic label used for a dismissible barrier.
/// This argument defaults to 'Dismiss'. Pass a localized string, for example
/// `MaterialLocalizations.of(context).modalBarrierDismissLabel` or
/// `CupertinoLocalizations.of(context).modalBarrierDismissLabel`.
///
/// The `requestFocus` controls whether the popover should request focus when
/// presented. Set it to false to prevent dismissing any active keyboard.
/// Defaults to [Navigator.requestFocus] if not provided
///
/// The `popoverTransitionBuilder` replaces the default fade. It receives the
/// route animation and the popover and returns the widget to show.
///
/// The popover depends only on `package:flutter/widgets.dart`, so it works
/// with `package:flutter/material.dart`, `package:flutter/cupertino.dart`,
/// `package:material_ui` and `package:cupertino_ui`. The body is not wrapped
/// in a `Material`. Wrap it in the `Material` of your UI library when it
/// contains widgets that require one, such as `InkWell`, `ListTile` or
/// `TextField`. Use `MaterialType.transparency`, since an opaque `Material`
/// covers the glass background.
/// Inherited themes such as `Theme`, `DefaultTextStyle` and `IconTheme` are
/// captured from `context` and applied to the body.

Future<T?> showPopover<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder bodyBuilder,
  PopoverDirection direction = PopoverDirection.bottom,
  PopoverTransition transition = PopoverTransition.scale,
  Color? backgroundColor,
  Brightness? brightness,
  Color? barrierColor,
  Duration? transitionDuration,
  double? radius,
  List<BoxShadow>? shadow,
  double? arrowWidth,
  double? arrowHeight,
  double arrowDxOffset = 0,
  double arrowDyOffset = 0,
  double contentDyOffset = 0,
  double contentDxOffset = 0,
  bool barrierDismissible = true,
  double? width,
  double? height,
  VoidCallback? onPop,
  bool? requestFocus,
  @Deprecated(
    'This argument is ignored. Implementation of [PopoverItem] was updated.'
    'This feature was deprecated in v0.2.8',
  )
  bool Function()? isParentAlive,
  BoxConstraints? constraints,
  RouteSettings? routeSettings,
  String? barrierLabel,
  PopoverTransitionBuilder? popoverTransitionBuilder,
  Key? key,
  bool allowClicksOnBackground = false,
  PopoverArrowStyle arrowStyle = PopoverArrowStyle.adaptive,
}) {
  constraints = (width != null || height != null)
      ? constraints?.tighten(width: width, height: height) ??
            BoxConstraints.tightFor(width: width, height: height)
      : constraints;

  final platform = defaultTargetPlatform;
  final apple = platform == TargetPlatform.macOS
      ? PopoverShape.macos
      : PopoverShape.ios;
  final shape = switch (arrowStyle) {
    PopoverArrowStyle.triangle => PopoverShape.triangle,
    PopoverArrowStyle.apple => apple,
    PopoverArrowStyle.adaptive =>
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
          ? apple
          : PopoverShape.triangle,
  };
  final arrowSize = Size(
    arrowWidth ??
        switch (shape) {
          PopoverShape.triangle => 24,
          PopoverShape.ios => 26,
          PopoverShape.macos => 25.42,
        },
    arrowHeight ?? (shape == PopoverShape.triangle ? 12 : 13),
  );
  final cornerRadius =
      radius ??
      switch (shape) {
        PopoverShape.triangle => 8,
        PopoverShape.ios => 34,
        PopoverShape.macos => 20,
      };
  final boxShadow =
      shadow ??
      switch (shape) {
        PopoverShape.triangle => _triangleShadow,
        PopoverShape.ios => _iosShadow,
        PopoverShape.macos => _macosShadow,
      };

  // iOS 26 opens a popover on one spring and closes it on a softer one.
  final spring =
      shape == PopoverShape.ios && transition == PopoverTransition.scale;
  final fadesGlass =
      popoverTransitionBuilder == null &&
      backgroundColor == null &&
      shape != PopoverShape.triangle;

  final navigator = Navigator.of(context, rootNavigator: true);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);

  return navigator.push<T>(
    PopoverRoute<T>(
      allowClicksOnBackground: allowClicksOnBackground,
      pageBuilder: (_, animation, __) {
        return PopScope(
          onPopInvokedWithResult: (didPop, _) => onPop?.call(),
          child: PopoverItem(
            transition: transition,
            child: themes.wrap(Builder(builder: bodyBuilder)),
            context: context,
            backgroundColor: backgroundColor,
            brightness: brightness ?? _contrastWithText(context),
            direction: direction,
            radius: cornerRadius,
            boxShadow: boxShadow,
            animation: animation,
            arrowWidth: arrowSize.width,
            arrowHeight: arrowSize.height,
            shape: shape,
            fadesGlass: fadesGlass,
            constraints: constraints,
            arrowDxOffset: arrowDxOffset,
            arrowDyOffset: arrowDyOffset,
            contentDyOffset: contentDyOffset,
            contentDxOffset: contentDxOffset,
            key: key,
          ),
        );
      },
      requestFocus: requestFocus,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? _defaultBarrierLabel,
      barrierColor:
          barrierColor ??
          (shape == PopoverShape.triangle
              ? const Color(0x80000000)
              : const Color(0x00000000)),
      transitionDuration:
          transitionDuration ??
          (spring ? IosPopoverMotion.presentDuration : _fadeDuration),
      reverseTransitionDuration:
          transitionDuration ??
          (spring ? IosPopoverMotion.dismissDuration : _fadeDuration),
      settings: routeSettings,
      transitionBuilder: (builderContext, animation, _, child) {
        if (popoverTransitionBuilder != null) {
          return popoverTransitionBuilder(animation, child);
        }
        return fadesGlass
            ? child
            : _FadeTransitionWidget(
                animation: animation,
                curve: spring ? IosPopoverMotion.present : Curves.easeOut,
                reverseCurve: spring ? IosPopoverMotion.dismiss.flipped : null,
                child: child,
              );
      },
    ),
  );
}

const _defaultBarrierLabel = 'Dismiss';

const _fadeDuration = Duration(milliseconds: 200);

/// The background brightness that keeps the text the body inherits from
/// [context] readable, or null when no text color is inherited.
Brightness? _contrastWithText(BuildContext context) {
  final color = DefaultTextStyle.of(context).style.color;
  if (color == null) return null;
  final luminance = color.computeLuminance() + 0.05;
  return luminance * luminance > 0.15 ? Brightness.dark : Brightness.light;
}

const _triangleShadow = [BoxShadow(color: Color(0x1F000000), blurRadius: 5)];

/// The wide, soft shadow of iOS 26 popovers, measured from a simulator.
const _iosShadow = [BoxShadow(color: Color(0x6B000000), blurRadius: 210)];

/// The shadow of macOS 26 popovers, measured from a screenshot of NSPopover.
const _macosShadow = [
  BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 3.6)),
];

class _FadeTransitionWidget extends StatefulWidget {
  const _FadeTransitionWidget({
    required this.child,
    required this.animation,
    required this.curve,
    this.reverseCurve,
  });
  final Widget child;
  final Animation<double> animation;
  final Curve curve;
  final Curve? reverseCurve;

  @override
  State<_FadeTransitionWidget> createState() => _FadeTransitionWidgetState();
}

class _FadeTransitionWidgetState extends State<_FadeTransitionWidget> {
  late final CurvedAnimation _animation;

  @override
  void initState() {
    super.initState();
    _animation = CurvedAnimation(
      parent: widget.animation,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}
