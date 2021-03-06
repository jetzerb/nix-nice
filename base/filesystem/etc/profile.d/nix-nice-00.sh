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
for dir in /opt/*
do
	[ -d "$dir" ] || continue;
	for file in "$dir"/*.completion
	do
		[ -f "$file" ] && . "$file";
	done;
	found=;
	for bin in /bin /sbin ""
	do
		path="$dir$bin";
		if [ -d "$path" ]
		then
			# don't add base path if already added bin and/or sbin
			[ -n "$found" ] && [ -z "$bin" ] && continue;
			found=1;
			prependPath "$path";
		fi;
	done;
done;
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
	for cmd in 2 3
	do
		cmd=/usr/bin/python$cmd
		if [ -x $cmd ]
		then
			alias python=$cmd;
			break;
		fi;
	done;
fi;

# I like vi
cmd="$(command -v vi)";
# if it's aliased, pull out the executable
case "$cmd" in
	"alias vi="*)
		cmd="${cmd#*=\'}";
		cmd="${cmd%\'}";;
esac;
if [ -n "$cmd" ]
then
	export VISUAL="$cmd";
	export EDITOR="$cmd";
fi;
cmd=$(realpath "$cmd");
if [ -n "$cmd" ]
then
	cmd=$(basename "$cmd");
	# less.sh is like less but with color syntax
	cmd=/usr/share/"$cmd"/runtime/macros/less.sh;
	[ -f "$cmd" ] && alias lesss="$cmd";
fi;


# nobody likes to type ".sh"
pushd . >/dev/null;
IFS=':' read -ra dirs <<< "$PATH";
for dir in "${dirs[@]}"
do
	[ -d "$dir" ] || continue;
	cd "$dir" || continue;
	for cmd in $(/bin/ls -1f ./*.sh 2>/dev/null)
	do
		cmd=${cmd#./};
		alias "${cmd%.sh}"="$dir/$cmd";
	done;
done;
popd >/dev/null || echo "Unable to pop directory";



#
# cd up a few directories
#   blank = toplevel of current git repo, or home dir if not in a git repo
#       ^ = same as above
#      ^^ = out of repo, to project/user dir
#     ^^^, ^^^^, etc up one more directory
#
#       % = current folder, but toggle between "Code" and "Review" dirs/workspaces
#       $ = current folder, but toggle between container & hosthome
#       n = up "n" levels where n is an integer
# pattern = up until we reach a directory matching the specified file globbing pattern
#
# if another parameter is specified, cd to that dir after performing the above actions
#
# Note: must be a function rather than a script, because scripts execute in a subshell
# and can't affect your working directory
#
unalias ud 2>/dev/null;
ud() {
	case "$1" in
		"" | ^*)
			# up to top of repo
			tgt=$(git rev-parse --show-toplevel 2> /dev/null);
			tgt=${tgt:-$HOME}; # or home dir if not in a repo
			up=${1:1}; # remove first ^
			tgt=$tgt${up//^/\/..}; # go up one level for every ^
			;;
		%)
			case "$PWD" in
				*/src/code/*)
					tgt=${PWD/\/code\//\/review\/};;
				*/src/review/*)
					tgt=${PWD/\/review\//\/code\/};;
				*)
					tgt=$PWD;;
			esac;;
		$)
			case "$PWD" in
				$HOME/hosthome | $HOME/hosthome/*)
				        tgt=${PWD/\/hosthome/};;
				$HOME*) tgt=${PWD/$HOME/$HOME\/hosthome};;
				*)      tgt=$PWD;;
			esac;;
		[0-9]*) # move up "n" dirs
			tgt=$PWD;
			up=$1;
			while [ "$up" -gt 0 ]
			do
				tgt=${tgt%/*}; # remove final "/dirname" from path
				up=$((up-1));
			done;
			;;
		- | ~)
			tgt=$1; # pass through commonly used cd idioms
			;;
		*)
			# back up to dir containing the specified pattern
			tgt=$(echo "$PWD/" | sed 's/\(.*'"${1//\//\\/}"'[^\/]*\)\/.*/\1/;')
			;;
	esac;
	shift;

	sub="$*";
	[ -n "$sub" ] && [ "${sub:1:1}" != "/" ] && sub="/$sub";
	eval 'cd '"'$tgt'$sub";  # use eval so globbing works
}


# If you don't set your language, tmux will not print unicode characters properly
export LANG=en_US.UTF-8;

# Ensure browser set (or ddgr will not work properly)
export BROWSER=www-browser;

# Set environment variables for each non-printable ASCII character
# except for 0x00 (ASCII_NUL) because it's the string terminator
ascii_cmd=$(echo "
	SOH 01	start of heading
	STX 02	start of text
	ETX 03	end of text
	EOT 04	end of transmission
	ENQ 05	enquiry
	ACK 06	acknowledge
	BEL 07	bell
	BS  08	backspace
	HT  09	horizontal tab
	LF  0A	NL line feed, newline
	VT  0B	vertical tab
	FF  0C	NP form feed, new page
	CR  0D	carriage return
	SO  0E	shift out
	SI  0F	shift in
	DLE 10	data link escape
	DC1 11	device control 1
	DC2 12	device control 2
	DC3 13	device control 3
	DC4 14	device control 4
	NAK 15	negative acknowledge
	SYN 16	synchronous idle
	ETB 17	end of transmission block
	CAN 18	cancel
	EM  19	end of medium
	SUB 1A	substitute
	ESC 1B	escape
	FS  1C	file separator
	GS  1D	group separator
	RS  1E	record separator
	US  1F	unit separator
	DEL 7F	delete
" |
awk 'NF >= 2 {printf("export ASCII_%s=$(printf \"\\x%s\");\n", $1, $2);}'
);
eval "$ascii_cmd";


# ---------
# Set up fzf (fuzzy finder)
for src in \
	/opt/fzf/shell/completion.bash \
	/opt/fzf/shell/key-bindings.bash \
	~/.fzf.bash
do
	[ -f "$src" ] && . "$src";
done;
