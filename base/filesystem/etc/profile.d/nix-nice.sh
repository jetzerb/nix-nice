#
# additional config/setup to perform at login
#
# Note: Linux's /etc/profile will source all scripts ending in ".sh"
# under /etc/profile.d, so put this script there
#
#

# commandline editing using vi mode
set -o vi;

# colorful directory listings
eval "$(dircolors)";
alias ls='ls -F --color=auto --show-control-chars';

# other useful aliases
alias  l='ls';            # saves 50%!
alias ll='ls -l';         # long listing
alias la='ls -lA';        # list dotfiles too
alias lr='ls -lR';        # recursive long listing
alias lR='ls -lAR';       # recursive long listing with dotfiles too
alias l.='ls -ld .*';     # list only dotfiles
alias cd..='cd ..';       # that spacebar can be tricky
alias less='less -riNX';  # -r = raw control codes for colored text
                          # -i = smart case search (case insensitive if all lowercase search terms)
                          # -N = show line numbers
                          # -X = don't clear screen on exit
alias nocomment="grep -Ev '^[[:blank:]]*(#|$)'"; # show all non-comment lines from config files
alias nocmt=nocomment;

# use the most fully-featured vi available
for myVI in nvim vim vis elvis xvi nvi
do
	myEXE="$(which $myVI)";
	if [ -n "$myEXE" ]
	then
		export VISUAL="$myEXE";
		export EDITOR="$myEXE";
		alias vi="$myEXE";
		# less.sh is like less but with color syntax
		myLESS=/usr/share/$myVI/runtime/macros/less.sh;
		[ -f $myLESS ] && alias lesss=$myLESS;
		break;
	fi;
done;
unset myVI myEXE myLESS;


# nobody likes to type ".sh"
for myCMD in $(find /opt/*/bin /usr/local/bin -type f -name '*.sh')
do
	alias $(basename ${myCMD%.sh})=$myCMD;
done;
unset myCMD;

#
# cd up a few directories
#   blank = toplevel of current git repo, or home dir if not in a git repo
#       ^ = same as above
#      ^^ = out of repo
#      ^^ = out of repo's parent dir
#       % = current folder, but toggle between "Code" and "Review" dirs/workspaces
#       $ = current folder, but toggle between container & hosthome
#       n = up "n" levels where n is an integer
# pattern = up until we reach a directory matching the specified file globbing pattern
#
# if another parameter is specified, cd to that dir after performing the above actions
#
ud() {
	local TGT I STAR SUB;
	case "$1" in
		("" | ^ | ^^ | ^^^)
			# up to top of repo
			TGT=$(git rev-parse --show-toplevel 2> /dev/null);
			TGT=${TGT:-$HOME}; # or home dir if not in a repo
			I=${#1};
			while [ $I -gt 1 ]
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
				$HOME/hosthome/*) TGT=${PWD/\/hosthome/};;
				$HOME*)           TGT=${PWD/$HOME/$HOME\/hosthome};;
				*)                TGT=$PWD;;
			esac;;
		([0-9] | [0-9][0-9]) # move up "n" dirs
			TGT=$PWD;
			I=$1;
			while [ $I -gt 0 ]
			do
				TGT=${TGT%/*}; # remove final "/dirname" from path
				I=$((I-1));
			done;
			;;
		(- | ~)
			TGT=$1; # pass through commonly used cd idioms
			;;
		*)
			TGT=${PWD%*$1*}$1; # find last occurrence of the pattern in PWD
			STAR="*";
			;;
	esac;
	shift;

	SUB=$@;
	[ -n "$SUB" ] && [ ${SUB:1:1} != / ] && SUB=/$SUB;
	cd "$TGT"$STAR"$SUB";
}


# Include 3rd party exe and tab completion
for myDIR in /opt/*
do
	[ -d "$myDIR" ] || continue;
	[ "$PATH" = "${PATH#*$myDIR/bin*}" ] && export PATH="$myDIR/bin:$PATH";
	for myFILE in "$myDIR"/*.completion
	do
		[ -f "$myFILE" ] && . "$myFILE";
	done;
done;
unset myDIR myFILE;


# If you don't set your language, tmux will not print unicode characters properly
export LANG=en_US.UTF-8

# ---------
# Set up fzf (fuzzy finder)
for myFZF in \
	/opt/fzf/shell/completion.bash \
	/opt/fzf/shell/key-bindings.bash \
	~/.fzf.bash
do
	[ -f $myFZF ] && . $myFZF;
done;
unset myFZF;
