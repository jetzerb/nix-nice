#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

#
# Swap out bits of the filesystem for the versions in our persistfs volume.
# Meant to be called at container startup.
# Files to persist are listed in /usr/local/etc/persistfs_files
#
# ****TODO:
#     Can't use symbolic links for things like /etc/passwd
#     The system calls that utilize it require an actual file:(
#     Can't do a hard link to /persistfs because it's a different volume:(
#     So...need to redesign.  Probably use something like the existing code
#     below to initially populate /persistfs, but set up fluffy to watch
#     all the persisted files, and copy to /persistfs any time there's a change.
#

PERSISTFS=${1:-persistfs};

# bail now if no persistfs
if [ ! -d "/$PERSISTFS" ]
then
	echo "/$PERSISTFS does not exist.  Not setting up persistent filesystem.";
	exit 0;
fi;


#
# move a file, being careful to ensure the path exists
# usage: mvNlink src tgt [link]
#
function mvNlink () {
	SRC=$1;
	TGT=$2;
	TGTDIR=$(dirname "$TGT");
	mkdir -p "$TGTDIR";
	mv "$SRC" "$TGT";
	if [ -n "$3" ]
	then
		ln -s "$TGT" "$SRC";
		echo "$PERSISTFS...successfully linked file: [$TGT]";
	fi;
}

#
# Ensure that each entry listed in the config file is linked to
# the persistent file system.
#
LIST=/usr/local/etc/${PERSISTFS}_files;
[ -f $LIST ] && grep -Ev '^[[:blank:]]*(#|$)' "$LIST" |
while read SRC
do
	TGT="/${PERSISTFS}${SRC}";

	if [ ! -e "$SRC" ]
	then
		echo "$PERSISTFS...!!!! The specified source file does not exist: [$SRC]";
		[ -e "$TGT" ] && echo "$PERSISTFS...        But the target file does.";
		continue;
	fi;

	# file doesn't yet exist in persistfs; move & link
	if [ ! -e "$TGT" ]
	then
		mvNlink "$SRC" "$TGT" 1;
		continue;
	fi;

	# Check if source already links to target
	if [ "$TGT" = $(realpath "$SRC") ]
	then
		[ ! -e "$TGT" ] && echo "$PERSISTFS...Source links to non-existent target [$SRC]";
		continue;
	fi;


	# Source and Target both exist (probably an upgraded package replaced
	# the link with a new file). Compare the files/directories between
	# source and target.
	# * call out files that exist in TGT but not SRC
	# * check each file residing in SRC to see if it's newer/different
	#   from what's in TGT and if so make a copy in the persistent volume
	#   prior to linking.

	for TGTFILE in $(find "$TGT")
	do
		SRCFILE=${TGTFILE#/$PERSISTFS};
		if [ ! -e "$SRCFILE" ]
		then
			echo "$PERSISTFS...Target file has no source: [$TGTFILE]";
		fi;
	done;

	SFX=$(date +'_%Y%m%d%H%M%S');
	for SRCFILE in $(find "$SRC" -type f)
	do
		TGTFILE="/${PERSISTFS}${SRCFILE}";
		if [ ! -e "$TGTFILE" ]
		then
			mvNlink "$SRCFILE" "$TGTFILE" "";
			continue;
		fi;
		SRCMOD=$(stat -c '%Y' "$SRCFILE");
		TGTMOD=$(stat -c '%Y' "$TGTFILE");
		if [ $SRCMOD -gt $TGTMOD ] && [ ! $(cmp "$SRCFILE" "$TGTFILE") ] 2>/dev/null
		then
			mvNlink "$SRCFILE" "${TGTFILE}${SFX}" "";
			echo "$PERSISTFS...Updated source file is has been saved [${TGTFILE}${SFX}]";
		fi;
	done;

	rm -rf "$SRC";
	ln -s "$TGT" "$SRC";
done;
