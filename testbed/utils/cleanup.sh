#!/bin/bash

set -exu

for cmd in \
	"down --rmi local" \
	"build --no-cache" \
	"up -d"
do
	docker-compose ${cmd}
done
