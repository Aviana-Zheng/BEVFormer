#!/bin/bash
DOCKER_BUILDKIT=1 docker build --build-arg CUDA_VERSION=11.1.1 \
                               --build-arg CUDNN_VERSION=8 \
                               --build-arg OS_VERSION=20.04 \
                               --add-host github.com:20.205.243.166 -f Dockerfile -t bevformer:1.0 . 