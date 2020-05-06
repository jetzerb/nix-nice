#!/usr/bin/env bash

#
# additional config/setup to perform at login
#
# Note: Linux's /etc/profile will source all scripts ending in ".sh"
# under /etc/profile.d, so put this script there
#
#

# commandline editing using vi mode
set -o vi;

prependPath () {
	[ "$PATH" = "${PATH#*$1}" ] && export PATH="$1:$PATH";
}

# Include 3rd party exe paths and tab completion
for myDIR in /opt/*
do
	[ -d "$myDIR" ] || continue;
	for myFILE in "$myDIR"/*.completion
	do
		[ -f "$myFILE" ] && . "$myFILE";
	done;
	myFound=;
	for myBIN in /bin /sbin ""
	do
		myPATH="$myDIR$myBIN";
		if [ -d "$myPATH" ]
		then
			# don't add base path if already added bin and/or sbin
			[ -n "$myFound" ] && [ -z "$myBIN" ] && continue;
			myFound=1;
			prependPath "$myPATH";
		fi;
	done;
done;
unset myDIR myFILE myPATH myBIN;
prependPath "$HOME/bin";
prependPath "$HOME/.local/bin";


# colorful directory listings
eval "$(dircolors)";
alias ls='/bin/ls -F --color=auto --show-control-chars';

# other useful aliases
alias  l='ls';        # saves 50%!
alias ll='ls -l';     # long listing
alias la='ls -lA';    # list dotfiles too
alias lr='ls -lR';    # recursive long listing
alias lR='ls -lAR';   # recursive long listing with dotfiles too
alias l.='ls -ld .*'; # list only dotfiles
alias cd..='cd ..';   # that spacebar can be tricky
alias nocomment="/bin/grep -Ev '^[[:blank:]]*(#|$)'"; # show all non-comment lines from config files
alias nocmt=nocomment;
alias less='/usr/bin/less -iKMNQRWX';
                      # -i = smart case search (case insensitive if all lowercase search terms)
                      # -K = quit in response to CTRL-C
                      # -M = long prompt (shows line numbers & percentage)
                      # -N = show line numbers
                      # -Q = quiet the terminal bell
                      # -R = raw control codes for colored text
                      # -W = highlight first new line after forward movement
                      # -X = don't clear screen on exit

# Per PEP 394, there is ambiguity in whether the "python" command should point
# to python2 or python3.  If we don't have a "python" command, make an alias.
# To prevent old programs from breaking, set to python2 if that's installed,
# otherwise python3
if ! type python >/dev/null 2>&1
then
	for myCMD in 2 3
	do
		myCMD=/usr/bin/python$myCMD
		if [ -x $myCMD ]
		then
			alias python=$myCMD;
			break;
		fi;
	done;
fi;
unset myCMD;

# I like vi
myCMD="$(command -v vi)";
# if it's aliased, pull out the executable
case "$myCMD" in
	"alias vi="*)
		myCMD="${myCMD#*=\'}";
		myCMD="${myCMD%\'}";;
esac;
if [ -n "$myCMD" ]
then
	export VISUAL="$myCMD";
	export EDITOR="$myCMD";
fi;
myCMD=$(realpath "$myCMD");
if [ -n "$myCMD" ]
then
	myCMD=$(basename "$myCMD");
	# less.sh is like less but with color syntax
	myCMD=/usr/share/"$myCMD"/runtime/macros/less.sh;
	[ -f "$myCMD" ] && alias lesss="$myCMD";
fi;
unset myCMD;


# nobody likes to type ".sh"
pushd . >/dev/null;
IFS=':' read -ra myDIRS <<< "$PATH";
for myDIR in "${myDIRS[@]}"
do
	[ -d "$myDIR" ] || continue;
	cd "$myDIR" || continue;
	for myCMD in $(/bin/ls -1f ./*.sh 2>/dev/null)
	do
		myCMD=${myCMD#./};
		alias "${myCMD%.sh}"="$myDIR/$myCMD";
	done;
done;
unset myDIRS myDIR myCMD;
popd >/dev/null || echo "Unable to pop directory";


#
# function to print a nice header.  frequently comes in handy
mkhdr() {
	echo "$*" | sed '{h; s/./-/g; s/^/\n\n/; p; x;}';
}

#
# function to center a string of text.
center() {
	line="${1:-}";
	echo "$line" | pr -To $(( (${2:-80} - ${#line}) / 2 ));
}

#
# function to center a string of text

#
# cd up a few directories
#   blank = toplevel of current git repo, or home dir if not in a git repo
#       ^ = same as above
#      ^^ = out of repo, to project/user dir
#     ^^^ = out of project/user dir to source control provider dir
#    ^^^^ = out of source control provider dir to code/review dir
#   ^^^^^ = out of code/review dir to parent source dir
#  ^^^^^^ = out of parent source dir to whatever is above that
#       % = current folder, but toggle between "Code" and "Review" dirs/workspaces
#       $ = current folder, but toggle between container & hosthome
#       n = up "n" levels where n is an integer
# pattern = up until we reach a directory matching the specified file globbing pattern
#
# if another parameter is specified, cd to that dir after performing the above actions
#
ud() {
	local TGT I SUB;
	case "$1" in
		("" | ^ | ^^ | ^^^ | ^^^^ | ^^^^^ | ^^^^^^)
			# up to top of repo
			TGT=$(git rev-parse --show-toplevel 2> /dev/null);
			TGT=${TGT:-$HOME}; # or home dir if not in a repo
			I=${#1};
			while [ "$I" -gt 1 ]
			do
				TGT=$TGT/..;  # back up one more dir for each extra ^
				I=$((I-1));
			done;
			;;
		%)
			case "$PWD" in
				$HOME/src/code/*   | $HOME/hosthome/src/code/*)
					TGT=${PWD/\/code\//\/review\/};;
				$HOME/src/review/* | $HOME/hosthome/src/review/*)
					TGT=${PWD/\/review\//\/code\/};;
				*)
					TGT=$PWD;;
			esac;;
		$)
			case "$PWD" in
				$HOME/hosthome | $HOME/hosthome/*)
				        TGT=${PWD/\/hosthome/};;
				$HOME*) TGT=${PWD/$HOME/$HOME\/hosthome};;
				*)      TGT=$PWD;;
			esac;;
		([0-9] | [0-9][0-9]) # move up "n" dirs
			TGT=$PWD;
			I=$1;
			while [ "$I" -gt 0 ]
			do
				TGT=${TGT%/*}; # remove final "/dirname" from path
				I=$((I-1));
			done;
			;;
		(- | ~)
			TGT=$1; # pass through commonly used cd idioms
			;;
		*)
			# back up to dir containing the specified pattern
			TGT=$(echo "$PWD/" | sed 's/\(.*'"${1//\//\\/}"'[^\/]*\)\/.*/\1/;')
			;;
	esac;
	shift;

	SUB="$*";
	[ -n "$SUB" ] && [ "${SUB:1:1}" != "/" ] && SUB="/$SUB";
	eval 'cd '"'$TGT'$SUB";  # use eval so globbing works
}


# If you don't set your language, tmux will not print unicode characters properly
export LANG=en_US.UTF-8;

# Ensure browser set (or ddgr will not work properly)
export BROWSER=www-browser;

# Set environment variables for each non-printable ASCII character
#ASCII_NUL=$(printf "\x00"); export ASCII_NUL; # null; can't do this because c strings are null terminated
ASCII_SOH=$(printf "\x01"); export ASCII_SOH; # start of heading
ASCII_STX=$(printf "\x02"); export ASCII_STX; # start of text
ASCII_ETX=$(printf "\x03"); export ASCII_ETX; # end of text
ASCII_EOT=$(printf "\x04"); export ASCII_EOT; # end of transmission
ASCII_ENQ=$(printf "\x05"); export ASCII_ENQ; # enquiry
ASCII_ACK=$(printf "\x06"); export ASCII_ACK; # acknowledge
ASCII_BEL=$(printf "\x07"); export ASCII_BEL; # bell
ASCII_BS=$( printf "\x08"); export ASCII_BS ; # backspace
ASCII_HT=$( printf "\x09"); export ASCII_HT ; # horizontal tab
ASCII_LF=$( printf "\x0A"); export ASCII_LF ; # NL line feed, newline
ASCII_VT=$( printf "\x0B"); export ASCII_VT ; # vertical tab
ASCII_FF=$( printf "\x0C"); export ASCII_FF ; # NP form feed, new page
ASCII_CR=$( printf "\x0D"); export ASCII_CR ; # carriage return
ASCII_SO=$( printf "\x0E"); export ASCII_SO ; # shift out
ASCII_SI=$( printf "\x0F"); export ASCII_SI ; # shift in
ASCII_DLE=$(printf "\x10"); export ASCII_DLE; # data link escape
ASCII_DC1=$(printf "\x11"); export ASCII_DC1; # device control 1
ASCII_DC2=$(printf "\x12"); export ASCII_DC2; # device control 2
ASCII_DC3=$(printf "\x13"); export ASCII_DC3; # device control 3
ASCII_DC4=$(printf "\x14"); export ASCII_DC4; # device control 4
ASCII_NAK=$(printf "\x15"); export ASCII_NAK; # negative acknowledge
ASCII_SYN=$(printf "\x16"); export ASCII_SYN; # synchronous idle
ASCII_ETB=$(printf "\x17"); export ASCII_ETB; # end of transmission block
ASCII_CAN=$(printf "\x18"); export ASCII_CAN; # cancel
ASCII_EM=$( printf "\x19"); export ASCII_EM ; # end of medium
ASCII_SUB=$(printf "\x1A"); export ASCII_SUB; # substitute
ASCII_ESC=$(printf "\x1B"); export ASCII_ESC; # escape
ASCII_FS=$( printf "\x1C"); export ASCII_FS ; # file separator
ASCII_GS=$( printf "\x1D"); export ASCII_GS ; # group separator
ASCII_RS=$( printf "\x1E"); export ASCII_RS ; # record separator
ASCII_US=$( printf "\x1F"); export ASCII_US ; # unit separator
ASCII_DEL=$(printf "\x7F"); export ASCII_DEL; # delete



# ---------
# Set up fzf (fuzzy finder)
for myFZF in \
	/opt/fzf/shell/completion.bash \
	/opt/fzf/shell/key-bindings.bash \
	~/.fzf.bash
do
	[ -f "$myFZF" ] && . "$myFZF";
done;
unset myFZF;
