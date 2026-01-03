ARG BASE_IMAGE=agent-base
FROM ${BASE_IMAGE}

LABEL com.kinoto.agent.name="goose"

# Install Goose in virtual environment
RUN apk add --no-cache python3 py3-pip py3-virtualenv
RUN python3 -m venv /opt/goose-venv && \
    /opt/goose-venv/bin/pip install --upgrade pip && \
    /opt/goose-venv/bin/pip install 'langfuse>=2.0.0,<3.0.0' && \
    /opt/goose-venv/bin/pip install goose-ai
RUN ln -s /opt/goose-venv/bin/goose /usr/local/bin/goose
RUN rm -rf /tmp/*

COPY allowlist.txt /etc/kinoto/allowlist.txt
