#!/usr/bin/env sh
# Goldens are rendered on Linux, like in CI. The tests run on a copy of the
# repository so the host's .dart_tool stays untouched.
set -eu
cd "$(dirname "$0")/.."
docker build --platform linux/amd64 -t popover-goldens tool/goldens
docker run --rm --platform linux/amd64 -v "$PWD":/src popover-goldens sh -c '
  cp -r /src /work && cd /work && rm -rf .dart_tool build
  flutter pub get >/dev/null
  flutter test --update-goldens test/golden_test.dart
  cp test/goldens/*.png /src/test/goldens/
'
