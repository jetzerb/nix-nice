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
jq -r 'sort_by(.name) | .[] .name' |
while read REPO
do
	echo -e "\n-------> $REPO";
	DIR=$(urlencode.sh $REPO);
	if [ ! -d "$DIR" ]
	then
		echo "Cloning $REPO";
		clone.sh "$REPO";
	fi;
	cd "$DIR";
	MAIN=$(git branch -r | sed -n '/HEAD/ {s!.*/!!; p;}');
	if [ -z "$MAIN" ]
	then
		echo "!!!! No Remote Branches !!!!";
	else
		git checkout $MAIN || true;
		git pull || true;
	fi;
	cd ..;
done;
