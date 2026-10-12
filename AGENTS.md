# Working on popover

Instructions for AI coding agents in this repository. Apps that use the
package get `skills/popover-usage/SKILL.md` instead.

## Commands

- `flutter test` runs the unit and widget tests. Goldens are skipped outside
  Linux.
- `./tool/update_goldens.sh` renders `test/goldens/` in Docker, like CI. Run
  it after any change that moves pixels and look at the diff.
- `flutter analyze` must report no issues. `dart format lib test` before a
  commit.
- `dart run mutation_test -o build/mutation-test-report mutation_test.xml`
  runs the mutation test over `lib/`. CI fails below 75% and mutates only the
  changed declarations on a pull request, so cover new branches with tests.
- `cd example && flutter drive --driver test_driver/integration_test.dart
  --target integration_test/popover_test.dart` runs the E2E test on a device.

## Rules

- The package depends only on `package:flutter/widgets.dart`. Do not import
  Material or Cupertino in `lib/`.
- Placement, outlines, glass, shadows and motion on Apple platforms are
  measured from UIKit and AppKit. Do not change a measured constant or an
  expected frame in `test/apple_placement_test.dart` without measuring the
  native popover again.
- Impeller gives a `BackdropFilter` inside an `Opacity` layer an empty
  backdrop. The glass fades in `PopoverRenderShiftedBox`, not in an
  `Opacity`.
- Write docs, comments and commit messages in English, plain and short. No
  em dashes or curly quotes.
- Update `README.md`, `CHANGELOG.md` and `skills/popover-usage/SKILL.md`
  when the public API or a default changes.

## Tools

`.mcp.json` registers the Dart and Flutter MCP server (`dart mcp-server`),
which gives agents the analyzer, pub.dev search, tests and hot reload. The
`dart-flutter` plugin from `flutter/agent-plugins` adds Dart and Flutter
skills for Claude Code.
