#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="$(mktemp -d)"
trap 'rm -rf "$PROFILE"' EXIT

command -v chromium >/dev/null
chromium \
  --headless=new \
  --disable-gpu \
  --hide-scrollbars \
  --no-first-run \
  --user-data-dir="$PROFILE" \
  --window-size=1600,900 \
  --screenshot="$ROOT/preview.png" \
  "file://$ROOT/assets/preview.html" >/dev/null 2>&1

file "$ROOT/preview.png"
