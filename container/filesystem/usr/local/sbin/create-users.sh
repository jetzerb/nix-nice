#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';


#
# ------
# Function to create users, based on hosthome volume mount
#
for CONFIG in /hosthome/*/.ssh
do
	# create the user with a random password (pwd req'd for SSH connection
	# even if only allowing key authentication)
	USER=$(basename $(dirname "$CONFIG"));
	if [ -n "$(getent passwd $USER)" ]
	then
		echo "Skipping pre-existing user $USER";
		continue;
	fi;
	echo "Creating user $USER";

	# if pre-existing home dir, get the UID
	USERID=
	if [ -d /home/"$USER" ]
	then
		USERID=$(ls -ld /home/"$USER" | awk '{print $3}');
		if [ "$USERID" -eq "$USERID" ] && [ "$USERID" -gt 0 ] 2> /dev/null # i.e. if USERID is numeric and not root user
		then
			echo "  * found existing home dir with User ID $USERID";
			USERID="-u $USERID";
		fi;
	fi;

	useradd -s /bin/bash -m -g users -G sudo $USERID "$USER";
	echo "  * created user";


	PASSWD=$(head -c 32 /dev/urandom |base64 |head -c 32);
	echo "$USER:$PASSWD" | chpasswd;
	echo "  * with random password";

	cd /home/"$USER";
	echo $PASSWD > .pwd; # Save password so user can sudo
	# copy public key(s) for SSH authentication
	if [ ! -d .ssh ]
	then
		mkdir .ssh;
		for PUB in /hosthome/"$USER"/.ssh/*.pub
		do
			cat "$PUB" | dos2unix >> .ssh/authorized_keys;
			echo "  * added $PUB to list of ssh authorized keys";
		done;
	fi;

	# link to host home directory
	if [ ! -e hosthome ]
	then
		ln -s /hosthome/"$USER" /home/"$USER"/hosthome;
		echo "  * symlinked "hosthome" to the host home directory";
	fi;


	# If host user has a git config file, fill in some more info here
	CONFIG=/hosthome/"$USER"/.gitconfig;
	[ -f "$CONFIG" ] || continue;

	# set user account's full name based on contents of git config file
	FULLNAME=$(awk -F '= *' '/\[user\]/ {while (! /name *=/) {getline;} print $2; exit;}' "$CONFIG");
	if [ -n "$FULLNAME" ]
	then
		FULLNAME=$(echo $FULLNAME |sed 's/\(.*\), *\(.*\)/\2 \1/'); # change "Last, First" to "First Last"
		chfn -f "$FULLNAME" "$USER";
		echo "  * using full name $FULLNAME";
	else
		echo "  * no configured name in .gitconfig";
	fi;

	# copy git "user" section from host home dir
	if [ ! -f .gitconfig ]
	then
		sed -n '/\[user\]$/,/^[      ]*$/p' "$CONFIG" | dos2unix > .gitconfig;
		echo "  * user & email copied from global git config file";
	fi;

	echo "";
done;
