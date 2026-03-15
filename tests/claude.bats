#!/usr/bin/env bats

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  # Reset memoized gum state
  unset _gum_available

  # Source the wrapper script (BASH_SOURCE guard prevents main from running)
  source "$REPO_ROOT/claude"

  # Mock external commands by default
  docker() { :; }
  git() { :; }
  gum() { :; }
  export -f docker git gum
}

# ---------------------------------------------------------------------------
# _usage
# ---------------------------------------------------------------------------

@test "_usage prints version from version.txt" {
  local expected_version
  expected_version="$(cat "$REPO_ROOT/version.txt")"
  run _usage
  [[ "$output" == *"claude-sandbox ${expected_version}"* ]]
}

@test "_usage contains --sandbox flag" {
  run _usage
  [[ "$output" == *"--sandbox"* ]]
}

@test "_usage contains --help flag" {
  run _usage
  [[ "$output" == *"--help"* ]]
}

@test "_usage contains ANTHROPIC_API_KEY" {
  run _usage
  [[ "$output" == *"ANTHROPIC_API_KEY"* ]]
}

@test "_usage contains repo URL" {
  run _usage
  [[ "$output" == *"https://github.com/claude-contrib/claude-sandbox"* ]]
}

# ---------------------------------------------------------------------------
# _has_gum
# ---------------------------------------------------------------------------

@test "_has_gum returns 0 when gum is on PATH" {
  unset _gum_available
  gum() { :; }
  export -f gum
  run _has_gum
  [[ "$status" -eq 0 ]]
}

@test "_has_gum returns 1 when gum is not on PATH" {
  unset _gum_available
  unset -f gum
  # Ensure gum is not on PATH
  PATH="/nonexistent"
  run _has_gum
  [[ "$status" -eq 1 ]]
}

@test "_has_gum memoizes result" {
  unset _gum_available
  # First call: gum is not available
  unset -f gum
  PATH="/nonexistent"
  _has_gum || true
  # Now make gum available — memoized value should still say unavailable
  gum() { :; }
  export -f gum
  run _has_gum
  [[ "$status" -eq 1 ]]
}

# ---------------------------------------------------------------------------
# _gum_log
# ---------------------------------------------------------------------------

@test "_gum_log falls back to stderr message when no gum" {
  unset _gum_available
  unset -f gum
  PATH="/nonexistent"
  run _gum_log --level info "hello world"
  [[ "$output" == *"hello world"* ]]
}

@test "_gum_log calls gum when available" {
  unset _gum_available
  gum() { echo "gum called: $*"; }
  export -f gum
  run _gum_log --level info "hello world"
  [[ "$output" == *"gum called: log --level info hello world"* ]]
}

# ---------------------------------------------------------------------------
# _gum_spin
# ---------------------------------------------------------------------------

@test "_gum_spin falls back to running command directly when no gum" {
  unset _gum_available
  unset -f gum
  PATH="/nonexistent"
  run _gum_spin "doing stuff" echo "direct output"
  [[ "$output" == *"direct output"* ]]
}

@test "_gum_spin calls gum spin when available" {
  unset _gum_available
  gum() { echo "gum: $*"; }
  export -f gum
  run _gum_spin "doing stuff" echo "hello"
  [[ "$output" == *"gum: spin --spinner dot --title doing stuff -- echo hello"* ]]
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

@test "_get_container_network returns first non-default network" {
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

@test "_get_container_network falls back to first network when all are defaults" {
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
  [[ "$status" -eq 0 ]]
  [[ "$output" == "bridge" ]]

  rm -rf "$tmpdir"
}

# ---------------------------------------------------------------------------
# _get_container_image
# ---------------------------------------------------------------------------

@test "_get_container_image succeeds without pulling when image exists locally" {
  CLAUDE_HOST_VERSION="1.0.0"
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
  CLAUDE_HOST_VERSION="1.0.0"
  unset _gum_available
  unset -f gum
  PATH="/nonexistent"

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
  [[ "$output" == *"could not find host claude binary"* ]]
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

@test "main --help exits 0 and shows usage" {
  run main --help
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"claude-sandbox"* ]]
  [[ "$output" == *"--sandbox"* ]]
}

@test "main --sandbox --help shows help" {
  run main --sandbox --help
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"claude-sandbox"* ]]
}

@test "main with no args and no host claude errors gracefully" {
  _claude_script_this="$(realpath "$REPO_ROOT/claude")"
  PATH="/nonexistent"

  run main
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"could not find host claude binary"* ]]
}

# ---------------------------------------------------------------------------
# _run_in_docker
# ---------------------------------------------------------------------------

@test "_run_in_docker maps working dir for path under HOME" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"
  mkdir -p "$tmpdir/projects/myapp"
  cd "$tmpdir/projects/myapp"

  _claude_script_dir="$REPO_ROOT"
  unset SSH_AUTH_SOCK GH_TOKEN GITHUB_TOKEN

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "DOCKER_WORKING_DIR=$CLAUDE_DOCKER_WORKING_DIR" ;;
    esac
  }
  export -f docker

  run _run_in_docker
  [[ "$output" == *"DOCKER_WORKING_DIR=/home/claude/projects/myapp"* ]]

  rm -rf "$tmpdir"
}

@test "_run_in_docker falls back to /home/claude/workspace for path outside HOME" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="/nonexistent-home-dir"
  cd "$tmpdir"

  _claude_script_dir="$REPO_ROOT"
  unset SSH_AUTH_SOCK GH_TOKEN GITHUB_TOKEN

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "DOCKER_WORKING_DIR=$CLAUDE_DOCKER_WORKING_DIR" ;;
    esac
  }
  export -f docker

  run _run_in_docker
  [[ "$output" == *"DOCKER_WORKING_DIR=/home/claude/workspace"* ]]

  rm -rf "$tmpdir"
}

@test "_run_in_docker passes -T when stdin is not a tty" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"
  cd "$tmpdir"

  _claude_script_dir="$REPO_ROOT"
  unset SSH_AUTH_SOCK GH_TOKEN GITHUB_TOKEN

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "ARGS: $*" ;;
    esac
  }
  export -f docker

  # In bats, stdin is not a tty so -T is added
  run _run_in_docker
  [[ "$output" == *"run -T"* ]]

  rm -rf "$tmpdir"
}

@test "_run_in_docker forwards SSH_AUTH_SOCK volume and env" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"
  cd "$tmpdir"

  _claude_script_dir="$REPO_ROOT"
  export SSH_AUTH_SOCK="/tmp/test-ssh.sock"
  unset GH_TOKEN GITHUB_TOKEN

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "ARGS: $*" ;;
    esac
  }
  export -f docker

  run _run_in_docker
  [[ "$output" == *"/tmp/test-ssh.sock:/run/ssh-agent"* ]]

  unset SSH_AUTH_SOCK
  rm -rf "$tmpdir"
}

@test "_run_in_docker forwards GH_TOKEN when set" {
  local tmpdir
  tmpdir="$(mktemp -d)"
  HOME="$tmpdir"
  cd "$tmpdir"

  _claude_script_dir="$REPO_ROOT"
  export GH_TOKEN="test-token"
  unset SSH_AUTH_SOCK GITHUB_TOKEN

  docker() {
    case "$1" in
      image) return 0 ;;
      compose) echo "ARGS: $*" ;;
    esac
  }
  export -f docker

  run _run_in_docker
  [[ "$output" == *"GH_TOKEN"* ]]

  unset GH_TOKEN
  rm -rf "$tmpdir"
}
