ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="codex"

# Install OpenAI Codex CLI
RUN apk add --no-cache nodejs npm \
    && npm install -g @openai/codex \
    && rm -rf /root/.npm /tmp/*

COPY allowlist.txt /etc/kinoto/allowlist.txt

# Overlay mounts for settings persistence
RUN echo "/mnt/lower/global:/home/agent/.codex" >> /etc/kinoto/overlays.conf \
    && echo "/mnt/lower/local:/workspace/.codex" >> /etc/kinoto/overlays.conf
