import 'package:material_ui/material_ui.dart';

extension BuildContextExtension on BuildContext {
  static Rect? getWidgetBounds(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return (box != null) ? box.semanticBounds : null;
  }

  static Offset? getWidgetLocalToGlobal(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return (box != null) ? box.localToGlobal(Offset.zero) : null;
  }
}
