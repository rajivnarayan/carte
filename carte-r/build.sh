#!/bin/bash
set -euxo pipefail
self_path=$(dirname $0)
cd ${self_path}/assets
docker build --platform=linux/amd64 -f ../Dockerfile --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION="latest" -t carte-r:latest .
