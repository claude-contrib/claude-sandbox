#!/bin/bash

# Get the project root if it has a devcontainer configuration.
# Uses git to resolve the project root, then checks for
# .devcontainer/devcontainer.json or .devcontainer.json.
# Stdout: absolute path to the project root.
# Returns: 0 if a devcontainer config exists, 1 otherwise.
_get_project_path() {
  local project_path
  project_path="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1

  [ -f "$project_path/.devcontainer/devcontainer.json" ] && echo "$project_path" && return 0
  [ -f "$project_path/.devcontainer.json" ] && echo "$project_path" && return 0

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

  if [ -n "$container_id" ]; then
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

  # fallback: use first network even if it's a default type
  network="$(echo "$network_list" | head -n1)"

  if [ -n "$network" ]; then
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
