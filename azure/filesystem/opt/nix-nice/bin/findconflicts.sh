#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

#
# For each object modified in the current branch, check for modifications to
# the same object in other branches
#



# Cache the list of all user stories & bugs
TMP="/tmp/$(basename $0).$$"; # temp file name
WIQL="\
select id \
      ,[System.WorkItemType] \
      ,[ExactSciencesAgileProcess.Release] \
      ,[System.State] \
      ,[Microsoft.VSTS.Common.StateChangeDate] \
from WorkItems \
where [System.WorkItemType] in ('User Story','Bug') \
";
vsts work item query --output table --wiql "$WIQL" > "$TMP";

MYBRANCH=$(git rev-parse --abbrev-ref HEAD);


# list all objects modified in commits to this branch that don't appear in
# the develop branch
git log --format='' --name-only ^origin/develop HEAD |
sort -u |
while read FILE
do
	echo -e "\n$FILE";
	CONFLICTS=0;
	for BRANCH in $(git branch -r | sed 's/^  *//; s/  *$//;' | grep -vE 'origin/(develop|master)')
	do
		[ "$BRANCH" = "origin/$MYBRANCH" ] && continue;

		COUNT=$(grep -c "$FILE" <(git log --format='' --name-only ^origin/develop "$BRANCH") || true);
		if [ $COUNT -gt 0 ]
		then
			US=$(echo $BRANCH | sed 's!.*/[^0-9]*\([0-9]*\)[^0-9]*.*!\1!');
			if [ "$US" = "" ]
			then
				echo -e "\t!!!! Branch does not indicate the user story";
			fi;
			STATUS=$(sed -n "/^ *$US /p;}" "$TMP");
			[ "$STATUS" = "" ] && STATUS="<No work item found for $US>";
			[[ "$STATUS" == "* Closed *" ]] && continue;
			echo -e "\t$COUNT; $BRANCH\n\t\t$STATUS";
			CONFLICTS=1;
		fi;
	done;
	[ $CONFLICTS -eq 0 ] && echo -e "\t<no conflicts>";
done;

rm "$TMP";
