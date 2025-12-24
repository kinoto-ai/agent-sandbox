ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="gemini"

RUN apk add --no-cache \
    nodejs \
    npm \
    python3 \
    make \
    g++

# Install Gemini CLI (needs build tools for native modules)
RUN npm install -g @google/gemini-cli

# Remove build deps to reduce size
RUN apk del python3 make g++

COPY allowlist.txt /etc/kinoto/allowlist.txt

ENV ASSISTANT_CMD="gemini"
