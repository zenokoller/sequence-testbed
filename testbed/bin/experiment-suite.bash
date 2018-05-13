#!/bin/bash

set -eu

# Usage $0 <conf name> <out dir> <plot.py path> <space-separated symbol_bits>
#
# Runs `experiment.bash` using `config` for all given `symbol_bits`, aggregating
# the results in $OUT_DIR. Then, runs `plot.py`.

readonly CONF_NAME=$1; shift
readonly OUT_DIR=$1; shift
readonly PLOT_PY_PATH=$1; shift

. bin/experiment.bash

readonly CSV_PATH="${OUT_DIR}/${CONF_NAME}-$(timestamp).csv"
touch "${CSV_PATH}"

# cycle through symbol_bits
for s in "$@"
do
    echo ">>> Running experiment.bash with -c ${CONF_NAME} -s ${s}..." 
    run_experiment "${CONF_NAME}" "${CSV_PATH}" "${s}"
done

echo ">>> Plotting using ${PLOT_PY_PATH}..."
OUTPUT=$(${PLOT_PY_PATH})
