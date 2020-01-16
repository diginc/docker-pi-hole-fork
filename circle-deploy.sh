#!/usr/bin/env bash
set -ex
# Circle CI Job for merging/deploying all architectures (post-test passing)
. circle-vars.sh

annotate() {
    local base=$1
    local image=$2
    local arch=${image##*_}
    local docker_arch=${arch_map[$arch]}

    if [ -z $docker_arch ]; then
        echo "Unknown arch in docker tag: ${arch}"
        exit 1
    else
        $dry docker manifest annotate ${base} ${image} --os linux --arch ${docker_arch}
    fi
}

# Confirm docker layer sharing worked
docker images

# Keep in sync with circle-ci job names
declare -A arch_map=( ["amd64"]="amd64" ["armhf"]="arm" ["arm64"]="arm64")
IMAGES=()

# push image when not running a PR
if [[ "$CIRCLE_PR_NUMBER" == "" ]]; then
    echo $DOCKERHUB_PASS | docker login --username=$DOCKERHUB_USER --password-stdin
    for TAG in ${!arch_map[@]}; do
       docker images | grep $TAG
    done
fi

