#!/bin/sh

ALPINE=${1:-3.24.2}
UNBOUND=${2:-1.26.2}

docker buildx build \
    --build-arg ALPINE=${ALPINE} \
    --build-arg UNBOUND=${UNBOUND} \
    .
