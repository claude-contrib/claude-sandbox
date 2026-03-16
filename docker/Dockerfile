# syntax=docker/dockerfile:1

# Stage 1: Build — install all packages via nix
FROM nixos/nix:2.34.1 AS builder

RUN echo "sandbox = false" >> /etc/nix/nix.conf && \
    echo "filter-syscalls = false" >> /etc/nix/nix.conf && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

WORKDIR /build

COPY flake.nix flake.lock ./

RUN nix profile add \
      --option keep-outputs false \
      --option keep-derivations false \
      .#claude-sandbox && \
    nix store gc && \
    nix store optimise

# Stage 2: Runtime — minimal base with nix store copied in
FROM debian:bookworm-20250407-slim

RUN useradd -m -u 1000 -s /bin/bash claude

COPY --from=builder /nix/store /nix/store
COPY --from=builder --chown=claude:claude /etc/nix /etc/nix
COPY --from=builder --chown=claude:claude /nix/var /nix/var
COPY --from=builder --chown=claude:claude /root/.nix-profile /home/claude/.nix-profile

RUN chmod 1777 /nix/store && \
    mkdir -p /home/claude/.local/bin \
             /home/claude/.local/share/claude \
             /home/claude/.config/claude && \
    chown -R claude:claude /home/claude

USER claude

ENV LANG=C.UTF-8
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
ENV PATH="/home/claude/.nix-profile/bin:/home/claude/.local/bin:/nix/var/nix/profiles/default/bin:$PATH"

WORKDIR /home/claude

COPY --chown=claude:claude settings.json /home/claude/.local/share/claude/settings.json
COPY --chown=claude:claude --chmod=755 claude-exec.sh /home/claude/.local/bin/claude-exec.sh

CMD ["claude-exec.sh"]
