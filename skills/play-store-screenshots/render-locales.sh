#!/usr/bin/env bash
# Renders localized Play Store screenshots with headless Chrome/Chromium.
# Requires index.html's single-canvas mode: ?locale=<code>&render=<slide id|feature-graphic>
#
#   bash render-locales.sh                # every locale in config.locales except en
#   bash render-locales.sh ja ko          # only these
#
# Env overrides:
#   CHROME=/path/to/chrome   browser binary (auto-detected otherwise)
#   SERVE_ROOT=..            directory to serve (default: this folder)
#   PAGE_PATH=/mockups/      URL path of index.html under SERVE_ROOT (default: /)
#   OUT=exports              output folder (default: ./exports)
#   PORT=8765
#
# Output: $OUT/phone/<locale>/NN-<id>-1080x1920.png
#         $OUT/feature-graphic/<locale>/feature-graphic-1024x500.png
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SERVE_ROOT="${SERVE_ROOT:-$HERE}"
PAGE_PATH="${PAGE_PATH:-/}"
OUT="${OUT:-$HERE/exports}"
PORT="${PORT:-8765}"

if [ -z "${CHROME:-}" ]; then
  for c in chromium chromium-browser google-chrome google-chrome-stable chrome \
           "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; do
    if command -v "$c" >/dev/null 2>&1 || [ -x "$c" ]; then CHROME="$c"; break; fi
  done
fi
[ -n "${CHROME:-}" ] || { echo "No Chrome/Chromium found; set CHROME=/path/to/browser" >&2; exit 1; }

# Slide ids + locales straight from config.js (needs node; config.js is a plain script).
read_config() {
  node -e "
    const vm = require('vm'), fs = require('fs'), ctx = {};
    vm.runInNewContext(fs.readFileSync('$HERE/config.js', 'utf8') + ';this.__c = config;', ctx);
    console.log(ctx.__c.$1.join(' '));
  "
}
command -v node >/dev/null || { echo "node is required to read config.js" >&2; exit 1; }
read -r -a SLIDES <<< "$(read_config 'slides.map(s => s.id)')"
LOCALES=("$@")
[ ${#LOCALES[@]} -eq 0 ] && read -r -a LOCALES <<< "$(read_config 'locales')"

HAS_PIL=1
python3 -c "import PIL" 2>/dev/null || { HAS_PIL=0; echo "Pillow not found — PNGs keep their alpha channel (Play rejects alpha; flatten before upload)" >&2; }

python3 -m http.server "$PORT" --directory "$SERVE_ROOT" >/dev/null 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null' EXIT
sleep 1

shot() { # url width height out
  "$CHROME" --headless=new --hide-scrollbars --force-device-scale-factor=1 \
    --window-size="$2,$3" --virtual-time-budget=20000 --screenshot="$4" "$1" >/dev/null 2>&1
  if [ "$HAS_PIL" = 1 ]; then
    python3 -c "import sys;from PIL import Image;Image.open(sys.argv[1]).convert('RGB').save(sys.argv[1])" "$4"
  fi
}

BASE="http://localhost:$PORT$PAGE_PATH"
for loc in "${LOCALES[@]}"; do
  [ "$loc" = en ] && [ $# -eq 0 ] && { echo "skipping en (render it explicitly: bash render-locales.sh en)"; continue; }
  mkdir -p "$OUT/phone/$loc" "$OUT/feature-graphic/$loc"
  for i in "${!SLIDES[@]}"; do
    id=${SLIDES[$i]}; n=$(printf "%02d" $((i + 1)))
    shot "$BASE?locale=$loc&render=$id" 1080 1920 "$OUT/phone/$loc/$n-$id-1080x1920.png"
  done
  shot "$BASE?locale=$loc&render=feature-graphic" 1024 500 "$OUT/feature-graphic/$loc/feature-graphic-1024x500.png"
  echo "$loc done"
done
