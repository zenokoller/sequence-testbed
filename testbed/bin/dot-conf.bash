#!/bin/bash

set -eu

if [ $# != 1 ]
then
  echo "Usage $0 <configuration file>"
  exit 1
fi

readonly CONFIG="$1"
readonly OFMT="pdf"
readonly OFILE="$(basename ${CONFIG}).${OFMT}"

# read links configuration from the supplied file and network configuration
# from .env 
. "${CONFIG}"
. .env


cat << EOF | dot -T${OFMT} -o ${OFILE}
digraph G {
  rankdir = LR

  C  [label = "${CLIENT_DOMAIN_CLIENT_ADDR}"]
  R1 [label = "${CLIENT_DOMAIN_ROUTER_ADDR}"]
  R2 [label = "${SERVER_DOMAIN_ROUTER_ADDR}"]
  S  [label = "${SERVER_DOMAIN_SERVER_ADDR}"]

  subgraph cluster_C {
    label = "client"
    C
  }

  subgraph cluster_R {
    label = "router"
    edge [arrowhead = "none"]
    R1 -> R2
  }

  subgraph cluster_S {
    label = "server"
    S
  }

  # uplink
  C -> R1 [label = "${CLIENT_DOMAIN_UPLINK_CONFIG}", color = "red", fontcolor = "red"]
  R2 -> S [label = "${SERVER_DOMAIN_UPLINK_CONFIG}", color = "red", fontcolor = "red"]

  # downlink
  S -> R2 [label = "${SERVER_DOMAIN_DOWNLINK_CONFIG}", color = "blue", fontcolor = "blue"]
  R1 -> C [label = "${CLIENT_DOMAIN_DOWNLINK_CONFIG}", color = "blue", fontcolor = "blue"]
}
EOF

if [ "$(uname)" == "Darwin" ]; then
  open ${OFILE}
else
  echo ">>> test network configuration saved to ${OFILE}"
fi

# vim: ai ts=2 sw=2 et sts=2 ft=sh
