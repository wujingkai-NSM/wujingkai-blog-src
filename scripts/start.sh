#!/usr/bin/env bash
# Start the Hugo dev server for this blog (run from anywhere; paths are resolved relative to this file)
set -e
cd "$(dirname "$0")/.."

HUGO_WINGET="/c/Users/wu-ji/AppData/Local/Microsoft/WinGet/Packages/Hugo.Hugo.Extended_Microsoft.Winget.Source_8wekyb3d8bbwe/hugo.exe"

if command -v hugo >/dev/null 2>&1; then
  hugo server
elif [ -x "$HUGO_WINGET" ]; then
  echo "hugo not on PATH, using winget install: $HUGO_WINGET"
  "$HUGO_WINGET" server
else
  echo "ERROR: hugo not found. Install with: winget install Hugo.Hugo.Extended" >&2
  exit 1
fi
