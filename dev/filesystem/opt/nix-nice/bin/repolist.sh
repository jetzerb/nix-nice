#!/bin/bash
set -euo pipefail;

PROJECT=${1:-};

if [ -z "$PROJECT" ]
then
	PROJECT=$(echo ${PWD#$HOME} | awk -F '/' '{print $5;}');
fi;

if [ -z "$PROJECT" ]
then
	echo "Not in a project directory, and no project specified.";
	exit 1;
fi;

# Figure out how to get the list of repos based on the current
# working directory
URL=$(echo ${PWD#$HOME} | awk -F '/' '{sub("=","/",$4); print $4;}');

echo "Repos at '$URL' for project/user '$PROJECT'";

case "$URL" in
	dev.azure.com/*)
		az repos list --project "$PROJECT" |
		jq '.[] | {isFork, name}' |
		trdsql -ijson -oat 'select isFork, name from - order by isFork, name'
		;;
	github.com)
		curl -s https://api.github.com/users/"$PROJECT"/repos |
		trdsql -ijson -oat '
			select fork, name, created_at, updated_at, description
			from -
			order by fork, name'
		;;
	*)
		echo "Unhandled source control provider: '$URL'";;
esac;
