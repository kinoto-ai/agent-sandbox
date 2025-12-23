#!/bin/bash
set -e

# Generate SSH key if not provided
if [ ! -f /root/.ssh/id_ed25519 ]; then
    mkdir -p /root/.ssh
    ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N "" -q
fi

# Add proxy host to known_hosts
mkdir -p /root/.ssh
ssh-keyscan -H "$PROXY_HOST" >> /root/.ssh/known_hosts 2>/dev/null || true

# ASSISTANT_CMD is injected (e.g., "gemini --yolo")
if [ -z "$ASSISTANT_CMD" ]; then
    echo "Error: ASSISTANT_CMD not set"
    exit 1
fi

# SSH into proxy and run assistant
exec ssh -t -o StrictHostKeyChecking=accept-new \
    -i /root/.ssh/id_ed25519 \
    "root@${PROXY_HOST}" \
    "$ASSISTANT_CMD"
