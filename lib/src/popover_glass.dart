import 'dart:ui' show Brightness, ImageFilter;

import 'package:flutter/painting.dart';

import 'popover_shape.dart';

/// The Liquid Glass background of iOS 26 and macOS 26 popovers: the content
/// behind the popover is blurred and recolored, and the outline is lit.
///
/// The values are fitted to screenshots of `UIPopoverPresentationController`
/// on an iOS 26 simulator and of `NSPopover` on macOS 26, over 22 solid
/// backgrounds and over a black and white edge. Native glass also bends the
/// light near the outline and adapts to the brightness of a wide area behind
/// it. A blur and a color matrix leave both out.
final class PopoverGlass {
  const PopoverGlass._({
    required this.sigma,
    required this.matrix,
    required this.rim,
  });

  /// The blur of the content behind the popover, in logical pixels.
  final double sigma;

  /// A [ColorFilter.matrix] applied to the blurred content. Alpha is always
  /// 255, so the popover stays opaque over transparent pixels.
  final List<double> matrix;

  /// The light along the inside of the outline, one logical pixel wide.
  final Color rim;

  /// The filter for the backdrop, faded toward no filter at all as
  /// [opacity] goes to 0.
  ///
  /// Impeller gives a backdrop filter inside an opacity layer an empty
  /// backdrop, so the glass cannot fade with an `Opacity` around it.
  ImageFilter filter([double opacity = 1]) {
    final sigma = this.sigma * opacity;
    return ImageFilter.compose(
      outer: ColorFilter.matrix(matrixAt(opacity)),
      inner: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
    );
  }

  /// [matrix] blended with the identity, all of it at an [opacity] of 1.
  List<double> matrixAt(double opacity) => [
    for (var i = 0; i < 20; i++)
      _identity[i] + (matrix[i] - _identity[i]) * opacity,
  ];

  static const _identity = <double>[
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  /// The glass of [shape] in [brightness], or null for
  /// [PopoverShape.triangle], which has none.
  static PopoverGlass? of(PopoverShape shape, Brightness brightness) =>
      switch ((shape, brightness)) {
        (PopoverShape.triangle, _) => null,
        (PopoverShape.ios, Brightness.light) => iosLight,
        (PopoverShape.ios, Brightness.dark) => iosDark,
        (PopoverShape.macos, Brightness.light) => macosLight,
        (PopoverShape.macos, Brightness.dark) => macosDark,
      };

  static const iosLight = PopoverGlass._(
    sigma: 7,
    matrix: [
      0.538, -0.264, -0.023, 0, 177.9, //
      -0.072, 0.332, -0.009, 0, 179.5,
      -0.092, -0.281, 0.613, 0, 178.8,
      0, 0, 0, 0, 255,
    ],
    rim: Color(0x80FFFFFF),
  );

  static const iosDark = PopoverGlass._(
    sigma: 9,
    matrix: [
      0.537, -0.244, -0.001, 0, 14.6, //
      -0.067, 0.349, -0.002, 0, 16.8,
      -0.066, -0.254, 0.603, 0, 14.8,
      0, 0, 0, 0, 255,
    ],
    rim: Color(0x1FFFFFFF),
  );

  static const macosLight = PopoverGlass._(
    sigma: 7,
    matrix: [
      0.513, -0.202, -0.052, 0, 184.9, //
      -0.036, 0.339, -0.026, 0, 182.3,
      -0.082, -0.268, 0.613, 0, 184.1,
      0, 0, 0, 0, 255,
    ],
    rim: Color(0x99FFFFFF),
  );

  static const macosDark = PopoverGlass._(
    sigma: 11,
    matrix: [
      0.558, -0.236, -0.027, 0, 18.9, //
      -0.053, 0.372, -0.019, 0, 17.4,
      -0.09, -0.28, 0.649, 0, 20.0,
      0, 0, 0, 0, 255,
    ],
    rim: Color(0x4DFFFFFF),
  );
}
