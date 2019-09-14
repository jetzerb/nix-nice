#!/bin/sh

#
# Spit out some stats for each repository in the current working directory.
#

STATFILE=$(mktemp);

for REPO in *
do
	cd "$REPO";
	NUMFILES=$(find . -not -path "./.git*" -not -path ./README.md -type f | wc -l);
	NUMBRANCHES=$(git branch -r |wc -l);
	COMMITSTATS=$(
	git log --format='%ai|%an' |sed 's/ /|/;' | trdsql -icsv -id '|' '
	with summary as (
		select sum(count(*)) over () as CommitCnt
		      ,c3 as Author
		      ,sum(count(*)) over (partition by c3) as AuthorCommits
		      ,max(c1) as RecentDt
		from -
		group by c3
	)
	select *
	from summary
	order by AuthorCommits desc
	limit 1';
	);
	[ $? -eq 0 ] && echo "$REPO,$COMMITSTATS,$NUMFILES,$NUMBRANCHES" >> $STATFILE;
	cd ..;
done;

# Change the output options if you prefer something other than an ASCII table.
#trdsql -icsv -oh -ocsv "
trdsql -icsv -oat "
select c1 as RepoName
      ,c7 as NumBranches
      ,c6 as NumFiles
      ,c2 as NumCommits
      ,c3 as PrimaryAuthor
      ,c4 as AuthorCommits
      ,c5 as LatestCommit
from $STATFILE
order by c1
";

rm $STATFILE;
