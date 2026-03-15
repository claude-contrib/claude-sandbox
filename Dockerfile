# syntax=docker/dockerfile:1

FROM ubuntu:24.04

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN apt-get update && apt-get install -y curl git gh jq ripgrep sudo xz-utils ca-certificates && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://install.determinate.systems/nix | sh -s -- install linux --no-confirm --init none --no-start-daemon --extra-conf "sandbox = false" --extra-conf "filter-syscalls = false"

RUN useradd -m -u 1001 -s /bin/bash claude

RUN chown -R claude:claude /nix

USER claude

WORKDIR /home/claude

RUN curl -fsSL https://claude.ai/install.sh | bash

ENV NIX_CONFIG="experimental-features = nix-command flakes"
ENV PATH="/home/claude/.local/bin:/nix/var/nix/profiles/default/bin:$PATH"
ENV LANG=C.UTF-8
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

RUN mkdir -p /home/claude/.config/claude

RUN git clone https://github.com/claude-contrib/claude-status.git /home/claude/.local/share/claude-status \
    && ln -s /home/claude/.local/share/claude-status/claude-status /home/claude/.local/bin/claude-status

COPY --chown=claude:claude claude-exec.sh /home/claude/.local/bin/claude-exec.sh
COPY --chown=claude:claude settings.json /home/claude/.local/share/claude/settings.json

RUN chmod +x /home/claude/.local/bin/claude-exec.sh

CMD ["claude-exec.sh"]
