# Popover

[![pub](https://img.shields.io/pub/v/popover.svg)](https://pub.dev/packages/popover)
[![CI](https://github.com/minikin/popover/workflows/On%20Pull%20Request/badge.svg)](https://github.com/minikin/popover/actions)
[![coverage](https://codecov.io/gh/minikin/popover/branch/main/graph/badge.svg?token=CHT3D24SOQ)](https://codecov.io/gh/minikin/popover)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

<p align="center">
  <img src="https://i.ibb.co/0DW1XQ0/popover-demo.png" alt="Popovers with arrows pointing at the buttons that opened them" />
</p>

A Flutter popover in the style of iOS: a box with an arrow pointing at the
widget that opened it. `showPopover` pushes a route on the root navigator,
measures the widget behind the `context` you pass, and places the body above,
below or beside it. It runs on iOS, Android, macOS, Windows, Linux and the
web, and depends only on `package:flutter/widgets.dart`.

## Install

```bash
flutter pub add popover
```

Dart 3.9 and Flutter 3.35 or newer.

## Quick start

Call `showPopover` with the context of the widget the arrow should point at:

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
          width: 160,
          height: 112,
          bodyBuilder: (context) => Material(
            type: MaterialType.transparency,
            child: Column(
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
        debugPrint('Picked $choice');
      },
      child: const Text('Menu'),
    );
  }
}
```

`showPopover` returns the value passed to `Navigator.pop`, or `null` when the
user taps outside. `example/lib/main.dart` places nine buttons across the
screen. Run it with `cd example && flutter run`.

## Material and Cupertino

Flutter 3.47 moved Material and Cupertino into the
[`material_ui`](https://pub.dev/packages/material_ui) and
[`cupertino_ui`](https://pub.dev/packages/cupertino_ui) packages, whose classes
differ from the ones in `package:flutter/material.dart` and
`package:flutter/cupertino.dart`. Since 0.5.0 popover depends on none of them
and works in a `MaterialApp` or a `CupertinoApp` from either source.

The body is not wrapped in a `Material`. `InkWell`, `ListTile`, `TextField`,
`IconButton` and the other widgets that need one throw
`No Material widget found` unless you wrap the body in the `Material` of your
UI library, as the quick start does.

`showPopover` captures `Theme`, `DefaultTextStyle`, `IconTheme` and the other
inherited themes at `context` and applies them to the body, as `showDialog`
does. The body gets the text and icon style in effect where it was opened:
white when opened from an action on a colored `AppBar`, and `MaterialApp`'s
red debug style when `context` has no `Material` ancestor. A `Material`
wrapper resets the text to the theme's `bodyMedium`. An `IconTheme` around the
body resets the icons.

Cupertino widgets such as `CupertinoListTile` need no wrapper.

`barrierLabel` is the screen reader label of the barrier and defaults to
`'Dismiss'`. For a localized one, pass
`MaterialLocalizations.of(context).modalBarrierDismissLabel` or
`CupertinoLocalizations.of(context).modalBarrierDismissLabel`.

## Placement

`direction` picks the side: `PopoverDirection.bottom` by default, or `top`,
`left` or `right`. When the body does not fit on that side, the popover opens
on the opposite one.

`width`, `height` and `constraints` size the body. `arrowWidth` and
`arrowHeight` size the arrow. `arrowDxOffset` and `arrowDyOffset` move the
point the arrow aims at, and `contentDxOffset` and `contentDyOffset` move the
body.

## Dismissing

A tap on the barrier closes the popover. `barrierDismissible: false` keeps it
open, and `barrierColor` tints the barrier. With
`allowClicksOnBackground: true`, taps pass through the barrier to the widgets
behind it and `barrierDismissible` is ignored. `onPop` runs whenever the
route pops.

`requestFocus: false` stops the popover from taking focus, so an open
keyboard stays up.

## Animation

The popover fades in over `transitionDuration`, 200 ms by default.
`PopoverTransition.scale`, the default, also grows the body from the arrow.
`PopoverTransition.other` turns the scaling off. `popoverTransitionBuilder`
replaces the fade:

```dart
showPopover(
  context: context,
  bodyBuilder: (context) => const Text('Hello'),
  popoverTransitionBuilder: (animation, child) =>
      SlideTransition(
        position: Tween(begin: const Offset(0, -0.1), end: Offset.zero)
            .animate(animation),
        child: child,
      ),
);
```

## Contributing

The project accepts pull requests, not issues. Open a PR with a fix or a
reproduction in the example app. [CONTRIBUTING.md](CONTRIBUTING.md) covers
tests, the mutation test gate and versioning.

## License

MIT. See the [LICENSE](LICENSE) file.
