#!/bin/bash
set -euo pipefail;
IFS='$\n\t';

#
# Function to show usage information if unknown option(s) specified
#
usage () {
	cat <<EOF >&2
Invalid flag specified in "$@";
Usage: $0 [-c compareBranch] [-o format] [-d delim]
          [-h] [-v]

    -c compareBranch: specify the "compare to" branch (e.g. master);
       defaults to the repo's default branch if not specified

    -o format: specify the trdsql output format (at, json, etc);
       defaults to csv if not specified

    -d delim: specify the output delimiter (for csv output format);
       defaults to ASCII Unit Separator (0x1F, 37) if not specified

    -h include headers in the output;
       defaults to no headers if not specified

    -v verbose output (sent to STDERR so as to not disturb the actual output)
}
EOF
	exit 1;
}

# Process commandline arguments
while getopts ":c:b:o:d:hBv" opt
do
	case "$opt" in
		c) BASEBRANCH=$OPTARG;;
		b) BRANCH=$OPTARG;;
		o) OUTFMT="-o$OPTARG";;
		d) DELIM="-od '$OPTARG'";;
		h) HEADER="-oh";;
		B) PFX="'BRANCH' as Branch";;
		v) VERBOSE=1;;
		*) usage "$@"; exit 1;;
	esac;
done;


delim=$(printf "\x1f"); # ASCII "unit separator"

git log --format="%h${delim}%ai${delim}%an${delim}%s"  --name-status --no-merges "$BASEBRANCH".."$BRANCH" \
| awk -F $delim -v OFS=$delim '

# Gather stats from individual commits
NF == 4 {
	dt = $2; name = $3; cmt = $4;

	commitCnt++;
	if (!authorList[name]) authorCnt++;
	authorList[name]++; # number of commits for this author
	if (!firstCommit || dt < firstCommit) firstCommit   = dt " " name;
	if (!lastCommit  || dt > lastCommit ) lastCommit    = dt " " name;
	if (authorList[name]   > primaryCnt ) {
		primaryCnt    = authorList[name];
		primaryAuthor = name;
	}

}

# Count the files touched in this commit
/^[A-Z]/ {
	files++;
	authorFiles[name]++;
}

# Output the findings
END {
	print "CommitCnt", "FileCnt", "FirstCommit", "LastCommit", "AuthorCnt", "PrimaryAuthor", "PrimaryCommitCnt", "PrimaryFileCnt";
	print commitCnt, files, firstCommit, lastCommit, authorCnt, primaryAuthor, primaryCnt, authorFiles[primaryAuthor];
}'
