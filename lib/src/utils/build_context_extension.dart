import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  static Rect getWidgetBounds(BuildContext context) {
    final RenderBox box = context.findRenderObject();
    return (box != null && box.semanticBounds != null)
        ? box.semanticBounds
        : Rect.zero;
  }

  static Offset getWidgetLocalToGlobal(BuildContext context) {
    final RenderBox box = context.findRenderObject();
    return box == null ? Offset.zero : box.localToGlobal(Offset.zero);
  }
}
