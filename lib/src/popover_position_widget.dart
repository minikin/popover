import 'package:flutter/material.dart';

import 'popover_direction.dart';
import 'popover_position_render_object.dart';

class PopoverPositionWidget extends SingleChildRenderObjectWidget {
  final Rect? attachRect;
  final Animation<double>? scale;
  final BoxConstraints? constraints;
  final PopoverDirection? direction;
  final double? arrowHeight;

  const PopoverPositionWidget({
    required this.arrowHeight,
    this.attachRect,
    this.constraints,
    this.scale,
    this.direction,
    Widget? child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PopoverPositionRenderObject(
      attachRect: attachRect,
      direction: direction,
      constraints: constraints,
      arrowHeight: arrowHeight,
    );
  }

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
