#!/bin/bash

set -eux

readonly NODE_NAME="$1"
readonly GW="$2"
readonly DST_SUBNET="$3"

# Add route to client
ip route add ${DST_SUBNET} via ${GW}

# prompt
echo export PS1="\"[${NODE_NAME}] \\W # \"" > /root/.bashrc

/go/bin/netemd --config /root/share/netemd-config.json
