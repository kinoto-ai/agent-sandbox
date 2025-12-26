#!/bin/bash
# Forward external port 11455 to localhost:1455 for OAuth callback
socat TCP-LISTEN:11455,fork,bind=0.0.0.0,reuseaddr TCP:127.0.0.1:1455 &
