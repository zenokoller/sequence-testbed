#!/bin/bash

set -eux

readonly NODE_NAME="$1"

# prompt
echo export PS1="\"[${NODE_NAME}] \\W # \"" > /root/.bashrc

/go/bin/netemd --config /root/share/netemd-config.json