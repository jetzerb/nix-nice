#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

#
# Linux Container Entry Point / Startup script
#
#   * if persisted system files exist, restore them
#   * create users based on /hosthome directories
#   * if /home/<user> already exists (e.g. if persisted via a mount), ensure
#     that the uid is preserved
#   * start services (SSH, dbus), drop to shell
#


#
# ------
# Function to show usage information if unknown options are specified
#
usage() {
	cat <<EOF >&2
Usage: $0 [-e] [-p] [-u] [-s]
	-e to handle environment variables passed in at container startup
	-p TODO: to restore persisted files, based on persistfs volume mount
	-u to create users, based on hosthome volume mount
	-s to start services (SSH, dbus)
EOF
	exit 1;
}


#
# ------
# Main
#
while getopts ":epus" opt
do
	case "$opt" in
		e) ENVIRO=1;;
		p) PERSIST=1;;
		u) USERS=1;;
		s) SERVICES=1;;
		*) usage;;
	esac;
done;

# Do all the setup and save the output to a log file
(
	echo -e "\n============================================================";
	echo "$(date +'%Y-%m-%d %H:%M:%S %:z (%a, %Z)') Container Startup Script Execution";
	echo "Full commandline: $@";
	/usr/local/sbin/create_links.sh;
	[ -n "${ENVIRO:-}"  ] && /usr/local/sbin/environment_setup.sh;
	[ -n "${PERSIST:-}" ] && echo "No persistent file restore yet"; #/usr/local/sbin/persistfs_sync.sh;
	[ -n "${USERS:-}"   ] && /usr/local/sbin/create_users.sh;
	if [ -n "${SERVICES:-}" ]
	then
		echo "Starting dbus daemon";
		service dbus start;
		echo "Starting SSH daemon";
		service ssh start;
	fi;

) 2>&1 | tee -a /var/log/$(basename "$0");

# keep container running after doing all of the above
sleep infinity;
