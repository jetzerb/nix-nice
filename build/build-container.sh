#!/bin/sh

#
# Build the Docker container image.
# A symlink to this script should be placed in each build target folder
# to facilitate building the container image locally.

# get version info based on tag attached to HEAD commit
VER=$(git log -1 --format='%D' |sed -n '/tag:/{s/.*tag: *//; s/ .*//; s/,.*//; p;}');

if [ -z "$VER" ]
then
	echo "Current HEAD has no tag.";
	VER="local-$(git log -1 --format='%h')"; # use short commit hash
fi;

# Reproduce all the Docker variables and make them available to the hooks
export SOURCE_BRANCH=$(git rev-parse --abbrev-ref HEAD);
export SOURCE_COMMIT=$(git log -1 --format='%H');
export COMMIT_MSG=$(git log -1 --format='%s');
export DOCKER_REPO='jetzerb/nix-nice';
export DOCKERFILE_PATH=$PWD;
export CACHE_TAG="${PWD##*/}-$VER";
export IMAGE_NAME="$DOCKER_REPO:$CACHE_TAG";

echo "Building Image $IMAGE_NAME";

# re-use the pre-build hook that Docker automated builds use
hooks/pre_build;

# now build the image
docker build -t "$IMAGE_NAME" .;

# do any cleanup work
hooks/post_build;
