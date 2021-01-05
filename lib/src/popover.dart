import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'popover_direction.dart';
import 'popover_item.dart';
import 'popover_utils.dart';
import 'utils/build_context_extension.dart';

class Popover extends StatelessWidget {
  final Widget child;
  final WidgetBuilder builder;
  final Color backgroundColor;
  final Color barrierColor;
  final Duration transitionDuration;
  final PopoverDirection direction;
  final double radius;
  final List<BoxShadow> shadow;
  final double width;
  final double height;
  final BoxConstraints popoverConstraints;

  Popover({
    @required this.child,
    @required this.builder,
    this.backgroundColor = Colors.white,
    this.barrierColor = Colors.black45,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.direction = PopoverDirection.bottom,
    this.radius = 8,
    this.shadow = PopoverUtils.defaultShadow,
    this.width,
    this.height,
    BoxConstraints popoverConstraints,
  })  : assert(builder != null),
        popoverConstraints = (width != null || height != null)
            ? popoverConstraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : popoverConstraints;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        final offset = BuildContextExtension.getWidgetLocalToGlobal(context);
        final bounds = BuildContextExtension.getWidgetBounds(context);
        Widget body;
        showGeneralDialog(
          context: context,
          pageBuilder: (buildContext, animation, secondaryAnimation) {
            return Builder(builder: (_) => const SizedBox.shrink());
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
                attachRect: Rect.fromLTWH(
                  offset.dx,
                  offset.dy,
                  bounds.width,
                  bounds.height,
                ),
                child: body,
                constraints: popoverConstraints,
                color: backgroundColor,
                boxShadow: shadow,
                radius: radius,
                animation: animation,
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
