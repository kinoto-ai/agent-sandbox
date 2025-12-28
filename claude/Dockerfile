ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="claude"

# Install Claude Code as agent user (can self-update)
RUN apk add --no-cache nodejs npm
USER agent
RUN npm install -g @anthropic-ai/claude-code
USER root
RUN rm -rf /tmp/*

COPY allowlist.txt /etc/kinoto/allowlist.txt
