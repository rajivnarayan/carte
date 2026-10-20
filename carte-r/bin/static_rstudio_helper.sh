#!/bin/bash
# Helper script to run the static carte-r-rstudio image (RStudio pre-installed)
# The image is set by CARTE_IMAGE_RSTUDIO in .env
set -euxo pipefail

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

# pull latest version of container
${DOCKER_COMPOSE_CMD} -f $self_path/../docker-compose.yml pull rstudio_static

# launch rstudio
${DOCKER_COMPOSE_CMD} -f $self_path/../docker-compose.yml up rstudio_static
