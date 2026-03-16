#!/usr/bin/env bash

set -euo pipefail

[ -z "${DEBUG:-}" ] || set -x

claude_settings_path="/home/claude/.local/share/claude/settings.json"
claude_system_prompt="You are running inside a Docker container as user 'claude' (home: /home/claude). The working directory path is a bind mount from the host — it does not reflect your user identity."

# Extract --append-system-prompt values from args and concatenate them
# into claude_system_prompt, rebuilding the remaining args.
filtered_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --append-system-prompt=*)
      claude_system_prompt+=$'\n'"${1#--append-system-prompt=}"
      shift
      ;;
    --append-system-prompt)
      claude_system_prompt+=$'\n'"${2:-}"
      shift 2
      ;;
    *)
      filtered_args+=("$1")
      shift
      ;;
  esac
done

if [ -f flake.nix ]; then
  nix develop .# \
    --accept-flake-config \
    --no-update-lock-file \
    --command claude --settings "$claude_settings_path" --append-system-prompt "$claude_system_prompt" "${filtered_args[@]}"
else
  claude --settings "$claude_settings_path" --append-system-prompt "$claude_system_prompt" "${filtered_args[@]}"
fi
