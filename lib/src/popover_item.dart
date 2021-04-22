import 'package:flutter/material.dart';

import 'popover_context.dart';
import 'popover_direction.dart';
import 'popover_position_widget.dart';
import 'utils/build_context_extension.dart';
import 'utils/utils.dart';

class PopoverItem extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final PopoverDirection? direction;
  final double? radius;
  final List<BoxShadow>? boxShadow;
  final Animation<double>? animation;
  final double? arrowWidth;
  final double? arrowHeight;
  final BoxConstraints? constraints;
  final BuildContext context;
  final double arrowDxOffset;
  final double arrowDyOffset;
  final double contentDyOffset;

  const PopoverItem({
    required this.child,
    required this.context,
    this.backgroundColor,
    this.direction,
    this.radius,
    this.boxShadow,
    this.animation,
    this.arrowWidth,
    this.arrowHeight,
    this.constraints,
    this.arrowDxOffset = 0,
    this.arrowDyOffset = 0,
    this.contentDyOffset = 0,
    Key? key,
  }) : super(key: key);

  @override
  _PopoverItemState createState() => _PopoverItemState();
}

class _PopoverItemState extends State<PopoverItem> {
  BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        _configureConstraints();
        final offset =
            BuildContextExtension.getWidgetLocalToGlobal(widget.context);
        final bounds = BuildContextExtension.getWidgetBounds(widget.context);
        final attachRect = Rect.fromLTWH(
          offset.dx + widget.arrowDxOffset,
          offset.dy + widget.arrowDyOffset,
          bounds.width,
          bounds.height + widget.contentDyOffset,
        );

        return Stack(
          children: [
            PopoverPositionWidget(
              attachRect: attachRect,
              scale: widget.animation,
              constraints: constraints,
              direction: widget.direction,
              arrowHeight: widget.arrowHeight,
              child: PopoverContext(
                attachRect: attachRect,
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
      },
    );
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
