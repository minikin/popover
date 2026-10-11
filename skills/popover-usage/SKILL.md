---
name: popover-usage
description: Use when the user shows a popover, a dropdown menu, a context panel or a tooltip-like bubble anchored to a widget with package:popover, or works with showPopover, Popover, PopoverController, PopoverDirection or PopoverArrowStyle.
---

# Popover

`package:popover` shows a transient panel with an arrow that points at an
anchor widget. On iOS, iPadOS and macOS it looks and moves like the native
popover by default. It depends only on `package:flutter/widgets.dart`.

## Guidelines

- Pick the API by how the popover is driven:
  - `showPopover(context: ..., bodyBuilder: ...)` from a callback, such as
    `onPressed`. It returns a `Future` with the value passed to
    `Navigator.pop`, or `null` when the user taps outside.
  - `Popover(controller: ..., content: ..., child: anchor)` when app state
    opens and closes it. Call `show`, `hide` or `toggle` on a
    `PopoverController`, dispose the controller, and read `isOpen`, which
    turns false when the user closes the popover.
- Pass the context of the anchor, not of the page. Wrap the anchor in a
  `Builder`, or use `GlobalKey.currentContext`. With the `Popover` widget the
  `child` is the anchor.
- The body is not wrapped in a `Material`. When it contains `ListTile`,
  `InkWell`, `TextField`, `Checkbox` or `Switch`, wrap it in
  `Material(type: MaterialType.transparency)`. An opaque `Material` hides
  the glass background on Apple platforms.
- Size the body with `width`, `height` or `constraints`. The popover flips,
  slides and shrinks to stay on screen, so give long content a scrollable
  body.
- Pick the side with `direction` (`PopoverDirection.bottom` by default). It
  is a preference: the popover opens on the other side when it does not fit.
- Put the look in a `PopoverStyle` passed as `style:`: `arrowStyle`,
  `backgroundColor`, `brightness`, `barrierColor`, `radius`, `shadow`,
  `arrowWidth`, `arrowHeight`, `transition`, `transitionDuration`. They are
  not arguments of `showPopover` or `Popover`. For app-wide defaults, wrap
  the app in `PopoverTheme(data: PopoverStyle(...), child: ...)`. The style
  at the call wins over the theme.
- Leave style fields null to keep the native defaults on Apple platforms:
  the Apple outline, Liquid Glass, no dimming and the native springs.
  Elsewhere the defaults are a triangle arrow, a white or dark gray body and
  a dimmed barrier.
- For the look of 0.4 everywhere, set
  `PopoverStyle(arrowStyle: PopoverArrowStyle.triangle, backgroundColor: ...)`
  in a `PopoverTheme`.
- Light or dark follows the text color the body inherits from `context`.
  Set the style's `brightness` when the popover opens from a place with a
  different text color than its body, such as a colored `AppBar`.
- In a `popoverTransitionBuilder`, do not use `Opacity` or `FadeTransition`
  with the glass background. Impeller gives a backdrop filter inside an
  opacity layer nothing to blur.
- Set `semanticsLabel` so screen readers announce the popover, and pass a
  localized `barrierLabel`.
- In widget tests, call `tester.pumpAndSettle()` after opening or closing.
  On iOS the default animation takes 494 ms to open and 516 ms to close.

## Examples

A menu from a button, returning the choice:

```dart
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final choice = await showPopover<String>(
          context: context,
          width: 200,
          semanticsLabel: 'Actions',
          bodyBuilder: (context) => Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in ['Copy', 'Share'])
                  ListTile(
                    title: Text(item),
                    onTap: () => Navigator.pop(context, item),
                  ),
              ],
            ),
          ),
        );
        if (choice != null) debugPrint('Picked $choice');
      },
      child: const Text('Actions'),
    );
  }
}
```

A popover driven by state:

```dart
class InfoButton extends StatefulWidget {
  const InfoButton({super.key});

  @override
  State<InfoButton> createState() => _InfoButtonState();
}

class _InfoButtonState extends State<InfoButton> {
  final _controller = PopoverController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Popover(
      controller: _controller,
      direction: PopoverDirection.top,
      content: (context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Saved to your library'),
      ),
      child: IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: _controller.toggle,
      ),
    );
  }
}
```
