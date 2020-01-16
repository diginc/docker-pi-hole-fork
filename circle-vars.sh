export DOCKER_CLI_EXPERIMENTAL=enabled

# The docker image will  match the github repo path by default but is overrideable with CircleCI environment
# IMAGE Overridable by Circle environment, including namespace (e.g. IMAGE=bobsmith/test-img:latest)
IMAGE="${IMAGE:-${CIRCLE_PROJECT_REPONAME}}"
HUB_NAMESPACE="${HUB_NAMESPACE:-$CIRCLE_PROJECT_USERNAME}"
[[ $CIRCLE_PROJECT_USERNAME == "pi-hole" ]] && HUB_NAMESPACE="pihole" # Custom mapping for namespace
[[ $IMAGE != *"/"* ]] && IMAGE="${HUB_NAMESPACE}/${IMAGE}" # If missing namespace, add one

# Secondary docker tag info (origin github branch/tag) will get prepended also
if [[ $CIRCLE_JOB != *"deploy"* ]] ; then
    [[ $IMAGE != *":"* ]] && IMAGE="${IMAGE}:$CIRCLE_JOB" # If tag missing, add circle job name as a tag (architecture here)
  DOCKER_TAG="${CIRCLE_TAG:-$CIRCLE_BRANCH}"
  if [[ -n "$DOCKER_TAG" ]]; then
      # remove latest tag if used (as part of a user provided image variable)
      IMAGE="${IMAGE/:latest/:}"
      # Prepend the github tag(version) or branch. image:arch = image:v1.0-arch
      IMAGE="${IMAGE/:/:${DOCKER_TAG}-}"
      # latest- sometimes has a trailing slash, remove it
      IMAGE="${IMAGE/%-/}"
  fi
fi
