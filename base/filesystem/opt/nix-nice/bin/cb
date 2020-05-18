#!/bin/sh

#
# Copy a stream of data or file(s) contents to clipboard,
# stripping off the UTF 8 Byte Order Markers

# use xclip or xsel, whichever is installed
for CBMGR in xclip xsel
do
	type $CBMGR >/dev/null 2>&1;
	[ $? -eq 0 ] && break;
done;

awk 'FNR == 1 {sub(/^\xef\xbb\xbf/,"");} {print;}' "$@" | $CBMGR;
