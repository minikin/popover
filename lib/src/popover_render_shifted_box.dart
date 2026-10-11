import 'package:flutter/rendering.dart';

import 'apple_popover_path.dart';
import 'popover_direction.dart';
import 'popover_glass.dart';
import 'popover_path.dart';
import 'popover_shape.dart';
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
  PopoverShape _shape;
  PopoverGlass? _glass;
  final _backdrop = LayerHandle<BackdropFilterLayer>();

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
    PopoverShape shape = PopoverShape.triangle,
    PopoverGlass? glass,
  }) : _shape = shape,
       _glass = glass,
       super(child) {
    _attachRect = attachRect;
    _color = color;
    _boxShadow = boxShadow;
    _scale = scale;
    _radius = radius;
    _direction = direction;
  }

  PopoverShape get shape => _shape;
  set shape(PopoverShape value) {
    if (_shape == value) return;
    _shape = value;
    markNeedsPaint();
  }

  /// Replaces [color] when not null.
  PopoverGlass? get glass => _glass;
  set glass(PopoverGlass? value) {
    if (_glass == value) return;
    _glass = value;
    if (value == null) _backdrop.layer = null;
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => _glass != null;

  @override
  void dispose() {
    _backdrop.layer = null;
    super.dispose();
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
    if (_scale == value) return;
    _scale = value;
    markNeedsPaint();
  }

  /// The side [PopoverPositionRenderObject] picked, or [direction] when laid
  /// out on its own.
  PopoverDirection get _resolvedDirection {
    final constraints = this.constraints;
    return constraints is PopoverConstraints
        ? constraints.direction
        : direction ?? PopoverDirection.bottom;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final transform = Matrix4.identity();
    final childParentData = child!.parentData as BoxParentData;
    final _direction = _resolvedDirection;
    final bodyRect = childParentData.offset & child!.size;
    if (shape != PopoverShape.triangle) {
      _paintApple(context, offset, transform, _direction);
      return;
    }

    final arrowLeft = _arrowStart(
      attachRect.center.dx - offset.dx,
      child!.size.width,
    );
    final arrowTop = _arrowStart(
      attachRect.center.dy - offset.dy,
      child!.size.height,
    );

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
        arrowRect = Rect.fromLTWH(0, arrowTop, arrowHeight, arrowWidth!);
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

  void _paintApple(
    PaintingContext context,
    Offset offset,
    Matrix4 transform,
    PopoverDirection direction,
  ) {
    final vertical = PopoverUtils.isVertical(direction);
    final extent = vertical ? size.width : size.height;
    final target = vertical
        ? attachRect.center.dx - offset.dx
        : attachRect.center.dy - offset.dy;
    // UIKit keeps the tip half an arrow base from the body edge, AppKit 0.75.
    final inset = shape == PopoverShape.macos ? 0.75 : arrowWidth! / 2;
    final tip = extent < 2 * inset
        ? extent / 2
        : target.clamp(inset, extent - inset);
    Path outline(Rect frame, double tip) => switch (shape) {
      PopoverShape.macos => MacPopoverPath(
        arrowWidth: arrowWidth!,
        arrowHeight: arrowHeight,
        radius: radius ?? 0,
      ).toPath(frame: frame, direction: direction, tip: tip),
      _ => ApplePopoverPath(
        arrowWidth: arrowWidth!,
        arrowHeight: arrowHeight,
        radius: radius ?? 0,
      ).toPath(frame: frame, direction: direction, tip: tip),
    };
    final path = outline(Offset.zero & size, tip);

    _transform(transform, switch (direction) {
      PopoverDirection.bottom => Offset(tip, 0),
      PopoverDirection.top => Offset(tip, size.height),
      PopoverDirection.right => Offset(0, tip),
      PopoverDirection.left => Offset(size.width, tip),
    });

    for (final boxShadow in boxShadow ?? const <BoxShadow>[]) {
      final shift = offset + boxShadow.offset;
      final shadow = outline(
        (Offset.zero & size).inflate(boxShadow.spreadRadius).shift(shift),
        tip + (vertical ? shift.dx : shift.dy),
      );
      context.pushTransform(needsCompositing, offset, transform, (context, _) {
        final canvas = context.canvas;
        // Glass blurs what is behind it, so the shadow stays outside, as on
        // iOS and macOS.
        if (glass != null) {
          canvas
            ..save()
            ..clipPath(
              Path()
                ..fillType = PathFillType.evenOdd
                ..addRect(shadow.getBounds().inflate(boxShadow.blurSigma * 3))
                ..addPath(path, offset),
            );
        }
        canvas.drawPath(shadow, boxShadow.toPaint());
        if (glass != null) canvas.restore();
      });
    }

    _pushClipPath(context, offset, path, transform);
  }

  /// Where the arrow base starts along a body side of [extent] so the arrow
  /// points at [target] without running into a rounded corner.
  double _arrowStart(double target, double extent) {
    final min = radius ?? 0;
    final max = extent - min - arrowWidth!;
    if (max < min) return (extent - arrowWidth!) / 2;
    return (target - arrowWidth! / 2).clamp(min, max);
  }

  @override
  void performLayout() {
    assert(constraints.maxHeight.isFinite);

    _configureChildConstrains();
    _configureChildSize();
    _configureChildOffset();
  }

  void _configureChildConstrains() {
    final arrow = PopoverUtils.isVertical(_resolvedDirection)
        ? EdgeInsets.only(bottom: arrowHeight)
        : EdgeInsets.only(right: arrowHeight);
    child!.layout(constraints.deflate(arrow), parentUsesSize: true);
  }

  void _configureChildOffset() {
    final _direction = _resolvedDirection;

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
    final arrow = PopoverUtils.isVertical(_resolvedDirection)
        ? Size(0, arrowHeight)
        : Size(arrowHeight, 0);
    size = constraints.constrain(
      child!.size + Offset(arrow.width, arrow.height),
    );
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
      Rect place(Rect rect) => rect
          .shift(offset)
          .shift(boxShadow.offset)
          .inflate(boxShadow.spreadRadius);

      final path = PopoverPath(
        radius!,
      ).draw(direction, place(arrowRect!), place(bodyRect));

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
    final bounds = (Offset.zero & size).expandToInclude(path.getBounds());
    // Scaled before it is clipped, so a glass backdrop, which fills the whole
    // clip, grows with the body during the scale transition.
    context.pushTransform(needsCompositing, offset, transform, (
      context,
      offset,
    ) {
      context.pushClipPath(needsCompositing, offset, bounds, path, (
        context,
        offset,
      ) {
        final glass = this.glass;
        if (glass == null) {
          context.canvas.drawRect(
            bounds.shift(offset),
            Paint()..color = color!,
          );
          super.paint(context, offset);
          return;
        }
        _backdrop.layer = (_backdrop.layer ?? BackdropFilterLayer())
          ..filter = glass.filter;
        context.pushLayer(_backdrop.layer!, (context, offset) {
          context.canvas.drawPath(
            path.shift(offset),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = glass.rim,
          );
          super.paint(context, offset);
        }, offset);
      });
    });
  }

  void _transform(Matrix4 transform, Offset translation) {
    final s = scale ?? 1.0;
    transform.translateByDouble(translation.dx, translation.dy, 0.0, 1.0);
    transform.scaleByDouble(s, s, 1.0, 1.0);
    transform.translateByDouble(-translation.dx, -translation.dy, 0.0, 1.0);
  }
}
