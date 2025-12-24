ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

RUN apk add --no-cache \
    nodejs \
    npm

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

COPY allowlist.txt /etc/kinoto/allowlist.txt

ENV ASSISTANT_CMD="claude"
