#!/usr/bin/env sh
# Renders tool/demo/index.html with the integration test screenshots at 3x:
#   tool/demo/render.sh <screenshots dir> <output.png|output.webp> [dark|light]
# A .webp output needs cwebp.
set -eu
shots=$(cd "$1" && pwd)
out=$2
theme=${3:-dark}
dir=$(cd "$(dirname "$0")" && pwd)
missing=
for shot in $(sed -n 's/.*data-shot="\([^"]*\)".*/\1/p' "$dir/index.html"); do
  [ -f "$shots/${shot}_demo.png" ] || missing="$missing ${shot}_demo.png"
done
if [ -n "$missing" ]; then
  echo "Missing screenshots in $shots:$missing" >&2
  exit 1
fi
page="file://$dir/index.html?shots=file://$shots&theme=$theme"

for candidate in google-chrome google-chrome-stable chromium \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; do
  if command -v "$candidate" >/dev/null 2>&1 || [ -x "$candidate" ]; then
    chrome=$candidate
    break
  fi
done
: "${chrome:?Chrome not found}"

png=$out
case $out in *.webp) png="${out%.webp}.png" ;; esac

"$chrome" --headless=new --disable-gpu --hide-scrollbars \
  --allow-file-access-from-files --force-device-scale-factor=3 \
  --window-size=1600,1000 --virtual-time-budget=10000 \
  --screenshot="$png" "$page"

if [ "$png" != "$out" ]; then
  cwebp -quiet -q 90 -m 6 "$png" -o "$out"
  rm "$png"
fi
