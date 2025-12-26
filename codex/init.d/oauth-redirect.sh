#!/bin/bash
# Redirect external port 1455 to localhost for OAuth callback
sysctl -w net.ipv4.conf.eth0.route_localnet=1
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 1455 -j DNAT --to-destination 127.0.0.1:1455
