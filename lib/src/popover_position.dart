import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:popover/src/popover_direction.dart';
import 'package:popover/src/popover_position_render_object.dart';

class PopoverPosition extends SingleChildRenderObjectWidget {
  @override
  final Widget child;
  final Rect attachRect;
  final Animation<double> animation;
  final BoxConstraints constraints;
  final PopoverDirection direction;

  const PopoverPosition({
    @required this.child,
    this.attachRect,
    this.constraints,
    this.animation,
    this.direction,
    Key key,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      PopoverPositionRenderObject(
        attachRect: attachRect,
        direction: direction,
        constraints: constraints,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    PopoverPositionRenderObject renderObject,
  ) {
    renderObject
      ..attachRect = attachRect
      ..direction = direction
      ..additionalConstraints = constraints;
  }
}
