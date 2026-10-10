import 'package:flutter/widgets.dart';

import '../popover_direction.dart';

abstract class PopoverUtils {
  /// The gap Apple keeps between a popover and the safe area: 10 on iPhone,
  /// 19 at the sides, 30 at the top and 10 at the bottom on iPad, 12 on
  /// macOS. Other platforms use the iPhone gap.
  static EdgeInsets screenMargin(TargetPlatform platform, Size screenSize) {
    if (platform == TargetPlatform.macOS) return const EdgeInsets.all(12);
    if (platform == TargetPlatform.iOS && screenSize.shortestSide >= 600) {
      return const EdgeInsets.fromLTRB(19, 30, 19, 10);
    }
    return const EdgeInsets.all(10);
  }

  static const _tolerance = 0.01;

  /// Picks the side of [attachRect] for a popover with a body of [bodySize],
  /// the way Apple platforms do.
  ///
  /// The preferred [direction] wins when the popover fits there, then the
  /// opposite side. On macOS, like `NSPopover`, the two perpendicular sides
  /// come next. When nothing fits, the popover takes the preferred or the
  /// opposite side, whichever has more room, like
  /// `UIPopoverPresentationController`.
  static PopoverDirection popoverDirection({
    required Rect attachRect,
    required Size bodySize,
    required double arrowHeight,
    required PopoverDirection? direction,
    required Rect bounds,
    required TargetPlatform platform,
  }) {
    final preferred = direction ?? PopoverDirection.bottom;
    final opposite = _opposite(preferred);
    final candidates = [
      preferred,
      opposite,
      if (platform == TargetPlatform.macOS)
        ...(isVertical(preferred)
            ? const [PopoverDirection.right, PopoverDirection.left]
            : const [PopoverDirection.bottom, PopoverDirection.top]),
    ];

    for (final candidate in candidates) {
      final extent = isVertical(candidate)
          ? bodySize.height + arrowHeight
          : bodySize.width + arrowHeight;
      if (extent <=
          room(attachRect, candidate, bounds, platform) + _tolerance) {
        return candidate;
      }
    }

    return room(attachRect, opposite, bounds, platform) >
            room(attachRect, preferred, bounds, platform)
        ? opposite
        : preferred;
  }

  /// The space for the popover, arrow included, on [direction]'s side of
  /// [attachRect].
  ///
  /// Outside macOS, a popover on the left or the right may cover
  /// [attachRect] up to its center, as UIKit does.
  static double room(
    Rect attachRect,
    PopoverDirection direction,
    Rect bounds,
    TargetPlatform platform,
  ) {
    final coversHalf = platform != TargetPlatform.macOS;
    return switch (direction) {
      PopoverDirection.top => attachRect.top - bounds.top,
      PopoverDirection.bottom => bounds.bottom - attachRect.bottom,
      PopoverDirection.left =>
        (coversHalf ? attachRect.center.dx : attachRect.left) - bounds.left,
      PopoverDirection.right =>
        bounds.right - (coversHalf ? attachRect.center.dx : attachRect.right),
    };
  }

  static bool isVertical(PopoverDirection? direction) {
    return direction == null ||
        direction == PopoverDirection.top ||
        direction == PopoverDirection.bottom;
  }

  static PopoverDirection _opposite(PopoverDirection direction) {
    return switch (direction) {
      PopoverDirection.top => PopoverDirection.bottom,
      PopoverDirection.bottom => PopoverDirection.top,
      PopoverDirection.left => PopoverDirection.right,
      PopoverDirection.right => PopoverDirection.left,
    };
  }
}

/// Constraints that also carry the side [PopoverPositionRenderObject] picked
/// for the popover.
@immutable
final class PopoverConstraints extends BoxConstraints {
  final PopoverDirection direction;

  PopoverConstraints(BoxConstraints constraints, this.direction)
    : super(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        minHeight: constraints.minHeight,
        maxHeight: constraints.maxHeight,
      );

  @override
  bool operator ==(Object other) {
    return other is PopoverConstraints &&
        other.direction == direction &&
        super == other;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, direction);
}

typedef PopoverTransitionBuilder =
    Widget Function(Animation<double> animation, Widget child);
