# syntax=docker/dockerfile:1

# Stage 1: Build — install all packages via nix
FROM nixos/nix:2.34.1 AS builder

RUN echo "sandbox = false" >> /etc/nix/nix.conf && \
    echo "filter-syscalls = false" >> /etc/nix/nix.conf && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

WORKDIR /build

COPY flake.nix flake.lock ./

RUN nix profile add \
      --profile /nix/var/nix/profiles/default \
      --option keep-outputs false \
      --option keep-derivations false \
      .#claude-sandbox && \
    nix store gc && \
    nix store optimise

# Stage 2: Runtime — minimal base with nix store copied in
FROM debian:bookworm-20250407-slim

RUN groupadd nixbld && \
    useradd -m -u 1000 -s /bin/bash -G nixbld claude

COPY --from=builder --chown=root:nixbld /nix/store /nix/store
COPY --from=builder --chown=root:nixbld /etc/nix /etc/nix
COPY --from=builder --chown=root:nixbld --chmod=g+w /nix/var /nix/var

RUN chmod 1775 /nix/store && \
    mkdir -p /home/claude/.cache \
             /home/claude/.local/bin \
             /home/claude/.local/share/claude \
             /home/claude/.config/claude && \
    chown -R claude:claude /home/claude

USER claude

ENV LANG=C.UTF-8
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
ENV SSL_CERT_FILE="/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
ENV NIX_SSL_CERT_FILE="/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
ENV PATH="/nix/var/nix/profiles/default/bin:/home/claude/.local/bin:$PATH"

WORKDIR /home/claude

COPY --chown=claude:claude settings.json /home/claude/.local/share/claude/settings.json
COPY --chown=claude:claude hooks/context.json /home/claude/.local/share/claude/hooks/context.json
COPY --chown=claude:claude --chmod=755 claude-exec.sh /home/claude/.local/bin/claude-exec.sh
COPY --chown=claude:claude --chmod=755 hooks/context.sh /home/claude/.local/share/claude/hooks/context.sh

CMD ["claude-exec.sh"]
