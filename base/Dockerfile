FROM alpine:3.21

LABEL com.kinoto.agent.type="base"

RUN apk add --no-cache \
    tmux \
    iptables \
    ip6tables \
    bash \
    su-exec

# Create unprivileged user for running assistant
RUN adduser -D -h /home/agent agent

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# User can mount allowlists at /etc/kinoto/allowlist.d/
RUN mkdir -p /etc/kinoto/allowlist.d

# Terminal settings
ENV TERM=xterm-256color

# tmux configuration
RUN printf "set -g status off\nset -g remain-on-exit on\n" > /home/agent/.tmux.conf && \
    chown agent:agent /home/agent/.tmux.conf

# Default command (override in derived images)
ENV ASSISTANT_CMD="sh"

ENTRYPOINT ["/entrypoint.sh"]
