#!/usr/bin/env bash
set -ex
# Circle CI Job for merging/deploying all architectures (post-test passing)
. circle-vars.sh

annotate() {
    local base=$1
    local image=$2
    local arch=$3
    local annotate_flags="${annotate_map[$arch]}"

    $dry docker manifest annotate ${base} ${image} --os linux ${annotate_flags}
}

# Keep in sync with circle-ci job names
declare -A annotate_map=( 
    ["amd64"]="--arch amd64" 
    ["armel"]="--arch arm --variant v6" 
    ["armhf"]="--arch arm --variant v7" 
    ["arm64"]="--arch arm64 --variant v8"
)

# push image when not running a PR
if [[ "$CIRCLE_PR_NUMBER" == "" ]]; then
    images=()
    echo $DOCKERHUB_PASS | docker login --username=$DOCKERHUB_USER --password-stdin
    cat ~/.docker/config.json | jq '.experimental="enabled"' | tee ~/.docker/config.json
    ls -lat ./ci-workspace/
    cd ci-workspace

    for arch in *; do
        arch_image=$(cat $arch)
        docker pull $arch_image
        images+=($arch_image)
    done

    docker manifest create $MULTIARCH_IMAGE ${images[*]}
    for arch in *; do
        arch_image=$(cat $arch)
        docker pull $arch_image
        annotate "$MULTIARCH_IMAGE" "$arch_image" "$arch"
    done

    docker push "$MULTIARCH_IMAGE"
    docker manifest inspect "$MULTIARCH_IMAGE"
fi
