import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'popover_direction.dart';
import 'utils/popover_utils.dart';

final class PopoverPositionRenderObject extends RenderShiftedBox {
  late Rect _attachRect;
  late Rect _bounds;
  double arrowHeight;
  BoxConstraints? _additionalConstraints;
  PopoverDirection? _direction;
  TargetPlatform _platform;

  PopoverPositionRenderObject({
    required this.arrowHeight,
    required Rect attachRect,
    required Rect bounds,
    RenderBox? child,
    BoxConstraints? constraints,
    PopoverDirection? direction,
    TargetPlatform platform = TargetPlatform.iOS,
  }) : _platform = platform,
       super(child) {
    _attachRect = attachRect;
    _bounds = bounds;
    _additionalConstraints = constraints;
    _direction = direction;
  }

  BoxConstraints? get additionalConstraints => _additionalConstraints;
  set additionalConstraints(BoxConstraints? value) {
    if (_additionalConstraints == value) return;
    _additionalConstraints = value;
    markNeedsLayout();
  }

  Rect get attachRect => _attachRect;
  set attachRect(Rect value) {
    if (_attachRect == value) return;
    _attachRect = value;
    markNeedsLayout();
  }

  /// The area the popover stays in: the screen minus the safe area and
  /// [PopoverUtils.screenMargin].
  Rect get bounds => _bounds;
  set bounds(Rect value) {
    if (_bounds == value) return;
    _bounds = value;
    markNeedsLayout();
  }

  PopoverDirection? get direction => _direction;
  set direction(PopoverDirection? value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  TargetPlatform get platform => _platform;
  set platform(TargetPlatform value) {
    if (_platform == value) return;
    _platform = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    final requested = direction ?? PopoverDirection.bottom;

    child!.layout(_popoverConstraints(requested), parentUsesSize: true);
    final arrow = PopoverUtils.isVertical(requested)
        ? Offset(0, arrowHeight)
        : Offset(arrowHeight, 0);
    final resolved = PopoverUtils.popoverDirection(
      attachRect: attachRect,
      bodySize: child!.size - arrow as Size,
      arrowHeight: arrowHeight,
      direction: requested,
      bounds: bounds,
      platform: platform,
    );
    final room = PopoverUtils.room(attachRect, resolved, bounds, platform);
    child!.layout(
      _popoverConstraints(
        resolved,
        room: room < arrowHeight ? arrowHeight : room,
      ),
      parentUsesSize: true,
    );

    final childParentData = child!.parentData! as BoxParentData;
    childParentData.offset = _offset(resolved, child!.size);
  }

  /// The constraints of the popover, arrow included, on [direction]'s side.
  PopoverConstraints _popoverConstraints(
    PopoverDirection direction, {
    double? room,
  }) {
    final vertical = PopoverUtils.isVertical(direction);
    final body = _additionalConstraints ?? const BoxConstraints();
    final arrowWidth = vertical ? 0.0 : arrowHeight;
    final arrowHeightOnAxis = vertical ? arrowHeight : 0.0;
    final popover = BoxConstraints(
      minWidth: body.minWidth + arrowWidth,
      maxWidth: body.maxWidth + arrowWidth,
      minHeight: body.minHeight + arrowHeightOnAxis,
      maxHeight: body.maxHeight + arrowHeightOnAxis,
    );
    var limits = BoxConstraints(
      maxWidth: bounds.width < 0 ? 0 : bounds.width,
      maxHeight: bounds.height < 0 ? 0 : bounds.height,
    );
    if (room != null) {
      limits = limits.enforce(
        vertical
            ? BoxConstraints(maxHeight: room)
            : BoxConstraints(maxWidth: room),
      );
    }
    return PopoverConstraints(popover.enforce(limits), direction);
  }

  Offset _offset(PopoverDirection direction, Size size) {
    switch (direction) {
      case PopoverDirection.top:
        return Offset(_slide(size.width, true), attachRect.top - size.height);
      case PopoverDirection.bottom:
        return Offset(_slide(size.width, true), attachRect.bottom);
      case PopoverDirection.left:
        var left = attachRect.left - size.width;
        if (left < bounds.left) {
          left = (attachRect.center.dx - size.width).clamp(left, bounds.left);
        }
        return Offset(left, _slide(size.height, false));
      case PopoverDirection.right:
        var left = attachRect.right;
        if (left + size.width > bounds.right) {
          left = (bounds.right - size.width).clamp(attachRect.center.dx, left);
        }
        return Offset(left, _slide(size.height, false));
    }
  }

  /// Centers the popover on [attachRect] along the side it sits on, then
  /// slides it to stay within [bounds].
  double _slide(double extent, bool horizontally) {
    final center = horizontally ? attachRect.center.dx : attachRect.center.dy;
    final min = horizontally ? bounds.left : bounds.top;
    final max = (horizontally ? bounds.right : bounds.bottom) - extent;
    if (max < min) return min;
    return (center - extent / 2).clamp(min, max);
  }
}
