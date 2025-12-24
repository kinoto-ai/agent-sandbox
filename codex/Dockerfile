ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="codex"

RUN apk add --no-cache \
    nodejs \
    npm

# Install OpenAI Codex CLI
RUN npm install -g @openai/codex

COPY allowlist.txt /etc/kinoto/allowlist.txt

ENV ASSISTANT_CMD="codex"
