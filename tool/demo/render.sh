#!/usr/bin/env sh
# Renders tool/demo/index.html with the integration test screenshots to a PNG:
#   tool/demo/render.sh <screenshots dir> <output.png>
set -eu
shots=$(cd "$1" && pwd)
out=$2
page="file://$(cd "$(dirname "$0")" && pwd)/index.html?shots=file://$shots"

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
  --window-size=1600,1040 --virtual-time-budget=10000 \
  --screenshot="$out" "$page"
