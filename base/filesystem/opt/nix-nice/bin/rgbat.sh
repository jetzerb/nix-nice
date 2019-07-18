#!/bin/sh

usage() {
	cat <<EOF

$(basename $0) <regex>

Browse through files identified by "ripgrep" that contain the specified
pattern, using "bat", and automatically highlighting the pattern.
EOF
}

case "$1" in
	-h | -? | --help)
		usage;
		exit 0;
esac;


# Do it in a subshell so as to not disturb environment variables
(
	IFS=$(/bin/echo -e "\n\t");  # handle filenames with spaces

	FILES=$(rg -il "$1");
	[ -n "$FILES" ] && bat --pager='/usr/bin/less -iKMQRWXp "'$1'"' $FILES;
);
