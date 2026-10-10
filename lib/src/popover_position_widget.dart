import 'package:flutter/widgets.dart';

import 'popover_direction.dart';
import 'popover_position_render_object.dart';

final class PopoverPositionWidget extends SingleChildRenderObjectWidget {
  final Rect attachRect;
  final Size bounds;
  final double arrowHeight;
  final BoxConstraints? constraints;
  final PopoverDirection? direction;

  const PopoverPositionWidget({
    required this.arrowHeight,
    required this.attachRect,
    required this.bounds,
    this.constraints,
    this.direction,
    Widget? child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PopoverPositionRenderObject(
      attachRect: attachRect,
      bounds: bounds,
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
      ..bounds = bounds
      ..direction = direction
      ..additionalConstraints = constraints;
  }
}
