# syntax=docker/dockerfile:1

FROM nixos/nix:latest

ENV LANG=C.UTF-8
ENV TERM=xterm-256color
ENV COLORTERM=truecolor

RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf && \
    echo "sandbox = false" >> /etc/nix/nix.conf && \
    echo "filter-syscalls = false" >> /etc/nix/nix.conf

RUN echo "claude:x:1000:1000::/home/claude:/bin/sh" >> /etc/passwd && \
    echo "claude:x:1000:" >> /etc/group && \
    mkdir -p /home/claude && \
    chown claude:claude /home/claude && \
    chown -R claude:claude /nix

USER claude

WORKDIR /home/claude

COPY --chown=claude:claude flake.nix flake.lock ./

RUN nix profile install .#claude-sandbox && \
    rm flake.nix flake.lock && \
    nix store gc && \
    nix store optimise && \
    rm -rf ~/.cache/nix

ENV PATH="/home/claude/.nix-profile/bin:/home/claude/.local/bin:/nix/var/nix/profiles/default/bin:$PATH"

RUN mkdir -p /home/claude/.config/claude /home/claude/.local/bin /home/claude/.local/share/claude

RUN git clone https://github.com/claude-contrib/claude-status.git /home/claude/.local/share/claude-status \
    && ln -s /home/claude/.local/share/claude-status/claude-status /home/claude/.local/bin/claude-status

COPY --chown=claude:claude claude-exec.sh /home/claude/.local/bin/claude-exec.sh
COPY --chown=claude:claude settings.json /home/claude/.local/share/claude/settings.json

RUN chmod +x /home/claude/.local/bin/claude-exec.sh

CMD ["claude-exec.sh"]
