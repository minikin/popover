import 'package:flutter/material.dart';
import 'package:popover/src/popover_direction.dart';
import 'package:popover/src/utils/utils.dart';

class PopoverUtils {
  static const double arrowWidth = 12;
  static const double arrowHeight = 8;

  PopoverUtils._();

  static PopoverDirection reCalculatePopoverDirection(
    Rect attachRect,
    Size size,
    PopoverDirection direction,
  ) {
    switch (direction) {
      case PopoverDirection.top:
        return (attachRect.top < size.height + arrowHeight)
            ? PopoverDirection.bottom
            : PopoverDirection.top;
      case PopoverDirection.bottom:
        return Utils().screenHeight >
                attachRect.bottom + size.height + arrowHeight
            ? PopoverDirection.bottom
            : PopoverDirection.top;
      case PopoverDirection.left:
        return (attachRect.left < size.width + arrowHeight)
            ? PopoverDirection.right
            : PopoverDirection.left;
      case PopoverDirection.right:
        return Utils().screenWidth > attachRect.right + size.width + arrowHeight
            ? PopoverDirection.right
            : PopoverDirection.left;
      default:
        return direction;
    }
  }
}
