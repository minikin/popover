import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../popover.dart';
import 'popover_context.dart';
import 'popover_glass.dart';
import 'popover_position_widget.dart';
import 'popover_render_shifted_box.dart';
import 'resolved_popover_style.dart';
import 'utils/build_context_extension.dart';
import 'utils/popover_utils.dart';

class PopoverItem extends StatefulWidget {
  final Widget child;
  final ResolvedPopoverStyle style;
  final PopoverDirection? direction;
  final Animation<double> animation;
  final BoxConstraints? constraints;
  final BuildContext context;
  final double arrowDxOffset;
  final double arrowDyOffset;
  final double contentDyOffset;
  final double contentDxOffset;

  /// Fades the glass in the render object instead of in the route, see
  /// [PopoverRenderShiftedBox.opacity].
  final bool fadesGlass;

  const PopoverItem({
    required this.child,
    required this.context,
    required this.style,
    required this.animation,
    this.direction,
    this.constraints,
    this.arrowDxOffset = 0,
    this.arrowDyOffset = 0,
    this.contentDyOffset = 0,
    this.contentDxOffset = 0,
    this.fadesGlass = false,
    super.key,
  });

  @override
  _PopoverItemState createState() => _PopoverItemState();
}

class _PopoverItemState extends State<PopoverItem> {
  late Rect _attachRect;

  /// The route animation through the spring or fade curve, when the item
  /// springs or fades its glass.
  CurvedAnimation? _motion;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final insets = MediaQuery.viewInsetsOf(context);
    final screen = MediaQuery.sizeOf(context);
    final obscured = EdgeInsets.fromLTRB(
      math.max(padding.left, insets.left),
      math.max(padding.top, insets.top),
      math.max(padding.right, insets.right),
      math.max(padding.bottom, insets.bottom),
    );
    final bounds =
        (obscured + PopoverUtils.screenMargin(defaultTargetPlatform, screen))
            .deflateRect(Offset.zero & screen);
    final attachRect = PopoverUtils.clampToBounds(_attachRect, bounds);
    final style = widget.style;
    final brightness =
        style.brightness ?? MediaQuery.platformBrightnessOf(context);
    final glass = style.backgroundColor == null
        ? PopoverGlass.of(style.shape, brightness)
        : null;

    return Stack(
      children: [
        PopoverPositionWidget(
          attachRect: attachRect,
          bounds: bounds,
          constraints: widget.constraints,
          platform: defaultTargetPlatform,
          direction: widget.direction,
          arrowHeight: style.arrowHeight,
          child: AnimatedBuilder(
            animation: widget.animation,
            builder: (context, child) {
              final motion = style.motion;
              final progress = _motion?.value;
              return PopoverContext(
                attachRect: attachRect,
                scale: motion != null
                    ? lerpDouble(motion.startScale, 1, progress!)!
                    : style.transition == PopoverTransition.scale
                    ? widget.animation.value
                    : 1,
                reveal: motion != null && motion.grows ? progress! : 1,
                radius: style.radius,
                backgroundColor: style.solidColor(brightness),
                glass: glass,
                opacity: widget.fadesGlass ? _motion!.value : 1,
                boxShadow: style.shadow,
                direction: widget.direction,
                arrowWidth: style.arrowWidth,
                arrowHeight: style.arrowHeight,
                shape: style.shape,
                child: child,
              );
            },
            // The body repaints on its own layer, so scrolling or a blinking
            // cursor inside it does not repaint the outline and its shadow.
            child: RepaintBoundary(
              child: Listener(
                behavior: HitTestBehavior.opaque,
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _attachRect = _anchorRect() ?? Rect.zero;
    _followAnchor();
    final motion = widget.style.motion;
    if (motion != null || widget.fadesGlass) {
      _motion = CurvedAnimation(
        parent: widget.animation,
        curve: motion?.present ?? Curves.easeOut,
        reverseCurve: motion?.dismiss.flipped,
      );
    }
  }

  @override
  void dispose() {
    _motion?.dispose();
    super.dispose();
  }

  /// Re-places the popover after every frame in which the anchor moved, like
  /// `UIPopoverPresentationController` does for its source view.
  void _followAnchor() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final rect = _anchorRect();
      if (rect != null && rect != _attachRect) {
        setState(() => _attachRect = rect);
      }
      _followAnchor();
    });
  }

  Rect? _anchorRect() {
    if (!widget.context.mounted) return null;
    final anchor = globalRectOf(widget.context);
    if (anchor == null) return null;

    return Rect.fromLTWH(
      anchor.left + widget.arrowDxOffset,
      anchor.top + widget.arrowDyOffset,
      anchor.width + widget.contentDxOffset,
      anchor.height + widget.contentDyOffset,
    );
  }
}
