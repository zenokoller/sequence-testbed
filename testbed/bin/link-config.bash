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

if [ $# = 0 ]
then
  echo "Usage $0 -c <configuration file> [ -n ]"
  exit 1
fi

CONFIG=''
CHECK_CONTAINERS=true

while getopts 'c:n' flag; do
  case "${flag}" in
    c) CONFIG="${OPTARG}" ;;
    n) CHECK_CONTAINERS=false ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

# read links configuration from the supplied file and network configuration
# from .env
. "${CONFIG}"
. .env

# containers must be up & running for the script to work, unless we already checked this
if [ "${CHECK_CONTAINERS}" = true ]
then
  . $(dirname "$0")/check_containers_running.bash
  check_containers_running
fi

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
