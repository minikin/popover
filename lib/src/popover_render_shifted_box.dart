import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart';

import 'popover_direction.dart';
import 'popover_path.dart';
import 'utils/popover_utils.dart';

final class PopoverRenderShiftedBox extends RenderShiftedBox {
  late Rect _attachRect;
  double? arrowWidth;
  double arrowHeight;
  PopoverDirection? _direction;
  Color? _color;
  List<BoxShadow>? _boxShadow;
  double? _scale;
  double? _radius;

  PopoverRenderShiftedBox({
    required Rect attachRect,
    required this.arrowHeight,
    this.arrowWidth,
    RenderBox? child,
    Color? color,
    List<BoxShadow>? boxShadow,
    double? scale,
    double? radius,
    PopoverDirection? direction,
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

  List<BoxShadow>? get boxShadow => _boxShadow;
  set boxShadow(List<BoxShadow>? value) {
    if (_boxShadow == value) return;
    _boxShadow = value;
    markNeedsLayout();
  }

  Color? get color => _color;
  set color(Color? value) {
    if (_color == value) return;
    _color = value;
    markNeedsLayout();
  }

  PopoverDirection? get direction => _direction;
  set direction(PopoverDirection? value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  double? get radius => _radius;
  set radius(double? value) {
    if (_radius == value) return;
    _radius = value;
    markNeedsLayout();
  }

  double? get scale => _scale;
  set scale(double? value) {
    _scale = value;
    markNeedsLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final transform = Matrix4.identity();
    final childParentData = child!.parentData as BoxParentData;
    final _direction = PopoverUtils.popoverDirection(
      attachRect,
      size,
      arrowHeight,
      direction,
    );
    final bodyRect = childParentData.offset & child!.size;

    final arrowLeft =
        attachRect.left + attachRect.width / 2 - arrowWidth! / 2 - offset.dx;

    final arrowTop =
        attachRect.top + attachRect.height / 2 - arrowWidth! / 2 - offset.dy;

    late Rect arrowRect;
    late Offset translation;

    switch (_direction) {
      case PopoverDirection.top:
        arrowRect = Rect.fromLTWH(
          arrowLeft,
          child!.size.height,
          arrowWidth!,
          arrowHeight,
        );

        translation = Offset(arrowLeft + arrowWidth! / 2, size.height);
        break;
      case PopoverDirection.bottom:
        arrowRect = Rect.fromLTWH(arrowLeft, 0, arrowWidth!, arrowHeight);
        translation = Offset(arrowLeft + arrowWidth! / 2, 0);
        break;
      case PopoverDirection.left:
        arrowRect = Rect.fromLTWH(
          child!.size.width,
          arrowTop,
          arrowHeight,
          arrowWidth!,
        );

        translation = Offset(size.width, arrowTop + arrowWidth! / 2);
        break;
      case PopoverDirection.right:
        arrowRect = Rect.fromLTWH(
          0,
          arrowTop,
          arrowHeight,
          arrowWidth!,
        );
        translation = Offset(0, arrowTop + arrowWidth! / 2);
        break;
    }

    _transform(transform, translation);

    _paintShadows(context, transform, offset, _direction, arrowRect, bodyRect);

    _pushClipPath(
      context,
      offset,
      PopoverPath(radius!).draw(_direction, arrowRect, bodyRect),
      transform,
    );
  }

  @override
  void performLayout() {
    assert(constraints.maxHeight.isFinite);

    _configureChildConstrains();
    _configureChildSize();
    _configureChildOffset();
  }

  void _configureChildConstrains() {
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

    child!.layout(childConstraints, parentUsesSize: true);
  }

  void _configureChildOffset() {
    final _direction = PopoverUtils.popoverDirection(
      attachRect,
      size,
      arrowHeight,
      direction,
    );

    final childParentData = child!.parentData as BoxParentData?;
    if (_direction == PopoverDirection.bottom) {
      childParentData!.offset = Offset(0, arrowHeight);
    } else if (_direction == PopoverDirection.right) {
      childParentData!.offset = Offset(arrowHeight, 0);
    } else {
      childParentData!.offset = const Offset(0, 0);
    }
  }

  void _configureChildSize() {
    if (direction == PopoverDirection.top ||
        direction == PopoverDirection.bottom) {
      size = Size(child!.size.width, child!.size.height + arrowHeight);
    } else {
      size = Size(child!.size.width + arrowHeight, child!.size.height);
    }
  }

  void _paintShadows(
    PaintingContext context,
    Matrix4 transform,
    Offset offset,
    PopoverDirection direction,
    Rect? arrowRect,
    Rect bodyRect,
  ) {
    if (boxShadow == null) return;
    for (final boxShadow in boxShadow!) {
      final paint = boxShadow.toPaint();

      arrowRect = arrowRect!
          .shift(offset)
          .shift(boxShadow.offset)
          .inflate(boxShadow.spreadRadius);

      bodyRect = bodyRect
          .shift(offset)
          .shift(boxShadow.offset)
          .inflate(boxShadow.spreadRadius);

      final path = PopoverPath(radius!).draw(_direction, arrowRect, bodyRect);

      context.pushTransform(needsCompositing, offset, transform, (
        context,
        offset,
      ) {
        context.canvas.drawPath(path, paint);
      });
    }
  }

  void _pushClipPath(
    PaintingContext context,
    Offset offset,
    Path path,
    Matrix4 transform,
  ) {
    context.pushClipPath(needsCompositing, offset, offset & size, path, (
      context,
      offset,
    ) {
      context.pushTransform(needsCompositing, offset, transform, (
        context,
        offset,
      ) {
        final backgroundPaint = Paint();
        backgroundPaint.color = color!;
        context.canvas.drawRect(offset & size, backgroundPaint);
        super.paint(context, offset);
      });
    });
  }

  void _transform(Matrix4 transform, Offset translation) {
    transform.translateByVector3(Vector3(translation.dx, translation.dy, 0));
    transform.scaleByVector3(Vector3(scale ?? 1.0, scale ?? 1.0, 1.0));
    transform.translateByVector3(Vector3(-translation.dx, -translation.dy, 0));
  }
}
