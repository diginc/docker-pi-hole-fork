#!/usr/bin/env bash
set -ex

# Circle CI Job for single architecture

# setup qemu/variables
docker run --rm --privileged multiarch/qemu-user-static:register --reset > /dev/null
. circle-vars.sh

# generate and build dockerfile
docker build -t image_pipenv -f Dockerfile_build .
env > /tmp/env
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$(pwd):/ws" \
    --env-file /tmp/env \
    image_pipenv /ws/Dockerfile.sh
# docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd):/ws" --env-file /tmp/env image_pipenv /ws/Dockerfile.sh

docker images
echo $DOCKERHUB_PASS | docker login --username=$DOCKERHUB_USER --password-stdin
docker push $IMAGE
