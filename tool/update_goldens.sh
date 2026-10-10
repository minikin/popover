#!/usr/bin/env sh
# Goldens are rendered on Linux, like in CI.
set -eu
cd "$(dirname "$0")/.."
docker build --platform linux/amd64 -t popover-goldens tool/goldens
docker run --rm --platform linux/amd64 -v "$PWD":/app -w /app popover-goldens \
  flutter test --update-goldens test/golden_test.dart
