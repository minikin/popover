import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'multiple_gesture_recognizer.dart';
import 'popover_direction.dart';
import 'popover_item.dart';
import 'utils/build_context_extension.dart';

class Popover extends StatelessWidget {
  /// Parent widget to which Popover is `attached`
  final Widget child;

  /// [WidgetBuilder] is builder which builds body/content of Popover
  final WidgetBuilder bodyBuilder;

  /// Background [Color] of Popover
  final Color backgroundColor;

  /// Barrier [Color] of screen when Popoover is presented
  final Color barrierColor;

  /// Animation transition duration
  final Duration transitionDuration;

  /// Desired Popover's direction behaviour
  final PopoverDirection direction;

  /// Radius of Popover's body
  final double radius;

  /// Shadow [BoxShadow] of Popover
  final List<BoxShadow> shadow;

  /// Popover's arrow width
  final double arrowWidth;

  /// Popover's arrow height
  final double arrowHeight;

  /// Offsets arrow position on X axis. It can be positive or negative number
  final double arrowDxOffset;

  /// Offsets arrow position on Y axis. It can be positive 0r negative number
  final double arrowDyOffset;

  /// Offsets [Popover]s contetnt
  /// position on Y axis. It can be positive or negative number
  final double contentDyOffset;

  /// Popover's body/content widget width
  final double width;

  /// Popover's body/content widget height
  final double height;

  /// Popover's constraints
  final BoxConstraints constraints;

  /// Called to veto attempts by the user to dismiss the [Popover]
  final VoidCallback onPop;

  /// The `barrierDismissible` argument is used to determine whether this route
  /// can be dismissed by tapping the modal barrier. This argument defaults
  /// to true.
  final bool barrierDismissible;

  /// A [Popover] is a transient view that appears above other content onscreen
  /// when you tap a control or in an area.
  Popover({
    @required this.child,
    @required this.bodyBuilder,
    this.backgroundColor = Colors.white,
    this.barrierColor = Colors.black45,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.direction = PopoverDirection.bottom,
    this.radius = 8,
    this.shadow = const [BoxShadow(color: Colors.black12, blurRadius: 5)],
    this.arrowWidth = 24,
    this.arrowHeight = 12,
    this.arrowDxOffset = 0,
    this.arrowDyOffset = 0,
    this.contentDyOffset = 0,
    this.barrierDismissible = true,
    this.width,
    this.height,
    this.onPop,
    BoxConstraints constraints,
    Key key,
  })  : assert(bodyBuilder != null, child != null),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        MultipleGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<MultipleGestureRecognizer>(
          () => MultipleGestureRecognizer(),
          (i) {
            i.onTap = () => _showPopover(context);
          },
        ),
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  /// Present [Popover] programmatically.
  /// It might be useful for automation testing in case you're not using
  /// flutter_driver.
  void showPopover(BuildContext context) => _showPopover(context);

  Future<bool> _shouldPop() {
    if (onPop != null) {
      onPop();
      return Future.value(true);
    } else {
      return Future.value(true);
    }
  }

  void _showPopover(BuildContext context) {
    final offset = BuildContextExtension.getWidgetLocalToGlobal(context);
    final bounds = BuildContextExtension.getWidgetBounds(context);
    showGeneralDialog(
      context: context,
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        return Builder(builder: (_) => const SizedBox.shrink());
      },
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      transitionBuilder: (context, animation, _, child) {
        return WillPopScope(
          onWillPop: _shouldPop,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: PopoverItem(
              key: key,
              attachRect: Rect.fromLTWH(
                offset.dx + arrowDxOffset,
                offset.dy + arrowDyOffset,
                bounds.width,
                bounds.height + contentDyOffset,
              ),
              child: bodyBuilder(context),
              constraints: constraints,
              backgroundColor: backgroundColor,
              boxShadow: shadow,
              radius: radius,
              animation: animation,
              direction: direction,
              arrowWidth: arrowWidth,
              arrowHeight: arrowHeight,
            ),
          ),
        );
      },
    );
  }
}
