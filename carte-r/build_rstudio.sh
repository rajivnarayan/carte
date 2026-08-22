#!/bin/bash
# Build and push a Docker image with RStudio pre-installed to Docker Hub
# Usage: ./build_rstudio.sh [tag]
#
# tag: optional tag override, defaults to latest

set -euxo pipefail
self_path=$(dirname $0)

IMAGE_NAME=askrajiv/carte-r-rstudio
TAG=${1:-latest}
cd ${self_path}
docker build --platform=linux/amd64 -f Dockerfile.rstudio -t ${IMAGE_NAME}:${TAG} .
docker push ${IMAGE_NAME}:${TAG}
