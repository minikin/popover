## [0.5.1] - 12.10.2026

- Text between the grays `Color(0xFF858585)` and `Color(0xFF9D9D9D)` in luminance, such as `#8E8E93`, `#999999` or the iOS system blue `#0A84FF`, now gets the dark background by default instead of the light one. The switch moved from a luminance of 0.34 to 0.23, where the text has the same contrast against both backgrounds. `#999999` text was 2.9:1 on the white triangle and is 4.9:1 on the dark one.

## [0.5.0] - 12.10.2026

- Breaking: the minimum versions are Flutter 3.47.0 and Dart 3.13.0, up from Flutter 3.35.0 and Dart 3.9.0.
- Breaking: the look of a popover moved into `PopoverStyle`, passed as `style:` to `showPopover` and `Popover`: `arrowStyle`, `backgroundColor`, `brightness`, `barrierColor`, `radius`, `shadow`, `arrowWidth`, `arrowHeight`, `transition` and `transitionDuration`. The new `PopoverTheme` sets a style for a whole subtree, and the style at the call wins over it. `showPopover` no longer takes `key` or the deprecated `isParentAlive`. `PopoverTransitionBuilder`, the type of `popoverTransitionBuilder`, is now exported. The README has a before and after.
- Breaking: the popover depends only on `package:flutter/widgets.dart` and works with `package:flutter/material.dart`, `package:flutter/cupertino.dart`, `package:material_ui` and `package:cupertino_ui`. 0.4.0 threw `No MaterialLocalizations found` in a `CupertinoApp` ([#113](https://github.com/minikin/popover/pull/113)).(thanks [@livtanong](https://github.com/livtanong)).
  - The body is no longer wrapped in a `Material`. Wrap it in the `Material` of your UI library if it contains Material widgets that require one, such as `InkWell`, `ListTile`, `TextField`, `Checkbox` or `Switch`, with `MaterialType.transparency` so the glass background shows.
  - `barrierLabel` defaults to `'Dismiss'` instead of `MaterialLocalizations.modalBarrierDismissLabel`. Pass a localized label if you need one.
  - Inherited themes (`Theme`, `DefaultTextStyle`, `IconTheme` and others) are captured from the calling `context` and applied to the body. The body text and icon styles are the ones in effect at `context`: the `AppBar` foreground color when opened from an `AppBar` action, and `MaterialApp`'s red debug text without a `Material` ancestor. A `Material` around the body resets the text to `textTheme.bodyMedium`.
  - A translucent `backgroundColor` is painted once under the body instead of twice, so the body looks more transparent than before.
- Breaking: the popover is placed the way iOS, iPadOS and macOS place theirs. The rules come from `UIPopoverPresentationController` and `NSPopover` measured on iOS 26 simulators and macOS 26.
  - It stays inside the safe area and above the keyboard. The margin is 10 on iPhone, Android, web, Windows and Linux. On iPad it is 19 at the sides, 30 at the top and 10 at the bottom, and on macOS 13.
  - When the body fits on neither the preferred side nor the opposite one, it takes the side with more room and shrinks to fit, so a scrollable body scrolls. On macOS it first tries the two perpendicular sides, like `NSPopover`.
  - Outside macOS, a popover on the left or the right may cover the anchor up to its center, as UIKit does.
  - `width`, `height` and `constraints` are capped by the space available.
  - The popover follows its anchor when the anchor moves, scrolls or the screen rotates, as UIKit does for a source view. When the anchor leaves the tree while the popover is open, for example in a lazy list, the popover stays where the anchor was last seen.
  - An anchor partly or fully off screen is moved onto the screen edge first. UIKit does this below the bottom edge and beside the side edges but lets an anchor above the top edge push the popover off screen. The popover clamps on every edge.
  - The `triangle` arrow stops short of the rounded corners. The `apple` arrow merges into a nearby corner, as UIKit and AppKit do.
  - Flutter web follows the rules of the host OS, so it uses the macOS rules on a Mac.
- Breaking: on iOS, iPadOS and macOS the popover has the native shape by default. The new `arrowStyle` style field takes `PopoverArrowStyle.apple`, `triangle` or `adaptive`, the default, which is `apple` on Apple platforms and `triangle` elsewhere. Flutter web follows the host OS here too, so Safari on a Mac or an iPhone gets the `apple` shape.
  - On iOS the `apple` outline repeats the mask path of `UIPopoverPresentationController` on iOS 26 element for element: continuous corners with a 34 point radius, a 26 by 13 arrow with a rounded tip and filleted sides, and the corner next to the arrow merging into it. A test compares it with 31 paths dumped from a simulator. Its default shadow, `BoxShadow(color: Color(0x6B000000), blurRadius: 210)`, matches the iOS shadow within one level of brightness.
  - On macOS it repeats the `NSPopover` outline of macOS 26: 20 point corners, a 25.42 by 13 arrow with an arc for a tip, and AppKit's blend of the arrow into a nearby corner. A test compares it with 171 paths dumped from macOS. The default shadow, `BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 3.6))`, is fitted to a screenshot of `NSPopover`.
  - `arrowWidth`, `arrowHeight`, `radius` and `shadow` are now nullable and default per style. Set `PopoverStyle(arrowStyle: PopoverArrowStyle.triangle)` for the previous look.
- Breaking: with the `apple` shape the default background is the Liquid Glass of iOS 26 and macOS 26, a blur of the content behind with a tint and a light rim, fitted to native popovers captured over 22 backgrounds in light and dark mode. `backgroundColor` is now nullable, and a color passed in replaces the glass. The `triangle` default stays white, or `Color(0xFF2C2C2E)` in dark mode.
  - The new `brightness` style field picks light or dark. By default the background contrasts with the text color the body inherits from `context`, so an app that forces a light theme on a phone in dark mode gets a light popover. Without an inherited text color it follows the system setting.
  - `barrierColor` is now nullable. It defaults to transparent for the `apple` shape, since iOS and macOS do not dim the screen behind a popover, and to `Color(0x80000000)` for the `triangle`.
- Fixed: the popover flipped and slid against the size of the first window, not the screen it is shown in. Near the right edge it could open off screen.
- Fixed: a flipped popover drew its shadow with the arrow on the original side.
- Fixed: with more than one `BoxShadow` in `shadow`, every shadow after the first was shifted by the popover's position again.
- With the `apple` shape on iOS the popover opens and closes like an iOS 26 popover: it scales up from the arrow tip while its outline grows from 100 points to its full height, then shrinks back. The springs, 494 ms to open and 516 ms to close, are read from the `CASpringAnimation` objects UIKit attaches to a popover. On macOS it scales up from the tip and fades in on a spring over 440 ms and shrinks back over 200 ms, fitted to a recording of `NSPopover`. `transitionDuration` is now nullable, and a duration passed in applies to both directions.
- Added a package skill, `skills/popover-usage/SKILL.md`, which `dart run skills@ get` installs for coding agents, and pub.dev topics.
- Added the `Popover` widget and `PopoverController`, which keep a popover in the widget tree with its anchor as `child`. `show`, `hide` and `toggle` open and close it, and the controller follows when the user closes it.
- Added `semanticsLabel`, which names the popover for screen readers. Tests now cover Esc closing the popover, Tab staying inside it, focus going back to where it was, and screen readers seeing only the popover and its barrier.
- Added a `Mutation Test` CI workflow over `lib/` that fails below the 75% threshold in `mutation_test.xml`. It runs in parallel shards and, on a pull request, mutates only the changed declarations.
- Added golden tests, rendered on Linux, and an `E2E` CI workflow that runs the example's integration test on iPhone, iPad, macOS, Windows and Linux, in Chrome and on an Android emulator, with screenshots and rotation.
- Rebuilt the example app with a Roadmap tab, an issue list with a Share menu, and a Playground tab with a direction switcher. The `E2E` workflow renders a demo image of the example on every platform.

## [0.4.0] - 23.10.2025

- Fixed memory leak by disposing CurvedAnimation in FadeTransitionWidget ([#105](https://github.com/minikin/popover/pull/105), [#106](https://github.com/minikin/popover/pull/106)).(thanks [@ZacharyYongBB](https://github.com/ZacharyYongBB)).
- Added ability to click on widgets behind the barrier ([#101](https://github.com/minikin/popover/pull/101)).(thanks [@mcquenji](https://github.com/mcquenji)).
- Updated minimum Flutter and Dart versions to 3.35.0+ and 3.9.0+ respectively.

## [0.3.1] - 10.00.2024

- Update minimum Flutter and Dart versions to 3.24.0+ and 3.5.0+ respectively.

## [0.3.0+1] - 19.05.2024

- Update README.
- Update web example to use flutter.js service worker bootstrapping.

## [0.3.0] - 08.02.2024

- Fixed [Half of the widget is not shown](https://github.com/minikin/popover/issues/83). (thanks [@zwett](https://github.com/zwett)).

## [0.2.9] - 08.12.2023

- Added `contentDxOffset`. (thanks [@kasyanyukd1995](https://github.com/kasyanyukd1995)).

## [0.2.8+2] - 01.03.2023

- Fix [`PopoverItem._configureRect()` throws trying to access unmounted context](https://github.com/minikin/popover/issues/63).(thanks [@moescs](https://github.com/moescs)).

## [0.2.8+1] - 05.02.2023

- Fix [`backgroundColor` only effects arrow](https://github.com/minikin/popover/issues/59).

## [0.2.8] - 02.01.2023

- **BREAKING**: Improve popover rendering. `isParentAlive` parameter was deprecated. (thanks [@VictorOhashi](https://github.com/VictorOhashi)).

## [0.2.7] - 23.10.2022

- Add `popoverTransitionBuilder`. Users can provide custom animation transition now. (thanks [@sanjidbillah](https://github.com/sanjidbillah)).

## [0.2.6+3] - 12.10.2021

- Fixed the bug that appears when the parent widget from which `Popover` was presented has been removed from a widget tree (thanks [@ajaxspace](https://github.com/ajaxspace)).

## [0.2.6+2] - 17.06.2021

- Fixed the bug that appears when you change window size while popover is opened (thanks [@whitebug](https://github.com/whitebug)).

## [0.2.6+1] - 21.05.2021

- Set minimum dart version to 2.12.0.

## [0.2.6] - 21.05.2021

- Fix constraints size for `PopoverDirection.top` & `PopoverDirection.bottom`.

## [0.2.5] - 18.05.2021

- Recalculate popover shape on context changes.

## [0.2.4] - 17.05.2021

- Parameters `arrowDyOffset`, `arrowDxOffset` and `contentDyOffset` now can be apply again.
- Fix [Popover breaks when opened to the right](https://github.com/minikin/popover/issues/17).
- Update example.

## [0.2.3] - 03.05.2021.

- Add `RouteSettings? routeSettings` parameter.

## [0.2.2] - 22.04.2021.

- Rebuild Popover on device orientation changes (thanks [@SanekLic](https://github.com/SanekLic), [@shcherbuk96](https://github.com/shcherbuk96)).

## [0.2.1] - 04.04.2021.

- Lower minimum version requirements for Dart and Flutter to pass pub.dev validation.

## [0.2.0] - 04.04.2021.

- Migrate to NNBD.

## [0.1.0] - 09.02.2021.

- **BREAKING**: Refactor popover implementation to have identical API to included in Flutter modal dialogs e.g. `showCupertinoDialog`
- docs: README updates
- docs: example application updates

## [0.0.5] - 08.02.2021.

- Add `Key key`, `barrierDismissible` and `showPopover`.

## [0.0.4] - 27.01.2021.

- Add `arrowDyOffset`, `arrowDxOffset` and `contentDyOffset` public parameters.

## [0.0.3] - 21.01.2021.

- A `child` widget can be wrapped in `InkWell` or `GestureDetector`.

## [0.0.2] - 18.01.2021.

- Update `PopoverItem`.
- Add `PopoverDirection` to exports.
- Add documentation.

## [0.0.1] - 10.01.2021.

- Initial release.
