FROM alpine:3.21

LABEL com.kinoto.agent.type="base"

RUN apk add --no-cache \
    iptables \
    ip6tables \
    bash \
    su-exec \
    shadow \
    git

# Create unprivileged user for running assistant
RUN adduser -D -h /home/agent agent

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# User can mount allowlists at /etc/kinoto/allowlist.d/
RUN mkdir -p /etc/kinoto/allowlist.d

# Terminal settings
ENV TERM=xterm-256color

ENTRYPOINT ["/entrypoint.sh"]
