#!/usr/bin/env bash

project="$(../util/get-repo-name --full)";

image=$(dirname "$0");
image=$(cd "$image"; pwd);
image=${image##*/};

image="$project:$image-latest";

# pull out the container manifest
echo "$(date +'%Y-%m-%d %H:%M:%S.%N'): Extracting software manifest";
docker run -i --rm "$image" bash <<'EOF' > manifest.txt

cat /opt/nix-nice/etc/manifest.txt;

IFS=$'\n';

hdr() {
	echo "$1" |sed 'h; s/./-/g; s/^/\n\n\n/; p; x;';
}

hdr "Defaults For New Users";
md5sum $(find /etc/skel -type f |sort);

hdr "Nix-Nice Executables";
md5sum $(find /etc/ -type f -name 'nix-nice*' | sort);
md5sum $(find /opt/nix-nice -type f | sort);

if [ $(command -v git) ]
then
	hdr "git system-wide configuration";
	git config --list --system |sort;
fi;
EOF

echo "$(date +'%Y-%m-%d %H:%M:%S.%N'): Running tests";

# run unit test/validation for all installed software packages
echo "$(date +'%Y-%m-%d %H:%M:%S.%N'): running verification/tests";
testscript="$(mktemp)";
srcdir="$(dirname "$(realpath "$0")")";
verify="verify-installed-software";
cat "${srcdir}/${verify}-hdr" "${verify}.sh" > "$testscript";
docker run -i --rm "$image" bash < "$testscript"  > test-results.txt 2>&1;
rm "$testscript";

echo "$(date +'%Y-%m-%d %H:%M:%S.%N'): done";


# Advertise any errors encountered during testing
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
