FROM alpine:3.21

RUN apk add --no-cache \
    openssh-client \
    nodejs \
    npm \
    bash \
    python3 \
    make \
    g++

# Install Gemini CLI
RUN npm install -g @google/gemini-cli

# Remove build deps to reduce size
RUN apk del python3 make g++

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PROXY_HOST=kinoto-proxy
ENV PROXY_PORT=22

ENTRYPOINT ["/entrypoint.sh"]
