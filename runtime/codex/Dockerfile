FROM alpine:3.21

RUN apk add --no-cache \
    openssh-client \
    nodejs \
    npm \
    bash

# Install OpenAI Codex CLI
RUN npm install -g @openai/codex

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PROXY_HOST=kinoto-proxy
ENV PROXY_PORT=22

ENTRYPOINT ["/entrypoint.sh"]
