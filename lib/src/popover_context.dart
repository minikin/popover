import 'package:flutter/material.dart';

import 'popover_direction.dart';
import 'popover_render_shifted_box.dart';
import 'popover_transition.dart';

class PopoverContext extends SingleChildRenderObjectWidget {
  final Rect? attachRect;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Animation<double>? animation;
  final double? radius;
  final PopoverDirection? direction;
  final double? arrowWidth;
  final double? arrowHeight;
  final PopoverTransition transition;

  const PopoverContext({
    required this.transition,
    Widget? child,
    this.attachRect,
    this.backgroundColor,
    this.boxShadow,
    this.animation,
    this.radius,
    this.direction,
    this.arrowWidth,
    this.arrowHeight,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PopoverRenderShiftedBox(
      attachRect: attachRect,
      color: backgroundColor,
      boxShadow: boxShadow,
      scale: animation!.value,
      direction: direction,
      radius: radius,
      arrowWidth: arrowWidth,
      arrowHeight: arrowHeight,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    PopoverRenderShiftedBox renderObject,
  ) {
    renderObject
      ..attachRect = attachRect
      ..color = backgroundColor
      ..boxShadow = boxShadow
      ..scale = transition == PopoverTransition.scale ? animation!.value : 1.0
      ..direction = direction
      ..radius = radius
      ..arrowWidth = arrowWidth
      ..arrowHeight = arrowHeight;
  }
}
