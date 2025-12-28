ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="gemini"

# Install Gemini CLI to user-local directory (allows self-update)
# Build tools needed for native modules, removed after
RUN apk add --no-cache nodejs npm python3 make g++ \
    && npm config set prefix /home/agent/.local \
    && npm install -g @google/gemini-cli \
    && apk del python3 make g++ \
    && chown -R agent:agent /home/agent/.local \
    && rm -rf /root/.npm /tmp/*

COPY allowlist.txt /etc/kinoto/allowlist.txt
