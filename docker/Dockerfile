# syntax=docker/dockerfile:1

FROM nixos/nix:2.34.1

RUN echo "sandbox = false" >> /etc/nix/nix.conf && \
    echo "filter-syscalls = false" >> /etc/nix/nix.conf && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

RUN echo "claude:x:1000:1000::/home/claude:/bin/sh" >> /etc/passwd && \
    echo "claude:x:1000:" >> /etc/group && \
    mkdir -p /home/claude && \
    mkdir -p /home/claude/.local/bin && \
    mkdir -p /home/claude/.local/share/claude && \
    mkdir -p /home/claude/.config/claude && \
    chown -R claude:claude /home/claude && \
    chown -R claude:claude /nix

USER claude

ENV LANG=C.UTF-8
ENV TERM=xterm-256color
ENV COLORTERM=truecolor
ENV PATH=/home/claude/.local/bin:$PATH

WORKDIR /home/claude

COPY flake.nix flake.lock ./

RUN nix profile add --option keep-outputs false --option keep-derivations false .#claude-sandbox && \
    nix store gc && nix store optimise && rm -rf ~/.cache/nix
    
COPY --chown=claude:claude settings.json /home/claude/.local/share/claude/settings.json
COPY --chown=claude:claude --chmod=755 claude-exec.sh /home/claude/.local/bin/claude-exec.sh

CMD ["claude-exec.sh"]
