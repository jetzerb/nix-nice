#!/bin/sh

# Create a tmux session with a half dozen windows.
# Specify a file glob matching a project under
#  ~/src/[code|review]/[provider]/

if [ -z "$1" ]
then
	echo "No project name specified; just use plain old tmux.";
	exit 1;
fi;

case "$1" in
	-? | -h | -l | ls)
		tmux ls;
		exit 0;
esac;

for BASE in ~/src ~/hosthome/src
do
	PROJDIR=$(find $BASE -mindepth 3 -maxdepth 3 -type d -iname "*$1*" | head -1);
	[ -n "$PROJDIR" ] && break;
done;
PROJDIR=${PROJDIR#$BASE/*/};
SESSION=$(echo $1 |tr 'a-z' 'A-Z');

# detach from any existing session first
if [ -n "$TMUX" ]
then
	SESSION=$(tmux display-message -p '#{session_name}');
	echo "Already in session '$SESSION', and it's impossible to create a sibling session.";
	echo "Run this command again after detaching";
	sleep 2;
	tmux detach;
	exit 0; # unnecessary; detaching will stop the script
fi;


# check if session exists
tmux has-session -t $SESSION 2>/dev/null;

if [ $? != 0 ]
then
	echo "Building new session '$SESSION'";
	EXIST=0;
	for DIR in code review
	do
		for ITER in A B
		do
			if [ $EXIST -eq 0 ]
			then
				cd "$BASE/$DIR/$PROJDIR";
				tmux new-session -s $SESSION -n "$DIR$ITER" -d;
				EXIST=1;
			else
				tmux new-window -t $SESSION -n "$DIR$ITER" -c "$BASE/$DIR/$PROJDIR";
			fi;
		done;
	done;
	for ITER in 1 2
	do
		tmux new-window -t $SESSION -c "$HOME";
	done;
	tmux attach -t $SESSION \; select-window -t "codeA";
else
	echo "Attaching to existing session '$SESSION'";
	tmux attach -t $SESSION;
fi;
