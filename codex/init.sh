# Copy host settings to agent home (isolated copy)
if [ -d /mnt/lower/global ]; then
    mkdir -p /home/agent/.codex
    cp -a /mnt/lower/global/. /home/agent/.codex/
    chown -R agent:agent /home/agent/.codex
fi

if [ -d /mnt/lower/local ]; then
    mkdir -p /workspace/.codex
    cp -a /mnt/lower/local/. /workspace/.codex/
    chown -R agent:agent /workspace/.codex
fi
