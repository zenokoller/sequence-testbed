#!/usr/bin/env bash

expect_containers_are_running() {
  echo ">>> Checking containers are running..."

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
