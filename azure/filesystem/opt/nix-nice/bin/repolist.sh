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

az repos list --project "$PROJECT" --output table;
