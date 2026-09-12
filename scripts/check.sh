#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

for command_name in node jq; do
  if ! command -v "$command_name" >/dev/null; then
    printf 'Required check dependency not found: %s\n' "$command_name" >&2
    exit 1
  fi
done

node --test tests/*.test.mjs
jq -e '
  .schemaVersion == 1
  and .id == "io.github.pbjorklund.secondary-black-background"
  and .kinds == ["service"]
  and .entryPoints.service == "Service.qml"
' manifest.json >/dev/null

bash -n scripts/*.sh
if command -v shellcheck >/dev/null; then
  shellcheck scripts/*.sh
fi
if command -v omarchy >/dev/null; then
  omarchy plugin validate .
fi
