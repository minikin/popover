import 'package:flutter/rendering.dart';

import 'popover_direction.dart';
import 'popover_path.dart';
import 'utils/popover_utils.dart';

class PopoverRenderShiftedBox extends RenderShiftedBox {
  double arrowWidth;
  double arrowHeight;
  PopoverDirection _direction;
  Rect _attachRect;
  Color _color;
  List<BoxShadow> _boxShadow;
  double _scale;
  double _radius;

  PopoverRenderShiftedBox({
    this.arrowWidth,
    this.arrowHeight,
    RenderBox child,
    Rect attachRect,
    Color color,
    List<BoxShadow> boxShadow,
    double scale,
    double radius,
    PopoverDirection direction,
  }) : super(child) {
    _attachRect = attachRect;
    _color = color;
    _boxShadow = boxShadow;
    _scale = scale;
    _radius = radius;
    _direction = direction;
  }

  Rect get attachRect => _attachRect;
  set attachRect(Rect value) {
    if (_attachRect == value) return;
    _attachRect = value;
    markNeedsLayout();
  }

  List<BoxShadow> get boxShadow => _boxShadow;
  set boxShadow(List<BoxShadow> value) {
    if (_boxShadow == value) return;
    _boxShadow = value;
    markNeedsLayout();
  }

  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsLayout();
  }

  PopoverDirection get direction => _direction;
  set direction(PopoverDirection value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  double get radius => _radius;
  set radius(double value) {
    if (_radius == value) return;
    _radius = value;
    markNeedsLayout();
  }

  double get scale => _scale;
  set scale(double value) {
    _scale = value;
    markNeedsLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final transform = Matrix4.identity();
    final BoxParentData childParentData = child.parentData;
    final _direction = PopoverUtils.popoverDirection(
      attachRect,
      size,
      direction,
    );

    Rect arrowRect;
    Offset translation;
    Rect bodyRect;

    bodyRect = childParentData.offset & child.size;

    final arrowLeft =
        attachRect.left + attachRect.width / 2 - arrowWidth / 2 - offset.dx;

    final arrowTop =
        attachRect.top + attachRect.height / 2 - arrowWidth / 2 - offset.dy;

    switch (_direction) {
      case PopoverDirection.top:
        arrowRect = Rect.fromLTWH(
          arrowLeft,
          child.size.height,
          arrowWidth,
          arrowHeight,
        );

        translation = Offset(arrowLeft + arrowWidth / 2, size.height);

        break;
      case PopoverDirection.left:
        arrowRect = Rect.fromLTWH(
          child.size.width,
          arrowTop,
          arrowHeight,
          arrowWidth,
        );
        translation = Offset(size.width, arrowTop + arrowWidth / 2);
        break;
      case PopoverDirection.bottom:
        arrowRect = Rect.fromLTWH(arrowLeft, 0, arrowWidth, arrowHeight);
        translation = Offset(arrowLeft + arrowWidth / 2, 0);
        break;
      case PopoverDirection.right:
        arrowRect = Rect.fromLTWH(0, arrowTop, arrowHeight, arrowWidth);
        translation = Offset(0, arrowTop + arrowWidth / 2);
        break;
      default:
    }

    transform.translate(translation.dx, translation.dy);
    transform.scale(scale, scale, 1.0);
    transform.translate(-translation.dx, -translation.dy);

    _paintShadows(context, transform, offset, _direction, arrowRect, bodyRect);

    final path = PopoverPath(radius).draw(_direction, arrowRect, bodyRect);

    context.pushClipPath(needsCompositing, offset, offset & size, path, (
      context,
      offset,
    ) {
      context.pushTransform(needsCompositing, offset, transform, (
        context,
        offset,
      ) {
        final backgroundPaint = Paint();
        backgroundPaint.color = color;
        context.canvas.drawRect(offset & size, backgroundPaint);
        super.paint(context, offset);
      });
    });
  }

  @override
  void performLayout() {
    assert(constraints.maxHeight.isFinite);
    BoxConstraints childConstraints;

    if (direction == PopoverDirection.top ||
        direction == PopoverDirection.bottom) {
      childConstraints = BoxConstraints(
        maxHeight: constraints.maxHeight - arrowHeight,
      ).enforce(constraints);
    } else {
      childConstraints = BoxConstraints(
        maxWidth: constraints.maxWidth - arrowHeight,
      ).enforce(constraints);
    }

    child.layout(childConstraints, parentUsesSize: true);

    if (direction == PopoverDirection.top ||
        direction == PopoverDirection.bottom) {
      size = Size(child.size.width, child.size.height + arrowHeight);
    } else {
      size = Size(child.size.width + arrowHeight, child.size.height);
    }

    final _direction = PopoverUtils.popoverDirection(
      attachRect,
      size,
      direction,
    );

    final BoxParentData childParentData = child.parentData;
    if (_direction == PopoverDirection.bottom) {
      childParentData.offset = Offset(0.0, arrowHeight);
    } else if (_direction == PopoverDirection.right) {
      childParentData.offset = Offset(arrowHeight, 0.0);
    }
  }

  void _paintShadows(
    PaintingContext context,
    Matrix4 transform,
    Offset offset,
    PopoverDirection direction,
    Rect arrowRect,
    Rect bodyRect,
  ) {
    if (boxShadow == null) return;
    for (final boxShadow in boxShadow) {
      final paint = boxShadow.toPaint();

      arrowRect = arrowRect
          .shift(offset)
          .shift(boxShadow.offset)
          .inflate(boxShadow.spreadRadius);

      bodyRect = bodyRect
          .shift(offset)
          .shift(boxShadow.offset)
          .inflate(boxShadow.spreadRadius);

      final path = PopoverPath(radius).draw(_direction, arrowRect, bodyRect);

      context.pushTransform(needsCompositing, offset, transform, (
        context,
        offset,
      ) {
        context.canvas.drawPath(path, paint);
      });
    }
  }
}
