#!/usr/bin/env bash

set -euo pipefail

[ -z "${DEBUG:-}" ] || set -x

claude_settings_path="/home/claude/.local/share/claude/settings.json"
claude_system_prompt="You are running inside a Docker container as user 'claude' (home: /home/claude). The working directory path is a bind mount from the host — it does not reflect your user identity."

if [ -f flake.nix ]; then
  nix develop .# \
    --accept-flake-config \
    --no-update-lock-file \
    --command claude --settings "$claude_settings_path" --append-system-prompt "$claude_system_prompt" "$@"
else
  claude --settings "$claude_settings_path" --append-system-prompt "$claude_system_prompt" "$@"
fi
