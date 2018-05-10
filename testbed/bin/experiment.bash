#!/bin/bash

set -eu

start_node() {
    local name=$1
    local running_time=$2
    local args=$3
    local entrypoint="/root/python/nodes/$name/main.py"

    if [ ! -z "${!args}" ]
    then
        echo ">>> Starting $name"
        cmd="timeout -sINT ${!running_time}s python ${entrypoint} ${!args}"
        docker-compose exec -T ${name} ${cmd} &
    else
        echo ">>> Skipping $name (no arguments given)"
    fi
}


if [ $# != 1 ]
then
  echo "Usage $0 <path to experiment config>"
  exit 1
fi

readonly CONF="$1"

# read configuration file
. "${CONF}"

# containers must be up & running for the script to work
. $(dirname $0)/utils/check-containers.bash
expect_containers_are_running


# configure netem (make this a function)
echo ">>> Configuring netem using ${NETEM_CONFIG}..."
OUTPUT=$(bin/link-config.bash conf/netem/${NETEM_CONFIG} --nocheck)

# start nodes
start_node server RUNNING_TIME SERVER_ARGS
start_node router RUNNING_TIME ROUTER_ARGS
start_node client RUNNING_TIME CLIENT_ARGS

wait
echo ">>> All processes done."

if [ ! -z "$EVALUATION_SCRIPT" ]
then
    echo ">>> TODO: Start evaluation script here"
else
    echo ">>> No evaluation script given, stopping..."
fi
