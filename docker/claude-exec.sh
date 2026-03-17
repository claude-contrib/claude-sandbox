#!/usr/bin/env bash

set -euo pipefail

[ -z "${DEBUG:-}" ] || set -x

: "${CLAUDE_HOST_UID:?CLAUDE_HOST_UID is required}"
: "${CLAUDE_HOST_GID:?CLAUDE_HOST_GID is required}"
: "${CLAUDE_HOST_USER:?CLAUDE_HOST_USER is required}"
: "${CLAUDE_HOST_HOME:?CLAUDE_HOST_HOME is required}"

# Create the primary group if it doesn't already exist.
if ! getent group "$CLAUDE_HOST_GID" >/dev/null 2>&1; then
  groupadd -g "$CLAUDE_HOST_GID" "$CLAUDE_HOST_USER"
fi

# Create the user.
useradd \
  -u "$CLAUDE_HOST_UID" \
  -g "$CLAUDE_HOST_GID" \
  -G nixbld \
  -d "$CLAUDE_HOST_HOME" \
  -s /bin/bash \
  "$CLAUDE_HOST_USER"

# Set up required directories under the user's home.
install -d -o "$CLAUDE_HOST_UID" -g "$CLAUDE_HOST_GID" \
  "$CLAUDE_HOST_HOME/.cache" \
  "$CLAUDE_HOST_HOME/.local/bin" \
  "$CLAUDE_HOST_HOME/.local/share/claude" \
  "$CLAUDE_HOST_HOME/.config/claude"

# Copy managed settings to the user's settings location.
claude_settings_path="/etc/claude/settings.json"

# Drop privileges and execute claude.
if [[ -f flake.nix ]]; then
  exec gosu "$CLAUDE_HOST_USER" \
    nix develop .# \
    --accept-flake-config \
    --no-update-lock-file \
    --command claude --settings "$claude_settings_path" "$@"
else
  exec gosu "$CLAUDE_HOST_USER" \
    claude --settings "$claude_settings_path" "$@"
fi
