#!/bin/bash

set -eu

# Cycles given netem configs with `interval` [s] for `repeats` times.

if [ $# -lt 3 ]
then
    echo "Usage $0 <interval> <repeats> <space separated config names>"
    exit 1
fi

readonly INTERVAL=$1; shift
readonly REPEATS=$1; shift
readonly CONFIGS=( $@ )

# containers must be up & running
. $(dirname "$0")/check_containers_running.bash
check_containers_running

for ((i=0; i<$REPEATS; i++));
do
    conf="conf/${CONFIGS[$(($i % $#))]}.conf"
    echo ">>> Applying ${conf}..."
    $(dirname "$0")/link-config.bash -c "${conf}" -n
    sleep $INTERVAL
done

echo ">>> Done after ${REPEATS} config changes. Resetting links..."
$(dirname "$0")/link-reset.bash
