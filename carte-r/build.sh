#!/bin/bash
set -euxo pipefail
self_path=$(dirname $0)
cd ${self_path}/assets
# Target platform, e.g. PLATFORM=linux/arm64 ./build.sh
PLATFORM=${PLATFORM:-linux/amd64}
docker build --platform=${PLATFORM} -f ../Dockerfile --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg BUILD_VERSION="latest" -t carte-r:latest .
