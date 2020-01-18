#!/usr/bin/env bash
set -eux
# Circle CI Job for single architecture

# setup qemu/variables
. circle-vars.sh
docker run --rm --privileged multiarch/qemu-user-static:register --reset > /dev/null

# generate and build dockerfile
# docker run --rm -w /app -v $(pwd):/app kennethreitz/pipenv ./Dockerfile.py --arch=${CIRCLE_JOB} -v --hub_tag=${IMAGE}
docker build -t image_pipenv -f Dockerfile_build .
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock image_pipenv pipenv run ./Dockerfile.py
docker images

# run docker build & tests
# TODO: Add junitxml output and have circleci consume it
# 2 parallel max b/c race condition with docker fixture (I think?)
py.test -vv -n 2 -k "${CIRCLE_JOB}" ./test/

echo $DOCKERHUB_PASS | docker login --username=$DOCKERHUB_USER --password-stdin
docker push $IMAGE
