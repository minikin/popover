import 'package:flutter/painting.dart';

import 'popover_direction.dart';

/// Receives the elements of a popover outline. [Path] is adapted with
/// [PathPopoverSink], tests record the elements.
abstract interface class PopoverPathSink {
  void moveTo(double x, double y);

  void lineTo(double x, double y);

  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  );

  void close();
}

final class PathPopoverSink implements PopoverPathSink {
  final Path path;

  PathPopoverSink(this.path);

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void close() => path.close();
}

/// The outline UIKit draws for a popover on iOS 26: Apple's continuous corners
/// and an arrow with a rounded tip that flows into the body.
///
/// The construction repeats the mask path of `UIPopoverPresentationController`
/// element for element, including UIKit's quirks, so the shape matches the
/// native one at any size. At the default 26 by 13 arrow every number below is
/// in points; other sizes scale the arrow along and across its edge.
final class ApplePopoverPath {
  final double arrowWidth;
  final double arrowHeight;
  final double radius;

  const ApplePopoverPath({
    required this.arrowWidth,
    required this.arrowHeight,
    required this.radius,
  });

  /// Apple's continuous corner, in multiples of the corner radius.
  static const _k0 = 1.528665;
  static const _k1 = 1.08849296;
  static const _k2 = 0.86840689;
  static const _k3 = 0.63149379;
  static const _k4 = 0.07491139;
  static const _k5 = 0.37282383;
  static const _k6 = 0.16905956;

  /// UIKit ends the line of a top edge without the arrow this far past the
  /// corner radius.
  static const _topEdgeExtra = 32.0;

  /// Builds a [Path] for a popover filling [frame], arrow included, that
  /// opens on the [direction] side of its anchor. [tip] is the coordinate of
  /// the arrow tip along the edge the arrow sits on.
  Path toPath({
    required Rect frame,
    required PopoverDirection direction,
    required double tip,
  }) {
    final path = Path();
    build(PathPopoverSink(path), frame: frame, direction: direction, tip: tip);
    return path;
  }

  void build(
    PopoverPathSink sink, {
    required Rect frame,
    required PopoverDirection direction,
    required double tip,
  }) {
    final arrowEdge = switch (direction) {
      PopoverDirection.bottom => _Edge.top,
      PopoverDirection.top => _Edge.bottom,
      PopoverDirection.right => _Edge.left,
      PopoverDirection.left => _Edge.right,
    };
    final body = switch (arrowEdge) {
      _Edge.top => Rect.fromLTRB(
        frame.left,
        frame.top + arrowHeight,
        frame.right,
        frame.bottom,
      ),
      _Edge.bottom => Rect.fromLTRB(
        frame.left,
        frame.top,
        frame.right,
        frame.bottom - arrowHeight,
      ),
      _Edge.left => Rect.fromLTRB(
        frame.left + arrowHeight,
        frame.top,
        frame.right,
        frame.bottom,
      ),
      _Edge.right => Rect.fromLTRB(
        frame.left,
        frame.top,
        frame.right - arrowHeight,
        frame.bottom,
      ),
    };
    final r = _min(radius, _min(frame.width, frame.height) / 2 / _k0);
    final w = arrowWidth / 26;
    final h = arrowHeight / 13;

    final d = arrowEdge.travel;
    final n = arrowEdge.outward;
    final base = arrowEdge.pointAt(body, tip);
    Offset along(double a, [double out = 0]) =>
        base + d * (a * w) + n * (out * h);

    void move(Offset p) => sink.moveTo(p.dx, p.dy);
    void line(Offset p) => sink.lineTo(p.dx, p.dy);
    void cubic(Offset a, Offset b, Offset c) =>
        sink.cubicTo(a.dx, a.dy, b.dx, b.dy, c.dx, c.dy);

    void corner(Offset q, Offset dIn, Offset dOut) {
      final u = -dIn;
      final v = dOut;
      final p1 = q + u * (_k3 * r) + v * (_k4 * r);
      cubic(q + u * (_k1 * r), q + u * (_k2 * r), p1);
      line(p1);
      cubic(
        q + u * (_k5 * r) + v * (_k6 * r),
        q + u * (_k6 * r) + v * (_k5 * r),
        q + u * (_k4 * r) + v * (_k3 * r),
      );
      cubic(q + v * (_k2 * r), q + v * (_k1 * r), q + v * (_k0 * r));
    }

    final start = along(-18.5);
    move(start);
    cubic(along(-13), along(-13), along(-7.5, 6));
    line(along(-2, 12));
    cubic(along(0, 13), along(0, 13), along(2, 12));
    line(along(7.5, 6));
    cubic(along(13), along(13), along(18.5));

    // UIKit squashes at most one corner next to the arrow: the nearer one, and
    // only when the arrow base is closer to it than the corner radius.
    final out = arrowEdge.next;
    final outCorner = arrowEdge.endCorner(body);
    final baseEnd = along(13);
    final baseStart = along(-13);
    final inCorner = arrowEdge.previous.endCorner(body);
    final toOut = (outCorner - baseEnd).distance;
    final toIn = (baseStart - inCorner).distance;
    final squashOut = toOut < r && toOut < toIn;
    final squashIn = toIn < r && toIn < toOut;
    if (squashOut) {
      line(baseEnd);
      cubic(outCorner, outCorner, outCorner + out.travel * r);
    } else {
      corner(outCorner, d, out.travel);
    }

    var edge = out;
    for (var i = 0; i < 2; i++) {
      final q = edge.endCorner(body);
      line(edge.lineEnd(q, r));
      corner(q, edge.travel, edge.next.travel);
      edge = edge.next;
    }

    line(edge.lineEnd(inCorner, r));
    if (squashIn) {
      cubic(inCorner, inCorner, baseStart);
    } else {
      corner(inCorner, edge.travel, d);
      line(start);
    }
    sink.close();
  }

  static double _min(double a, double b) => a < b ? a : b;
}

/// The edges of the body in the order UIKit walks them, counterclockwise on
/// screen.
enum _Edge {
  top(Offset(-1, 0), Offset(0, -1)),
  left(Offset(0, 1), Offset(-1, 0)),
  bottom(Offset(1, 0), Offset(0, 1)),
  right(Offset(0, -1), Offset(1, 0));

  final Offset travel;
  final Offset outward;

  const _Edge(this.travel, this.outward);

  _Edge get next => _Edge.values[(index + 1) % _Edge.values.length];

  _Edge get previous => _Edge.values[(index + 3) % _Edge.values.length];

  Offset endCorner(Rect body) => switch (this) {
    _Edge.top => body.topLeft,
    _Edge.left => body.bottomLeft,
    _Edge.bottom => body.bottomRight,
    _Edge.right => body.topRight,
  };

  Offset pointAt(Rect body, double along) => switch (this) {
    _Edge.top => Offset(along, body.top),
    _Edge.bottom => Offset(along, body.bottom),
    _Edge.left => Offset(body.left, along),
    _Edge.right => Offset(body.right, along),
  };

  /// Where UIKit ends the straight part of this edge before corner [q].
  Offset lineEnd(Offset q, double r) => switch (this) {
    _Edge.top => q - travel * (r + ApplePopoverPath._topEdgeExtra),
    _ => q - travel * r,
  };
}
