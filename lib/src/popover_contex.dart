import 'package:flutter/material.dart';
import 'package:popover/src/popover_context_render_object.dart';
import 'package:popover/src/popover_direction.dart';

class PopoverContext extends SingleChildRenderObjectWidget {
  final Rect attachRect;
  final Color color;
  final List<BoxShadow> boxShadow;
  final Animation<double> scale;
  final double radius;
  final PopoverDirection direction;

  const PopoverContext({
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
  RenderObject createRenderObject(BuildContext context) =>
      PopoverContextRenderObject(
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
    PopoverContextRenderObject renderObject,
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
