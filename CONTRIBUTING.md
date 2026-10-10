# Contributing

## How this project works

This project is maintained on a volunteer basis with limited bandwidth.
After years of open source experience, I've found that the vast majority of
GitHub issues are requests for the maintainer to do work, not contributions.
That model isn't sustainable.

**Issues are therefore disabled. Pull requests are the only contribution channel.**

If you've found a bug or have an improvement in mind, please open a PR directly.
A PR with a working fix or a minimal reproduction in the example app is always welcome.

## Pull Request Process

1. Fork the repository and create your branch from `main`.
2. Make sure the existing tests pass: `flutter test`. Developing the package needs
   Flutter 3.47+, because the tests also run against `material_ui` and `cupertino_ui`.
   CI also runs a mutation test over `lib/` that fails below the threshold in
   `mutation_test.xml`. Run it locally with
   `dart run mutation_test -o build/mutation-test-report mutation_test.xml`.
   CI splits the same run into six parallel shards with
   `tool/ci/mutation_shards.py` and checks the threshold on their sum.

   Golden tests in `test/golden_test.dart` run only on Linux, because text and
   shadows render a few pixels differently on macOS. If your change moves pixels,
   regenerate them in Docker with `tool/update_goldens.sh` and look at the diff of
   `test/goldens/`. `test/apple_placement_test.dart` holds popover frames measured
   on UIKit and NSPopover. Do not change an expected frame without measuring it on
   a simulator.

   The integration test opens popovers in the example app on a device and saves
   screenshots to `example/build/screenshots/`:

   ```bash
   cd example
   flutter drive -d <device> --driver test_driver/integration_test.dart \
     --target integration_test/popover_test.dart
   ```
3. If your change affects the public API or behavior, update `README.md` and add or
   update tests accordingly.
4. Bump the version in `pubspec.yaml` following [SemVer](https://semver.org/) and add
   an entry to `CHANGELOG.md`.
5. Open the PR against `main`. Describe what problem it solves and which platforms
   you tested on.

The maintainer reviews PRs as time allows. Providing a clean, well-scoped PR is the
best way to get a fast review.

## Code Style

Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) conventions.
Run `dart format .` and `dart analyze` before submitting.

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md).
