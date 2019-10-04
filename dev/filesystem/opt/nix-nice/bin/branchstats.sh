#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

# For the specified (or current) branch, output the following stats:

#
# Function to show usage information if unknown option(s) specified
#
usage () {
	cat <<EOF >&2
Invalid flag specified in "$@";
Usage: $0 [-c compareBranch] [-b branchName] [-o format] [-d delim]
          [-h] [-B] [-v]

    -c compareBranch: specify the "compare to" branch (e.g. master);
       if not specified, show stats for the entirety of branchName.
       use "default" to use the repo's default branch (i.e. the one
       listed as "HEAD" at the origin)

    -b branch: specify the branch for which stats are desired;
       defaults to current branch if not specified

    -o format: specify the trdsql output format (at, json, etc);
       defaults to csv if not specified

    -d delim: specify the output delimiter (for csv output format);
       defaults to comma if not specified

    -h include headers in the output;
       defaults to no headers if not specified

    -B include branch names in the output

    -v verbose output (sent to STDERR so as to not disturb the actual output)
}
EOF
	exit 1;
}

# Use ASCII Unit Separator internally as delimiter since no one else in the
# world seems to. That will avoid "field contains the delimiter" issues.
d=$(printf "\x1f");


# Process commandline arguments
while getopts ":c:b:o:d:hBv" opt
do
	case "$opt" in
		c) baseBranch=$OPTARG;;
		b) branch=$OPTARG;;
		o) outFmt="-o$OPTARG";;
		d) delim="-od=$OPTARG";;
		h) header="-oh";;
		B) prefix="'BRANCH' as Branch, 'BASE' as BaseBranch,";;
		v) verbose=1;;
		*) usage "$@"; exit 1;;
	esac;
done;

# set default values if not specified by the caller

baseBranch=${baseBranch:-default};
if [ "$(echo $baseBranch |tr 'A-Z' 'a-z')" = "default" ]
then
	baseBranch=$(git branch -r | sed -n '/HEAD/ {s!.*/!!; p;}');
fi;

branch=${branch:-$(git rev-parse --abbrev-ref HEAD)};
outFmt=${outFmt:-};
delim=${delim:-};
header=${header:-};
prefix=${prefix:-};
if [ -n "$prefix" ]
then
	prefix="${prefix/BRANCH/$branch}";
	prefix="${prefix/BASE/$baseBranch}";
fi;
verbose=${verbose:-};


[ -n "$verbose" ] && cat <<EOF >&2
Gathering stats on commits in branch
	$branch
that don't appear in branch
	$baseBranch
with these output options:
- Format:    $outFmt
- Delimiter: $delim
- Header:    $header
- Include Branch: ${prefix:-No}
EOF

# Get the stats from the branch
# NOTE: if branch is fully committed, there will be no git log entries
# and no output at all, other than a head if it was requested
stats=$(
git log --format=">>${d}%ai${d}%an${d}" --shortstat --no-merges "$baseBranch".."$branch" \
| awk -F $d -v OFS=$d '
# commit line
$1 == ">>" {
	dt   = $2;
	name = $3;
	# ensure last, first name format in case people want to sort on it
	if (name !~ /,/) {
		gsub(/ +/," ",name); # condense multiple spaces to single
		l = split(name,na," ");
		name = na[l] ",";
		for (i = 1; i < l; i++) name = name " " na[i];
	}

	author[name]++;  # number of commits
	if (!first[name] || first[name] > dt) first[name] = dt;
	if (!last[name]  || last[name]  < dt) last[name]  = dt;
}

# short stat line
/^ [0-9]/ {
	sub(/^ +/,"");
	gsub(" ",FS);
	# accumulate data per author.
	# parse entire line; sometimes "insertions" is missing
	for (i = 2; i <= 7; i++) {
		     if ($i ~ /file/  ) files[name] += $(i-1);
		else if ($i ~ /insert/)   ins[name] += $(i-1);
		else if ($i ~ /delet/ )   del[name] += $(i-1);
	}
}

END {
	for (name in author) {
		print name, author[name], first[name], last[name], files[name], ins[name], del[name];
	}
}'
);

[ -z "$stats" ] && [ -n "$verbose" ] && echo "No commits pending from '$branch' to '$baseBranch'" >&2;


# Output the data in the requested format
hdr=(Author CommitCnt FirstCommitDt LastCommitDt FileModCnt InsertCnt DeleteCnt);
(IFS="$d"; echo "${hdr[*]}"; echo "$stats";) \
| trdsql -icsv -id "$d" -ih $outFmt $delim $header '
select '$prefix'
       *
from stdin
order by cast(CommitCnt as int) desc';
