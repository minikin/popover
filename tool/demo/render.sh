#!/usr/bin/env sh
# Renders tool/demo/index.html with the integration test screenshots to a PNG:
#   tool/demo/render.sh <screenshots dir> <output.png> [dark|light]
set -eu
shots=$(cd "$1" && pwd)
out=$2
theme=${3:-dark}
page="file://$(cd "$(dirname "$0")" && pwd)/index.html?shots=file://$shots&theme=$theme"

for candidate in google-chrome google-chrome-stable chromium \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; do
  if command -v "$candidate" >/dev/null 2>&1 || [ -x "$candidate" ]; then
    chrome=$candidate
    break
  fi
done
: "${chrome:?Chrome not found}"

"$chrome" --headless=new --disable-gpu --hide-scrollbars \
  --allow-file-access-from-files --force-device-scale-factor=2 \
  --window-size=1600,1000 --virtual-time-budget=10000 \
  --screenshot="$out" "$page"
