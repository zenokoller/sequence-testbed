#!/bin/bash

set -eu

start_node() {
    local name=$1
    local args=$2

    local entrypoint="/root/python/nodes/$name/main.py"

    if [ ! -z "${!args}" ]
    then
        echo ">>> Starting $name"
        timeout="timeout -sINT ${RUNNING_TIME}s"
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
    # Starts nodes where {CLIENT|ROUTER|SERVER}_ARGS is nonempty, node configuration 
    # taken from separate config file. 
    # Stop nodes after RUNNING_TIME and run POST_RUN_SCRIPT.

    local csv_path=$1
    local symbol_bits=$2

    symbol_bits_arg=''
    if [ ! -z ${symbol_bits} ]
    then
        symbol_bits_arg="-s ${symbol_bits}"
    fi

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

    if [ ! -z "${POST_RUN_SCRIPT}" ]
    then
        EVAL_ARGS="${START_TIME}s ${END_TIME}s ${csv_path} ${symbol_bits}"
        echo ">>> Running ${POST_RUN_SCRIPT} ${EVAL_ARGS}"
        OUTPUT=$(${POST_RUN_SCRIPT} ${EVAL_ARGS})
    else
        echo ">>> No evaluation script given, stopping..."
    fi
}

if [ $# -ne 3 ]
then
    echo "Usage $0 <config name> <out dir> <run name>"
    exit 1
fi

readonly CONFIG=$1
readonly OUT_DIR=$2
readonly NAME=$3

#  Create file for writing results
readonly RUN_ID="${NAME}-$(timestamp)"
readonly CSV_PATH="${OUT_DIR}/${CONFIG}-${RUN_ID}.csv"
echo ">>> Writing results to ${CSV_PATH}"
touch "${CSV_PATH}"

# read configuration file
echo ">>> Using config ${CONFIG}"
. "conf/experiment/${CONFIG}.conf"

# containers must be up & running
. $(dirname $0)/utils/check-containers.bash
expect_containers_are_running

for s in $SYMBOL_BITS
do
    for ((i=1; i<=$RUNS; i++));
    do
        echo ">>> Running experiment with -s ${s} (${i} of ${RUNS})..." 
        run_experiment "${CSV_PATH}" "${s}"
    done
done

PLOT_ARGS="${CSV_PATH} ${RUN_ID}"
echo ">>> Plotting: ${PLOT_SCRIPT} ${PLOT_ARGS}"
OUTPUT=$(${PLOT_SCRIPT} "${PLOT_ARGS}")
