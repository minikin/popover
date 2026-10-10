import 'dart:math' as math;

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

/// The outline AppKit draws for an `NSPopover` on macOS 26: Apple's
/// continuous corners with a 20 point radius and an arrow whose tip is an arc
/// and whose base is filleted into the body.
///
/// The construction repeats the mask path of the popover frame, dumped from
/// macOS 26.7, element for element. A body too small for the full corner
/// squeezes it towards a circle, and next to a corner the arrow's near
/// fillet, the straight run and the first corner cubics become one cubic, as
/// in AppKit. At the default 25.42 by 13 arrow every number below is in
/// points.
final class MacPopoverPath {
  final double arrowWidth;
  final double arrowHeight;
  final double radius;

  const MacPopoverPath({
    required this.arrowWidth,
    required this.arrowHeight,
    required this.radius,
  });

  /// The right half of the arrow relative to the tip, y down from the frame
  /// edge: the fillet's end on the body edge and its two handles, the end of
  /// the flank, the tip arc's tangent point and the tip arc from there to its
  /// mirror image.
  static const _filletEnd = Offset(15.992523, 13);
  static const _filletHandleOnEdge = Offset(13.893326, 13);
  static const _filletHandleOnFlank = Offset(11.882751, 12.153877);
  static const _flankEnd = Offset(10.415237, 10.652870);
  static const _tipTangent = Offset(3.904099, 3.993179);
  static const _tipArc = [
    Offset(1.796021, 1.837006),
    Offset(-1.660828, 1.798012),
    Offset(-3.817017, 3.906090),
    Offset(-3.846375, 3.934792),
    Offset(-3.875397, 3.963821),
    Offset(-3.904099, 3.993179),
  ];

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
    final vertical =
        direction == PopoverDirection.top ||
        direction == PopoverDirection.bottom;
    // The path is built with the arrow on the top edge of a canvas that is
    // `width` along the arrow edge and `height` across it, then mapped.
    final width = vertical ? frame.width : frame.height;
    final height = vertical ? frame.height : frame.width;
    final along = tip - (vertical ? frame.left : frame.top);
    final map = switch (direction) {
      PopoverDirection.bottom => (Offset p) => frame.topLeft + p,
      PopoverDirection.top => (Offset p) => Offset(
        frame.left + p.dx,
        frame.bottom - p.dy,
      ),
      PopoverDirection.right => (Offset p) => Offset(
        frame.left + p.dy,
        frame.top + p.dx,
      ),
      PopoverDirection.left => (Offset p) => Offset(
        frame.right - p.dy,
        frame.top + p.dx,
      ),
    };

    final segments = _canonical(width, height, along);
    final start = map(segments.first.end);
    sink.moveTo(start.dx, start.dy);
    for (final segment in segments.skip(1)) {
      final end = map(segment.end);
      if (segment.c1 == null) {
        sink.lineTo(end.dx, end.dy);
      } else {
        final c1 = map(segment.c1!);
        final c2 = map(segment.c2!);
        sink.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
      }
    }
    sink.close();
  }

  /// Segments of the outline with the arrow on the top edge, starting with a
  /// move to the right end of the arrow tip.
  List<_Segment> _canonical(double width, double height, double tip) {
    final w = arrowWidth / 25.42;
    final h = arrowHeight / 13;
    final top = arrowHeight;
    final bodyHeight = height - top;
    // AppKit rounds half the shorter side down and keeps the radius a point
    // under that.
    final limit = (_min(width, bodyHeight) / 2).floorToDouble() - 1;
    final r = limit > 0 ? _min(radius, limit) : 0.0;
    final alongTop = _CornerHalf.of(width / 2, r);
    final alongSide = _CornerHalf.of(bodyHeight / 2, r);

    Offset arrow(Offset p) => Offset(tip + p.dx * w, p.dy * h);
    Offset mirrored(Offset p) => Offset(-p.dx, p.dy);

    final topLeft = _corner(
      Offset(0, top),
      const Offset(-1, 0),
      const Offset(0, 1),
      alongTop,
      alongSide,
    );
    final topRight = _corner(
      Offset(width, top),
      const Offset(0, -1),
      const Offset(-1, 0),
      alongSide,
      alongTop,
    );
    final bottomLeft = _corner(
      Offset(0, height),
      const Offset(0, 1),
      const Offset(1, 0),
      alongSide,
      alongTop,
    );
    final bottomRight = _corner(
      Offset(width, height),
      const Offset(1, 0),
      const Offset(0, -1),
      alongTop,
      alongSide,
    );
    final left = _side((p) => arrow(mirrored(p)), topLeft);
    final right = _side(arrow, topRight.reversed.toList());

    return [
      _Segment.line(arrow(_tipTangent)),
      _Segment.cubic(arrow(_tipArc[0]), arrow(_tipArc[1]), arrow(_tipArc[2])),
      _Segment.cubic(arrow(_tipArc[3]), arrow(_tipArc[4]), arrow(_tipArc[5])),
      _Segment.line(arrow(mirrored(_flankEnd))),
      ...left,
      _Segment.line(bottomLeft.first),
      ..._cubics(bottomLeft),
      _Segment.line(bottomRight.first),
      ..._cubics(bottomRight),
      _Segment.line(right.last.end),
      ..._reversed(right, arrow(_flankEnd)),
      _Segment.line(arrow(_tipTangent)),
    ];
  }

  /// One side of the arrow from the end of its flank into the corner there.
  /// [arrow] places arrow points, mirrored for the left side, and [corner]
  /// holds the corner's points walking away from the arrow.
  List<_Segment> _side(Offset Function(Offset) arrow, List<Offset> corner) {
    final flankEnd = arrow(_flankEnd);
    final filletEnd = arrow(_filletEnd);
    final filletChord = flankEnd - filletEnd;

    // AppKit drops every corner cubic that starts past the fillet's end,
    // past meaning on the arrow's side of the line through the fillet's end
    // at right angles to the fillet's chord.
    var dropped = 0;
    while (dropped < 3 &&
        _dot(corner[3 * dropped] - filletEnd, filletChord) > 0) {
      dropped++;
    }
    if (dropped == 0) {
      return [
        _Segment.cubic(
          arrow(_filletHandleOnFlank),
          arrow(_filletHandleOnEdge),
          filletEnd,
        ),
        _Segment.line(corner.first),
        ..._cubics(corner),
      ];
    }

    // The fillet, the straight run and the dropped cubics become one cubic
    // from the flank's end to the end of the last dropped cubic. Its handles
    // point like the fillet's first and that cubic's last, with the same
    // handle to chord ratios.
    final end = corner[3 * dropped];
    final chord = (end - flankEnd).distance;
    final flank = flankEnd - arrow(_tipTangent);
    final filletHandle = (arrow(_filletHandleOnFlank) - flankEnd).distance;
    final start =
        flankEnd +
        flank / flank.distance * (filletHandle / filletChord.distance * chord);
    final tangent = end - corner[3 * dropped - 1];
    final cornerChord = (end - corner[3 * dropped - 3]).distance;
    final finish = cornerChord > 0
        ? end - tangent * (chord / cornerChord)
        : end;
    return [
      _Segment.cubic(start, finish, end),
      ..._cubics(corner.sublist(3 * dropped)),
    ];
  }

  /// The ten points of the corner at [q], entered along [dIn] and left along
  /// [dOut]. The first cubic and the across parts of the middle cubic's
  /// handles follow the entry edge, the rest the exit edge, as in AppKit.
  static List<Offset> _corner(
    Offset q,
    Offset dIn,
    Offset dOut,
    _CornerHalf entry,
    _CornerHalf exit,
  ) {
    Offset at(double alongEntry, double alongExit) =>
        q - dIn * alongEntry + dOut * alongExit;
    return [
      for (var i = 0; i < 5; i++) at(entry.along[i], entry.across[i]),
      at(entry.across[4], exit.along[4]),
      for (var i = 3; i >= 0; i--) at(exit.across[i], exit.along[i]),
    ];
  }

  /// The cubics through [points], one per three points after the first.
  static List<_Segment> _cubics(List<Offset> points) => [
    for (var i = 1; i + 2 < points.length; i += 3)
      _Segment.cubic(points[i], points[i + 1], points[i + 2]),
  ];

  /// [side] runs from [flankEnd] outward to where the side edge starts.
  /// Returns it walked back from that point to [flankEnd].
  static List<_Segment> _reversed(List<_Segment> side, Offset flankEnd) {
    return [
      for (var i = side.length - 1; i >= 0; i--)
        _reverse(side[i], i == 0 ? flankEnd : side[i - 1].end),
    ];
  }

  static _Segment _reverse(_Segment segment, Offset to) => segment.c1 == null
      ? _Segment.line(to)
      : _Segment.cubic(segment.c2!, segment.c1!, to);

  static double _dot(Offset a, Offset b) => a.dx * b.dx + a.dy * b.dy;

  static double _min(double a, double b) => a < b ? a : b;
}

/// The half of a corner next to one edge, as distances from the corner point
/// along that edge and across it: the point on the edge, the two handles of
/// the first cubic, its end and the first handle of the middle cubic.
final class _CornerHalf {
  final List<double> along;
  final List<double> across;

  const _CornerHalf(this.along, this.across);

  /// Apple's continuous corner for radius 1.
  static const continuous = _CornerHalf(
    [
      ApplePopoverPath._k0,
      ApplePopoverPath._k1,
      ApplePopoverPath._k2,
      ApplePopoverPath._k3,
      ApplePopoverPath._k5,
    ],
    [0, 0, 0, ApplePopoverPath._k4, ApplePopoverPath._k6],
  );

  /// A circle for radius 1 in three arcs, split at the angle where the
  /// continuous corner's first cubic ends.
  static final circular = _circle();

  static _CornerHalf _circle() {
    final split = math.atan2(
      1 - ApplePopoverPath._k3,
      1 - ApplePopoverPath._k4,
    );
    final first = 4 / 3 * math.tan(split / 4);
    final middle = 4 / 3 * math.tan((math.pi / 2 - 2 * split) / 4);
    final s = math.sin(split);
    final c = math.cos(split);
    return _CornerHalf(
      [1, 1 - first, 1 - s + first * c, 1 - s, 1 - s - middle * c],
      [0, 0, 1 - c - first * s, 1 - c, 1 - c + middle * s],
    );
  }

  /// The half for radius [r] on an edge reaching [half] from its middle to
  /// the corner: the continuous corner where it fits, else moved towards the
  /// circle in proportion to the shortfall, until it reaches the circle when
  /// the edge is as short as the radius.
  factory _CornerHalf.of(double half, double r) {
    const k0 = ApplePopoverPath._k0;
    final t = r > 0 ? ((k0 * r - half) / ((k0 - 1) * r)).clamp(0.0, 1.0) : 0.0;
    List<double> mix(List<double> a, List<double> b) => [
      for (var i = 0; i < a.length; i++) (a[i] + (b[i] - a[i]) * t) * r,
    ];
    return _CornerHalf(
      mix(continuous.along, circular.along),
      mix(continuous.across, circular.across),
    );
  }
}

final class _Segment {
  final Offset? c1;
  final Offset? c2;
  final Offset end;

  const _Segment.line(this.end) : c1 = null, c2 = null;

  const _Segment.cubic(Offset this.c1, Offset this.c2, this.end);
}
