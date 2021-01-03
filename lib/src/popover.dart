import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:popover/src/popover_contex.dart';
import 'package:popover/src/popover_direction.dart';
import 'package:popover/src/popover_position.dart';

class Popover extends StatefulWidget {
  final Rect attachRect;
  final Widget child;
  final Color color;
  final List<BoxShadow> boxShadow;
  final double radius;
  final PopoverDirection direction;
  final Animation<double> doubleAnimation;
  BoxConstraints constraints;

  const Popover({
    @required this.attachRect,
    @required this.child,
    this.color = Colors.white,
    this.direction = PopoverDirection.bottom,
    this.radius = 14,
    this.doubleAnimation,
    this.boxShadow,
    Key key,
  }) : super(key: key);

  @override
  PopoverState createState() => PopoverState();
}

class PopoverState extends State<Popover> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PopoverPosition(
          attachRect: widget.attachRect,
          animation: widget.doubleAnimation,
          constraints: widget.constraints,
          direction: widget.direction,
          child: PopoverContext(
            attachRect: widget.attachRect,
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
