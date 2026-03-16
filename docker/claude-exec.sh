#!/usr/bin/env bash

set -euo pipefail

[ -z "${DEBUG:-}" ] || set -x

claude_settings_path="/home/claude/.local/share/claude/settings.json"

if [ -f flake.nix ]; then
  nix develop .# \
    --accept-flake-config \
    --no-update-lock-file \
    --command claude --settings "$claude_settings_path" "$@"
else
  claude --settings "$claude_settings_path" "$@"
fi
