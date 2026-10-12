# Popover

<p align="center">
  <a href="https://pub.dev/packages/popover"><img src="https://raw.githubusercontent.com/minikin/popover/badges/pub.svg" alt="pub"></a>
  <a href="https://github.com/minikin/popover/actions/workflows/on_pull_request.yml"><img src="https://raw.githubusercontent.com/minikin/popover/badges/ci.svg" alt="CI"></a>
  <a href="https://codecov.io/gh/minikin/popover"><img src="https://raw.githubusercontent.com/minikin/popover/badges/coverage.svg" alt="coverage"></a>
  <a href="https://github.com/minikin/popover/blob/main/LICENSE"><img src="https://raw.githubusercontent.com/minikin/popover/badges/license.svg" alt="license"></a>
</p>

<p align="center">
  <a href="https://developer.apple.com/design/human-interface-guidelines/popovers"><img src="https://raw.githubusercontent.com/minikin/popover/main/assets/hig-quote.svg" alt="A popover is a transient view that appears above other content when people click or tap a control or interactive area. Apple Human Interface Guidelines"></a>
</p>

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

Dart 3.13 and Flutter 3.47 or newer.

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
the user closes it with a tap outside, Esc or the back gesture. `onPop` runs
whenever it pops. `Popover` takes the other arguments of `showPopover`, and
they apply when it opens. A new `content` rebuilds an open popover. When
`Popover` leaves the tree, its popover closes without the closing animation
and `isOpen` stays true, so it opens again when a `Popover` with the same
controller comes back.

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

## Style and theme

`PopoverStyle` holds how a popover looks and moves: `arrowStyle`,
`backgroundColor`, `brightness`, `barrierColor`, `radius`, `shadow`,
`arrowWidth`, `arrowHeight`, `transition` and `transitionDuration`. Every
field is optional, and a field left null falls back to the native default of
the platform, described in the sections below. Pass a style per popover with
`style:`, or set one for a whole subtree with `PopoverTheme`:

```dart
PopoverTheme(
  data: const PopoverStyle(radius: 16),
  child: MaterialApp(home: const HomePage()),
);

showPopover(
  context: context,
  style: const PopoverStyle(arrowStyle: PopoverArrowStyle.triangle),
  bodyBuilder: (context) => const Text('Hello'),
);
```

The style at the call is merged on top of the theme, so its non-null fields
win. A null field keeps what is below it, so a field set in the theme cannot
be cleared per call: a theme `backgroundColor` turns the glass off for every
popover below it, and a theme `brightness` turns off the contrast with the
text. `shadow: const []` removes the shadow. Popovers opened from inside a
popover see the same theme.

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
host OS. `arrowWidth`, `arrowHeight`, `radius` and `shadow` override the
defaults of either shape, for example `PopoverStyle(radius: 13)` for the
corners of iOS before version 26.

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
text gets a light background, light text a dark one, with the switch at the
gray `Color(0xFF858585)`, where both backgrounds give the same contrast. So the
body stays readable in an app that forces a light or a dark theme. Without an inherited
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
available. `arrowDxOffset` and
`arrowDyOffset` move the point the arrow aims at. `contentDxOffset` and
`contentDyOffset` widen and heighten the anchor, which moves a popover that
opens to the right or below.

## Dismissing

A tap on the barrier closes the popover. `barrierDismissible: false` keeps it
open, and the style's `barrierColor` replaces the default tint. With
`allowClicksOnBackground: true`, taps pass through the barrier to the widgets
behind it and `barrierDismissible` is ignored. `onPop` runs whenever the
route pops.

`requestFocus: false` stops the popover from taking focus, so an open
keyboard stays up.

## Keyboard and accessibility

Esc closes the popover on every platform, as it closes an `NSPopover`, unless
`barrierDismissible` is false or `allowClicksOnBackground` is true. While
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

The popover fades in over the style's `transitionDuration`, 200 ms by
default. `PopoverTransition.scale`, the default `transition`, also grows the
body from the arrow.
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

## Using with AI agents

The package ships a skill that teaches coding agents how to use it: which API
to pick, the anchor context, the `Material` wrapper, the native defaults and
the pitfalls. Install it into your app with the `skills` tool:

```sh
dart run skills@ get --package popover
```

It lands in `.agents/skills/`, or in `.claude/skills/` with `--agent claude`.
For the analyzer, pub.dev search and hot reload, add the Dart and Flutter MCP
server, which comes with the Dart SDK:

```sh
claude mcp add dart -- dart mcp-server
```

## Migrating from 0.4

0.5.0 changes how the popover looks and behaves on iOS, iPadOS and macOS, and
how its body is built everywhere.

- The body is no longer wrapped in a `Material`. Wrap it in
  `Material(type: MaterialType.transparency)` when it holds `InkWell`,
  `ListTile`, `TextField` or other widgets that need one.
- The body inherits `Theme`, `DefaultTextStyle` and `IconTheme` from
  `context`. A `Material` around it resets the text style.
- `barrierLabel` defaults to `'Dismiss'`. Pass a localized label if you need
  one.
- The popover is placed like a native one: it flips, slides and shrinks to
  stay inside the safe area, and `width`, `height` and `constraints` are
  capped by the room available.
- On Apple platforms the defaults are native: the `apple` outline, Liquid
  Glass, no dimming behind the popover and the native springs. Dark mode
  follows the text color the body inherits.
- The look moved into `PopoverStyle`: `transition`, `backgroundColor`,
  `barrierColor`, `transitionDuration`, `radius`, `shadow`, `arrowWidth` and
  `arrowHeight` go into `style:` instead of `showPopover`. `PopoverTheme`
  sets them for a whole subtree.
- `key` and the deprecated `isParentAlive` are gone from `showPopover`.

Before and after:

```dart
// 0.4
showPopover(
  context: context,
  radius: 12,
  arrowHeight: 15,
  backgroundColor: Colors.white,
  bodyBuilder: (context) => const MyBody(),
);

// 0.5
showPopover(
  context: context,
  style: const PopoverStyle(
    radius: 12,
    arrowHeight: 15,
    backgroundColor: Colors.white,
  ),
  bodyBuilder: (context) => const MyBody(),
);
```

To keep the look of 0.4 everywhere, set it once at the root:

```dart
PopoverTheme(
  data: const PopoverStyle(
    arrowStyle: PopoverArrowStyle.triangle,
    backgroundColor: Color(0xFFFFFFFF),
  ),
  child: MaterialApp(home: const HomePage()),
);
```

and wrap bodies in a `Material` where they need one.

With the `triangle` style the barrier still dims to `Color(0x80000000)` and
the popover still fades and scales in over 200 ms.

## Contributing

The project accepts pull requests, not issues. Open a PR with a fix or a
reproduction in the example app. [CONTRIBUTING.md](CONTRIBUTING.md) covers
tests, the mutation test gate and versioning.

## License

MIT. See the [LICENSE](LICENSE) file.
