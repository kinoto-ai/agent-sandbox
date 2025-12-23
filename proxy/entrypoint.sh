#!/bin/bash
set -e

# Accept public key from environment or mounted file
if [ -n "$AUTHORIZED_KEY" ]; then
    echo "$AUTHORIZED_KEY" > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

# Create wrapper script for docker exec (handles TTY detection)
# Note: Container name is embedded directly since SSH sessions don't inherit env
cat > /usr/local/bin/kinoto-exec << EXECSCRIPT
#!/bin/bash
CONTAINER="$USER_CONTAINER_NAME"

if [ -n "\$SSH_ORIGINAL_COMMAND" ]; then
    # Command provided: run it
    if [ -t 0 ]; then
        exec docker exec -it "\$CONTAINER" /bin/sh -c "\$SSH_ORIGINAL_COMMAND"
    else
        exec docker exec -i "\$CONTAINER" /bin/sh -c "\$SSH_ORIGINAL_COMMAND"
    fi
else
    # No command: interactive shell
    exec docker exec -it "\$CONTAINER" /bin/sh
fi
EXECSCRIPT
chmod +x /usr/local/bin/kinoto-exec

# Configure ForceCommand for SSH -> docker exec -> user container
if [ "$USE_TMUX" = "true" ]; then
    FORCE_CMD="tmux new-session -A -s kinoto 'docker exec -it $USER_CONTAINER_NAME /bin/sh'"
else
    FORCE_CMD="/usr/local/bin/kinoto-exec"
fi
echo "ForceCommand $FORCE_CMD" >> /etc/ssh/sshd_config

# Resolve domain to IPs
resolve_domain() {
    local domain="$1"
    # Use getent which is more reliable in containers
    getent ahosts "$domain" 2>/dev/null | awk '{print $1}' | sort -u
}

# Apply iptables rules based on security level
apply_iptables() {
    # Flush existing rules
    iptables -F OUTPUT 2>/dev/null || true
    ip6tables -F OUTPUT 2>/dev/null || true

    if [ "$SECURITY_LEVEL" = "permissive" ]; then
        echo "Permissive mode: allowing all traffic"
        iptables -P OUTPUT ACCEPT
        ip6tables -P OUTPUT ACCEPT
        return
    fi

    # Default deny
    iptables -P OUTPUT DROP
    ip6tables -P OUTPUT DROP

    # Allow loopback
    iptables -A OUTPUT -o lo -j ACCEPT
    ip6tables -A OUTPUT -o lo -j ACCEPT

    # Allow established connections
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    ip6tables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    # Allow DNS (needed for resolution)
    iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
    ip6tables -A OUTPUT -p udp --dport 53 -j ACCEPT
    ip6tables -A OUTPUT -p tcp --dport 53 -j ACCEPT

    # Load and resolve allowlist
    local allowlist="/etc/kinoto/allowlists/${SECURITY_LEVEL}.txt"
    if [ ! -f "$allowlist" ]; then
        echo "Warning: allowlist not found: $allowlist"
        return
    fi

    echo "Applying $SECURITY_LEVEL allowlist..."
    local count=0

    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

        # Resolve domain to IPs
        local ips
        ips=$(resolve_domain "$line")

        if [ -z "$ips" ]; then
            echo "  Warning: could not resolve $line"
            continue
        fi

        for ip in $ips; do
            # Detect IPv4 vs IPv6
            if [[ "$ip" == *:* ]]; then
                ip6tables -A OUTPUT -d "$ip" -p tcp --dport 443 -j ACCEPT 2>/dev/null || true
                ip6tables -A OUTPUT -d "$ip" -p tcp --dport 80 -j ACCEPT 2>/dev/null || true
            else
                iptables -A OUTPUT -d "$ip" -p tcp --dport 443 -j ACCEPT
                iptables -A OUTPUT -d "$ip" -p tcp --dport 80 -j ACCEPT
            fi
        done

        count=$((count + 1))
    done < "$allowlist"

    echo "Resolved $count domains"
}

apply_iptables

echo "Starting kinoto-proxy with security level: $SECURITY_LEVEL"
exec /usr/sbin/sshd -D -e
