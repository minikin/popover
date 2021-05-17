import 'package:flutter/material.dart';

import 'popover_direction.dart';
import 'popover_item.dart';

/// A popover is a transient view that appears above other content onscreen
/// when you tap a control or in an area.
///
/// This function allows for customization of aspects of the dialog popup.
///
/// `bodyBuilder` argument is  builder which builds body/content of popover.
///
/// The `direction` is desired Popover's direction behaviour.
/// This argument defaults to `PopoverDirection.bottom`.
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
/// The`contentDyOffset` offsets [Popover]s contetnt
/// position on Y axis. It can be positive or negative number.
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
Future<T?> showPopover<T extends Object?>({
  required BuildContext context,
  required WidgetBuilder bodyBuilder,
  PopoverDirection direction = PopoverDirection.bottom,
  Color backgroundColor = const Color(0x8FFFFFFFF),
  Color barrierColor = const Color(0x80000000),
  Duration transitionDuration = const Duration(milliseconds: 200),
  double radius = 8,
  List<BoxShadow> shadow = const [
    BoxShadow(color: Color(0x1F000000), blurRadius: 5)
  ],
  double arrowWidth = 24,
  double arrowHeight = 12,
  double arrowDxOffset = 0,
  double arrowDyOffset = 0,
  double contentDyOffset = 0,
  bool barrierDismissible = true,
  double? width,
  double? height,
  VoidCallback? onPop,
  BoxConstraints? constraints,
  RouteSettings? routeSettings,
  String? barrierLabel,
  Key? key,
}) {
  constraints = (width != null || height != null)
      ? constraints?.tighten(width: width, height: height) ??
          BoxConstraints.tightFor(width: width, height: height)
      : constraints;

  return Navigator.of(context, rootNavigator: true).push<T>(
    RawDialogRoute<T>(
      pageBuilder: (_, __, ___) {
        return Builder(builder: (_) => const SizedBox.shrink());
      },
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ??=
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      settings: routeSettings,
      transitionBuilder: (builderContext, animation, _, child) {
        return WillPopScope(
          onWillPop: () {
            if (onPop != null) {
              onPop();
              return Future.value(true);
            } else {
              return Future.value(true);
            }
          },
          child: FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: PopoverItem(
              child: bodyBuilder(builderContext),
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
              key: key,
            ),
          ),
        );
      },
    ),
  );
}
