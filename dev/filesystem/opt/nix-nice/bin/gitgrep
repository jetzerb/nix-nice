#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

#
# Facilitate searching across branches within (a) repo(s)
# via "git grep"
#
# *jetzerb 2019-05-24 created
#

#
# ==================================================
# Functions

#
# ------
# Function to search all branches for the pattern from the current location
search() {
	YELLOW=$'\e[1;33m';
	CYAN=$'\e[1;36m';
	NORMAL=$'\e[0;0m';

	(git show-ref --heads || true) |
	cut -d ' ' -f2 |
	while read BRANCH
	do
		#echo "Branch: $BRANCH" | sed 's!refs/heads/!!; h; s/./=/g; p; x; p; x;';
		(git grep --break --heading --line-number --color=always -iEe "$@" "$BRANCH" && echo -e "\n\n" || true) |
		sed "s!^refs/heads/\([^:]*\):\(.*\)!${YELLOW}\1${NORMAL} : ${CYAN}\2${NORMAL}!;";
	done;
}


#
# ==================================================
# Script Entry Point


#
# ------
# If currently inside a repo, just search here
if git rev-parse --git-dir > /dev/null 2>&1
then
	search "$@";
	exit $?;
fi;

#
# ------
# Since we got to this point, we're not in a git repo,
# so try each child directory
GREEN=$'\e[1;32m';
NORMAL=$'\e[0;0m';
find . -maxdepth 1 -type d |
sed '1d; s!^\.\/!!;' |
sort -f |
while read DIR
do
	[ "$DIR" = "." ] && continue; # skip current dir
	cd "$DIR";
	if git rev-parse --git-dir > /dev/null 2>&1
	then
		echo -n $GREEN;
		echo "Repository: $DIR"; # | sed 'h; s/./#/g; p; x; p; x;';
		echo    $NORMAL;
		search "$@";
	fi;
	cd ..;
done;
