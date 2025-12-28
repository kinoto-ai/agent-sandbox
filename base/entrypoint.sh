#!/bin/bash
set -e

# Apply iptables rules (AI APIs only)
apply_iptables() {
    iptables -F OUTPUT 2>/dev/null || true
    ip6tables -F OUTPUT 2>/dev/null || true

    # Default deny
    iptables -P OUTPUT DROP
    ip6tables -P OUTPUT DROP

    # Allow loopback
    iptables -A OUTPUT -o lo -j ACCEPT
    ip6tables -A OUTPUT -o lo -j ACCEPT

    # Allow established connections
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    ip6tables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    # Allow DNS
    iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
    ip6tables -A OUTPUT -p udp --dport 53 -j ACCEPT
    ip6tables -A OUTPUT -p tcp --dport 53 -j ACCEPT

    # Resolve and allow hosts from allowlists
    for allowlist in /etc/kinoto/allowlist.txt /etc/kinoto/allowlist.d/*.txt; do
        [ -f "$allowlist" ] || continue
        while IFS= read -r domain || [ -n "$domain" ]; do
            [[ "$domain" =~ ^#.*$ || -z "$domain" ]] && continue

            for ip in $(getent ahosts "$domain" 2>/dev/null | awk '{print $1}' | sort -u); do
                if [[ "$ip" == *:* ]]; then
                    ip6tables -A OUTPUT -d "$ip" -p tcp --dport 443 -j ACCEPT 2>/dev/null || true
                    ip6tables -A OUTPUT -d "$ip" -p tcp --dport 80 -j ACCEPT 2>/dev/null || true
                else
                    iptables -A OUTPUT -d "$ip" -p tcp --dport 443 -j ACCEPT
                    iptables -A OUTPUT -d "$ip" -p tcp --dport 80 -j ACCEPT
                fi
            done
        done < "$allowlist"
    done
}

# Apply network rules if we have CAP_NET_ADMIN
apply_iptables 2>/dev/null || echo "Note: iptables requires CAP_NET_ADMIN"

# Run init.d scripts as agent
for script in /etc/kinoto/init.d/*.sh; do
    [ -x "$script" ] && su-exec agent "$script"
done

# Change agent UID/GID to match host for file permissions
if [ -n "$HOST_UID" ] && [ "$HOST_UID" != "1000" ]; then
    usermod -u "$HOST_UID" agent
    groupmod -g "$HOST_UID" agent
    chown -R agent:agent /home/agent 2>/dev/null || true
fi

# Run the command passed to docker run as agent
exec su-exec agent "$@"
