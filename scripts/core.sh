#!/bin/bash

# Check if gum is available (memoized).
_has_gum() {
  if [ -z "${_gum_available+x}" ]; then
    if command -v gum &>/dev/null; then
      _gum_available=1
    else
      _gum_available=0
    fi
  fi
  [ "$_gum_available" -eq 1 ]
}

# Gum wrapper. Dispatches to the matching gum subcommand when available,
# falls back to plain stderr output otherwise.
# Usage: _gum log --level info "message"
#        _gum spin "title" cmd [args...]
_gum() {
  local subcmd="$1"
  shift
  case "$subcmd" in
  log)
    if _has_gum; then
      gum log "$@"
    else
      local msg="${*: -1}"
      printf '%s\n' "$msg" >&2
    fi
    ;;
  spin)
    local title="$1"
    shift
    if _has_gum; then
      gum spin --spinner dot --title "$title" -- "$@"
    else
      printf '%s\n' "$title" >&2
      "$@"
    fi
    ;;
  esac
}
