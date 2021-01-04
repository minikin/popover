import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'popover_direction.dart';
import 'popover_utils.dart';
import 'utils/utils.dart';

class PopoverPositionShiftedBox extends RenderShiftedBox {
  PopoverDirection _direction;
  Rect _attachRect;
  BoxConstraints _additionalConstraints;

  PopoverPositionShiftedBox({
    RenderBox child,
    Rect attachRect,
    Color color,
    BoxConstraints constraints,
    Animation<double> scale,
    PopoverDirection direction,
  }) : super(child) {
    _attachRect = attachRect;
    _additionalConstraints = constraints;
    _direction = direction;
  }

  BoxConstraints get additionalConstraints => _additionalConstraints;

  set additionalConstraints(BoxConstraints value) {
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

  PopoverDirection get direction => _direction;

  set direction(PopoverDirection value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  Offset calcOffset(Size size) {
    final calcDirection = PopoverUtils.reCalculatePopoverDirection(
      attachRect,
      size,
      direction,
    );

    if (calcDirection == PopoverDirection.top ||
        calcDirection == PopoverDirection.bottom) {
      var bodyLeft = 0.0;

      if (attachRect.left > size.width / 2 &&
          Utils().screenWidth - attachRect.right > size.width / 2) {
        bodyLeft = attachRect.left + attachRect.width / 2 - size.width / 2;
      } else if (attachRect.left < size.width / 2) {
        bodyLeft = 10.0;
      } else {
        bodyLeft = Utils().screenWidth - 10.0 - size.width;
      }

      if (calcDirection == PopoverDirection.bottom) {
        return Offset(bodyLeft, attachRect.bottom);
      } else {
        return Offset(bodyLeft, attachRect.top - size.height);
      }
    } else {
      var bodyTop = 0.0;
      if (attachRect.top > size.height / 2 &&
          Utils().screenHeight - attachRect.bottom > size.height / 2) {
        bodyTop = attachRect.top + attachRect.height / 2 - size.height / 2;
      } else if (attachRect.top < size.height / 2) {
        bodyTop = 10.0;
      } else {
        bodyTop = Utils().screenHeight - 10.0 - size.height;
      }

      if (calcDirection == PopoverDirection.right) {
        return Offset(attachRect.right, bodyTop);
      } else {
        return Offset(attachRect.left - size.width, bodyTop);
      }
    }
  }

  @override
  void performLayout() {
    child.layout(
      _additionalConstraints.enforce(constraints),
      parentUsesSize: true,
    );
    size = Size(constraints.maxWidth, constraints.maxHeight);
    final BoxParentData childParentData = child.parentData;
    childParentData.offset = calcOffset(child.size);
  }
}
