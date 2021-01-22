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

  /// Popover's body/content widget width
  final double width;

  /// Popover's body/content widget height
  final double height;

  /// Popover's constraints
  final BoxConstraints popoverConstraints;

  /// Called to veto attempts by the user to dismiss the [Popover]
  final VoidCallback onPop;

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
    this.width,
    this.height,
    this.onPop,
    BoxConstraints popoverConstraints,
  })  : assert(bodyBuilder != null, child != null),
        popoverConstraints = (width != null || height != null)
            ? popoverConstraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : popoverConstraints;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        MultipleGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<MultipleGestureRecognizer>(
          () => MultipleGestureRecognizer(),
          (i) {
            i.onTap = () => _presentPopoverContent(context);
          },
        ),
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }

  void _presentPopoverContent(BuildContext context) {
    final offset = BuildContextExtension.getWidgetLocalToGlobal(context);
    final bounds = BuildContextExtension.getWidgetBounds(context);
    showGeneralDialog(
      context: context,
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        return Builder(builder: (_) => const SizedBox.shrink());
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return WillPopScope(
          onWillPop: _shouldPop,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: PopoverItem(
              attachRect: Rect.fromLTWH(
                offset.dx,
                offset.dy,
                bounds.width,
                bounds.height,
              ),
              child: bodyBuilder(context),
              constraints: popoverConstraints,
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

  Future<bool> _shouldPop() {
    if (onPop != null) {
      onPop();
      return Future.value(true);
    } else {
      return Future.value(true);
    }
  }
}
