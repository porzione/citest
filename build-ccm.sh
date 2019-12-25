#!/bin/bash

docker build \
       $@ \
       -t citest-ccm . \
       -f Dockerfile-ccm \
       --build-arg=SOURCE_COMMIT=$(git rev-parse --short HEAD) \
       --build-arg=SOURCE_BRANCH=$(git rev-parse --abbrev-ref HEAD)

docker tag citest-ccm porzione/citest-ccm
