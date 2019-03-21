#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

#
# Windows Subsystem for Linux doesn't know how to handle symbolic links
# properly.  It just creates a file that references the source.  So when
# the container starts, create links as necessary.
#

cd /opt/nix-nice;
find . -type f |
while read FILE
do
	#echo "$0: Checking file $FILE";
	SRC=$(cat "$FILE");
	(
		cd "${FILE%/*}";
		if [ -f "$SRC" ]
		then
			echo "\t$0: linking [${FILE##*/}] to [$SRC]";
			ln -sf "$SRC" "${FILE##*/}";
		fi;
	);
done;
