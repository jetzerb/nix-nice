# Nix-Nice
My \*NIX environment: Packages, profile, scripts, etc, for every day use
and/or software development, either on a dedicated machine or a container.

The primary motivators for this project are to
- Document my preferred development environment.
- Package it up in a Docker Container that I can run on Windows in place
  of [Git for Windows](https://gitforwindows.org/) and [Windows
  Subsystem for
  Linux](https://docs.microsoft.com/en-us/windows/wsl/about), because of
  how [SLOW](https://rufflewind.com/2014-08-23/windows-bash-slow)
  those environments are.  Things have gotten better some time in later
  2018, so that WSL is not nearly as slow as it used to be, but still
  pretty inconvenient.

## Layout
In order to appeal to a wide audience, there are multiple layers of
files
- base layer applicable to any linux user comfortable with the commandline
- layer for developers (git, [VS Code](https://code.visualstudio.com/),
  [DBeaver](https://dbeaver.io/))
- layer for MS-centric developers ([VSTS
  CLI](https://docs.microsoft.com/en-us/cli/vsts/overview?view=vsts-cli-latest))

## Docker Container
If you configure your Windows >= 10 or Server >= 2016 to use Docker,
you can run a linux container, which uses an actual Linux kernel, and get
things done in 1-10% of the time required by non-native Linux-on-Windows
solutions.

**NOTE**: If you use a bind mount to share your files between the
Windows host and the container, Docker will make an SMB share behind the
scenes.  From within the container, I have observed that file access is
about 10% as fast as with the native Linux filesystem.

For this reason, I created a docker volume to hold the development
files. I tried using Guido Diepen's
[volume-sharer](https://github.com/gdiepen/volume-sharer)
container to access the files from Windows.  Unfortunately, this is also
very slow; you have to click through popup warnings about non-local files,
and Visual Studio doesn't seem to notice when files update.  VS is also
*significantly* slower.  I don't know if there is a graceful solution:(.
I'm currently using an rsync-based script to compare and sync between the
container filesystem and the windows host filesystem, and have been using
that without any significant problems. You can call it in one of three
ways:
- cmphost: compare container filesystem to the corresponding location
  on the host
- sethost: copy files from the container to the corresponding location
  on the host
- gethost: copy files from the corresponding location on the host to
  the container

Open Item list:
- [Git Credential Manager for Mac & Linux](https://github.com/Microsoft/Git-Credential-Manager-for-Mac-and-Linux)
  requires a java runtime, which significantly bloats the container size.
  For now, just use Personal Access Tokens.  The default git config file
  will cache the credentials for 10 hours, so you should only need to
  enter your name & token once per day.
- The original image is based on Alpine Linux because the resulting container
  image builds faster and is much smaller than the corresponding Ubuntu-based
  image.  However, Alpine is based on the [musl](https://www.musl-libc.org/)
  c library, rather than [glibc](https://www.gnu.org/software/libc/).
  Electron (the framework upon which Atom, VS Code, SQL Ops Studio, and
  other cool toys are built) [doesn't work with
  musl](https://github.com/electron/electron/issues/9662).
  I'm switching to Ubuntu for now.  It also has more packages that I'm
  interested in, so the Dockerfiles tend to be more straight-forward.

### TODO
- Scour the internet for cool things to add.  For example, [CLI
  Improved](https://news.ycombinator.com/item?id=17874718)
- Figure out how [Git Bash](https://git-scm.com/) determines user IDs.
  Somehow the "id" command knows about all the users in my organization,
  and spits out a unique 7 digit number for each person.  We all seem to
  share the same group id.  It's tied to Active Directory somehow, but I
  don't know exactly how.  And when I run ```whoami -all``` from a
  powershell window, it dumps out an awful lot of information, but the
  UID and GID that Git Bash reports are nowhere to be found.
  Running ```strace id``` shows references to
  ```pwdgrp::fetch_account_from_windows```. This isn't important for
  individual use of the container, but if the container is shared on a
  terminal server, it's important to keep everyone's user IDs consistent.
  MS claims to be working on AD authentication for Linux containers
  under mssql-docker [issue #165](https://github.com/Microsoft/mssql-docker/issues/165).
  There are at least two other issues that have been folded into it, but
  thus far nothing has come of it.
  - [#262](https://github.com/Microsoft/mssql-docker/issues/262)
  - [#273](https://github.com/Microsoft/mssql-docker/issues/273)
- VS Code is quite sluggish using X forwarding.  Couldn't get x2go Windows
  client work.  There is much better performance when coding in a browser
  via [code-server](https://github.com/cdr/code-server).
- Allow LCOW?  Currently, the `--mount` syntax doesn't work.  I'm sure
  there are other issues as well.
