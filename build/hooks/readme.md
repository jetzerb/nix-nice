# Docker Build Phase Hooks

## Generic Instructions
Per [Docker's documentation](https://docs.docker.com/docker-hub/builds/advanced),
the hooks directory holds custom scripts that will be run as part of Docker Hub's
automated builds.

File Names must be:
- hooks/post_checkout
- hooks/pre_build
- hooks/post_build
- hooks/pre_test
- hooks/post_test
- hooks/pre_push (only used when executing a build rule or automated build )
- hooks/post_push (only used when executing a build rule or automated build )

And several environment variables are available:

- SOURCE_BRANCH: the name of the branch or the tag that is currently being tested.
- SOURCE_COMMIT: the SHA1 hash of the commit being tested.
- COMMIT_MSG: the message from the commit being tested and built.
- DOCKER_REPO: the name of the Docker repository being built.
- DOCKERFILE_PATH: the dockerfile currently being built.
- CACHE_TAG: the Docker repository tag being built.
- IMAGE_NAME: the name and tag of the Docker repository being built. (This variable is a combination of DOCKER_REPO:CACHE_TAG.)


## Usage within this repo
All build targets contain hooks directories with symlinks to the scripts in
the build directory.

The pre_build hook is used to
1. Merge the base image & container image filesystems together
2. Create the Message Of The Day within the container image

The post_build hook just does a bit of cleanup and then issues a status message.

See build-container.sh for more information.
