ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="claude"

# Install Claude Code (agent can self-update via /usr/local)
RUN apk add --no-cache nodejs npm \
    && npm install -g @anthropic-ai/claude-code \
    && rm -rf /root/.npm /tmp/*

COPY allowlist.txt /etc/kinoto/allowlist.txt
