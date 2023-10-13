import 'package:flutter/painting.dart';

import 'popover_direction.dart';

final class PopoverPath {
  final double radius;

  const PopoverPath(this.radius);

  Path draw(
    PopoverDirection? direction,
    Rect? arrowRect,
    Rect bodyRect,
  ) {
    final path = Path();

    if (arrowRect != null) {
      if (direction == PopoverDirection.top) {
        _drawTopElement(path, arrowRect, bodyRect);
      } else if (direction == PopoverDirection.right) {
        _drawRightElement(path, arrowRect, bodyRect);
      } else if (direction == PopoverDirection.left) {
        _drawLeftElement(path, arrowRect, bodyRect);
      } else {
        _drawBottomElement(path, arrowRect, bodyRect);
      }
      path.close();
      return path;
    } else {
      path.close();
      return path;
    }
  }

  void _drawBottomElement(Path path, Rect arrowRect, Rect bodyRect) {
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

  void _drawLeftElement(Path path, Rect arrowRect, Rect bodyRect) {
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
  }

  void _drawRightElement(Path path, Rect arrowRect, Rect bodyRect) {
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
  }

  void _drawTopElement(Path path, Rect arrowRect, Rect bodyRect) {
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
  }
}
