import 'package:flutter/material.dart';

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
/// This function allows for customization of aspects of the dialog popup.
///
/// `bodyBuilder` argument is  builder which builds body/content of popover.
///
/// The `direction` is desired Popover's direction behavior.
/// This argument defaults to `PopoverDirection.bottom`.
///
/// The `transition` is desired Popover's transition behavior.
/// This argument defaults to `PopoverTransition.scale`.
///
/// The `backgroundColor` is background [Color] of popover.
/// This argument defaults to `Color(0x8FFFFFFFF)`.
///
/// The `barrierColor` is barrier [Color] of screen when popover is presented.
/// This argument defaults to `Color(0x80000000)`.
///
/// The `transitionDuration` argument is used to determine how long it takes
/// for the route to arrive on or leave off the screen. This argument defaults
/// to 200 milliseconds.
///
/// The `radius` of popover's body.
/// This argument defaults to 8.
///
/// The `shadow`  is [BoxShadow] of popover body.
/// This argument defaults to
/// `[BoxShadow(color: Color(0x1F000000), blurRadius: 5)]`.
///
/// The `arrowWidth` is width of arrow.
/// This argument defaults to 24.
///
/// The `arrowHeight` is height of arrow.
/// This argument defaults to 12.
///
/// The `arrowDxOffset` offsets arrow position on X axis.
/// It can be positive or negative number.
/// This argument defaults to 0.
///
/// The `arrowDyOffset` offsets arrow position on Y axis.
/// It can be positive or negative number.
/// This argument defaults to 0.
///
/// The`contentDyOffset` offsets [Popover]s content
/// position on Y axis. It can be positive or negative number.
/// This argument defaults to 0.
///
/// The`contentDxOffset` offsets [Popover]s content
/// position on X axis. It can be positive or negative number.
/// This argument defaults to 0.
///
/// The `barrierDismissible` argument is used to determine whether this route
/// can be dismissed by tapping the modal barrier. This argument defaults
/// to true.
///
/// The `width` is popover's body/content widget width.
///
/// The` height` is popover's body/content widget height.
///
/// The `onPop` called to veto attempts by the user to dismiss the popover.
///
/// The `constraints` is popover's constraints.
///
/// The `routeSettings` is data that might be useful in constructing a [Route].
///
/// The `barrierLabel` is semantic label used for a dismissible barrier.
///
///The `popoverBuilder` is used for transition builder

Future<T?> showPopover<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder bodyBuilder,
  PopoverDirection direction = PopoverDirection.bottom,
  PopoverTransition transition = PopoverTransition.scale,
  Color backgroundColor = const Color(0x8FFFFFFFF),
  Color barrierColor = const Color(0x80000000),
  Duration transitionDuration = const Duration(milliseconds: 200),
  double radius = 8,
  List<BoxShadow> shadow = const [
    BoxShadow(color: Color(0x1F000000), blurRadius: 5),
  ],
  double arrowWidth = 24,
  double arrowHeight = 12,
  double arrowDxOffset = 0,
  double arrowDyOffset = 0,
  double contentDyOffset = 0,
  double contentDxOffset = 0,
  bool barrierDismissible = true,
  double? width,
  double? height,
  VoidCallback? onPop,
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
}) {
  constraints = (width != null || height != null)
      ? constraints?.tighten(width: width, height: height) ??
            BoxConstraints.tightFor(width: width, height: height)
      : constraints;

  return Navigator.of(context, rootNavigator: true).push<T>(
    PopoverRoute<T>(
      allowClicksOnBackground: allowClicksOnBackground,
      pageBuilder: (_, animation, __) {
        return PopScope(
          onPopInvokedWithResult: (didPop, _) => onPop?.call(),
          child: PopoverItem(
            transition: transition,
            child: Builder(builder: bodyBuilder),
            context: context,
            backgroundColor: backgroundColor,
            direction: direction,
            radius: radius,
            boxShadow: shadow,
            animation: animation,
            arrowWidth: arrowWidth,
            arrowHeight: arrowHeight,
            constraints: constraints,
            arrowDxOffset: arrowDxOffset,
            arrowDyOffset: arrowDyOffset,
            contentDyOffset: contentDyOffset,
            contentDxOffset: contentDxOffset,
            key: key,
          ),
        );
      },
      barrierDismissible: barrierDismissible,
      barrierLabel:
          barrierLabel ??
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
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
