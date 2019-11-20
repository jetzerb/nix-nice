#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

#
# Sync or compare the current folder with the same folder on the host system
# The action of the script depends on the how the script was called:
#   cmphost.sh compares the current folder to the host system
#   gethost.sh pulls from the host system to the current folder
#   sethost.sh pushes the current folder to the host system
#

if [ "${PWD#~/hosthome}" != "$PWD" ]
then
	echo "Current directory is on the host filesystem." >&2;
	exit 1;
fi;

HOSTPATH="$HOME/hosthome${PWD#$HOME}/";
CMD=$(basename "$0");
CMD=${CMD:0:3};

if [ "$CMD" = "get" ]
then
	SRC="$HOSTPATH";
	TGT=".";
	echo "Pulling from Host";
else
	SRC=".";
	TGT="$HOSTPATH";
	if [ "$CMD" = "cmp" ]
	then
		echo "Comparing to Host";
	else
		echo "Pushing to Host";
	fi;
fi;

if [ "$CMD" = "cmp" ]
then
	meld "$SRC" "$TGT";
else
	EXCLUDES=();
	for FILE in ~/.config/rsync/*excl*
	do
		[ -f "$FILE" ] && EXCLUDES+=(--exclude-from="$FILE");
	done;
	mkdir -p "$TGT"; # rsync won't create the target directory
	rsync -av --del "${EXCLUDES[@]}" "$SRC" "$TGT";
fi;
