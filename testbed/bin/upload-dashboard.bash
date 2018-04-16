#!/bin/bash

set -eu

if [ $# != 1 ]
then
  echo "Usage $0 <dashboard file>"
  exit 1
fi

readonly DASHBOARD="$1"
readonly CHRONOGRAF="http://localhost:8888/chronograf/v1/dashboards"

cat ${DASHBOARD} \
  | jq -r '.dashboards[]' \
  | curl \
    --silent \
    --include \
    --request POST \
    --header "Accept: application/json" \
    --dump-header - \
    --data @- \
    --output /dev/null \
    ${CHRONOGRAF}

# vim: ai ts=2 sw=2 et sts=2 ft=sh
