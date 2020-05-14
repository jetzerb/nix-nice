#!/bin/bash
set -euo pipefail;

project=${1:-};

# strip the prefix off of the current working dir
path=$(echo "$PWD" | sed 's!^.*/\(src/\)!\1!;');

if [ -z "$project" ]
then
	project=$(echo "$path" | awk -F '/' '{print $4;}');
fi;

if [ -z "$project" ]
then
	echo "Not in a project directory, and no project specified.";
	exit 1;
fi;

# Figure out how to get the list of repos based on the current
# working directory
url=$(echo "$path" | awk -F '/' '{sub("=","/",$3); print $3;}');

echo "Repos at '$url' for project/user '$project'";

case "$url" in
	dev.azure.com/*)
		az repos list --project "$project" |
		jq '.[] | {isFork, name}' |
		trdsql -ijson -oat 'select isFork, name from - order by isFork, name'
		;;
	github.com)
		curl -s https://api.github.com/users/"$project"/repos |
		trdsql -driver sqlite3 -ijson -oat '
			select fork, name, created_at, updated_at, description
			from -
			order by fork, name'
		;;
	*)
		echo "Unhandled source control provider: '$url'";;
esac;
