#!/usr/bin/env sh
# Goldens are rendered on Linux, like in CI. The tests run on a copy of the
# repository so the host's .dart_tool stays untouched.
set -eu
cd "$(dirname "$0")/.."
flutter=$(sed -n 's/.*"flutter": *"\(.*\)".*/\1/p' .fvmrc)
docker build --platform linux/amd64 --build-arg FLUTTER_VERSION="$flutter" \
  -t popover-goldens tool/goldens
docker run --rm --platform linux/amd64 -v "$PWD":/src popover-goldens sh -c '
  set -e
  mkdir /work && cd /src
  tar cf - --exclude=build --exclude=.dart_tool --exclude=.git . | tar xf - -C /work
  cd /work
  flutter pub get >/dev/null
  flutter test --update-goldens test/golden_test.dart
  cp test/goldens/*.png /src/test/goldens/
'
