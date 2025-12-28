ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="codex"

# Install OpenAI Codex CLI as agent user (can self-update)
RUN apk add --no-cache nodejs npm
USER agent
RUN npm install -g @openai/codex
USER root
RUN rm -rf /tmp/*

COPY allowlist.txt /etc/kinoto/allowlist.txt
COPY init.d/ /etc/kinoto/init.d/
RUN chmod +x /etc/kinoto/init.d/*.sh
