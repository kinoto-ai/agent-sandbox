# Copy host settings to agent home (isolated copy)
if [ -d /mnt/lower/global ]; then
    mkdir -p /home/agent/.claude
    cp -a /mnt/lower/global/. /home/agent/.claude/
    chown -R agent:agent /home/agent/.claude
fi

if [ -d /mnt/lower/local ]; then
    mkdir -p /workspace/.claude
    cp -a /mnt/lower/local/. /workspace/.claude/
    chown -R agent:agent /workspace/.claude
fi

# Copy credentials file
if [ -f /mnt/files/claude.json ]; then
    cp /mnt/files/claude.json /home/agent/.claude.json
    chown agent:agent /home/agent/.claude.json
fi
