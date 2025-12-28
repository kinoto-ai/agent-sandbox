FROM alpine:3.21

LABEL com.kinoto.agent.type="base"

RUN apk add --no-cache \
    iptables \
    ip6tables \
    bash \
    su-exec \
    shadow \
    git \
    socat

# Create unprivileged user for running assistant
RUN adduser -D -h /home/agent agent

# Setup local bin directory for user-installable packages
RUN mkdir -p /home/agent/.local/bin && \
    chown -R agent:agent /home/agent/.local

# Add local bin to PATH (allows agent to install/update packages)
ENV PATH="/home/agent/.local/bin:$PATH"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# User can mount allowlists at /etc/kinoto/allowlist.d/
RUN mkdir -p /etc/kinoto/allowlist.d

# Init scripts directory (scripts here run before main process)
RUN mkdir -p /etc/kinoto/init.d

# Terminal settings
ENV TERM=xterm-256color

ENTRYPOINT ["/entrypoint.sh"]
