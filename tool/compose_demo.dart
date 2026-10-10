import 'dart:io';

import 'package:image/image.dart' as img;

/// Builds the README demo image from the integration test screenshots:
///
///     dart run tool/compose_demo.dart <screenshots dir> <output.png>
const _rows = [
  [
    ('iOS_phone', 'iPhone'),
    ('iOS_tablet', 'iPad'),
    ('android_phone', 'Android'),
  ],
  [
    ('macOS', 'macOS'),
    ('windows', 'Windows'),
    ('linux', 'Linux'),
    ('web', 'Web'),
  ],
];
const _width = 2400;
const _gap = 48;
const _label = 72;
const _outputWidth = 1600;

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('usage: compose_demo.dart <screenshots dir> <output.png>');
    exit(64);
  }
  final rows = [
    for (final row in _rows)
      [
        for (final (file, label) in row)
          if (_load('${args[0]}/${file}_demo.png') case final shot?)
            (shot, label),
      ],
  ].where((row) => row.isNotEmpty).toList();
  if (rows.isEmpty) {
    stderr.writeln('no *_demo.png screenshots in ${args[0]}');
    exit(1);
  }

  final heights = [
    for (final row in rows)
      ((_width - _gap * (row.length + 1)) /
              row.fold(
                0.0,
                (sum, tile) => sum + tile.$1.width / tile.$1.height,
              ))
          .floor(),
  ];
  final height =
      heights.fold(0, (sum, h) => sum + h + _label) + _gap * (rows.length + 1);
  final canvas = img.Image(width: _width, height: height)
    ..clear(img.ColorRgb8(255, 255, 255));

  var y = _gap;
  for (final (index, row) in rows.indexed) {
    final rowHeight = heights[index];
    final tiles = [
      for (final (shot, label) in row)
        (
          img.copyResize(
            shot,
            height: rowHeight,
            interpolation: img.Interpolation.average,
          ),
          label,
        ),
    ];
    final used = tiles.fold(0, (sum, tile) => sum + tile.$1.width);
    final spacing = (_width - used) ~/ (tiles.length + 1);
    var x = spacing;
    for (final (tile, label) in tiles) {
      img.drawRect(
        canvas,
        x1: x - 1,
        y1: y - 1,
        x2: x + tile.width,
        y2: y + tile.height,
        color: img.ColorRgb8(210, 210, 210),
        thickness: 2,
      );
      img.compositeImage(canvas, tile, dstX: x, dstY: y);
      img.drawString(
        canvas,
        label,
        font: img.arial48,
        x: x + tile.width ~/ 2 - label.length * 12,
        y: y + tile.height + 12,
        color: img.ColorRgb8(40, 40, 40),
      );
      x += tile.width + spacing;
    }
    y += rowHeight + _label + _gap;
  }

  final output = img.copyResize(
    canvas,
    width: _outputWidth,
    interpolation: img.Interpolation.average,
  );
  File(args[1]).writeAsBytesSync(img.encodePng(output, level: 9));
}

img.Image? _load(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('missing $path');
    return null;
  }
  return img.decodePng(file.readAsBytesSync());
}
