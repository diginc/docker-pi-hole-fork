#!/usr/bin/env bash
set -eux
# Circle CI Job for single architecture

# setup qemu/variables
. circle_vars.sh
docker run --rm --privileged multiarch/qemu-user-static:register --reset > /dev/null

# generate and build dockerfile
pip install -q --upgrade pip
pip install -q -r requirements.txt
./Dockerfile.py --arch=${CIRCLE_JOB} -v --hub_tag=${IMAGE}
docker images

# run docker build & tests
# TODO: Add junitxml output and have circleci consume it
# 2 parallel max b/c race condition with docker fixture (I think?)
py.test -vv -n 2 -k "${CIRCLE_JOB}" ./test/

echo $DOCKERHUB_PASS | docker login --username=$DOCKERHUB_USER --password-stdin
docker push $IMAGE
