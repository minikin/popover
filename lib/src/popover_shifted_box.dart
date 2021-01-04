import 'package:flutter/rendering.dart';

import 'popover_direction.dart';
import 'popover_utils.dart';

class PopoverShiftedBox extends RenderShiftedBox {
  PopoverDirection _direction;
  Rect _attachRect;
  Color _color;
  List<BoxShadow> _boxShadow;
  double _scale;
  double _radius;

  PopoverShiftedBox({
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
    final calculatedDirection = PopoverUtils.reCalculatePopoverDirection(
      attachRect,
      size,
      direction,
    );

    Rect arrowRect;
    Offset translation;
    Rect bodyRect;

    final BoxParentData childParentData = child.parentData;
    bodyRect = childParentData.offset & child.size;

    final arrowLeft = attachRect.left +
        attachRect.width / 2 -
        PopoverUtils.arrowWidth / 2 -
        offset.dx;

    final arrowTop = attachRect.top +
        attachRect.height / 2 -
        PopoverUtils.arrowWidth / 2 -
        offset.dy;

    switch (calculatedDirection) {
      case PopoverDirection.top:
        arrowRect = Rect.fromLTWH(
          arrowLeft,
          child.size.height,
          PopoverUtils.arrowWidth,
          PopoverUtils.arrowHeight,
        );

        translation = Offset(
          arrowLeft + PopoverUtils.arrowWidth / 2,
          size.height,
        );

        break;
      case PopoverDirection.left:
        arrowRect = Rect.fromLTWH(
          child.size.width,
          arrowTop,
          PopoverUtils.arrowHeight,
          PopoverUtils.arrowWidth,
        );
        translation = Offset(
          size.width,
          arrowTop + PopoverUtils.arrowWidth / 2,
        );
        break;
      case PopoverDirection.bottom:
        arrowRect = Rect.fromLTWH(
          arrowLeft,
          0,
          PopoverUtils.arrowWidth,
          PopoverUtils.arrowHeight,
        );
        translation = Offset(arrowLeft + PopoverUtils.arrowWidth / 2, 0);
        break;
      case PopoverDirection.right:
        arrowRect = Rect.fromLTWH(
          0,
          arrowTop,
          PopoverUtils.arrowHeight,
          PopoverUtils.arrowWidth,
        );
        translation = Offset(0, arrowTop + PopoverUtils.arrowWidth / 2);
        break;
      default:
        break;
    }

    transform.translate(translation.dx, translation.dy);
    transform.scale(scale, scale, 1.0);
    transform.translate(-translation.dx, -translation.dy);

    _paintShadows(
      context,
      transform,
      offset,
      calculatedDirection,
      arrowRect,
      bodyRect,
    );

    final clipPath = _getClip(calculatedDirection, arrowRect, bodyRect);
    context.pushClipPath(
      needsCompositing,
      offset,
      offset & size,
      clipPath,
      (context, offset) {
        context.pushTransform(needsCompositing, offset, transform,
            (context, offset) {
          final backgroundPaint = Paint();
          backgroundPaint.color = color;
          context.canvas.drawRect(offset & size, backgroundPaint);
          super.paint(context, offset);
        });
      },
    );
  }

  @override
  void performLayout() {
    assert(constraints.maxHeight.isFinite);
    BoxConstraints childConstraints;

    if (direction == PopoverDirection.top ||
        direction == PopoverDirection.bottom) {
      childConstraints = BoxConstraints(
        maxHeight: constraints.maxHeight - PopoverUtils.arrowHeight,
      ).enforce(constraints);
    } else {
      childConstraints = BoxConstraints(
        maxWidth: constraints.maxWidth - PopoverUtils.arrowHeight,
      ).enforce(constraints);
    }

    child.layout(childConstraints, parentUsesSize: true);

    if (direction == PopoverDirection.top ||
        direction == PopoverDirection.bottom) {
      size = Size(
        child.size.width,
        child.size.height + PopoverUtils.arrowHeight,
      );
    } else {
      size = Size(
        child.size.width + PopoverUtils.arrowHeight,
        child.size.height,
      );
    }

    final calculatedDirection = PopoverUtils.reCalculatePopoverDirection(
      attachRect,
      size,
      direction,
    );

    final BoxParentData childParentData = child.parentData;

    if (calculatedDirection == PopoverDirection.bottom) {
      childParentData.offset = const Offset(0, PopoverUtils.arrowHeight);
    } else if (calculatedDirection == PopoverDirection.right) {
      childParentData.offset = const Offset(PopoverUtils.arrowHeight, 0);
    }
  }

  Path _getClip(
    PopoverDirection direction,
    Rect arrowRect,
    Rect bodyRect,
  ) {
    final path = Path();

    if (direction == PopoverDirection.top) {
      path.moveTo(arrowRect.left, arrowRect.top);
      path.lineTo(arrowRect.left + arrowRect.width / 2, arrowRect.bottom);
      path.lineTo(arrowRect.right, arrowRect.top);
      path.lineTo(bodyRect.right - radius, bodyRect.bottom);

      path.conicTo(
        bodyRect.right,
        bodyRect.bottom,
        bodyRect.right,
        bodyRect.bottom - radius,
        1,
      );

      path.lineTo(bodyRect.right, bodyRect.top + radius);
      path.conicTo(
        bodyRect.right,
        bodyRect.top,
        bodyRect.right - radius,
        bodyRect.top,
        1,
      );

      path.lineTo(bodyRect.left + radius, bodyRect.top);
      path.conicTo(
        bodyRect.left,
        bodyRect.top,
        bodyRect.left,
        bodyRect.top + radius,
        1,
      );

      path.lineTo(bodyRect.left, bodyRect.bottom - radius);
      path.conicTo(
        bodyRect.left,
        bodyRect.bottom,
        bodyRect.left + radius,
        bodyRect.bottom,
        1,
      );
    } else if (direction == PopoverDirection.right) {
      path.moveTo(arrowRect.right, arrowRect.top);
      path.lineTo(arrowRect.left, arrowRect.top + arrowRect.height / 2);
      path.lineTo(arrowRect.right, arrowRect.bottom);
      path.lineTo(bodyRect.left, bodyRect.bottom - radius);

      path.conicTo(
        bodyRect.left,
        bodyRect.bottom,
        bodyRect.left + radius,
        bodyRect.bottom,
        1,
      );

      path.lineTo(bodyRect.right - radius, bodyRect.bottom);
      path.conicTo(
        bodyRect.right,
        bodyRect.bottom,
        bodyRect.right,
        bodyRect.bottom - radius,
        1,
      );

      path.lineTo(bodyRect.right, bodyRect.top + radius);
      path.conicTo(
        bodyRect.right,
        bodyRect.top,
        bodyRect.right - radius,
        bodyRect.top,
        1,
      );

      path.lineTo(bodyRect.left + radius, bodyRect.top);
      path.conicTo(
        bodyRect.left,
        bodyRect.top,
        bodyRect.left,
        bodyRect.top + radius,
        1,
      );
    } else if (direction == PopoverDirection.left) {
      path.moveTo(arrowRect.left, arrowRect.top);
      path.lineTo(arrowRect.right, arrowRect.top + arrowRect.height / 2);
      path.lineTo(arrowRect.left, arrowRect.bottom);
      path.lineTo(bodyRect.right, bodyRect.bottom - radius);

      path.conicTo(
        bodyRect.right,
        bodyRect.bottom,
        bodyRect.right - radius,
        bodyRect.bottom,
        1,
      );

      path.lineTo(bodyRect.left + radius, bodyRect.bottom);
      path.conicTo(
        bodyRect.left,
        bodyRect.bottom,
        bodyRect.left,
        bodyRect.bottom - radius,
        1,
      );

      path.lineTo(bodyRect.left, bodyRect.top + radius);
      path.conicTo(
        bodyRect.left,
        bodyRect.top,
        bodyRect.left + radius,
        bodyRect.top,
        1,
      );

      path.lineTo(bodyRect.right - radius, bodyRect.top);
      path.conicTo(
        bodyRect.right,
        bodyRect.top,
        bodyRect.right,
        bodyRect.top + radius,
        1,
      );
    } else {
      path.moveTo(arrowRect.left, arrowRect.bottom);
      path.lineTo(arrowRect.left + arrowRect.width / 2, arrowRect.top);
      path.lineTo(arrowRect.right, arrowRect.bottom);
      path.lineTo(bodyRect.right - radius, bodyRect.top);

      path.conicTo(
        bodyRect.right,
        bodyRect.top,
        bodyRect.right,
        bodyRect.top + radius,
        1,
      );

      path.lineTo(bodyRect.right, bodyRect.bottom - radius);
      path.conicTo(
        bodyRect.right,
        bodyRect.bottom,
        bodyRect.right - radius,
        bodyRect.bottom,
        1,
      );

      path.lineTo(bodyRect.left + radius, bodyRect.bottom);
      path.conicTo(
        bodyRect.left,
        bodyRect.bottom,
        bodyRect.left,
        bodyRect.bottom - radius,
        1,
      );

      path.lineTo(bodyRect.left, bodyRect.top + radius);
      path.conicTo(
        bodyRect.left,
        bodyRect.top,
        bodyRect.left + radius,
        bodyRect.top,
        1,
      );
    }
    path.close();
    return path;
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
    for (final item in boxShadow) {
      final paint = item.toPaint();

      arrowRect = arrowRect.shift(offset).shift(item.offset).inflate(
            item.spreadRadius,
          );

      bodyRect =
          bodyRect.shift(offset).shift(item.offset).inflate(item.spreadRadius);

      final path = _getClip(direction, arrowRect, bodyRect);

      context.pushTransform(
        needsCompositing,
        offset,
        transform,
        (context, offset) {
          context.canvas.drawPath(path, paint);
        },
      );
    }
  }
}
