ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="claude"

# Install Claude Code
RUN apk add --no-cache nodejs npm \
    && npm install -g @anthropic-ai/claude-code \
    && rm -rf /root/.npm /tmp/*

COPY allowlist.txt /etc/kinoto/allowlist.txt

# Overlay mounts for settings persistence
RUN echo "/mnt/lower/global:/home/agent/.claude" >> /etc/kinoto/overlays.conf \
    && echo "/mnt/lower/local:/workspace/.claude" >> /etc/kinoto/overlays.conf

COPY init.sh /etc/kinoto/init.d/claude.sh
