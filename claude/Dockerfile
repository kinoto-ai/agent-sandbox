ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="claude"

# Install Claude Code to user-local directory (allows self-update)
RUN apk add --no-cache nodejs npm \
    && npm config set prefix /home/agent/.local \
    && npm install -g @anthropic-ai/claude-code \
    && chown -R agent:agent /home/agent/.local \
    && rm -rf /root/.npm /tmp/*

COPY allowlist.txt /etc/kinoto/allowlist.txt
