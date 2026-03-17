#!/bin/bash

# Check if the Docker daemon is reachable.
# Returns: 0 if Docker is running, 1 otherwise.
_check_docker() {
  docker info &>/dev/null
}

# Get the project root if it has a devcontainer configuration.
# Uses git to resolve the project root, then checks for
# .devcontainer/devcontainer.json or .devcontainer.json.
# Stdout: absolute path to the project root.
# Returns: 0 if a devcontainer config exists, 1 otherwise.
_get_project_path() {
  local project_path
  project_path="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1

  [[ -f "$project_path/.devcontainer/devcontainer.json" ]] && echo "$project_path" && return 0
  [[ -f "$project_path/.devcontainer.json" ]] && echo "$project_path" && return 0

  return 1
}

# Get the container ID of a running devcontainer for the current project.
# Queries docker for containers with the devcontainer.local_folder label
# matching the project root. Returns the first running match.
# Stdout: short container ID.
# Returns: 0 if a running devcontainer is found, 1 otherwise.
_get_container_id() {
  local project_path
  project_path="$(_get_project_path)" || return 1

  local container_id
  container_id="$(docker ps -q \
    --filter "label=devcontainer.local_folder=$project_path" \
    --filter "status=running" \
    2>/dev/null | head -n1)" || return 1

  if [[ -n "$container_id" ]]; then
    echo "$container_id"
  else
    return 1
  fi
}

# Get the Docker network of a running devcontainer for the current project.
# Inspects the container's attached networks and returns the first
# non-default one (preferring compose-created networks like myproject_default).
# Falls back to the first network if all are default types.
# Stdout: Docker network name.
# Returns: 0 if a network is found, 1 otherwise.
_get_container_network() {
  local container_id
  container_id="$(_get_container_id)" || return 1

  local network_list
  network_list="$(docker inspect "$container_id" \
    --format '{{range $name, $_ := .NetworkSettings.Networks}}{{$name}}{{"\n"}}{{end}}' \
    2>/dev/null)" || return 1

  local network
  while IFS= read -r network; do
    case "$network" in
    bridge | host | none | "") continue ;;
    *)
      echo "$network"
      return 0
      ;;
    esac
  done <<<"$network_list"

  # No non-default network found; fall back to the first network on the list.
  # This can happen when the devcontainer only uses default Docker networks
  # (bridge/host/none), which is unusual but should still be usable.
  network="$(echo "$network_list" | head -n1)"

  if [[ -n "$network" ]]; then
    echo "$network"
  else
    return 1
  fi
}

# Ensure the container image is available locally, pulling if needed.
_get_container_image() {
  local image="ghcr.io/claude-contrib/claude-sandbox:${CLAUDE_DOCKER_TAG}"
  if docker image inspect "$image" &>/dev/null; then
    return 0
  fi
  _gum spin "Pulling Docker image $image" docker pull "$image"
}

# Get the group ID of a file as seen from inside the sandbox container.
# Mounts the file into a temporary container and stats it, ensuring the GID
# reflects the container's view rather than the host's. Used to map the SSH
# agent socket group so the in-container user can access it.
# Args: $1 - absolute path to the file to stat (e.g. $SSH_AUTH_SOCK).
# Stdout: numeric group ID.
# Returns: 0 on success; on failure outputs nothing and the caller falls back
#          to the default group (CLAUDE_USER_GROUP:-1000).
_get_container_group() {
  local fpath="$1"
  local image="ghcr.io/claude-contrib/claude-sandbox:${CLAUDE_DOCKER_TAG}"
  docker run --rm -v "$fpath:/var/group" "$image" stat -c "%g" /var/group 2>/dev/null
}
