import 'package:flutter/material.dart';

class PopoverRoute<T> extends RawDialogRoute<T> {
  /// If true, widgets behind the barrier can receive pointer events.
  final bool allowClicksOnBackground;

  PopoverRoute({
    required super.pageBuilder,
    super.anchorPoint,
    super.barrierColor,
    super.barrierDismissible,
    super.barrierLabel,
    super.settings,
    super.transitionBuilder,
    super.transitionDuration,
    super.traversalEdgeBehavior,
    this.allowClicksOnBackground = false,
  });

  @override
  Widget buildModalBarrier() {
    return IgnorePointer(
      ignoring: allowClicksOnBackground,
      child: super.buildModalBarrier(),
    );
  }
}
