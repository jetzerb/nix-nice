#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

#
# Show each object matching the specified pattern, along with the latest
# commit for each branch:
#
#  path/to/object/of/interest
#     commit information
#        branch1
#        branch2
#        etc
#
# *jetzerb 2018-02-20 created
#

PATTERN="$@"; # pattern specified by the caller

TAB=$(echo -ne "\t");  # delimiter for sort later on
PREVHASH="";           # when printing, need to know
PREVFILE="";           # when the values change
COMMIT="";             # initialize empty var

YELLOW="\033[1;33m";  
CYAN="\033[1;36m";
NORMAL="\033[0;0m";

# jump up to top level of repo so that git log finds the files
cd "$(git rev-parse --show-toplevel)";


for BRANCH in $(git branch -a --format="%(refname)" |sed 's!^refs/[^/][^/]*/!!')
do
	RESULT=$(git ls-tree -r  --full-name "$BRANCH" | (grep -iE "$PATTERN" || true) | sed 's/^[^ ]* [^ ]* //');
	[ -n "$RESULT" ] && echo "$RESULT" | sed 's!$!\t'$BRANCH'!';
done |
sort -t "$TAB" -k 2,2 -k 1,1 -k 3,3 |
while read -r -a INFO
do
	HASH=${INFO[0]}; FILE=${INFO[1]}; BRANCH=${INFO[2]};
	if [ "$FILE" != "$PREVFILE" ]
	then
		[ -n "$COMMIT" ] && echo -e "\n\n"; # vertical space after previous file
		echo -e "${YELLOW}${FILE}${NORMAL}";
		PREVFILE="$FILE"; COMMIT="";
	fi;
	if [ "$HASH" != "$PREVHASH" ]
	then
		[ -n "$COMMIT" ] && echo;  #vertical space after commit
		# use sed below because head sporadically fails for unknown reason
		COMMIT=$(git log --format="%h : %ae : %aD : %s" "$BRANCH" -- "$FILE" |sed -n '1p');
		echo -e "\t${CYAN}${COMMIT}${NORMAL}";
		PREVHASH=$HASH;
	fi;
	echo -e "\t\t$BRANCH";
done;
