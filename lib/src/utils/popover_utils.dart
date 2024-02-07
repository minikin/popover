import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../popover_direction.dart';

abstract class PopoverUtils {
  static PopoverDirection popoverDirection(
    Rect attachRect,
    Size size,
    double arrowHeight,
    PopoverDirection? direction,
  ) {
    switch (direction) {
      case PopoverDirection.top:
        return (attachRect.top < size.height + arrowHeight)
            ? PopoverDirection.bottom
            : PopoverDirection.top;
      case PopoverDirection.bottom:
        return physicalSize.height >
                attachRect.bottom + size.height + arrowHeight
            ? PopoverDirection.bottom
            : PopoverDirection.top;
      case PopoverDirection.left:
        return (attachRect.left < size.width + arrowHeight)
            ? PopoverDirection.right
            : PopoverDirection.left;
      case PopoverDirection.right:
        return physicalSize.width > attachRect.right + size.width + arrowHeight
            ? PopoverDirection.right
            : PopoverDirection.left;
      default:
        return PopoverDirection.bottom;
    }
  }

  static Size get physicalSize =>
      PlatformDispatcher.instance.views.first.physicalSize /
      PlatformDispatcher.instance.views.first.devicePixelRatio;
}

typedef PopoverTransitionBuilder = Widget Function(
  Animation<double> animation,
  Widget child,
);
