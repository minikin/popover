import 'package:flutter/material.dart';

import 'popover_direction.dart';
import 'popover_render_shifted_box.dart';

class PopoverContext extends SingleChildRenderObjectWidget {
  final Rect? attachRect;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Animation<double>? animation;
  final double? radius;
  final PopoverDirection? direction;
  final double? arrowWidth;
  final double? arrowHeight;
  final bool isAnimateZooming;

  const PopoverContext({
    Widget? child,
    this.attachRect,
    this.backgroundColor,
    this.boxShadow,
    this.animation,
    this.radius,
    this.direction,
    this.arrowWidth,
    this.arrowHeight,
    required this.isAnimateZooming,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PopoverRenderShiftedBox(
      attachRect: attachRect,
      color: backgroundColor,
      boxShadow: boxShadow,
      scale: isAnimateZooming ? animation!.value : 1,
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
      ..scale = isAnimateZooming ? animation!.value : 1
      ..direction = direction
      ..radius = radius
      ..arrowWidth = arrowWidth
      ..arrowHeight = arrowHeight;
  }
}
