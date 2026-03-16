# Claude Sandbox

> Sandboxed Docker environment for [Claude Code](https://claude.ai/code) — full autonomy, zero risk to your host.

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

The sandbox container comes pre-configured with:
- **Nix flakes** — auto-activates `flake.nix` if present, giving Claude access to the same compilers, linters, and dev tools you use — an equal developer in your environment
- **Project mount** — your working directory is mounted read-write, so Claude reads and edits your code directly, just as you would
- **Devcontainer network** — auto-joins the devcontainer's Docker network, giving Claude access to the same databases, APIs, and services your environment exposes

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

# Show help
claude --help

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
Joining Docker network 'myproject_default'
```

## Configuration

### Environment variables

The full list of host environment variables forwarded to the sandbox is defined in [`claude-sandbox.env`](claude-sandbox.env).

Two additional variables are handled specially:

| Variable | Description |
|----------|-------------|
| `CLAUDE_SANDBOX` | Always run in sandbox mode — equivalent to passing `--sandbox` on every invocation |
| `SSH_AUTH_SOCK` | SSH agent socket — bind-mounted into the container at `/run/ssh-agent` |
| `DEBUG` | Enable debug tracing (`set -x`) |

### Settings

The sandbox ships with a baked-in [`docker/settings.json`](docker/settings.json) that enables `bypassPermissions` and configures other container defaults.

To layer your own settings on top, create `~/.claude/settings.docker.json` on your host:

```json
{
  "theme": "dark",
  "autoUpdates": false
}
```

At startup, any `settings.*.json` files found in `CLAUDE_CONFIG_DIR` inside the container are merged left-to-right with the baked-in settings appended last. This means the baked-in values (such as `bypassPermissions`) always take final precedence and cannot be overridden.

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
