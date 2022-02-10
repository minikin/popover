import 'package:flutter/material.dart';

import '../popover_direction.dart';
import '../popover_transition.dart';
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
            : PopoverDirection.top;
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

  static Widget popoverTransitionWidget(
      {required PopoverTransition transition,
      required CurvedAnimation animation,
      required Widget child}) {
    switch (transition) {
      case PopoverTransition.fadeTransition:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case PopoverTransition.sizeTransition:
        return SizeTransition(
          sizeFactor: animation,
          child: child,
        );
      case PopoverTransition.rotationTransition:
        return RotationTransition(
          turns: animation,
          child: child,
        );

      default:
        return ScaleTransition(
          scale: animation,
          child: child,
        );
    }
  }
}
