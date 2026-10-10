import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'popover_arrow_style.dart';
import 'popover_direction.dart';
import 'popover_item.dart';
import 'popover_route.dart';
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
/// The `backgroundColor` is background [Color] of popover.
/// This argument defaults to `Color(0xFFFFFFFF)`.
///
/// The `barrierColor` is barrier [Color] of screen when popover is presented.
/// This argument defaults to `Color(0x80000000)`.
///
/// The `transitionDuration` argument is used to determine how long it takes
/// for the route to arrive on or leave off the screen. This argument defaults
/// to 200 milliseconds.
///
/// The `radius` of popover's body.
/// This argument defaults to 8 for [PopoverArrowStyle.triangle] and 34 for
/// [PopoverArrowStyle.apple], the corner radius of iOS 26 popovers.
///
/// The `shadow` is [BoxShadow] of popover body.
/// This argument defaults to
/// `[BoxShadow(color: Color(0x1F000000), blurRadius: 5)]` for
/// [PopoverArrowStyle.triangle] and to the wide, soft iOS shadow
/// `[BoxShadow(color: Color(0x6B000000), blurRadius: 210)]` for
/// [PopoverArrowStyle.apple].
///
/// The `arrowWidth` is width of arrow.
/// This argument defaults to 24 for [PopoverArrowStyle.triangle] and 26 for
/// [PopoverArrowStyle.apple].
///
/// The `arrowHeight` is height of arrow.
/// This argument defaults to 12 for [PopoverArrowStyle.triangle] and 13 for
/// [PopoverArrowStyle.apple].
///
/// The `arrowStyle` picks the shape of the arrow and the corners. It defaults
/// to [PopoverArrowStyle.adaptive]: the native iOS shape on iOS, iPadOS and
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
/// `TextField`.
/// Inherited themes such as `Theme`, `DefaultTextStyle` and `IconTheme` are
/// captured from `context` and applied to the body.

Future<T?> showPopover<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder bodyBuilder,
  PopoverDirection direction = PopoverDirection.bottom,
  PopoverTransition transition = PopoverTransition.scale,
  Color backgroundColor = const Color(0xFFFFFFFF),
  Color barrierColor = const Color(0x80000000),
  Duration transitionDuration = const Duration(milliseconds: 200),
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
  final appleShape = switch (arrowStyle) {
    PopoverArrowStyle.apple => true,
    PopoverArrowStyle.triangle => false,
    PopoverArrowStyle.adaptive =>
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS,
  };
  final arrowSize = Size(
    arrowWidth ?? (appleShape ? 26 : 24),
    arrowHeight ?? (appleShape ? 13 : 12),
  );
  final cornerRadius = radius ?? (appleShape ? 34 : 8);
  final boxShadow = shadow ?? (appleShape ? _appleShadow : _triangleShadow);

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
            direction: direction,
            radius: cornerRadius,
            boxShadow: boxShadow,
            animation: animation,
            arrowWidth: arrowSize.width,
            arrowHeight: arrowSize.height,
            appleShape: appleShape,
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
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      settings: routeSettings,
      transitionBuilder: (builderContext, animation, _, child) {
        return popoverTransitionBuilder == null
            ? _FadeTransitionWidget(child: child, animation: animation)
            : popoverTransitionBuilder(animation, child);
      },
    ),
  );
}

const _defaultBarrierLabel = 'Dismiss';

const _triangleShadow = [BoxShadow(color: Color(0x1F000000), blurRadius: 5)];

/// The wide, soft shadow of iOS 26 popovers, measured from a simulator.
const _appleShadow = [BoxShadow(color: Color(0x6B000000), blurRadius: 210)];

class _FadeTransitionWidget extends StatefulWidget {
  const _FadeTransitionWidget({required this.child, required this.animation});
  final Widget child;
  final Animation<double> animation;

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
      curve: Curves.easeOut,
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
