import 'package:flutter/widgets.dart';

/// The global rect of the render box of [context], or null while it has no
/// laid-out box, for example under `Visibility(maintainState: true)`.
Rect? globalRectOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.attached || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}
