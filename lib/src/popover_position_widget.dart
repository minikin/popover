import 'package:flutter/widgets.dart';

import 'popover_direction.dart';
import 'popover_position_render_object.dart';

final class PopoverPositionWidget extends SingleChildRenderObjectWidget {
  final Rect attachRect;
  final Rect bounds;
  final double arrowHeight;
  final BoxConstraints? constraints;
  final PopoverDirection? direction;
  final TargetPlatform platform;

  const PopoverPositionWidget({
    required this.arrowHeight,
    required this.attachRect,
    required this.bounds,
    this.constraints,
    required this.platform,
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
      platform: platform,
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
      ..additionalConstraints = constraints
      ..arrowHeight = arrowHeight
      ..platform = platform;
  }
}
