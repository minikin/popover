import 'package:flutter/material.dart';

import 'popover_direction.dart';
import 'popover_shifted_box.dart';

class PopoverRenderObject extends SingleChildRenderObjectWidget {
  final Rect attachRect;
  final Color color;
  final List<BoxShadow> boxShadow;
  final Animation<double> scale;
  final double radius;
  final PopoverDirection direction;

  const PopoverRenderObject({
    Widget child,
    this.attachRect,
    this.color,
    this.boxShadow,
    this.scale,
    this.radius,
    this.direction,
    Key key,
  }) : super(child: child, key: key);

  @override
  RenderObject createRenderObject(BuildContext context) => PopoverShiftedBox(
        attachRect: attachRect,
        color: color,
        boxShadow: boxShadow,
        scale: scale.value,
        direction: direction,
        radius: radius,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    PopoverShiftedBox renderObject,
  ) {
    renderObject
      ..attachRect = attachRect
      ..color = color
      ..boxShadow = boxShadow
      ..scale = scale.value
      ..direction = direction
      ..radius = radius;
  }
}
