#!/bin/bash
# build and push a Docker image with R-studio to AWS ECR
# Usage ./build.sh [ecr_tag]
# 
# ecr_tag: if provided, will tag the image with it before pushing it
# the to Image registry. Default is to tag the image as latest

set -euxo pipefail
self_path=$(dirname $0)

IMAGE_NAME=mrt-carte-r-rstudio
IMAGE_VER=$(git rev-parse --short HEAD)
ECR_TAG=${1:-latest}
ECR_NAME=276385367356.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_NAME}:${ECR_TAG}
cd ${self_path}
docker build --platform=linux/amd64 -f Dockerfile.rstudio -t $IMAGE_NAME:${IMAGE_VER} .
docker tag ${IMAGE_NAME}:${IMAGE_VER} ${ECR_NAME}
docker push ${ECR_NAME}
