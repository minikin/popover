import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'popover_direction.dart';
import 'popover_item.dart';
import 'utils/build_context_extension.dart';
import 'utils/popover_utils.dart';

class Popover extends StatelessWidget {
  final Widget child;
  final WidgetBuilder bodyBuilder;
  final Color backgroundColor;
  final Color barrierColor;
  final Duration transitionDuration;
  final PopoverDirection direction;
  final double radius;
  final List<BoxShadow> shadow;
  final double arrowWidth;
  final double arrowHeight;
  final double width;
  final double height;
  final BoxConstraints popoverConstraints;

  Popover({
    @required this.child,
    @required this.bodyBuilder,
    this.backgroundColor = Colors.white,
    this.barrierColor = Colors.black45,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.direction = PopoverDirection.bottom,
    this.radius = 8,
    this.shadow = PopoverUtils.defaultShadow,
    this.arrowWidth = PopoverUtils.arrowWidth,
    this.arrowHeight = PopoverUtils.arrowHeight,
    this.width,
    this.height,
    BoxConstraints popoverConstraints,
  })  : assert(bodyBuilder != null),
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
            );
          },
        );
      },
      child: child,
    );
  }
}
