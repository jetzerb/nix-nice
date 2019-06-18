# Installation & Container Build Instructions

## Installation
If you run Ubuntu Linux, and want to use the nix-nice software, you can jump
into the directory of interest (base, dev, etc) and run the `install.sh` script.
It will run the portions of the Dockerfile that perform the software
installation.  There may or may not be dependencies that require to you run the
base installation script before the others.

## Local Container Build
Run the `container-build.sh` script to build locally.  It will set up
environment variables just like the Docker Hub build process, and call the pre &
post build scripts.

## Hooks Directory
Each of the nix-nice build targets utilizes the common pre & post build scripts,
which are kept in the hooks directory here.

## Linux vs Windows Issues
My initial goal was to allow the container to be built on windows using WSL.
However, there have been issues maintaining file permissions and symbolic links.
Since the Docker build process runs on Linux, there are no such problems.  To
simplify the codebase, going forward a Linux environment will be assumed.  If
you are on a non-Linux environment and want to build a nix-nice container
locally, you can:
- run a nix-nice container
- make whatever changes/enhancements you like
- install and run Docker within the container
- run the container build process.  If you want to use the newly-built container
  image, you'll need to `docker save` the image to a tar file that is visible on
  your host machine, and then `docker load` the tar file from the host, or
  `docker push` the image your repository from within the container, and then
  `docker pull` the image on your host.
