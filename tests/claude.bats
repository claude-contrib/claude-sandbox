#!/usr/bin/env bats

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  # Reset config vars so tests don't leak state to each other
  unset CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL

  # Source the wrapper script (BASH_SOURCE guard prevents main from running)
  source "$REPO_ROOT/claude"

  # Mock external commands by default
  docker() { :; }
  git() { :; }
  gum() {
    case "$1" in
      log)
        shift
        echo "${@: -1}"
        ;;
      spin)
        shift
        while [[ $# -gt 0 && "$1" != "--" ]]; do shift; done
        [[ "$1" == "--" ]] && shift
        "$@"
        ;;
    esac
  }
  export -f docker git gum
}

# ---------------------------------------------------------------------------
# _show_help
# ---------------------------------------------------------------------------

@test "_show_help prints version from version.txt" {
  local expected_version
  expected_version="$(cat "$REPO_ROOT/version.txt")"
  run _show_help
  [[ "$output" == *"claude-sandbox ${expected_version}"* ]]
}

@test "_show_help contains --sandbox flag" {
  run _show_help
  [[ "$output" == *"--sandbox"* ]]
}

@test "_show_help contains --sandbox-help flag" {
  run _show_help
  [[ "$output" == *"--sandbox-help"* ]]
}


@test "_show_help contains repo URL" {
  run _show_help
  [[ "$output" == *"https://github.com/claude-contrib/claude-sandbox"* ]]
}

# ---------------------------------------------------------------------------
# gum log
# ---------------------------------------------------------------------------

@test "gum log calls gum" {
  gum() { echo "gum called: $*"; }
  export -f gum
  run gum log --level info "hello world"
  [[ "$output" == *"gum called: log --level info hello world"* ]]
}

# ---------------------------------------------------------------------------
# gum spin
# ---------------------------------------------------------------------------

@test "gum spin calls gum spin" {
  gum() { echo "gum: $*"; }
  export -f gum
  run gum spin --title "doing stuff" -- echo "hello"
  [[ "$output" == *"gum: spin --title doing stuff -- echo hello"* ]]
}

# ---------------------------------------------------------------------------
# _get_project_path
# ---------------------------------------------------------------------------

@test "_get_project_path returns git root with .devcontainer/devcontainer.json" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  mkdir -p "$tmpdir/.devcontainer"
  touch "$tmpdir/.devcontainer/devcontainer.json"

  git() { echo "$tmpdir"; }
  export -f git

  run _get_project_path
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$tmpdir" ]]

  rm -rf "$tmpdir"
}

@test "_get_project_path returns git root with .devcontainer.json" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  touch "$tmpdir/.devcontainer.json"

  git() { echo "$tmpdir"; }
  export -f git

  run _get_project_path
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$tmpdir" ]]

  rm -rf "$tmpdir"
}

@test "_get_project_path fails when not in a git repo" {
  git() { return 1; }
  export -f git

  run _get_project_path
  [[ "$status" -eq 1 ]]
}

@test "_get_project_path fails in git repo without devcontainer config" {
  local tmpdir
  tmpdir="$(mktemp -d)"

  git() { echo "$tmpdir"; }
  export -f git

  run _get_project_path
  [[ "$status" -eq 1 ]]

  rm -rf "$tmpdir"
}

@test "_get_project_path works from subdirectory" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  mkdir -p "$tmpdir/.devcontainer" "$tmpdir/subdir/nested"
  touch "$tmpdir/.devcontainer/devcontainer.json"

  git() { echo "$tmpdir"; }
  export -f git

  cd "$tmpdir/subdir/nested"
  run _get_project_path
  [[ "$status" -eq 0 ]]
  [[ "$output" == "$tmpdir" ]]

  rm -rf "$tmpdir"
}

# ---------------------------------------------------------------------------
# _get_container_id
# ---------------------------------------------------------------------------

@test "_get_container_id returns container ID from docker ps" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  mkdir -p "$tmpdir/.devcontainer"
  touch "$tmpdir/.devcontainer/devcontainer.json"

  git() { echo "$tmpdir"; }
  docker() { echo "abc123def456"; }
  export -f git docker

  run _get_container_id
  [[ "$status" -eq 0 ]]
  [[ "$output" == "abc123def456" ]]

  rm -rf "$tmpdir"
}

@test "_get_container_id fails when docker ps returns empty" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  mkdir -p "$tmpdir/.devcontainer"
  touch "$tmpdir/.devcontainer/devcontainer.json"

  git() { echo "$tmpdir"; }
  docker() { echo ""; }
  export -f git docker

  run _get_container_id
  [[ "$status" -eq 1 ]]

  rm -rf "$tmpdir"
}

# ---------------------------------------------------------------------------
# _get_container_network
# ---------------------------------------------------------------------------

@test "_get_container_network returns first compose network" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  mkdir -p "$tmpdir/.devcontainer"
  touch "$tmpdir/.devcontainer/devcontainer.json"

  git() { echo "$tmpdir"; }
  docker() {
    case "$1" in
      ps) echo "abc123" ;;
      inspect) printf "bridge\nmyproject_default\n" ;;
    esac
  }
  export -f git docker

  run _get_container_network
  [[ "$status" -eq 0 ]]
  [[ "$output" == "myproject_default" ]]

  rm -rf "$tmpdir"
}

@test "_get_container_network fails when only default networks exist" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  mkdir -p "$tmpdir/.devcontainer"
  touch "$tmpdir/.devcontainer/devcontainer.json"

  git() { echo "$tmpdir"; }
  docker() {
    case "$1" in
      ps) echo "abc123" ;;
      inspect) printf "bridge\nhost\nnone\n" ;;
    esac
  }
  export -f git docker

  run _get_container_network
  [[ "$status" -eq 1 ]]

  rm -rf "$tmpdir"
}

# ---------------------------------------------------------------------------
# _get_container_image
# ---------------------------------------------------------------------------

@test "_get_container_image succeeds without pulling when image exists locally" {
  CLAUDE_DOCKER_TAG="1.0.0"
  docker() {
    case "$1" in
      image) return 0 ;;
      pull) echo "SHOULD NOT PULL"; return 1 ;;
    esac
  }
  export -f docker

  run _get_container_image
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"SHOULD NOT PULL"* ]]
}

@test "_get_container_image pulls when image not found" {
  CLAUDE_DOCKER_TAG="1.0.0"

  docker() {
    case "$1" in
      image) return 1 ;;
      pull) echo "pulled"; return 0 ;;
    esac
  }
  export -f docker

  run _get_container_image
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"pulled"* ]]
}

# ---------------------------------------------------------------------------
# _run_in_host
# ---------------------------------------------------------------------------

@test "_run_in_host finds and runs first claude binary on PATH skipping self" {
  local tmpdir
  tmpdir="$(mktemp -d)"

  # Create a fake claude binary
  cat > "$tmpdir/claude" <<'SCRIPT'
#!/bin/bash
echo "host-claude $*"
SCRIPT
  chmod +x "$tmpdir/claude"

  # Override _claude_script_this so the wrapper skips itself
  _claude_script_this="$(realpath "$REPO_ROOT/claude")"
  PATH="$tmpdir:$PATH"

  run _run_in_host --flag1 arg1
  [[ "$status" -eq 0 ]]
  [[ "$output" == "host-claude --flag1 arg1" ]]

  rm -rf "$tmpdir"
}

@test "_run_in_host errors when no claude binary found" {
  _claude_script_this="$(realpath "$REPO_ROOT/claude")"
  PATH="/nonexistent"

  run _run_in_host
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Could not find host claude binary"* ]]
}

# ---------------------------------------------------------------------------
# GH_TOKEN aliasing
# ---------------------------------------------------------------------------

@test "GITHUB_TOKEN fills GH_TOKEN when GH_TOKEN is empty" {
  unset GH_TOKEN
  export GITHUB_TOKEN="gh-token-from-github"

  # Re-source to pick up fresh state
  source "$REPO_ROOT/claude"

  # Simulate what main does for GH_TOKEN
  export GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
  [[ "$GH_TOKEN" == "gh-token-from-github" ]]
}

@test "GH_TOKEN preserved when both are set" {
  export GH_TOKEN="original-gh-token"
  export GITHUB_TOKEN="github-token-ignored"

  export GH_TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
  [[ "$GH_TOKEN" == "original-gh-token" ]]
}

# ---------------------------------------------------------------------------
# main (invoked directly, not sourced)
# ---------------------------------------------------------------------------

@test "main --sandbox-help shows wrapper help and exits" {
  run main --sandbox-help
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"claude-sandbox"* ]]
  [[ "$output" == *"--sandbox"* ]]
}

@test "main --help forwards to host claude" {
  _run_in_host() { echo "host: $*"; }
  export -f _run_in_host

  run main --help
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"host: --help"* ]]
}

@test "main --sandbox --help forwards --help to docker claude" {
  _run_in_docker() { echo "docker: $*"; }
  export -f _run_in_docker

  run main --sandbox --help
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"docker: --help"* ]]
}

@test "main --help with other args forwards all to host" {
  _run_in_host() { echo "host: $*"; }
  export -f _run_in_host

  run main --print hello --help
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"host: --print hello --help"* ]]
}

@test "main with no args and no host claude errors gracefully" {
  _claude_script_this="$(realpath "$REPO_ROOT/claude")"
  PATH="/nonexistent"

  run main
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Could not find host claude binary"* ]]
}

# ---------------------------------------------------------------------------
# _check_docker
# ---------------------------------------------------------------------------

@test "_check_docker returns 0 when docker info succeeds" {
  docker() { return 0; }
  export -f docker
  run _check_docker
  [[ "$status" -eq 0 ]]
}

@test "_check_docker returns 1 when docker info fails" {
  docker() { return 1; }
  export -f docker
  run _check_docker
  [[ "$status" -eq 1 ]]
}

# ---------------------------------------------------------------------------
# _run_in_docker
# ---------------------------------------------------------------------------

@test "_run_in_docker uses host working dir path" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"
  mkdir -p "$tmpdir/projects/myapp"
  cd "$tmpdir/projects/myapp"

  _claude_script_dir="$REPO_ROOT"
  unset SSH_AUTH_SOCK GH_TOKEN GITHUB_TOKEN CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "WORKING_DIR=$CLAUDE_HOST_WORKING_DIR" ;;
    esac
  }
  export -f docker

  run _run_in_docker
  [[ "$output" == *"WORKING_DIR=$tmpdir/projects/myapp"* ]]

  rm -rf "$tmpdir"
}

@test "_run_in_docker uses absolute path for dir outside HOME" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="/nonexistent-home-dir"
  cd "$tmpdir"

  _claude_script_dir="$REPO_ROOT"
  unset SSH_AUTH_SOCK GH_TOKEN GITHUB_TOKEN CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "WORKING_DIR=$CLAUDE_HOST_WORKING_DIR" ;;
    esac
  }
  export -f docker

  run _run_in_docker
  [[ "$output" == *"WORKING_DIR=$tmpdir"* ]]

  rm -rf "$tmpdir"
}

@test "_run_in_docker passes -T when no controlling terminal" {
  if (: </dev/tty) 2>/dev/null; then
    skip "controlling terminal available"
  fi

  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"
  cd "$tmpdir"

  _claude_script_dir="$REPO_ROOT"
  unset SSH_AUTH_SOCK GH_TOKEN GITHUB_TOKEN CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "ARGS: $*" ;;
    esac
  }
  export -f docker

  run _run_in_docker
  [[ "$output" == *"-T"* ]]

  rm -rf "$tmpdir"
}

@test "_run_in_docker reconnects to /dev/tty when piped with terminal available" {
  if ! (: </dev/tty) 2>/dev/null; then
    skip "no controlling terminal"
  fi

  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"
  cd "$tmpdir"

  _claude_script_dir="$REPO_ROOT"
  unset SSH_AUTH_SOCK GH_TOKEN GITHUB_TOKEN CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "ARGS: $*" ;;
    esac
  }
  export -f docker

  run _run_in_docker
  [[ "$output" == *"ARGS:"* ]]
  [[ "$output" != *"-T"* ]]

  rm -rf "$tmpdir"
}

@test "_run_in_docker forwards SSH_AUTH_SOCK volume and env" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"
  cd "$tmpdir"

  _claude_script_dir="$REPO_ROOT"
  local ssh_sock="$tmpdir/test-ssh.sock"
  touch "$ssh_sock"
  export SSH_AUTH_SOCK="$ssh_sock"
  unset GH_TOKEN GITHUB_TOKEN CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "ARGS: $*" ;;
    esac
  }
  export -f docker

  run _run_in_docker
  [[ "$output" == *"claude-sandbox.ssh.yml"* ]]

  unset SSH_AUTH_SOCK
  rm -rf "$tmpdir"
}

@test "_run_in_docker mounts --add-dir directory as read-only volume" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"
  cd "$tmpdir"

  local extra_dir
  extra_dir="$(mktemp -d)"

  _claude_script_dir="$REPO_ROOT"
  unset SSH_AUTH_SOCK GH_TOKEN GITHUB_TOKEN CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "ARGS: $*" ;;
    esac
  }
  export -f docker

  run _run_in_docker --add-dir "$extra_dir"
  [[ "$output" == *"--volume ${extra_dir}:${extra_dir}:ro"* ]]

  rm -rf "$tmpdir" "$extra_dir"
}

@test "_run_in_docker resolves relative --add-dir path to absolute for mount" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"

  local extra_dir
  extra_dir="$(mktemp -d)"
  cd "$extra_dir"

  _claude_script_dir="$REPO_ROOT"
  unset SSH_AUTH_SOCK GH_TOKEN GITHUB_TOKEN CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "ARGS: $*" ;;
    esac
  }
  export -f docker

  run _run_in_docker --add-dir .
  [[ "$output" == *"--volume ${extra_dir}:${extra_dir}:ro"* ]]

  rm -rf "$tmpdir" "$extra_dir"
}

@test "_run_in_docker mounts --plugin-dir directory as read-only volume" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"
  cd "$tmpdir"

  local extra_dir
  extra_dir="$(mktemp -d)"

  _claude_script_dir="$REPO_ROOT"
  unset SSH_AUTH_SOCK GH_TOKEN GITHUB_TOKEN CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "ARGS: $*" ;;
    esac
  }
  export -f docker

  run _run_in_docker --plugin-dir "$extra_dir"
  [[ "$output" == *"--volume ${extra_dir}:${extra_dir}:ro"* ]]

  rm -rf "$tmpdir" "$extra_dir"
}

@test "_run_in_docker resolves relative --plugin-dir path to absolute for mount" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"

  local extra_dir
  extra_dir="$(mktemp -d)"
  cd "$extra_dir"

  _claude_script_dir="$REPO_ROOT"
  unset SSH_AUTH_SOCK GH_TOKEN GITHUB_TOKEN CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "ARGS: $*" ;;
    esac
  }
  export -f docker

  run _run_in_docker --plugin-dir .
  [[ "$output" == *"--volume ${extra_dir}:${extra_dir}:ro"* ]]

  rm -rf "$tmpdir" "$extra_dir"
}

@test "_run_in_docker exposes GH_TOKEN to docker compose environment" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"
  cd "$tmpdir"

  _claude_script_dir="$REPO_ROOT"
  export GH_TOKEN="test-token"
  unset SSH_AUTH_SOCK GITHUB_TOKEN CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL

  docker() {
    case "$1" in
      info)    return 0 ;;
      image)   return 0 ;;
      compose) echo "GH_TOKEN=${GH_TOKEN}" ;;
    esac
  }
  export -f docker

  run _run_in_docker
  [[ "$output" == *"GH_TOKEN=test-token"* ]]

  unset GH_TOKEN
  rm -rf "$tmpdir"
}

# ---------------------------------------------------------------------------
# _resolve_docker_env — host identity vars
# ---------------------------------------------------------------------------

@test "_resolve_docker_env sets CLAUDE_HOST_USER to current username" {
  _resolve_docker_env
  [[ "$CLAUDE_HOST_USER" == "$(id -un)" ]]
}

@test "_resolve_docker_env sets CLAUDE_HOST_UID to current user ID" {
  _resolve_docker_env
  [[ "$CLAUDE_HOST_UID" == "$(id -u)" ]]
}

@test "_resolve_docker_env sets CLAUDE_HOST_GID to current group ID" {
  _resolve_docker_env
  [[ "$CLAUDE_HOST_GID" == "$(id -g)" ]]
}

@test "_resolve_docker_env sets CLAUDE_HOST_HOME to HOME" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"

  _resolve_docker_env
  [[ "$CLAUDE_HOST_HOME" == "$tmpdir" ]]

  rm -rf "$tmpdir"
}

@test "_resolve_docker_env does not set CLAUDE_DOCKER_HOME" {
  unset CLAUDE_DOCKER_HOME
  _resolve_docker_env
  [[ -z "${CLAUDE_DOCKER_HOME:-}" ]]
}

@test "_resolve_docker_env defaults CLAUDE_CONFIG_DIR to ~/.config/claude" {
  unset CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL
  _resolve_docker_env
  [[ "$CLAUDE_CONFIG_DIR" == "$HOME/.config/claude" ]]
}

@test "_resolve_docker_env defaults GIT_CONFIG_GLOBAL to ~/.config/git/config" {
  unset CLAUDE_CONFIG_DIR GIT_CONFIG_GLOBAL
  _resolve_docker_env
  [[ "$GIT_CONFIG_GLOBAL" == "$HOME/.config/git/config" ]]
}

@test "_resolve_docker_env accepts CLAUDE_CONFIG_DIR under ~/.config" {
  export CLAUDE_CONFIG_DIR="$HOME/.config/my-claude"
  unset GIT_CONFIG_GLOBAL
  run _resolve_docker_env
  [[ "$status" -eq 0 ]]
}

@test "_resolve_docker_env accepts CLAUDE_CONFIG_DIR equal to ~/.config" {
  export CLAUDE_CONFIG_DIR="$HOME/.config"
  unset GIT_CONFIG_GLOBAL
  run _resolve_docker_env
  [[ "$status" -eq 0 ]]
}

@test "_resolve_docker_env rejects CLAUDE_CONFIG_DIR outside ~/.config" {
  export CLAUDE_CONFIG_DIR="$HOME/.claude"
  unset GIT_CONFIG_GLOBAL

  run _resolve_docker_env
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"CLAUDE_CONFIG_DIR must be under ~/.config"* ]]
}

@test "_resolve_docker_env rejects GIT_CONFIG_GLOBAL outside ~/.config" {
  unset CLAUDE_CONFIG_DIR
  export GIT_CONFIG_GLOBAL="$HOME/.gitconfig"

  run _resolve_docker_env
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"GIT_CONFIG_GLOBAL must be under ~/.config"* ]]
}

@test "_run_in_docker exits with error when Docker is not running" {
  docker() { return 1; }   # all docker calls fail — daemon is down
  export -f docker

  run _run_in_docker
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"Docker is not running"* ]]
}
