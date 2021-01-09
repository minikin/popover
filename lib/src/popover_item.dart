import 'package:flutter/material.dart';

import 'popover_context.dart';
import 'popover_direction.dart';
import 'popover_position_widget.dart';
import 'utils/popover_utils.dart';
import 'utils/utils.dart';

// ignore: must_be_immutable
class PopoverItem extends StatelessWidget {
  final Rect attachRect;
  final Widget child;
  final Color backgroundColor;
  final PopoverDirection direction;
  final double radius;
  final List<BoxShadow> boxShadow;
  final Animation<double> animation;
  final double arrowWidth;
  final double arrowHeight;
  BoxConstraints constraints;

  PopoverItem({
    @required this.attachRect,
    @required this.child,
    this.backgroundColor,
    this.direction,
    this.radius,
    this.boxShadow,
    this.animation,
    this.arrowWidth,
    this.arrowHeight,
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
          child: PopoverContext(
            attachRect: attachRect,
            animation: animation,
            radius: radius,
            backgroundColor: backgroundColor,
            boxShadow: boxShadow,
            direction: direction,
            arrowWidth: arrowWidth,
            arrowHeight: arrowHeight,
            child: Material(type: MaterialType.transparency, child: child),
          ),
        )
      ],
    );
  }

  void _configure(BoxConstraints constraints) {
    BoxConstraints _constraints;
    if (constraints != null) {
      _constraints = BoxConstraints(
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
      _constraints = BoxConstraints(
        maxHeight: Utils().screenHeight / 3,
        maxWidth: Utils().screenHeight / 3,
      );
    }
    this.constraints = _constraints.copyWith(
      maxHeight: _constraints.maxHeight + PopoverUtils.arrowHeight,
    );
  }
}
