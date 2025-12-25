# Copy claude.json if mounted
if [ -f /mnt/files/claude.json ]; then
    cp /mnt/files/claude.json /home/agent/.claude.json
    chown agent:agent /home/agent/.claude.json
fi
