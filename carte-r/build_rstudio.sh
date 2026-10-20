#!/bin/bash
# Build and push a Docker image with RStudio pre-installed to Docker Hub
# Usage: ./build_rstudio.sh [tag]
#
# tag: optional tag override, defaults to latest
# PLATFORM: target platform env var, defaults to linux/amd64

set -euxo pipefail
self_path=$(dirname $0)

IMAGE_NAME=askrajiv/carte-r-rstudio
TAG=${1:-latest}
PLATFORM=${PLATFORM:-linux/amd64}
cd ${self_path}
docker build --platform=${PLATFORM} -f Dockerfile.rstudio -t ${IMAGE_NAME}:${TAG} .
docker push ${IMAGE_NAME}:${TAG}
