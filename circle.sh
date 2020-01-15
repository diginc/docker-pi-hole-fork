#!/usr/bin/env bash -ex

# Circle CI Job for single architecture

# setup qemu/variables
docker run --rm --privileged multiarch/qemu-user-static:register --reset > /dev/null

# The docker image will  match the github repo path by default but is overrideable with CircleCI environment
# IMAGE Overridable by Circle environment, including namespace (e.g. IMAGE=bobsmith/test-img:latest)
IMAGE="${IMAGE:-${CIRCLE_PROJECT_REPONAME}}"
HUB_NAMESPACE="${HUB_NAMESPACE:-$CIRCLE_PROJECT_USERNAME}"
[[ $CIRCLE_PROJECT_USERNAME == "pi-hole" ]] && HUB_NAMESPACE="pihole" # Custom mapping for namespace
[[ $IMAGE != *"/"* ]] && IMAGE="${HUB_NAMESPACE}/${IMAGE}" # If missing namespace, add one
[[ $IMAGE != *":"* ]] && IMAGE="${IMAGE}:$CIRCLE_JOB" # If tag missing, add circle job name as a tag (architecture here)

# Secondary docker tag info (origin github branch/tag) will get prepended also
DOCKER_TAG="${CIRCLE_TAG:-$CIRCLE_BRANCH}"
if [[ -n "$DOCKER_TAG" ]]; then
    # remove latest tag if used (as part of a user provided image variable)
    IMAGE="${IMAGE/:latest/:}"
    # Prepend the github tag(version) or branch. image:arch = image:v1.0-arch
    IMAGE="${IMAGE/:/:${DOCKER_TAG}-}"
    # latest- sometimes has a trailing slash, remove it
    IMAGE="${IMAGE/%-/}"
fi

# generate and build dockerfile
pip install -q --upgrade pip
pip install -q -r requirements.txt
./Dockerfile.py --arch=${CIRCLE_JOB} -v --hub_tag=${IMAGE}
docker images

# run docker build & tests
# 2 parallel max b/c race condition with docker fixture (I think?)
py.test -vv -n 2 -k "${CIRCLE_JOB}" ./test/

# push image when not running a PR
if [[ "$CIRCLE_PR_NUMBER" == "" ]]; then
    echo $DOCKERHUB_PASS | docker login --username=$DOCKERHUB_USER --password-stdin
    docker push ${IMAGE}
fi
