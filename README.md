# Popover

[![pub](https://img.shields.io/pub/v/popover.svg)](https://pub.dev/packages/popover)
[![CI](https://github.com/minikin/popover/workflows/On%20Pull%20Request/badge.svg)](https://github.com/minikin/popover/actions)
[![coverage](https://codecov.io/gh/minikin/popover/branch/main/graph/badge.svg?token=CHT3D24SOQ)](https://codecov.io/gh/minikin/popover)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/minikin/popover/main/assets/demo-dark.webp">
    <img src="https://raw.githubusercontent.com/minikin/popover/main/assets/demo-light.webp" alt="The example app with open popovers on macOS, iPad, iPhone, Android, Windows, Linux and the web" />
  </picture>
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

## Popover widget

`Popover` keeps a popover in the widget tree. Its `child` is the anchor, and
a `PopoverController` opens and closes it:

```dart
class ShareButton extends StatefulWidget {
  const ShareButton({super.key});

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
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
      semanticsLabel: 'Share',
      content: (context) => const ShareMenu(),
      child: TextButton(
        onPressed: _controller.toggle,
        child: const Text('Share'),
      ),
    );
  }
}
```

`show`, `hide` and `toggle` open and close it, and `isOpen` turns false when
the user closes it with a tap outside, Esc or the back gesture. `onDismissed`
runs after it closes. `Popover` takes the arguments of `showPopover`, and they
apply when it opens. A new `content` rebuilds an open popover. When `Popover`
leaves the tree, its popover closes.

## Material and Cupertino

Flutter 3.47 moved Material and Cupertino into the
[`material_ui`](https://pub.dev/packages/material_ui) and
[`cupertino_ui`](https://pub.dev/packages/cupertino_ui) packages, whose classes
differ from the ones in `package:flutter/material.dart` and
`package:flutter/cupertino.dart`. Since 0.5.0 popover depends on none of them
and works in a `MaterialApp` or a `CupertinoApp` from either source.

The body is not wrapped in a `Material`. `InkWell`, `ListTile`, `TextField`,
`Checkbox` and the other widgets that need one throw
`No Material widget found` unless you wrap the body in the `Material` of your
UI library, as the quick start does. Use `MaterialType.transparency`, since an
opaque `Material` covers the glass background.

`showPopover` captures `Theme`, `DefaultTextStyle`, `IconTheme` and the other
inherited themes at `context` and applies them to the body, as `showDialog`
does. The body gets the text and icon style in effect where it was opened: the
`AppBar` foreground color when opened from an `AppBar` action, and
`MaterialApp`'s red debug style when `context` has no `Material` ancestor. A
`Material` wrapper resets the text to the theme's `bodyMedium`. An `IconTheme`
around the body resets the icons.

Cupertino widgets such as `CupertinoListTile` need no wrapper.

`barrierLabel` is the screen reader label of the barrier and defaults to
`'Dismiss'`. For a localized one, pass
`MaterialLocalizations.of(context).modalBarrierDismissLabel` or
`CupertinoLocalizations.of(context).modalBarrierDismissLabel`.

## Arrow style

`arrowStyle` picks the shape. `PopoverArrowStyle.apple` draws the native
outline. On iOS that is the iOS 26 popover: Apple's continuous corners with a
34 point radius and a 26 by 13 arrow whose tip is rounded and whose sides flow
into the body. On macOS it is the macOS 26 `NSPopover`: 20 point corners and an
arrow with an arc for a tip. Next to a corner the arrow merges into it, as on
the native platforms. The outlines repeat the mask paths UIKit and AppKit draw,
checked against paths dumped from an iOS simulator and from macOS, and the
default shadows are measured from both.

`PopoverArrowStyle.triangle` is the sharp triangle with 8 point corners from
earlier versions. `PopoverArrowStyle.adaptive`, the default, picks `apple` on
iOS, iPadOS and macOS and `triangle` everywhere else, on the web by the
host OS. `arrowWidth`,
`arrowHeight`, `radius` and `shadow` override the defaults of either style, for
example `radius: 13` for the corners of iOS before version 26.

## Background and dark mode

With the `apple` shape the default background is the Liquid Glass of iOS 26
and macOS 26: the content behind the popover shows through, blurred and
tinted, and a light rim runs along the outline. The blur, the tint and the rim
are fitted to native popovers captured over 22 backgrounds in light and dark
mode, and match them within a few levels of brightness on flat colors. Native
glass also bends the light near the outline and adapts to a wide area behind
it. The popover does neither, so fine detail such as text behind it blurs more
evenly than on iOS. The `triangle` shape gets white, or `Color(0xFF2C2C2E)` in
dark mode.

Light or dark follows the text color the body inherits from `context`: dark
text gets a light background, light text a dark one. So the body stays
readable in an app that forces a light or a dark theme. Without an inherited
text color it follows the system setting. `brightness` overrides both, and
`backgroundColor` replaces the glass with a solid color. A `Material` around
the body resets its text to the theme's `bodyMedium`, so pass `brightness`
when you open the popover from a place with a different text color, such as
an `AppBar` with a colored background.

iOS and macOS do not dim the screen behind a popover, so the barrier is
transparent with the `apple` shape and dims to `Color(0x80000000)` with the
`triangle`.

## Placement

The popover is placed the way `UIPopoverPresentationController` and
`NSPopover` place theirs. The rules were measured on iOS 26 simulators and
macOS 26.

`direction` is the preferred side: `PopoverDirection.bottom` by default, or
`top`, `left` or `right`. Left and right stay physical in right-to-left apps.
When the popover does not fit there, it opens on the opposite side. On macOS
it then tries the two perpendicular sides, like `NSPopover`. When it fits
nowhere, it takes the preferred or the opposite side, whichever has more room,
and the body shrinks to fit, so a scrollable body scrolls.

The popover stays inside the safe area and above the keyboard, with Apple's
margins: 10 on iPhone, 19 at the sides, 30 at the top and 10 at the bottom on
iPad, 13 on macOS. Android, Windows, Linux and the web use the iPhone margin.
Flutter web picks the rules of the host OS, so it gets the macOS rules on a
Mac.

Along the side it opens on, the body centers on the anchor and slides to stay
on screen. Outside macOS, a popover on the left or the right may cover the
anchor up to its center, as UIKit does. An anchor that is partly or fully off
screen is moved onto the screen edge first. The popover follows the anchor
when it moves, scrolls or the screen rotates.

`width`, `height` and `constraints` size the body and are capped by the room
available. `arrowWidth` and `arrowHeight` size the arrow. `arrowDxOffset` and
`arrowDyOffset` move the point the arrow aims at. `contentDxOffset` and
`contentDyOffset` widen and heighten the anchor, which moves a popover that
opens to the right or below.

## Dismissing

A tap on the barrier closes the popover. `barrierDismissible: false` keeps it
open, and `barrierColor` replaces the default tint of the barrier. With
`allowClicksOnBackground: true`, taps pass through the barrier to the widgets
behind it and `barrierDismissible` is ignored. `onPop` runs whenever the
route pops.

`requestFocus: false` stops the popover from taking focus, so an open
keyboard stays up.

## Keyboard and accessibility

Esc closes the popover on every platform, as it closes an `NSPopover`, unless
`barrierDismissible` is false. While
the popover is open, Tab moves through its body only, and when it closes,
focus goes back to the widget that had it. `requestFocus: false` leaves focus
where it is.

Screen readers see the popover, not the screen behind it. On iOS, Android and
macOS they also reach the barrier last, labeled with `barrierLabel`, which
closes the popover with a tap or the dismiss gesture. Flutter leaves the
barrier out of the semantics tree on Windows and Linux. `semanticsLabel` names the popover, and VoiceOver
and TalkBack announce the name when it opens, as they announce the title of a
dialog:

```dart
showPopover(
  context: context,
  semanticsLabel: 'Share',
  bodyBuilder: (context) => const ShareMenu(),
);
```

## Animation

The popover fades in over `transitionDuration`, 200 ms by default.
`PopoverTransition.scale`, the default, also grows the body from the arrow.
With the `apple` shape on iOS it moves like an iOS 26 popover instead: it
scales up from the arrow tip while its outline grows from 100 points to its
full height, on the spring UIKit uses, and closes on UIKit's softer closing
spring. The springs are read from the animations UIKit attaches to a
popover, so opening takes 494 ms and closing 516 ms. A `transitionDuration`
you pass applies to both. While closing, iOS also squashes the glass
vertically for the first few frames, which the popover does not.

On macOS it moves like `NSPopover`: it scales up from the arrow tip and fades
in on a spring over 440 ms, and shrinks back into the tip over 200 ms. These
springs are fitted to `NSPopover` recorded at 120 frames per second.
`PopoverTransition.other` turns the scaling off. `popoverTransitionBuilder`
replaces the fade. Avoid `Opacity` and `FadeTransition` in it with the glass
background: Impeller gives a backdrop filter inside an opacity layer nothing
to blur, so the glass shows as a flat tint until the fade ends.

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
