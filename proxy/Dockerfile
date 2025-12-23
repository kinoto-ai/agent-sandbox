FROM alpine:3.21

ARG SECURITY_LEVEL=balanced

RUN apk add --no-cache \
    openssh \
    tmux \
    docker-cli \
    iptables \
    ip6tables \
    bash

# SSH setup
RUN ssh-keygen -A && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

# Configure sshd
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

COPY allowlists/ /etc/kinoto/allowlists/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV SECURITY_LEVEL=${SECURITY_LEVEL}
ENV USER_CONTAINER_NAME=kinoto-user

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
