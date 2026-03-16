# syntax=docker/dockerfile:1

# Stage 1: Build — install all packages via nix
FROM nixos/nix:latest AS builder

RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf && \
    echo "sandbox = false" >> /etc/nix/nix.conf && \
    echo "filter-syscalls = false" >> /etc/nix/nix.conf

WORKDIR /build

COPY flake.nix flake.lock ./

RUN nix profile add .#claude-sandbox && nix store gc

# Stage 2: Runtime — minimal base with nix store copied in
FROM debian:bookworm-slim

RUN useradd -m -u 1000 -s /bin/bash claude

COPY --from=builder /etc/nix /etc/nix
COPY --from=builder /nix/var /nix/var
COPY --from=builder /nix/store /nix/store
COPY --from=builder /root/.nix-profile /home/claude/.nix-profile

RUN chmod 1777 /nix/store && \
    chown -R claude:claude /nix/var /home/claude/.nix-profile

USER claude

ENV LANG=C.UTF-8
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
ENV PATH="/home/claude/.nix-profile/bin:/home/claude/.local/bin:$PATH"

WORKDIR /home/claude

RUN mkdir -p /home/claude/.config/claude /home/claude/.local/bin /home/claude/.local/share/claude

COPY --chown=claude:claude claude-exec.sh /home/claude/.local/bin/claude-exec.sh
COPY --chown=claude:claude settings.json /home/claude/.local/share/claude/settings.json

RUN chmod +x /home/claude/.local/bin/claude-exec.sh

CMD ["claude-exec.sh"]
