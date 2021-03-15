import 'package:flutter/material.dart';

import 'popover_context.dart';
import 'popover_direction.dart';
import 'popover_position_widget.dart';
import 'utils/utils.dart';

class PopoverItem extends StatefulWidget {
  final Rect attachRect;
  final Widget child;
  final Color? backgroundColor;
  final PopoverDirection? direction;
  final double? radius;
  final List<BoxShadow>? boxShadow;
  final Animation<double>? animation;
  final double? arrowWidth;
  final double? arrowHeight;
  final BoxConstraints? constraints;

  const PopoverItem({
    required this.attachRect,
    required this.child,
    this.backgroundColor,
    this.direction,
    this.radius,
    this.boxShadow,
    this.animation,
    this.arrowWidth,
    this.arrowHeight,
    this.constraints,
    Key? key,
  }) : super(key: key);

  @override
  _PopoverItemState createState() => _PopoverItemState();
}

class _PopoverItemState extends State<PopoverItem> {
  BoxConstraints? constraints;

  Widget build(BuildContext context) {
    return Stack(
      children: [
        PopoverPositionWidget(
          attachRect: widget.attachRect,
          scale: widget.animation,
          constraints: constraints,
          direction: widget.direction,
          arrowHeight: widget.arrowHeight,
          child: PopoverContext(
            attachRect: widget.attachRect,
            animation: widget.animation,
            radius: widget.radius,
            backgroundColor: widget.backgroundColor,
            boxShadow: widget.boxShadow,
            direction: widget.direction,
            arrowWidth: widget.arrowWidth,
            arrowHeight: widget.arrowHeight,
            child: Material(
              type: MaterialType.transparency,
              child: widget.child,
            ),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _configureConstraints();
  }

  void _configureConstraints() {
    BoxConstraints _constraints;
    if (widget.constraints != null) {
      _constraints = BoxConstraints(
        maxHeight: Utils().screenHeight / 2,
        maxWidth: Utils().screenHeight / 2,
      ).copyWith(
        minWidth: widget.constraints!.minWidth.isFinite
            ? widget.constraints!.minWidth
            : null,
        minHeight: widget.constraints!.minHeight.isFinite
            ? widget.constraints!.minHeight
            : null,
        maxWidth: widget.constraints!.maxWidth.isFinite
            ? widget.constraints!.maxWidth
            : null,
        maxHeight: widget.constraints!.maxHeight.isFinite
            ? widget.constraints!.maxHeight
            : null,
      );
    } else {
      _constraints = BoxConstraints(
        maxHeight: Utils().screenHeight / 2,
        maxWidth: Utils().screenHeight / 2,
      );
    }
    constraints = _constraints.copyWith(
      maxHeight: _constraints.maxHeight + widget.arrowHeight!,
    );
  }
}
