#!/usr/bin/env bash

project="$(../util/get-repo-name --full)";

image=$(dirname "$0");
image=$(cd "$image"; pwd);
image=${image##*/};

image="$project:$image-latest";

# pull out the container manifest
docker run -i --rm "$image" cat /opt/nix-nice/etc/manifest.txt > manifest.txt

# run unit test/validation for all installed software packages
docker run -i --rm "$image" bash < verify-installed-software.sh  > test-results.txt 2>&1


error=$(
awk '
/^ERROR/ {
	for (i = 0; i < idx; i++) {
		print block[i];
	}
	printf("%s\n\n",$0);
}

/^---/ {idx = 0;}

{block[idx++] = $0;}
' test-results.txt
);

if [ -n "$error" ]
then
	echo "$error" 2>&1;
	exit 1;
fi;
