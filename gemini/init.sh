# Copy host settings to agent home (isolated copy)
if [ -d /mnt/lower/global ]; then
    mkdir -p /home/agent/.gemini
    cp -a /mnt/lower/global/. /home/agent/.gemini/
    chown -R agent:agent /home/agent/.gemini
fi

if [ -d /mnt/lower/local ]; then
    mkdir -p /workspace/.gemini
    cp -a /mnt/lower/local/. /workspace/.gemini/
    chown -R agent:agent /workspace/.gemini
fi
