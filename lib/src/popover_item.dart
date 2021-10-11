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
  final double? arrowDxOffset;
  final double? arrowDyOffset;
  final double? contentDyOffset;
  final bool Function()? isParentAlive;

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
    this.arrowDxOffset,
    this.arrowDyOffset,
    this.contentDyOffset,
    this.isParentAlive,
    Key? key,
  }) : super(key: key);

  @override
  _PopoverItemState createState() => _PopoverItemState();
}

class _PopoverItemState extends State<PopoverItem> {
  late BoxConstraints constraints;
  late Offset offset;
  late Rect bounds;
  late Rect attachRect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, __) {
        _configure();
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

  void _configure() {
    final bool isParentAlive;

    if (widget.isParentAlive != null) {
      isParentAlive = widget.isParentAlive!();
    } else {
      isParentAlive = true;
    }

    if (!isParentAlive) {
      return;
    }

    final box = widget.context.findRenderObject() as RenderBox;
    if (mounted && box.owner != null) {
      _configureConstraints();
      _configureRect();
    }
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
    if (widget.direction == PopoverDirection.top ||
        widget.direction == PopoverDirection.bottom) {
      constraints = _constraints.copyWith(
        maxHeight: _constraints.maxHeight + widget.arrowHeight!,
        maxWidth: _constraints.maxWidth,
      );
    } else {
      constraints = _constraints.copyWith(
        maxHeight: _constraints.maxHeight + widget.arrowHeight!,
        maxWidth: _constraints.maxWidth + widget.arrowWidth!,
      );
    }
  }

  void _configureRect() {
    offset = BuildContextExtension.getWidgetLocalToGlobal(widget.context);
    bounds = BuildContextExtension.getWidgetBounds(widget.context);
    attachRect = Rect.fromLTWH(
      offset.dx + (widget.arrowDxOffset ?? 0.0),
      offset.dy + (widget.arrowDyOffset ?? 0.0),
      bounds.width,
      bounds.height + (widget.contentDyOffset ?? 0.0),
    );
  }
}
