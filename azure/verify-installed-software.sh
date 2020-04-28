#!/usr/bin/env bash

#
# Test Script for Azure layer
#


#
# Function to spit out a header for the output of a test
printHdr () {
	echo -e "\nCommand: $1" |sed 'h; s/./-/g; p; x;';
}

checkInstall() {
	printHdr "$1";
	dpkg -l "$1" \
	| awk '
		BEGIN {msg = "ERROR: Package Not Installed!";}
		/^ii/ {msg = "OK";}
		END {print msg;}';
}

checkCommand() {
	printHdr "$1";
	eval "$2"  > /dev/null && echo "OK" || echo "ERROR";
}

# ensure we're all set up properly
export SHELL="$(command -v bash)";
. /etc/profile;
MYLOCALE=en_US.utf8 /opt/nix-nice/sbin/environment-setup.sh > /dev/null;


dir=/tmp/test;
mkdir -p "$dir" && cd "$dir";



# Test everything installed in the Dockerfile
checkInstall "libffi-dev";
checkInstall "libxss1";
checkInstall "libgconf-2-4";
checkInstall "libunwind8";

cmd='az';              checkCommand "$cmd" '$cmd extension list';
cmd='azuredatastudio'; checkCommand "$cmd" '$cmd --user-data-dir=/tmp --list-extensions';
