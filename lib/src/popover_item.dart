import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../popover.dart';
import 'popover_context.dart';
import 'popover_position_widget.dart';
import 'utils/build_context_extension.dart';
import 'utils/popover_utils.dart';

class PopoverItem extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final PopoverDirection? direction;
  final double? radius;
  final List<BoxShadow>? boxShadow;
  final Animation<double> animation;
  final double? arrowWidth;
  final double arrowHeight;
  final bool appleShape;
  final BoxConstraints? constraints;
  final BuildContext context;
  final double arrowDxOffset;
  final double arrowDyOffset;
  final double contentDyOffset;
  final double contentDxOffset;
  final PopoverTransition transition;

  const PopoverItem({
    required this.child,
    required this.context,
    required this.transition,
    required this.animation,
    required this.arrowHeight,
    this.appleShape = false,
    this.backgroundColor,
    this.direction,
    this.radius,
    this.boxShadow,
    this.arrowWidth,
    this.constraints,
    this.arrowDxOffset = 0,
    this.arrowDyOffset = 0,
    this.contentDyOffset = 0,
    this.contentDxOffset = 0,
    super.key,
  });

  @override
  _PopoverItemState createState() => _PopoverItemState();
}

class _PopoverItemState extends State<PopoverItem> {
  late Rect _attachRect;

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
              return PopoverContext(
                attachRect: attachRect,
                animation: widget.animation,
                radius: widget.radius,
                backgroundColor: widget.backgroundColor,
                boxShadow: widget.boxShadow,
                direction: widget.direction,
                arrowWidth: widget.arrowWidth,
                arrowHeight: widget.arrowHeight,
                appleShape: widget.appleShape,
                transition: widget.transition,
                child: child,
              );
            },
            child: Listener(
              behavior: HitTestBehavior.opaque,
              child: widget.child,
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
