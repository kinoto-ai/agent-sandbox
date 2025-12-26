#!/bin/bash
# Forward external connections to localhost
socat TCP-LISTEN:1455,fork,bind=0.0.0.0,reuseaddr TCP:127.0.0.1:1455 &
