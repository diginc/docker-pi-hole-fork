#!/usr/bin/env bash
set -ex

# Circle CI Job for single architecture

# setup qemu/variables
docker run --rm --privileged multiarch/qemu-user-static:register --reset > /dev/null
. circle-vars.sh

# generate and build dockerfile
# docker run --rm -w /app -v $(pwd):/app kennethreitz/pipenv ./Dockerfile.py --arch=${ARCH} -v --hub_tag=${IMAGE}
docker build -t image_pipenv -f Dockerfile_build .
env > /tmp/env
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$(pwd):/app" \
    --env-file /tmp/env \
    image_pipenv /app/Dockerfile.sh

docker images
echo $DOCKERHUB_PASS | docker login --username=$DOCKERHUB_USER --password-stdin
docker push $IMAGE
