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
2. Make sure the existing tests pass: `flutter test`.
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
