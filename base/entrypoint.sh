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

# Start or attach to tmux session
SESSION_NAME="${TMUX_SESSION:-kinoto}"

# If no TTY, run command directly (for testing/CI)
if [ ! -t 0 ]; then
    exec $ASSISTANT_CMD
fi

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # Session exists, create new window
    exec tmux new-window -t "$SESSION_NAME" "$ASSISTANT_CMD"
else
    # New session
    exec tmux new-session -s "$SESSION_NAME" "$ASSISTANT_CMD"
fi
