import 'package:flutter/material.dart';

import 'popover_direction.dart';
import 'popover_position_widget.dart';
import 'popover_render_shifted_box.dart';
import 'popover_utils.dart';
import 'utils/utils.dart';

// ignore: must_be_immutable
class PopoverItem extends StatelessWidget {
  final Rect attachRect;
  final Widget child;
  final Color color;
  final PopoverDirection direction;
  final double radius;
  final List<BoxShadow> boxShadow;
  final Animation<double> animation;
  BoxConstraints constraints;

  PopoverItem({
    @required this.attachRect,
    @required this.child,
    this.color = Colors.white,
    this.direction = PopoverDirection.bottom,
    this.radius = 8,
    this.boxShadow,
    this.animation,
    this.constraints,
    Key key,
  }) : super(key: key) {
    _configure(constraints);
  }

  Widget build(BuildContext context) {
    return Stack(
      children: [
        PopoverPositionWidget(
          attachRect: attachRect,
          scale: animation,
          constraints: constraints,
          direction: direction,
          child: _PopoverContext(
            attachRect: attachRect,
            animation: animation,
            radius: radius,
            color: color,
            boxShadow: boxShadow,
            direction: direction,
            child: Material(type: MaterialType.transparency, child: child),
          ),
        )
      ],
    );
  }

  void _configure(BoxConstraints constraints) {
    BoxConstraints temp;
    if (constraints != null) {
      temp = BoxConstraints(
        maxHeight: Utils().screenHeight / 3,
        maxWidth: Utils().screenHeight / 3,
      ).copyWith(
        minWidth: constraints.minWidth.isFinite ? constraints.minWidth : null,
        minHeight:
            constraints.minHeight.isFinite ? constraints.minHeight : null,
        maxWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
        maxHeight:
            constraints.maxHeight.isFinite ? constraints.maxHeight : null,
      );
    } else {
      temp = BoxConstraints(
        maxHeight: Utils().screenHeight / 3,
        maxWidth: Utils().screenHeight / 3,
      );
    }
    this.constraints = temp.copyWith(
      maxHeight: temp.maxHeight + PopoverUtils.arrowHeight,
    );
  }
}

class _PopoverContext extends SingleChildRenderObjectWidget {
  final Rect attachRect;
  final Color color;
  final List<BoxShadow> boxShadow;
  final Animation<double> animation;
  final double radius;
  final PopoverDirection direction;

  _PopoverContext({
    Widget child,
    this.attachRect,
    this.color,
    this.boxShadow,
    this.animation,
    this.radius,
    this.direction,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PopoverRenderShiftedBox(
      attachRect: attachRect,
      color: color,
      boxShadow: boxShadow,
      scale: animation.value,
      direction: direction,
      radius: radius,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    PopoverRenderShiftedBox renderObject,
  ) {
    renderObject
      ..attachRect = attachRect
      ..color = color
      ..boxShadow = boxShadow
      ..scale = animation.value
      ..direction = direction
      ..radius = radius;
  }
}
