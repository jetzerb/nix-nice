#!/usr/bin/env bash
set -euo pipefail;
IFS=$'\n\t';

#
# Linux Container Entry Point / Startup script
#
#   * create users based on /hosthome directories
#   * if /home/<user> already exists (e.g. if persisted via a mount), ensure
#     that the uid is preserved
#   * start services (SSH, dbus), drop to shell
#


# if command provided, run it and exit
if [ "$#" -gt 0 ]
then
	eval "$@";
	exit 0;
fi;

# Do all the setup and save the output to a log file
(
	echo -e "\n============================================================";
	echo "$(date +'%Y-%m-%d %H:%M:%S %:z (%a, %Z)') Container Startup Script Execution";

	/opt/nix-nice/sbin/create-links.sh;
	/opt/nix-nice/sbin/environment-setup.sh;
	/opt/nix-nice/sbin/create-users.sh;

	echo "Starting dbus daemon";
	service dbus start;
	echo "Starting SSH daemon";
	service ssh start -D;  # -D => run in the foreground

) 2>&1 | tee -a /var/log/"$(basename "$0")";
