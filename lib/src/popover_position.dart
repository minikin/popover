import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'popover_direction.dart';
import 'popover_position_shifted_box.dart';

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
      PopoverPositionShiftedBox(
        attachRect: attachRect,
        direction: direction,
        constraints: constraints,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    PopoverPositionShiftedBox shiftedBox,
  ) {
    shiftedBox
      ..attachRect = attachRect
      ..direction = direction
      ..additionalConstraints = constraints;
  }
}
