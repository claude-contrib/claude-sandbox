#!/usr/bin/env bash

set -euo pipefail

[ -z "${DEBUG:-}" ] || set -x

claude_settings_list=()

for f in "${CLAUDE_CONFIG_DIR}"/settings.*.json; do
  [[ -f "$f" ]] && claude_settings_list+=("$f")
done

claude_settings_path="/home/claude/.local/share/claude/settings.json"
claude_settings_list+=("$claude_settings_path")

if [[ ${#claude_settings_list[@]} -gt 1 ]]; then
  claude_settings_temp=$(mktemp /tmp/claude-settings-XXXXXX.json)
  trap 'rm -f "$claude_settings_temp"' EXIT
  jq -s 'reduce .[] as $x ({}; . * $x)' "${claude_settings_list[@]}" >"$claude_settings_temp"
  claude_settings_path="$claude_settings_temp"
fi

if [ -f flake.nix ]; then
  nix develop .# \
    --accept-flake-config \
    --no-update-lock-file \
    --command claude --settings "$claude_settings_path" "$@"
else
  claude --settings "$claude_settings_path" "$@"
fi
