ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="gemini"

# Install Gemini CLI (agent can self-update via /usr/local)
# Build tools needed for native modules, removed after
RUN apk add --no-cache nodejs npm python3 make g++ \
    && npm install -g @google/gemini-cli \
    && apk del python3 make g++ \
    && rm -rf /root/.npm /tmp/*

COPY allowlist.txt /etc/kinoto/allowlist.txt
