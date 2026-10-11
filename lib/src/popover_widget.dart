import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'popover.dart';
import 'popover_arrow_style.dart';
import 'popover_direction.dart';
import 'popover_route.dart';
import 'popover_transition.dart';
import 'utils/popover_utils.dart';

/// Opens and closes a [Popover].
///
/// [isOpen] also turns false when the user closes the popover, by tapping the
/// barrier, pressing Esc or going back.
class PopoverController extends ChangeNotifier {
  PopoverController({bool isOpen = false}) : _isOpen = isOpen;

  bool _isOpen;

  /// Whether the popover is open or opening.
  bool get isOpen => _isOpen;

  void show() => _set(true);

  void hide() => _set(false);

  void toggle() => _set(!_isOpen);

  void _set(bool value) {
    if (_isOpen == value) return;
    _isOpen = value;
    notifyListeners();
  }
}

/// Shows [content] in a popover anchored to [child] while [controller] is
/// open.
///
/// The other arguments are the ones of [showPopover], except its `key` and
/// the deprecated `isParentAlive`. They apply when the popover opens, so a
/// change to them shows the next time it opens. A new [content] rebuilds an
/// open popover.
///
/// When this widget leaves the tree, its popover closes at once, without the
/// closing animation. [PopoverController.isOpen] stays true, so a [Popover]
/// with the same controller opens again when it is inserted.
///
/// ```dart
/// final controller = PopoverController();
///
/// Popover(
///   controller: controller,
///   content: (context) => const Text('Hello'),
///   child: TextButton(
///     onPressed: controller.toggle,
///     child: const Text('Open'),
///   ),
/// );
/// ```
class Popover extends StatefulWidget {
  const Popover({
    required this.controller,
    required this.content,
    required this.child,
    this.direction = PopoverDirection.bottom,
    this.transition = PopoverTransition.scale,
    this.arrowStyle = PopoverArrowStyle.adaptive,
    this.backgroundColor,
    this.brightness,
    this.barrierColor,
    this.transitionDuration,
    this.radius,
    this.shadow,
    this.arrowWidth,
    this.arrowHeight,
    this.arrowDxOffset = 0,
    this.arrowDyOffset = 0,
    this.contentDxOffset = 0,
    this.contentDyOffset = 0,
    this.barrierDismissible = true,
    this.width,
    this.height,
    this.constraints,
    this.requestFocus,
    this.routeSettings,
    this.barrierLabel,
    this.semanticsLabel,
    this.popoverTransitionBuilder,
    this.allowClicksOnBackground = false,
    this.onPop,
    super.key,
  });

  final PopoverController controller;

  /// Builds the body of the popover.
  final WidgetBuilder content;

  /// The anchor the popover points at.
  final Widget child;

  /// Runs when the popover pops, however it was closed, while this widget is
  /// in the tree.
  final VoidCallback? onPop;

  final PopoverDirection direction;
  final PopoverTransition transition;
  final PopoverArrowStyle arrowStyle;
  final Color? backgroundColor;
  final Brightness? brightness;
  final Color? barrierColor;
  final Duration? transitionDuration;
  final double? radius;
  final List<BoxShadow>? shadow;
  final double? arrowWidth;
  final double? arrowHeight;
  final double arrowDxOffset;
  final double arrowDyOffset;
  final double contentDxOffset;
  final double contentDyOffset;
  final bool barrierDismissible;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final bool? requestFocus;
  final RouteSettings? routeSettings;
  final String? barrierLabel;
  final String? semanticsLabel;
  final PopoverTransitionBuilder? popoverTransitionBuilder;
  final bool allowClicksOnBackground;

  @override
  State<Popover> createState() => _PopoverState();
}

class _PopoverState extends State<Popover> {
  /// The open popover, null once it is closing or closed.
  PopoverRoute<Object?>? _route;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
    if (widget.controller.isOpen) _sync();
  }

  @override
  void didUpdateWidget(Popover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_sync);
      widget.controller.addListener(_sync);
      _sync();
    }
    // The popover lives in an overlay entry, which cannot rebuild while this
    // widget builds.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _route?.changedExternalState();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    // The tree is locked while this state is disposed, and the closing
    // popover must not reach back to its unmounted anchor.
    final route = _route;
    _route = null;
    if (route != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (route.isActive) route.navigator!.removeRoute(route);
      });
    }
    super.dispose();
  }

  void _sync() {
    if (widget.controller.isOpen == (_route != null)) return;
    // A route cannot be pushed or popped while the tree builds.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sync();
      });
      return;
    }
    widget.controller.isOpen ? _show() : _close();
  }

  void _show() {
    final route = popoverRoute<Object?>(
      context: context,
      bodyBuilder: (context) => widget.content(context),
      direction: widget.direction,
      transition: widget.transition,
      arrowStyle: widget.arrowStyle,
      backgroundColor: widget.backgroundColor,
      brightness: widget.brightness,
      barrierColor: widget.barrierColor,
      transitionDuration: widget.transitionDuration,
      radius: widget.radius,
      shadow: widget.shadow,
      arrowWidth: widget.arrowWidth,
      arrowHeight: widget.arrowHeight,
      arrowDxOffset: widget.arrowDxOffset,
      arrowDyOffset: widget.arrowDyOffset,
      contentDxOffset: widget.contentDxOffset,
      contentDyOffset: widget.contentDyOffset,
      barrierDismissible: widget.barrierDismissible,
      width: widget.width,
      height: widget.height,
      constraints: widget.constraints,
      requestFocus: widget.requestFocus,
      routeSettings: widget.routeSettings,
      barrierLabel: widget.barrierLabel,
      semanticsLabel: widget.semanticsLabel,
      popoverTransitionBuilder: widget.popoverTransitionBuilder,
      allowClicksOnBackground: widget.allowClicksOnBackground,
    );
    _route = route;
    Navigator.of(context, rootNavigator: true).push(route).whenComplete(() {
      if (!mounted) return;
      widget.onPop?.call();
      // Closed by the user, not by [_close] or a newer popover.
      if (_route == route) {
        _route = null;
        widget.controller.hide();
      }
    });
  }

  void _close() {
    final route = _route;
    _route = null;
    if (route == null || !route.isActive) return;
    final navigator = route.navigator!;
    if (route.isCurrent) {
      navigator.pop();
    } else {
      navigator.removeRoute(route);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
