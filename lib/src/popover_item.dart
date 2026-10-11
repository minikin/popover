import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../popover.dart';
import 'popover_context.dart';
import 'popover_glass.dart';
import 'popover_motion.dart';
import 'popover_position_widget.dart';
import 'popover_render_shifted_box.dart';
import 'popover_shape.dart';
import 'utils/build_context_extension.dart';
import 'utils/popover_utils.dart';

class PopoverItem extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final Brightness? brightness;
  final PopoverDirection? direction;
  final double? radius;
  final List<BoxShadow>? boxShadow;
  final Animation<double> animation;
  final double? arrowWidth;
  final double arrowHeight;
  final PopoverShape shape;
  final BoxConstraints? constraints;
  final BuildContext context;
  final double arrowDxOffset;
  final double arrowDyOffset;
  final double contentDyOffset;
  final double contentDxOffset;
  final PopoverTransition transition;

  /// Fades the glass in the render object instead of in the route, see
  /// [PopoverRenderShiftedBox.opacity].
  final bool fadesGlass;

  const PopoverItem({
    required this.child,
    required this.context,
    required this.transition,
    required this.animation,
    required this.arrowHeight,
    this.shape = PopoverShape.triangle,
    this.backgroundColor,
    this.brightness,
    this.direction,
    this.radius,
    this.boxShadow,
    this.arrowWidth,
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

  /// The route animation through the fade or spring curve, when the item
  /// fades its glass or springs.
  CurvedAnimation? _motion;

  /// [_motion] for an iOS popover that scales in, null otherwise.
  CurvedAnimation? _spring;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final obscured = EdgeInsets.fromLTRB(
      math.max(media.padding.left, media.viewInsets.left),
      math.max(media.padding.top, media.viewInsets.top),
      math.max(media.padding.right, media.viewInsets.right),
      math.max(media.padding.bottom, media.viewInsets.bottom),
    );
    final bounds =
        (obscured +
                PopoverUtils.screenMargin(defaultTargetPlatform, media.size))
            .deflateRect(Offset.zero & media.size);
    final attachRect = PopoverUtils.clampToBounds(_attachRect, bounds);
    final brightness =
        widget.brightness ?? MediaQuery.platformBrightnessOf(context);
    final backgroundColor = widget.backgroundColor;
    final glass = backgroundColor == null
        ? PopoverGlass.of(widget.shape, brightness)
        : null;

    return Stack(
      children: [
        PopoverPositionWidget(
          attachRect: attachRect,
          bounds: bounds,
          constraints: widget.constraints,
          platform: defaultTargetPlatform,
          direction: widget.direction,
          arrowHeight: widget.arrowHeight,
          child: AnimatedBuilder(
            animation: widget.animation,
            builder: (context, child) {
              final spring = _spring?.value;
              return PopoverContext(
                attachRect: attachRect,
                scale: spring != null
                    ? lerpDouble(IosPopoverMotion.startScale, 1, spring)!
                    : widget.transition == PopoverTransition.scale
                    ? widget.animation.value
                    : 1,
                reveal: spring ?? 1,
                radius: widget.radius,
                backgroundColor:
                    backgroundColor ??
                    (brightness == Brightness.dark
                        ? const Color(0xFF2C2C2E)
                        : const Color(0xFFFFFFFF)),
                glass: glass,
                opacity: widget.fadesGlass ? _motion!.value : 1,
                boxShadow: widget.boxShadow,
                direction: widget.direction,
                arrowWidth: widget.arrowWidth,
                arrowHeight: widget.arrowHeight,
                shape: widget.shape,
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
    final spring =
        widget.shape == PopoverShape.ios &&
        widget.transition == PopoverTransition.scale;
    if (spring || widget.fadesGlass) {
      _motion = CurvedAnimation(
        parent: widget.animation,
        curve: spring ? IosPopoverMotion.present : Curves.easeOut,
        reverseCurve: spring ? IosPopoverMotion.dismiss.flipped : null,
      );
      if (spring) _spring = _motion;
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
    final offset = BuildContextExtension.getWidgetLocalToGlobal(widget.context);
    final bounds = BuildContextExtension.getWidgetBounds(widget.context);
    if (offset == null || bounds == null) return null;

    return Rect.fromLTWH(
      offset.dx + widget.arrowDxOffset,
      offset.dy + widget.arrowDyOffset,
      bounds.width + widget.contentDxOffset,
      bounds.height + widget.contentDyOffset,
    );
  }
}
