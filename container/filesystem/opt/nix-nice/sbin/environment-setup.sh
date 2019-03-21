#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';


#
# ------
# Environment Variable Handling
#

ME=$(basename "$0");

# set base git repo url
if [ -n "${MYGITURL:-}" ] && [ -f /etc/gitconfig ]
then
	echo "$ME...Setting Git URL to $MYGITURL";
	sed -i "s!MYGITURL!$MYGITURL!" /etc/gitconfig;
else
	echo "$ME...MYGITURL not set; not setting alias in /etc/gitconfig";
fi;

# set up timezone
if [ -n "${MYTZ:-}" ]
then
	echo "$ME...Setting timezone to $MYTZ";
	echo "$MYTZ" > /etc/timezone;
	ln -sf /usr/share/zoneinfo/"$MYTZ" /etc/localtime;
else
	echo "$ME...MYTZ not set; not changing timezone";
fi;

# set up language
if [ -n "${MYLOCALE:-}" ]
then
	echo "$ME...Setting locale to $MYLOCALE";
	locale-gen "$MYLOCALE";
	update-locale LANG="$MYLOCALE";
else
	echo "$ME...MYLOCALE not set; not generating a locale";
fi;
