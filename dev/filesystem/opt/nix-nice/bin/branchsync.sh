#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

usage() {
	cat <<EOF
Refreshes your repository's branch list from origin
  - Gets new branches
  - Removes local branches that formerly tracked remote branches if the remote
    branch no longer exists.

No commandline options available.
EOF
}

#
#-------------------------------------------------------------------------------
#
# Main
#
#

case ${1:-} in
	-? | -h | --help)
		usage;
		exit 0 ;;
	"") ;; # fall through to code below
	*)
		usage;
		exit 1;;
esac;


# fetch from origin and prune any local tracking references if they don't
# exist on the server
echo "fetching info from origin";
git fetch -p origin;

# remove references in local repo if they no longer exist in the origin
echo "Removing references to deleted branches";
git remote prune origin;

# remove any local branches if they've been deleted in the origin
echo "Removing local branches if they no longer exist at the origin";
git branch -vv |
while read BRANCH
do
	# if branch contains the string ": gone]", it should be deleted from the local repository
	if [ "${BRANCH#*: gone]}" != "$BRANCH" ]
	then
		# Strip off leading "*" (appears on current branch), and any leading spaces.
		# Then everything after the first space (i.e. get branch name only)
		BRANCH=$(echo $BRANCH | sed 's/^[\* ]*//; s/ .*//;');
		echo "Deleting branch '$BRANCH'";
		git branch -d $BRANCH;
	fi;
done;
