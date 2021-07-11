import 'package:flutter/material.dart';

import '../popover_direction.dart';
import 'utils.dart';

abstract class PopoverUtils {
  static PopoverDirection popoverDirection(
    Rect? attachRect,
    Size size,
    PopoverDirection? direction,
    double? arrowHeight,
  ) {
    switch (direction) {
      case PopoverDirection.top:
        return (attachRect!.top < size.height + arrowHeight!)
            ? PopoverDirection.bottom
            : PopoverDirection.top;
      case PopoverDirection.bottom:
        return Utils().screenHeight >
                attachRect!.bottom + size.height + arrowHeight!
            ? PopoverDirection.bottom
            : (attachRect.bottom > size.height + arrowHeight ?
        PopoverDirection.top : PopoverDirection.left);
      case PopoverDirection.left:
        return (attachRect!.left < size.width + arrowHeight!)
            ? PopoverDirection.right
            : PopoverDirection.left;
      case PopoverDirection.right:
        return Utils().screenWidth >
                attachRect!.right + size.width + arrowHeight!
            ? PopoverDirection.right
            : PopoverDirection.left;
      default:
        return PopoverDirection.bottom;
    }
  }
}
