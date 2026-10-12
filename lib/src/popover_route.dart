import 'package:flutter/widgets.dart';

class PopoverRoute<T> extends RawDialogRoute<T> {
  /// If true, widgets behind the barrier can receive pointer events.
  final bool allowClicksOnBackground;

  @override
  final Duration reverseTransitionDuration;

  PopoverRoute({
    required super.pageBuilder,
    super.anchorPoint,
    super.barrierColor,
    super.barrierDismissible,
    super.barrierLabel,
    super.settings,
    super.transitionBuilder,
    super.transitionDuration,
    Duration? reverseTransitionDuration,
    super.traversalEdgeBehavior,
    super.requestFocus,
    this.allowClicksOnBackground = false,
  }) : reverseTransitionDuration =
           reverseTransitionDuration ?? transitionDuration;

  @override
  Widget buildModalBarrier() {
    return IgnorePointer(
      ignoring: allowClicksOnBackground,
      child: super.buildModalBarrier(),
    );
  }
}
