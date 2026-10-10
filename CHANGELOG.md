## [0.5.0] - 10.10.2026

- Breaking: the popover depends only on `package:flutter/widgets.dart` and works with `package:flutter/material.dart`, `package:flutter/cupertino.dart`, `package:material_ui` and `package:cupertino_ui`. 0.4.0 threw `No MaterialLocalizations found` in a `CupertinoApp` ([#113](https://github.com/minikin/popover/pull/113)).(thanks [@livtanong](https://github.com/livtanong)).
  - The body is no longer wrapped in a `Material`. Wrap it in the `Material` of your UI library if it contains Material widgets that require one, such as `InkWell`, `ListTile`, `TextField`, `Checkbox` or `Switch`.
  - `barrierLabel` defaults to `'Dismiss'` instead of `MaterialLocalizations.modalBarrierDismissLabel`. Pass a localized label if you need one.
  - Inherited themes (`Theme`, `DefaultTextStyle`, `IconTheme` and others) are captured from the calling `context` and applied to the body. The body text and icon styles are the ones in effect at `context`: the `AppBar` foreground color when opened from an `AppBar` action, and `MaterialApp`'s red debug text without a `Material` ancestor. A `Material` around the body resets the text to `textTheme.bodyMedium`.
  - A translucent `backgroundColor` is painted once under the body instead of twice, so the body looks more transparent than before.
- Breaking: the popover is placed the way iOS, iPadOS and macOS place theirs. The rules come from `UIPopoverPresentationController` and `NSPopover` measured on iOS 26 simulators and macOS 26.
  - It stays inside the safe area and above the keyboard. The margin is 10 on iPhone, Android, web, Windows and Linux. On iPad it is 19 at the sides, 30 at the top and 10 at the bottom, and on macOS 12.
  - When the body fits on neither the preferred side nor the opposite one, it takes the side with more room and shrinks to fit, so a scrollable body scrolls. On macOS it first tries the two perpendicular sides, like `NSPopover`.
  - Outside macOS, a popover on the left or the right may cover the anchor up to its center, as UIKit does.
  - `width`, `height` and `constraints` are capped by the space available.
  - The popover follows its anchor when the anchor moves, scrolls or the screen rotates, as UIKit does for a source view.
  - An anchor partly or fully off screen is moved onto the screen edge first. UIKit does this below the bottom edge and beside the side edges but lets an anchor above the top edge push the popover off screen. The popover clamps on every edge.
  - The arrow stops short of the rounded corners. UIKit merges the arrow into the corner instead, which waits for the native arrow shape.
  - Flutter web follows the rules of the host OS, so it uses the macOS rules on a Mac.
- Fixed: the popover flipped and slid against the size of the first window, not the screen it is shown in. Near the right edge it could open off screen.
- Fixed: a flipped popover drew its shadow with the arrow on the original side.
- Added a `Mutation Test` CI workflow over `lib/` that fails below the 17% threshold in `mutation_test.xml`. Developing the package now needs Flutter 3.47+ because `material_ui` and `cupertino_ui` require it. The minimum Flutter version for apps is unchanged.
- Added golden tests, rendered on Linux, and an `E2E` CI workflow that runs the example's integration test on iPhone, iPad, macOS, Windows and Linux, in Chrome and on an Android emulator, with screenshots and rotation.

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
