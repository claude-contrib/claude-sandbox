# Claude Sandbox

> Sandboxed Docker environment for [Claude Code](https://claude.ai/code) — full autonomy, system-level isolation.

[![Release](https://img.shields.io/github/v/release/claude-contrib/claude-sandbox)](https://github.com/claude-contrib/claude-sandbox/releases/latest)
[![Docker](https://img.shields.io/badge/ghcr.io-claude--sandbox-blue?logo=docker)](https://ghcr.io/claude-contrib/claude-sandbox)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Run Claude Code in an isolated Docker container with `bypassPermissions` enabled, Nix flake support, your project directory mounted read-write, and automatic devcontainer network detection. One command, two modes: forward to the host binary by default, or sandbox with a flag.

## How It Works

The `claude` wrapper script sits in your `$PATH` ahead of the real binary:

| Mode | Trigger | What happens |
|------|---------|--------------|
| **Forward** (default) | `claude` | Finds the host `claude` binary and runs it directly |
| **Sandbox** | `claude --sandbox` | Launches Claude Code inside a Docker container with full permissions |

```
claude --sandbox "fix the bug"
└── wrapper detects --sandbox, resolves host identity
      └── docker compose launches container with home + workdir mounted
            └── claude-exec.sh creates user (matching host UID/GID), drops privileges
                  └── claude runs as your user inside the sandbox
```

The sandbox container comes pre-configured with:
- **Nix flakes** — auto-activates `flake.nix` if present, giving Claude access to the same compilers, linters, and dev tools you use — an equal developer in your environment
- **Project mount** — your working directory is mounted read-write, so Claude reads and edits your code directly, just as you would
- **User identity** — the container dynamically creates a user matching your host UID, GID, and username, so file ownership on bind mounts is always correct
- **Volume isolation** — `~/.cache` and `~/.local` use dedicated Docker volumes to prevent cross-platform conflicts between host (macOS) and container (Linux)
- **Devcontainer network** — auto-joins the devcontainer's Docker network, giving Claude access to the same databases, APIs, and services your environment exposes

## Isolation Model

The sandbox uses Docker process isolation — Claude runs in a separate container as your user but cannot affect the host system.

**Isolated:**
- System files — no access to `/etc`, `/usr`, or host-installed packages
- Host processes — cannot see, signal, or interact with processes outside the container
- Package installation — `apt`, `brew`, and other system package managers are unavailable
- Caches — `~/.cache` and `~/.local` use dedicated Docker volumes, preventing cross-platform conflicts between macOS (host) and Linux (container)

**Shared (by design):**
- `$HOME` — mounted read-write so that git config (including `[include]` chains), Claude Code config (`~/.claude`, `~/.claude.json`), and other dotfiles work without manual setup
- Project directory — mounted read-write for code editing
- Credentials — API keys, cloud provider tokens, and `GH_TOKEN` are forwarded via environment variables (see [Configuration](#configuration))
- SSH agent — forwarded when `SSH_AUTH_SOCK` is set
- Network — the container has outbound internet access (required for the Claude API)

The sandbox prevents Claude from damaging your operating system or installing unwanted software. It does not restrict read access to files under your home directory.

## Installation

### Using zinit

```zsh
zinit light claude-contrib/claude-sandbox
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

## Devcontainer Network

If your project uses a [devcontainer](https://containers.dev/) (VS Code, Codespaces, devcontainer CLI), the sandbox automatically detects the running devcontainer and joins its Docker network. This lets Claude reach services (databases, APIs, etc.) defined in the devcontainer without any extra configuration.

Detection requires:
1. A `.devcontainer/devcontainer.json` or `.devcontainer.json` in the project root
2. A running devcontainer with the `devcontainer.local_folder` label matching the project

When a network is detected, you'll see:
```
Detected devcontainer network 'myproject_default'
```

## Configuration

The full list of host environment variables forwarded to the sandbox is defined in [`claude-sandbox.env.yml`](claude-sandbox.env.yml).

These additional variables are handled specially:

| Variable | Description |
|----------|-------------|
| `CLAUDE_SANDBOX` | Always run in sandbox mode — equivalent to passing `--sandbox` on every invocation |
| `SSH_AUTH_SOCK` | SSH agent socket — bind-mounted into the container |
| `DEBUG` | Enable debug tracing (`set -x`) |

### Settings

The host home directory is bind-mounted into the container at the same absolute path. Claude Code automatically picks up your settings — no extra configuration needed. The sandbox ships with a baked-in [`docker/settings.json`](docker/settings.json) that enables `bypassPermissions`; it is passed via `--settings` and always takes final precedence.

## Sessions

Sessions are shared between host and sandbox modes, so you can start a conversation on the host and continue it in the sandbox (or vice versa):

```bash
# Start on the host
claude

# Later, resume the same session in the sandbox
claude --sandbox --resume <session-id>
```

> **macOS note:** The host Claude Code stores its auth credentials in the macOS Keychain, which is not available inside the container. Run `claude` once inside the sandbox to log in — the credentials will be saved in `~/.claude` and reused on subsequent launches.

## Troubleshooting

Enable debug tracing to see every command the wrapper executes:

```bash
DEBUG=1 claude --sandbox
```

If the container is in a bad state (stale Nix store, corrupted cache), remove the Docker volumes and start fresh:

```bash
docker volume rm claude-nix claude-local claude-cache
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
