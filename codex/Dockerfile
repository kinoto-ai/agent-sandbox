ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="codex"

# Install OpenAI Codex CLI
RUN apk add --no-cache nodejs npm \
    && npm install -g @openai/codex \
    && rm -rf /root/.npm /tmp/*

COPY allowlist.txt /etc/kinoto/allowlist.txt

ENV ASSISTANT_CMD="codex"
