# Claude Sandbox

> Sandboxed Docker environment for [Claude Code](https://claude.ai/code) — full autonomy, zero risk to your host.

[![Release](https://img.shields.io/github/v/release/claude-contrib/claude-sandbox)](https://github.com/claude-contrib/claude-sandbox/releases/latest)
[![Docker](https://img.shields.io/badge/ghcr.io-claude--sandbox-blue?logo=docker)](https://ghcr.io/claude-contrib/claude-sandbox)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Run Claude Code in an isolated Docker container with `bypassPermissions` enabled, Nix flake support, and your project directory mounted read-write. One command, two modes: forward to the host binary by default, or sandbox with a flag.

## How It Works

The `claude` wrapper script sits in your `$PATH` ahead of the real binary:

| Mode | Trigger | What happens |
|------|---------|--------------|
| **Forward** (default) | `claude` | Finds the host `claude` binary and runs it directly |
| **Sandbox** | `claude --sandbox` | Launches Claude Code inside a Docker container with full permissions |

The sandbox container comes pre-configured with:
- **`bypassPermissions`** — no confirmation prompts
- **Nix flakes** — auto-activates `flake.nix` if present in your project
- **Project mount** — your working directory is mounted into the container
- **Devcontainer network** — auto-joins the devcontainer's Docker network if one is running

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

### Manual

```bash
git clone https://github.com/claude-contrib/claude-sandbox.git ~/.claude-sandbox
source ~/.claude-sandbox/claude-sandbox.plugin.zsh
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

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_API_KEY` | Anthropic API key (required, forwarded to sandbox) |
| `GH_TOKEN` | GitHub personal access token (forwarded to sandbox) |
| `GITHUB_TOKEN` | Alias for `GH_TOKEN` — used when `GH_TOKEN` is not set |
| `SSH_AUTH_SOCK` | SSH agent socket (forwarded to sandbox) |
| `DEBUG` | Enable debug tracing (`set -x`) |

## The claude-contrib Ecosystem

| Marketplace | Install key | What it provides |
|-------------|------------|-----------------|
| [claude-extensions](https://github.com/claude-contrib/claude-extensions) | `@claude-extensions` | Hooks, context rules, session automation |
| [claude-services](https://github.com/claude-contrib/claude-services) | `@claude-services` | MCP servers — browser, filesystem, sequential thinking |
| [claude-skills](https://github.com/claude-contrib/claude-skills) | `@claude-skills` | Slash commands — `/commit`, and more |
| **claude-sandbox** ← you are here | — | Sandboxed Docker environment for Claude Code |

## License

MIT — use it, fork it, extend it.
