import 'package:flutter/material.dart';
import 'package:popover/src/popover_direction.dart';
import 'package:popover/src/popover_item.dart';
import 'package:popover/src/utils/build_context_extension.dart';

class Popover extends StatelessWidget {
  static const _kDefaultShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 5,
    )
  ];

  final Widget child;
  final WidgetBuilder builder;
  final double width;
  final double height;
  final Color backgroundColor;
  final List<BoxShadow> shadow;
  final double radius;
  final Duration transitionDuration;
  final BoxConstraints constraints;
  final Color barrierColor;
  final PopoverDirection direction;

  Popover({
    @required this.child,
    this.backgroundColor = Colors.white,
    this.direction = PopoverDirection.bottom,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.barrierColor = Colors.black54,
    this.radius = 14,
    this.shadow = _kDefaultShadow,
    this.builder,
    this.width,
    this.height,
    BoxConstraints constraints,
  })  : assert(builder != null),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        final offset = BuildContextExtension.getWidgetLocalToGlobal(context);
        final bounds = BuildContextExtension.getWidgetBounds(context);
        var body;

        showGeneralDialog(
          context: context,
          pageBuilder: (buildContext, animation, secondaryAnimation) {
            return Builder(builder: (context) => Container());
          },
          barrierDismissible: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: barrierColor,
          transitionDuration: transitionDuration,
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            if (body == null) {
              body = builder(context);
            }
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: PopoverItem(
                rect: Rect.fromLTWH(
                  offset.dx,
                  offset.dy,
                  bounds.width,
                  bounds.height,
                ),
                child: body,
                constraints: constraints,
                color: backgroundColor,
                boxShadow: shadow,
                radius: radius,
                doubleAnimation: animation,
                direction: direction,
              ),
            );
          },
        );
      },
      child: child,
    );
  }
}
