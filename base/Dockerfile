FROM alpine:3.21

RUN apk add --no-cache \
    tmux \
    iptables \
    ip6tables \
    bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# User can mount allowlists at /etc/kinoto/allowlist.d/
RUN mkdir -p /etc/kinoto/allowlist.d

# Default command (override in derived images)
ENV ASSISTANT_CMD="sh"

ENTRYPOINT ["/entrypoint.sh"]
