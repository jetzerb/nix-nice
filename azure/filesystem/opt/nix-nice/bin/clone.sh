#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

#
# clone a git repository by name, assuming your present working directory
# is the project, and the dir above that holds the URL (github, azure
# devops, etc)


#
# function to urlencode a string;
# modified from https://gist.github.com/cdown/1163649
#
urlencode() {
	# urlencode <string>
	local LC_COLLATE=C

	local length="${#1}"
	for (( i = 0; i < length; i++ )); do
		local c="${1:i:1}"
		case $c in
			[a-zA-Z0-9.~_-]) printf "$c" ;;
			*) printf '%%%02X' "'$c" ;;
		esac
	done
}



# Get context from present working directory
PROJECT=$(basename "$PWD");
PROJECT=$(urlencode "$PROJECT");

URL=$(basename $(dirname "$PWD"));

USER=${URL#*=};
URL=${URL%%=*};
URL=$(urlencode "$URL");
if [ "$URL" != "$USER" ]
then
	USER=$(urlencode "$USER");
	URL="$URL/$USER";
fi;
URL="https://$URL";

# get the name of the repo to clone
REPO=$(urlencode "$1");

case $URL in
	https://github.com)
		git clone $URL/$PROJECT/${REPO}.git ;;
	https://dev.azure.com/*)
		git clone $URL/$PROJECT/_git/$REPO ;;
	*)
		echo "Oops.  Can't seem to figure this out.";
		echo "	URL:     $URL";
		echo "	Project: $PROJECT";
		echo "	Repo:    $REPO";
esac;
