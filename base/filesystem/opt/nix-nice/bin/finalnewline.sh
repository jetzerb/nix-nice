#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';

#
# ensure that each text file has an EOL on the final line
#

TOT=0;
UPD=0;

for FILE in $@
do
	TOT=$((TOT+1));
	EOL=$(tail -c4 "$FILE" | od -tx1 -A none);
	case "$EOL" in
		*0[ad]*) continue ;; # file already has trailing CR/LF
	esac;

	UPD=$((UPD+1));
	echo "$UPD. Updating $FILE";

	# get the correct end of line chars based on the first line in the file
	EOL=$(
		head -1 "$FILE" |
		tail -c4 |
		od -tc -A none |
		sed '
			s/  *[^\\]*//g;          # remove all but backslash escaped chars
			s/^\(\\0\)\(.*\)/\2\1/;  # move leading zero to the back, where head did not include it
		    ';
	);
	case "$EOL" in
		    "") EOL="\n"  ; echo "    No EOL chars; defaulting to $EOL";;
		"\0\0") EOL="\n\0"; echo "    No EOL chars; defaulting to $EOL";;
		     *)             echo "    Using $EOL (found on line 1 of file)";;
	esac;

	echo -en $EOL >> "$FILE";
done;

echo "Updated $UPD of $TOT files examined";
