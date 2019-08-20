#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

PROJECT=$(basename "$PWD");
URL=$(basename $(dirname "$PWD"));

echo "Refreshing all repos for URL '$URL', project / user '$PROJECT'";
case "$URL" in
	github.com)
		curl -s https://api.github.com/users/"$PROJECT"/repos;;
	dev.azure.com*)
		az repos list --project "$PROJECT";;
	*)
		echo '[{"name": "<Unknown Source Control Provider>"}]';;
esac |
jq '.[] .name' |
sed 's/^"\(.*\)"$/\1/' |
sort -f |
while read REPO
do
	echo -e "\n-------> $REPO";
	if [ ! -d "$REPO" ]
	then
		echo "Cloning $REPO";
		clone.sh "$REPO";
	fi;
	cd "$REPO";
	(git checkout develop || git checkout master ) && git pull \
		|| echo "!!!! Branchless Repo !!!!";
	cd ..;
done;
