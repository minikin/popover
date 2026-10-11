import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'popover_direction.dart';
import 'popover_item.dart';
import 'popover_route.dart';
import 'popover_shape.dart';
import 'popover_style.dart';
import 'popover_widget.dart';
import 'resolved_popover_style.dart';
import 'utils/popover_utils.dart';

/// Shows a popover with the body [bodyBuilder] builds, its arrow pointing at
/// the widget of [context].
///
/// Pass the context of the anchor, not of the page: wrap the anchor in a
/// `Builder` or use `GlobalKey.currentContext`. The returned future completes
/// with the value passed to `Navigator.pop`, or null when the user closes the
/// popover by tapping outside or pressing Esc.
///
/// [style] sets how the popover looks and moves. It is merged on top of the
/// closest [PopoverTheme], and every field left null falls back to the
/// native look of iOS 26 and macOS 26 on Apple platforms, a triangle
/// elsewhere. See [PopoverStyle] for the defaults.
///
/// [direction] is the preferred side. The popover opens on another side when
/// it does not fit, the way iOS and macOS popovers do. [width], [height] and
/// [constraints] size the body and are capped by the room on that side.
///
/// [arrowDxOffset] and [arrowDyOffset] move the point the arrow aims at.
/// [contentDxOffset] and [contentDyOffset] widen and heighten the anchor,
/// which moves a popover that opens to the right or below.
///
/// [barrierDismissible] lets a tap outside or Esc close the popover.
/// [allowClicksOnBackground] passes taps through to the widgets behind and
/// keeps the popover open, whatever [barrierDismissible] says.
/// [requestFocus] set to false leaves focus where it is, so an open keyboard
/// stays up.
///
/// [semanticsLabel] names the popover for screen readers, which announce it
/// when it opens. [barrierLabel] labels the barrier and defaults to
/// `'Dismiss'`. Pass a localized one, for example
/// `MaterialLocalizations.of(context).modalBarrierDismissLabel`.
///
/// [onPop] runs when the popover pops, however it was closed. It cannot
/// cancel the dismissal. [popoverTransitionBuilder] replaces the default
/// fade. Avoid `Opacity` in it with the glass background, since Impeller
/// gives a backdrop filter inside an opacity layer nothing to blur.
///
/// The popover depends only on `package:flutter/widgets.dart`. The body is
/// not wrapped in a `Material`. Wrap it in
/// `Material(type: MaterialType.transparency)` when it contains widgets that
/// need one, such as `InkWell`, `ListTile` or `TextField`. Inherited themes
/// such as `Theme`, `DefaultTextStyle`, `IconTheme` and [PopoverTheme] are
/// captured from [context] and applied to the body.
Future<T?> showPopover<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder bodyBuilder,
  PopoverStyle? style,
  PopoverDirection direction = PopoverDirection.bottom,
  double? width,
  double? height,
  BoxConstraints? constraints,
  double arrowDxOffset = 0,
  double arrowDyOffset = 0,
  double contentDxOffset = 0,
  double contentDyOffset = 0,
  bool barrierDismissible = true,
  bool allowClicksOnBackground = false,
  bool? requestFocus,
  String? barrierLabel,
  String? semanticsLabel,
  VoidCallback? onPop,
  RouteSettings? routeSettings,
  PopoverTransitionBuilder? popoverTransitionBuilder,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    popoverRoute<T>(
      context: context,
      bodyBuilder: bodyBuilder,
      style: style,
      direction: direction,
      width: width,
      height: height,
      constraints: constraints,
      arrowDxOffset: arrowDxOffset,
      arrowDyOffset: arrowDyOffset,
      contentDxOffset: contentDxOffset,
      contentDyOffset: contentDyOffset,
      barrierDismissible: barrierDismissible,
      allowClicksOnBackground: allowClicksOnBackground,
      requestFocus: requestFocus,
      barrierLabel: barrierLabel,
      semanticsLabel: semanticsLabel,
      onPop: onPop,
      routeSettings: routeSettings,
      popoverTransitionBuilder: popoverTransitionBuilder,
    ),
  );
}

/// Builds the route [showPopover] pushes, for [Popover] to push itself.
PopoverRoute<T> popoverRoute<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder bodyBuilder,
  PopoverStyle? style,
  PopoverDirection direction = PopoverDirection.bottom,
  double? width,
  double? height,
  BoxConstraints? constraints,
  double arrowDxOffset = 0,
  double arrowDyOffset = 0,
  double contentDxOffset = 0,
  double contentDyOffset = 0,
  bool barrierDismissible = true,
  bool allowClicksOnBackground = false,
  bool? requestFocus,
  String? barrierLabel,
  String? semanticsLabel,
  VoidCallback? onPop,
  RouteSettings? routeSettings,
  PopoverTransitionBuilder? popoverTransitionBuilder,
}) {
  constraints = (width != null || height != null)
      ? constraints?.tighten(width: width, height: height) ??
            BoxConstraints.tightFor(width: width, height: height)
      : constraints;

  // Read once: the anchor may leave the tree while the popover is open.
  final merged = PopoverTheme.read(context).merge(style);
  final resolved = ResolvedPopoverStyle.of(
    merged.brightness == null
        ? merged.copyWith(brightness: _contrastWithText(context))
        : merged,
    defaultTargetPlatform,
  );
  final fadesGlass =
      popoverTransitionBuilder == null &&
      resolved.backgroundColor == null &&
      resolved.shape != PopoverShape.triangle;

  final navigator = Navigator.of(context, rootNavigator: true);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);

  return PopoverRoute<T>(
    allowClicksOnBackground: allowClicksOnBackground,
    pageBuilder: (_, animation, __) {
      return PopScope(
        onPopInvokedWithResult: (didPop, _) => onPop?.call(),
        child: PopoverItem(
          child: themes.wrap(
            semanticsLabel == null
                ? Builder(builder: bodyBuilder)
                : Semantics(
                    scopesRoute: true,
                    namesRoute: true,
                    explicitChildNodes: true,
                    label: semanticsLabel,
                    child: Builder(builder: bodyBuilder),
                  ),
          ),
          context: context,
          style: resolved,
          direction: direction,
          animation: animation,
          fadesGlass: fadesGlass,
          constraints: constraints,
          arrowDxOffset: arrowDxOffset,
          arrowDyOffset: arrowDyOffset,
          contentDyOffset: contentDyOffset,
          contentDxOffset: contentDxOffset,
        ),
      );
    },
    requestFocus: requestFocus,
    // Taps reach the widgets behind, so the barrier must not close it, and
    // neither may Esc or the accessibility dismiss action.
    barrierDismissible: barrierDismissible && !allowClicksOnBackground,
    barrierLabel: barrierLabel ?? _defaultBarrierLabel,
    barrierColor: resolved.barrierColor,
    transitionDuration: resolved.presentDuration,
    reverseTransitionDuration: resolved.dismissDuration,
    settings: routeSettings,
    transitionBuilder: (builderContext, animation, _, child) {
      if (popoverTransitionBuilder != null) {
        return popoverTransitionBuilder(animation, child);
      }
      final motion = resolved.motion;
      return fadesGlass
          ? child
          : _FadeTransitionWidget(
              animation: animation,
              curve: motion?.present ?? Curves.easeOut,
              reverseCurve: motion?.dismiss.flipped,
              child: child,
            );
    },
  );
}

const _defaultBarrierLabel = 'Dismiss';

/// The background brightness that keeps the text the body inherits from
/// [context] readable, or null when no text color is inherited.
Brightness? _contrastWithText(BuildContext context) {
  final color = DefaultTextStyle.of(context).style.color;
  if (color == null) return null;
  final luminance = color.computeLuminance() + 0.05;
  return luminance * luminance > 0.15 ? Brightness.dark : Brightness.light;
}

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
