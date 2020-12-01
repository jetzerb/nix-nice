#!/usr/bin/env bash
IFS=$'\n\t';
set -euo pipefail;

#
# Build the Docker container image.
# A symlink to this script should be placed in each build target folder
# to facilitate building the container image locally.

# get version info based on tag attached to HEAD commit

# Reproduce all the Docker variables and make them available to the hooks
export SOURCE_BRANCH="$(git rev-parse --abbrev-ref HEAD)";
export SOURCE_COMMIT="$(git log -1 --format='%H')";
export COMMIT_MSG="$(git log -1 --format='%s')";
export DOCKER_REPO="$(../util/get-repo-name --full)";
export DOCKERFILE_PATH="$PWD";
export CACHE_TAG="$(../util/inc-ver)";
export IMAGE_NAME="$DOCKER_REPO:$CACHE_TAG";

echo "Building Image $IMAGE_NAME";

# re-use the pre-build hook that Docker automated builds use
hooks/pre_build "$IMAGE_NAME";

# now build the image
latest="${IMAGE_NAME%%-v*}-latest";
docker build -t "$IMAGE_NAME" -t "$latest" .;

# do any testing and cleanup work
hooks/post_build "$IMAGE_NAME";

# Commit updated manifest and test results, and tag the code
../util/commit-and-tag "$CACHE_TAG";

# Push the images (requires user to enter username & password)
docker login;
docker push "$IMAGE_NAME";
docker push "$latest";
docker logout;
