export DOCKER_CLI_EXPERIMENTAL=enabled
export CIRCLE_JOB="${CIRCLE_JOB:-}"
export ARCH="${ARCH:-$CIRCLE_JOB}"
if [[ -z "$ARCH" ]] ; then
    echo "Defaulting arch to amd64"
    ARCH="amd64"
fi
export IMAGE="${IMAGE:-${CIRCLE_PROJECT_REPONAME}}"
if [[ -z "$IMAGE" ]] ; then
    echo "Defaulting image name to pihole"
    IMAGE="pihole"
fi

# The docker image will  match the github repo path by default but is overrideable with CircleCI environment
# IMAGE Overridable by Circle environment, including namespace (e.g. IMAGE=bobsmith/test-img:latest)
export CIRCLE_PROJECT_USERNAME="${CIRCLE_PROJECT_USERNAME:-unset}"
export HUB_NAMESPACE="${HUB_NAMESPACE:-$CIRCLE_PROJECT_USERNAME}"
[[ $CIRCLE_PROJECT_USERNAME == "pi-hole" ]] && HUB_NAMESPACE="pihole" # Custom mapping for namespace
[[ $IMAGE != *"/"* ]] && IMAGE="${HUB_NAMESPACE}/${IMAGE}" # If missing namespace, add one

# Secondary docker tag info (origin github branch/tag) will get prepended also
if [[ $CIRCLE_JOB != *"deploy"* ]] ; then
    [[ $IMAGE != *":"* ]] && IMAGE="${IMAGE}:$ARCH" # If tag missing, add circle job name as a tag (architecture here)
  export DOCKER_TAG="${CIRCLE_TAG:-$CIRCLE_BRANCH}"
  if [[ -n "$DOCKER_TAG" ]]; then
      # remove latest tag if used (as part of a user provided image variable)
      IMAGE="${IMAGE/:latest/:}"
      # Prepend the github tag(version) or branch. image:arch = image:v1.0-arch
      IMAGE="${IMAGE/:/:${DOCKER_TAG}-}"
      # latest- sometimes has a trailing slash, remove it
      IMAGE="${IMAGE/%-/}"
  fi
fi
