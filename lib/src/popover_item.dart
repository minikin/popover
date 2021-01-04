import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'popover_direction.dart';
import 'popover_position.dart';
import 'popover_render_object.dart';
import 'popover_utils.dart';

class PopoverItem extends StatefulWidget {
  final Rect rect;
  final Widget child;
  final BoxConstraints constraints;
  final Color color;
  final List<BoxShadow> boxShadow;
  final double radius;
  final PopoverDirection direction;
  final Animation<double> doubleAnimation;

  PopoverItem({
    @required this.rect,
    @required this.child,
    @required this.constraints,
    this.color = Colors.white,
    this.direction = PopoverDirection.bottom,
    this.radius = 14,
    this.doubleAnimation,
    this.boxShadow,
    Key key,
  }) : super(key: key) {
    _configureConstrains(constraints);
  }

  @override
  PopoverItemState createState() => PopoverItemState();

  void _configureConstrains(BoxConstraints constraints) {
    BoxConstraints temp;
    if (constraints != null) {
      temp = const BoxConstraints(maxHeight: 120, maxWidth: 180).copyWith(
        minWidth: constraints.minWidth.isFinite ? constraints.minWidth : null,
        minHeight:
            constraints.minHeight.isFinite ? constraints.minHeight : null,
        maxWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
        maxHeight:
            constraints.maxHeight.isFinite ? constraints.maxHeight : null,
      );
    } else {
      temp = const BoxConstraints(maxHeight: 300, maxWidth: 180);
    }
    constraints = temp.copyWith(
      maxHeight: temp.maxHeight + PopoverUtils.arrowHeight,
    );
  }
}

class PopoverItemState extends State<PopoverItem>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PopoverPosition(
          attachRect: widget.rect,
          animation: widget.doubleAnimation,
          constraints: widget.constraints,
          direction: widget.direction,
          child: PopoverRenderObject(
            attachRect: widget.rect,
            scale: widget.doubleAnimation,
            radius: widget.radius,
            color: widget.color,
            boxShadow: widget.boxShadow,
            direction: widget.direction,
            child: Material(
              type: MaterialType.transparency,
              child: widget.child,
            ),
          ),
        )
      ],
    );
  }
}
