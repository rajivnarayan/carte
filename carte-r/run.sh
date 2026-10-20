#!/bin/bash
# Run a carte-r service defined in docker-compose.yml
# Usage: ./run.sh [service]
#
# service: one of the services in docker-compose.yml, defaults to rstudio_static
# Images and settings are read from .env

set -euo pipefail

if docker compose version &>/dev/null; then
	# use docker compose if it exists
	DOCKER_COMPOSE_CMD='docker compose'
elif [ -x "$(command -v docker-compose)" ]; then
	# try system version
	DOCKER_COMPOSE_CMD='docker-compose'
else
	echo "docker compose not found"
	exit 1
fi

self_path=$(dirname $(readlink -f $0))
COMPOSE="${DOCKER_COMPOSE_CMD} -f ${self_path}/docker-compose.yml"
SERVICE=${1:-rstudio_static}

# check that the service exists
SERVICES=$(${COMPOSE} config --services)
if ! grep -qx "${SERVICE}" <<< "${SERVICES}"; then
	echo "Unknown service: ${SERVICE}"
	echo "Available services:"
	echo "${SERVICES}"
	exit 1
fi

set -x

# pull latest version of container
${COMPOSE} pull ${SERVICE}

if [[ ${SERVICE} == 'base' ]]; then
	# base is an interactive shell
	${COMPOSE} run --rm ${SERVICE}
else
	${COMPOSE} up ${SERVICE}
fi
