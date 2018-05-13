#!/bin/bash

set -eu

# `run_experiment` runs a single experiment:
# 
# - Read config from -c flag, optional symbol_bits from -s
# - Configure netem using file config/netem/$NETEM_config
# - Start nodes where {CLIENT|ROUTER|SERVER}_ARGS is nonempty,
#   node configuration given in separate config file
# - Stop nodes after RUNNING_TIME
# - Run EVALUATION_SCRIPT

start_node() {
    local name=$1
    local args=$2

    local entrypoint="/root/python/nodes/$name/main.py"

    if [ ! -z "${!args}" ]
    then
        echo ">>> Starting $name"
        timeout="timeout -sKILL ${RUNNING_TIME}s"
        cmd="${timeout} python ${entrypoint} ${!args} ${symbol_bits_arg}"
        docker-compose exec -T ${name} ${cmd} &
    else
        echo ">>> Skipping $name (no arguments given)"
    fi
}

timestamp() {
  date +"%s"
}

run_experiment() {
    local config=$1
    local csv_path=$2
    local symbol_bits=$3

    symbol_bits_arg=''
    if [ ! -z ${symbol_bits} ]
    then
        symbol_bits_arg="-s ${symbol_bits}"
    fi

    # read configuration file
    . "conf/experiment/${config}.conf"

    # containers must be up & running for the script to work
    . $(dirname $0)/utils/check-containers.bash
    expect_containers_are_running


    # configure netem (make this a function)
    echo ">>> Configuring netem using ${NETEM_CONFIG}..."
    OUTPUT=$(bin/link-config.bash -c conf/netem/${NETEM_CONFIG} -n)

    # start nodes
    START_TIME=$(timestamp)
    sleep 3

    start_node server SERVER_ARGS
    start_node router ROUTER_ARGS
    start_node client CLIENT_ARGS

    wait
    sleep 3
    END_TIME=$(timestamp)
    echo ">>> All processes done."

    if [ ! -z "${EVALUATION_SCRIPT}" ]
    then
        EVAL_ARGS="${START_TIME}s ${END_TIME}s ${csv_path} ${symbol_bits}"
        echo ">>> Running evaluation: ${EVALUATION_SCRIPT} ${EVAL_ARGS}"
        OUTPUT=$(${EVALUATION_SCRIPT} ${EVAL_ARGS})
    else
        echo ">>> No evaluation script given, stopping..."
    fi
}
