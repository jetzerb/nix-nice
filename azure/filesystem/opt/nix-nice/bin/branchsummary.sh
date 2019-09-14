#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

# For each branch, show
# - number of commits in branch that aren't in the default (or passed in) branch
# - primary author of those commits
# - first & last commit date (just date, not time)
# - work item status if able to query (figure out github api for issues)
#
# Show the status of each branch in the repo
#


# Compare against the branch passed in by the caller, or the repo's default branch
BASEBRANCH=${1:-$(git branch -r | sed -n '/HEAD/ {s!.*/!!; p;}')};

# Create list of all the "real" remote branches in the repo
BRANCHFILE=$(mktemp);
git branch -r |grep -vE 'origin/(HEAD|develop|master|release)' |sed 's/^  *//; s/  *$//;' |sort > "$BRANCHFILE";

HDR="-h";
for BRANCH in $(cat "$BRANCHFILE")
do
	echo "Checking branch $BRANCH..." >&2;
	branchstats.sh -c "$BASEBRANCH" -b "$BRANCH" -B $HDR 2>/dev/null;
	HDR="";
done \
| trdsql -ih -oat 'select * from -';

rm "$BRANCHFILE";
