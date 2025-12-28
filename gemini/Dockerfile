ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="gemini"

# Install Gemini CLI as agent user (can self-update)
# Build tools needed for native modules, removed after
RUN apk add --no-cache nodejs npm python3 make g++
USER agent
RUN npm install -g @google/gemini-cli
USER root
RUN apk del python3 make g++ && rm -rf /tmp/*

COPY allowlist.txt /etc/kinoto/allowlist.txt
