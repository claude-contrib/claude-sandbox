# Claude Sandbox

> Sandboxed Docker environment for [Claude Code](https://claude.ai/code) — full autonomy, zero risk to your host.

[![Release](https://img.shields.io/github/v/release/claude-contrib/claude-sandbox)](https://github.com/claude-contrib/claude-sandbox/releases/latest)
[![Docker](https://img.shields.io/badge/ghcr.io-claude--sandbox-blue?logo=docker)](https://ghcr.io/claude-contrib/claude-sandbox)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Run Claude Code in an isolated Docker container with `bypassPermissions` enabled, Nix flake support, your **git repo root** mounted **read-write** (worktree-aware), and automatic devcontainer network detection. One command, two modes: forward to the host binary by default, or sandbox with a flag.

## How It Works

The `claude` wrapper script sits in your `$PATH` ahead of the real binary:

| Mode | Trigger | What happens |
|------|---------|--------------|
| **Forward** (default) | `claude` | Finds the host `claude` binary and runs it directly |
| **Sandbox** | `claude --sandbox` | Launches Claude Code inside a Docker container with full permissions |

```
claude --sandbox "fix the bug"
└── wrapper detects --sandbox, resolves host identity, volumes, network
      └── docker compose starts container, mounts ~/.config (ro), repo root (rw), SSH agent
            └── claude-exec.sh creates user (matching host UID/GID), drops privileges
                  └── claude runs as your user inside the sandbox
```

![Demo](docs/demo.webp)

The sandbox container comes pre-configured with:
- **Nix flakes** — auto-activates `flake.nix` if present, giving Claude access to the same compilers, linters, and dev tools you use — an equal developer in your environment
- **Project mount** — the git repo root is mounted **read-write** (falling back to `$PWD` outside a repo), so Claude can read and edit code across the entire repo including worktrees; the container's working directory is set to your actual `$PWD`
- **User identity** — the container dynamically creates a user matching your host UID, GID, and username, so file ownership on bind mounts is always correct
- **Persistent volumes** — `~/.cache` and `/nix` use dedicated Docker volumes so Nix store and cached artifacts survive container restarts without re-downloading
- **Devcontainer network** — auto-detects a running devcontainer and joins its Docker network, giving Claude access to the same databases, APIs, and services your environment exposes

## Isolation Model

The sandbox uses Docker process isolation — Claude runs in a separate container as your user but cannot affect the host system.

**Isolated:**
- Home directory — `$HOME` is **not** mounted; `~/.ssh`, `~/.gnupg`, `~/.aws`, and other dotfiles are inaccessible
- System files — no access to `/etc`, `/usr`, or host-installed packages
- Host processes — cannot see, signal, or interact with processes outside the container
- Package installation — `apt`, `brew`, and other system package managers are unavailable

**Shared (by design):**
- `~/.config` — mounted **read-only** so that git config (`GIT_CONFIG_GLOBAL`) and other host settings are available without manual setup; `CLAUDE_CONFIG_DIR` is mounted separately as **read-write** so Claude Code can persist its own state. Both must point to paths under `~/.config` (see [Configuration](#configuration))
- Git repo root — mounted **read-write** for code editing (worktree-aware; falls back to `$PWD`)
- Extra directories — any path passed via `--add-dir` or `--plugin-dir` is mounted **read-only** at the same absolute path inside the container
- Credentials — API keys, cloud provider tokens, and `GH_TOKEN` are forwarded via environment variables (see [Configuration](#configuration))
- SSH agent — forwarded when `SSH_AUTH_SOCK` is set
- Caches — `~/.cache` and `/nix` use dedicated Docker volumes (container-only, not host-shared) that persist across container restarts
- Network — outbound internet access (required for the Claude API); automatically joins a running devcontainer's Docker network when detected (see [Devcontainer Network](#devcontainer-network))

The sandbox prevents Claude from damaging your operating system, installing unwanted software, or accessing sensitive files under your home directory.

## Requirements

- [Docker](https://docs.docker.com/get-docker/) with the Compose plugin (`docker`)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/setup) (`claude`)
- [Gum](https://github.com/charmbracelet/gum) (`gum`)

**macOS (Homebrew):**

```bash
brew install --cask docker
brew install gum
```

**Nix:**

```bash
nix profile install nixpkgs#gum
```

Install `claude` separately: [Claude Code installation guide](https://docs.anthropic.com/en/docs/claude-code/setup)

## Installation

### Using zinit

```zsh
zinit light claude-contrib/claude-sandbox
```

### Using Nix flakes

```sh
nix profile install github:claude-contrib/claude-sandbox
```

Or in your `flake.nix` inputs:

```nix
inputs.claude-sandbox.url = "github:claude-contrib/claude-sandbox";
```

### Using sheldon

```toml
[plugins.claude-sandbox]
github = "claude-contrib/claude-sandbox"
```

### Manual (zsh)

```zsh
git clone https://github.com/claude-contrib/claude-sandbox.git ~/.claude-sandbox
echo 'source ~/.claude-sandbox/claude-sandbox.plugin.zsh' >> ~/.zshrc
source ~/.claude-sandbox/claude-sandbox.plugin.zsh
```

### Manual (bash)

The `claude` wrapper is a plain bash script. Add it to your `PATH` in `~/.bashrc`:

```bash
git clone https://github.com/claude-contrib/claude-sandbox.git ~/.claude-sandbox
echo 'export PATH="$HOME/.claude-sandbox:$PATH"' >> ~/.bashrc
export PATH="$HOME/.claude-sandbox:$PATH"
```

## Usage

```bash
# Forward to host claude (default)
claude

# Run in Docker sandbox
claude --sandbox

# Sandbox with args
claude --sandbox --print "hello"

# Show sandbox wrapper help
claude --sandbox-help

# Debug tracing
DEBUG=1 claude --sandbox
```

## Argument Handling

Some Claude CLI arguments are intercepted by the sandbox wrapper and handled specially before being forwarded to the container:

| Argument | Sandbox behaviour |
|----------|-------------------|
| `--add-dir DIR` | The directory is bind-mounted **read-only** into the container at the same absolute path, then forwarded to `claude` inside the sandbox |
| `--plugin-dir DIR` | The directory is bind-mounted **read-only** into the container at the same absolute path, then forwarded to `claude` inside the sandbox |

```bash
# Mount an extra directory read-only inside the sandbox
claude --sandbox --add-dir /path/to/docs

# Mount a plugin directory read-only inside the sandbox
claude --sandbox --plugin-dir /path/to/plugins
```

## Devcontainer Network

If your project uses a [devcontainer](https://containers.dev/) (VS Code, Codespaces, devcontainer CLI), the sandbox automatically detects the running devcontainer and joins its Docker network. This lets Claude reach services (databases, APIs, etc.) defined in the devcontainer without any extra configuration.

Detection requires:
1. A `.devcontainer/devcontainer.json` or `.devcontainer.json` in the project root
2. A running devcontainer with the `devcontainer.local_folder` label matching the project

User-defined compose networks provide DNS-based service discovery.

When a network is detected, you'll see:
```
Detected devcontainer network 'myproject_default'
```

## Configuration

The full list of host environment variables forwarded to the sandbox is defined in [`claude-sandbox.env.yml`](claude-sandbox.env.yml).

These additional variables are handled specially:

| Variable | Description |
|----------|-------------|
| `CLAUDE_CONFIG_DIR` | Claude Code config directory — defaults to `~/.config/claude`, must be under `~/.config` |
| `GIT_CONFIG_GLOBAL` | Git global config file — defaults to `~/.config/git/config`, must be under `~/.config` |
| `CLAUDE_SANDBOX` | Always run in sandbox mode — equivalent to passing `--sandbox` on every invocation |
| `DEBUG` | Enable debug tracing (`set -x`) |

### Settings

The host `~/.config` directory is bind-mounted **read-only** into the container at the same absolute path, so git config and other host settings are available. `CLAUDE_CONFIG_DIR` is mounted separately as **read-write**, so Claude Code can persist its own state. The sandbox ships with a baked-in [`docker/settings.json`](docker/settings.json) that enables `bypassPermissions`; it is passed via `--settings` and always takes final precedence.

## Sessions

Sessions are shared between host and sandbox modes, so you can start a conversation on the host and continue it in the sandbox (or vice versa):

```bash
# Start on the host
claude

# Later, resume the same session in the sandbox
claude --sandbox --resume <session-id>
```

> **macOS note:** The host Claude Code stores its auth credentials in the macOS Keychain, which is not available inside the container. Run `claude` once inside the sandbox to log in — the credentials will be saved in `CLAUDE_CONFIG_DIR` (defaults to `~/.config/claude`) and reused on subsequent launches.

## Troubleshooting

Enable debug tracing to see every command the wrapper executes:

```bash
DEBUG=1 claude --sandbox
```

If the container is in a bad state (stale Nix store, corrupted cache), remove the Docker volumes and start fresh:

```bash
docker volume rm claude-nix claude-cache
```

## The claude-contrib Ecosystem

| Repo | What it provides |
|------|-----------------|
| [claude-extensions](https://github.com/claude-contrib/claude-extensions) | Hooks, context rules, session automation |
| [claude-features](https://github.com/claude-contrib/claude-features) | Devcontainer features for Claude Code and Anthropic tools |
| [claude-languages](https://github.com/claude-contrib/claude-languages) | LSP language servers — completions, diagnostics, hover |
| **claude-sandbox** ← you are here | Sandboxed Docker environment for Claude Code |
| [claude-services](https://github.com/claude-contrib/claude-services) | MCP servers — browser, filesystem, sequential thinking |
| [claude-status](https://github.com/claude-contrib/claude-status) | Live status line — context, cost, model, branch, worktree |

## License

MIT — use it, fork it, extend it.
