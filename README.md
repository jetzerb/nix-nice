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
- layer for MS-centric developers ([Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
  and [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download?view=sql-server-2017))

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

### How to use the container
#### Create SSH Keys
You get into the container via ssh using key-based authentication.
The container startup script assumes there's a /hosthome mount and looks
for users with a ".ssh" folder, and then proceeds to create each of those
users inside the container and copies in the user's public keys. So each
interested user should run `ssh-keygen` if they don't yet have keys.
#### Optionally Create Docker Volume
If you plan to use the container for development purposes, you'll
definitely want to create a volume to mount as `/home` so that your work
survives container restarts.

```sh
docker volume create userdata
```

#### Start the Container
See `container-start*` files and/or docker compose files in the `container`
folder of the [nix-nice](https://github.com/jetzerb/nix-nice) git repo.
On Windows, you'd issue a command like this:
```dos
docker run --detach ^
-e "MYTZ=America/Chicago" ^
-e "MYLOCALE=en_US.utf8" ^
--mount type=bind,source="C:\Users",target=/hosthome ^
--mount type=volume,source=userdata,target=/home ^
-p 9922:22 ^
-h nix-nice ^
--name nix-nice ^
jetzerb/nix-nice:TagNameGoesHere
```

The `MYTZ` and `MYLOCALE` variables cause the container startup script
to set the container's time zone, and generate the specified locale.

The `hosthome` bind mount is required if users are to `ssh` into the
container.

The `userdata` volume mount holds users' home directories in the
container, so that when the container is re-started, their data is
persisted.

The `-p` option maps the desired port to the container's SSH port.
You can use 22 if you like, or any other port.

The `-h` option sets the host name.

The `--name` option sets the docker container name (as displayed by
`docker ps`).

Be sure to specify the desired tag name in place of `TagNameGoesHere`.

In a \*NIX environment, you'd issue the same command as above, but with
backslashes (\\) instead of carets (^) as the line continuation character,
and you'd specify `/home` in place of `C:\Users` in the bind mount.

#### Connect to the Container
Use `ssh` to connect to the container.  You may use X11 forwarding.
On Windows, I recommend using [SmarTTY](http://sysprogs.com/SmarTTY/),
since it comes bundled with an X server.


### Open Item list
- [Git Credential Manager for Mac & Linux](https://github.com/Microsoft/Git-Credential-Manager-for-Mac-and-Linux)
  requires a java runtime, which significantly bloats the container size.
  For now, just use Personal Access Tokens.  The default git config file
  will cache the credentials for 10 hours, so you should only need to
  enter your name & token once per day.
- The original image was based on Alpine Linux because the resulting container
  image builds faster and is much smaller than the corresponding Ubuntu-based
  image.  However, Alpine is based on the [musl](https://www.musl-libc.org/)
  c library, rather than [glibc](https://www.gnu.org/software/libc/).
  Electron (the framework upon which Atom, VS Code, SQL Data Studio, and
  other cool toys are built) [doesn't work with
  musl](https://github.com/electron/electron/issues/9662).
  I switched to Ubuntu.  It also has more packages that I'm
  interested in, so the Dockerfiles tend to be more straight-forward.

### TODO
- Scour the internet for cool things to add.  For example, [CLI
  Improved](https://news.ycombinator.com/item?id=17874718)
- Figure out how [Git Bash](https://git-scm.com/) determines user IDs.
  Somehow the "id" command knows about all the users in my organization,
  and spits out a unique 7 digit number for each person.  We all seem to
  share the same group id.  It's tied to Active Directory somehow, but I
  don't know exactly how.  And when I run `whoami -all` from a
  powershell window, it dumps out an awful lot of information, but the
  UID and GID that Git Bash reports are nowhere to be found.
  Running `strace id` shows references to
  `pwdgrp::fetch_account_from_windows`. This isn't important for
  individual use of the container, but if the container is shared on a
  terminal server, it's important to keep everyone's user IDs consistent.
  MS claims to be working on AD authentication for Linux containers
  under mssql-docker [issue #165](https://github.com/Microsoft/mssql-docker/issues/165).
  There are at least two other issues that have been folded into it, but
  thus far nothing has come of it.
  - [#262](https://github.com/Microsoft/mssql-docker/issues/262)
  - [#273](https://github.com/Microsoft/mssql-docker/issues/273)
- Graphical apps are quite sluggish using X forwarding on Windows.  Couldn't
  get x2go Windows client work.  There is much better performance when
  coding in a browser via [code-server](https://github.com/cdr/code-server).
  This seems to be much less of an issue on Linux.  Perhaps X Servers on
  Windows are just slow?
- Allow LCOW?  Currently, the `--mount` syntax doesn't work.  I'm sure
  there are other issues as well.
