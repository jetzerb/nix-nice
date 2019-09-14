#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

# **** TODO
# For each branch, show
# - number of commits in branch that aren't in the default (or passed in) branch
# - primary author of those commits
# - first & last commit date (just date, not time)
# - work item status if able to query (figure out github api for issues)
#
# Show the status of each branch in the repo
#

# Compare against the branch passed in by the caller, or the repo's default branch
COMPAREBRANCH=${1:-$(git branch -r | sed -n '/HEAD/ {s!.*/!!; p;}')};

# Create list of all the "real" remote branches in the repo
BRANCHEFILE=$(mktemp);
git branch -r |grep -vE 'origin/(HEAD|develop|master|release)' |sed 's/^  *//; s/  *$//;' |sort > "$BRANCHEFILE";

# get the distinct list of work items based on the branch names, assuming that
# a string of numerics in the branch name represents an issue or work item or
# issue number
ITEMS="";
# sed script to return the first numeric substring of a string:
XFORM="s!^[^0-9]*\([0-9]*\)[^0-9]*.*!\1!";
for ITM in $(sed $XFORM "$TMP.b")
do
	ITEMS="$ITEMS,$ITM";
done;
ITEMS=$(echo $ITEMS | sed 's/^,*//; s/,*$//;'); # remove leading & trailing commas

# Query those specific work items, along with their status & date of status change
WIQL="\
select id \
      ,[System.WorkItemType] \
      ,[ExactSciencesAgileProcess.Release] \
      ,[System.State] \
      ,[Microsoft.VSTS.Common.StateChangeDate] \
from WorkItems \
where id in ($ITEMS) \
";
vsts work item query --output table --wiql "$WIQL" > "$TMP.w";

for BRANCH in $(cat "$TMP.b")
do
	echo -e "\n$BRANCH";
	US=$(echo $BRANCH | sed $XFORM);
	if [ "$US" = "" ]
	then
		echo -e "\t!!!! Branch does not indicate the user story";
		continue;
	fi;
	STATUS=$(sed -n "/^ *$US /p;}" "$TMP.w");
	[ "$STATUS" = "" ] && STATUS="<No work item found for $US>";
	echo -e "\t$STATUS";
done;

rm "$TMP"*;
