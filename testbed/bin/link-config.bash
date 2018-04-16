#!/bin/bash

set -eu

# Dynamically compute the network interface associated to a given "domain" on
# the supplied "node"
#
# $1: node name
# $2: domain network
node_interface_for_domain() {
  local node=$1
  local domain_network=$2

  docker-compose exec ${node} ip route get ${domain_network} \
    | head -1 \
    | awk '{print $4}'
}

# A bunch of handy aliases
client_interface_for_client_domain() {
  node_interface_for_domain client ${CLIENT_DOMAIN_SUBNET}
}

server_interface_for_server_domain() {
  node_interface_for_domain server ${SERVER_DOMAIN_SUBNET}
}

router_interface_for_client_domain() {
  node_interface_for_domain router ${CLIENT_DOMAIN_SUBNET}
}

router_interface_for_server_domain() {
  node_interface_for_domain router ${SERVER_DOMAIN_SUBNET}
}

expect_containers_are_running() {
  echo ">>> Checking containers are running"

  for s in client server router
  do
    x=$(docker-compose ps -q ${s})
    if [ -z "${x}" ]
    then
      echo ">>> Node ${s} MUST be running (run 'make up' or 'make build-up')"
      exit 1
    fi
  done
}

if [ $# != 1 ]
then
  echo "Usage $0 <configuration file>"
  exit 1
fi

readonly CONFIG="$1"

# read links configuration from the supplied file and network configuration
# from .env 
. "${CONFIG}"
. .env

# containers must be up & running for the script to work
expect_containers_are_running

# map link names to the correct containers' interface
readonly linkmap__CLIENT_DOMAIN_UPLINK_CONFIG="client $(client_interface_for_client_domain)"
readonly linkmap__SERVER_DOMAIN_DOWNLINK_CONFIG="server $(server_interface_for_server_domain)"
readonly linkmap__CLIENT_DOMAIN_DOWNLINK_CONFIG="router $(router_interface_for_client_domain)"
readonly linkmap__SERVER_DOMAIN_UPLINK_CONFIG="router $(router_interface_for_server_domain)"


# apply configuration
for k in "CLIENT_DOMAIN_UPLINK_CONFIG" "CLIENT_DOMAIN_DOWNLINK_CONFIG" \
         "SERVER_DOMAIN_UPLINK_CONFIG" "SERVER_DOMAIN_DOWNLINK_CONFIG"
do
  # Even though no configuration has been supplied at this round, we
  # still need to drop any settings that are currently active on the interface.
  n=linkmap__${k}
  # ( vars[0] vars[1] ) <=> ( container-name network-interface )
  vars=( ${!n} )

  # Drop previous configuration (if any)
  echo ">>> [${vars[0]}:${vars[1]}] reset qdisc"
  reset_cmd="tc qdisc del dev ${vars[1]} root"
  docker-compose exec ${vars[0]} ${reset_cmd} || true

  if [ ! -z "${!k}" ]
  then
    # Apply new configuration
    echo ">>> [${vars[0]}:${vars[1]}] apply rule => ${!k}"
    apply_cmd="tc qdisc add dev ${vars[1]} root netem ${!k}"
    docker-compose exec ${vars[0]} ${apply_cmd}
  else
    echo ">>> Skipping empty $k"
  fi
done

exit 0

# vim: ai ts=2 sw=2 et sts=2 ft=sh
