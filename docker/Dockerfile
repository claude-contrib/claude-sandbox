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
COPY --from=builder /etc/nix /etc/nix
COPY --from=builder /nix/var /nix/var
COPY --from=builder /root/.nix-profile /home/claude/.nix-profile

RUN sed -i '/^build-users-group/d' /etc/nix/nix.conf && \
    chmod 1777 /nix/store && \
    chown -R claude:claude /nix/var && \
    mkdir -p /home/claude/.cache \
             /home/claude/.local/bin \
             /home/claude/.local/share/claude \
             /home/claude/.config/claude && \
    chown -R claude:claude /home/claude

USER claude

ENV LANG=C.UTF-8
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
ENV SSL_CERT_FILE="/home/claude/.nix-profile/etc/ssl/certs/ca-bundle.crt"
ENV NIX_SSL_CERT_FILE="/home/claude/.nix-profile/etc/ssl/certs/ca-bundle.crt"
ENV PATH="/home/claude/.nix-profile/bin:/home/claude/.local/bin:/nix/var/nix/profiles/default/bin:$PATH"

WORKDIR /home/claude

COPY --chown=claude:claude settings.json /home/claude/.local/share/claude/settings.json
COPY --chown=claude:claude --chmod=755 claude-exec.sh /home/claude/.local/bin/claude-exec.sh
COPY --chown=claude:claude --chmod=755 hooks/context.sh /home/claude/.local/share/claude/hooks/context.sh

CMD ["claude-exec.sh"]
