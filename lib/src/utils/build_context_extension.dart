import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  static Rect getWidgetBounds(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return (box != null) ? box.semanticBounds : Rect.zero;
  }

  static Offset getWidgetLocalToGlobal(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return box == null ? Offset.zero : box.localToGlobal(Offset.zero);
  }
}
