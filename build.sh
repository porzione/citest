#!/bin/bash

docker build \
       $@ \
       -t citest . \
       --build-arg=SOURCE_COMMIT=$(git rev-parse --short HEAD) \
       --build-arg=SOURCE_BRANCH=$(git rev-parse --abbrev-ref HEAD)

