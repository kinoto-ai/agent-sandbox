ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="codex"

# Install OpenAI Codex CLI to user-local directory (allows self-update)
RUN apk add --no-cache nodejs npm \
    && npm config set prefix /home/agent/.local \
    && npm install -g @openai/codex \
    && chown -R agent:agent /home/agent/.local \
    && rm -rf /root/.npm /tmp/*

COPY allowlist.txt /etc/kinoto/allowlist.txt
COPY init.d/ /etc/kinoto/init.d/
RUN chmod +x /etc/kinoto/init.d/*.sh
