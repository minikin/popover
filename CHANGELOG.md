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
