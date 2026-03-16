#!/usr/bin/env bash
set -euo pipefail

CLAUDE_SETTINGS_PATH="/home/claude/.local/share/claude/settings.json"

if [ -f flake.nix ]; then
  nix develop .# \
    --accept-flake-config \
    --no-update-lock-file \
    --command claude --settings "$CLAUDE_SETTINGS_PATH" "$@"
else
  claude --settings "$CLAUDE_SETTINGS_PATH" "$@"
fi
