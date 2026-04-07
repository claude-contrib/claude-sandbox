#!/usr/bin/env bash

set -euo pipefail

[ -z "${DEBUG:-}" ] || set -x

: "${CLAUDE_HOST_UID:?CLAUDE_HOST_UID is required}"
: "${CLAUDE_HOST_GID:?CLAUDE_HOST_GID is required}"
: "${CLAUDE_HOST_USER:?CLAUDE_HOST_USER is required}"
: "${CLAUDE_HOST_HOME:?CLAUDE_HOST_HOME is required}"

CLAUDE_DOCKER_GROUP="nixbld"
CLAUDE_DOCKER_SHELL="/bin/bash"

# Create the primary group if it doesn't already exist.
if ! getent group "$CLAUDE_HOST_GID" >/dev/null 2>&1; then
  groupadd --non-unique -g "$CLAUDE_HOST_GID" "$CLAUDE_HOST_USER"
fi

# Create the user.
useradd --non-unique \
  -u "$CLAUDE_HOST_UID" \
  -g "$CLAUDE_HOST_GID" \
  -G "$CLAUDE_DOCKER_GROUP" \
  -d "$CLAUDE_HOST_HOME" \
  -s "$CLAUDE_DOCKER_SHELL" \
  "$CLAUDE_HOST_USER" 2>/dev/null

# Set up required directories under the user's home.
# $HOME itself is not bind-mounted (only ~/.config is), so ensure it exists.
install -d -o "$CLAUDE_HOST_UID" -g "$CLAUDE_HOST_GID" \
  "$CLAUDE_HOST_HOME" \
  "$CLAUDE_HOST_HOME/.cache" \
  "$CLAUDE_HOST_HOME/.local/bin" \
  "$CLAUDE_HOST_HOME/.local/share/claude"

# Fix ownership of nix state and named volumes (may have stale ownership).
chown -R "$CLAUDE_HOST_UID:$CLAUDE_HOST_GID" /nix/var "$CLAUDE_HOST_HOME/.cache" "$CLAUDE_HOST_HOME/.local"

# Fix SSH agent socket ownership so the container user can connect.
if [[ -n "${SSH_AUTH_SOCK:-}" ]] && [[ -e "${SSH_AUTH_SOCK}" ]]; then
  chown "$CLAUDE_HOST_UID:$CLAUDE_HOST_GID" "$SSH_AUTH_SOCK"
  chmod 660 "$SSH_AUTH_SOCK"
fi

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
