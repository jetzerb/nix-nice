#!/usr/bin/env bash

#
# Test Script for Developer layer
#


#
# Function to spit out a header for the output of a test
printHdr () {
	echo -e "\nCommand: $1" |sed 'h; s/./-/g; p; x;';
}

checkInstall() {
	printHdr "$1";
	dpkg -l "$1" \
	| awk '
		BEGIN {msg = "ERROR: Package Not Installed!";}
		/^ii/ {msg = "OK";}
		END {print msg;}';
}

checkCommand() {
	printHdr "$1";
	eval "$2"  > /dev/null && echo "OK" || echo "ERROR";
}

# ensure we're all set up properly
export SHELL="$(command -v bash)";
. /etc/profile;
MYLOCALE=en_US.utf8 /opt/nix-nice/sbin/environment-setup.sh > /dev/null;


dir=/tmp/test;
mkdir -p "$dir" && cd "$dir";



# Test everything installed in the Dockerfile
cmd='git';     checkCommand "$cmd" '$cmd init';
cmd='git-lfs'; checkCommand "$cmd" '$cmd install';
cmd='sqitch';  checkCommand "$cmd" '$cmd init dbproject';

cmd='shellcheck';
echo -e '#!/usr/bin/env bash\nfoo=bar; echo $foo;' > $cmd;
checkCommand "$cmd" '$cmd $cmd';

cmd="howdoi";  checkCommand "$cmd" '$cmd xyzpdq';
cmd="sqlite3"; checkCommand "$cmd" '$cmd -header -column /dev/null "select 1 as a, 2 as b"';
checkCommand "postgresql-client"  'psql -V';

checkInstall "libnotify4";
checkInstall "libxkbfile1";
checkInstall "libsecret-1-0";
checkInstall "libxss1";
checkInstall "libnss3";
checkInstall "default-jre-headless";
checkInstall "libc++1";
checkInstall "python3-pip";
checkInstall "python3-setuptools";
checkInstall "python3-wheel";
checkInstall "nodejs";
checkInstall "npm";

cmd="flk";     checkCommand "$cmd" 'echo "(println (+ 1 1))" | $cmd';
cmd="code";    checkCommand "$cmd" '$cmd --list-extensions --user-data-dir .';
cmd="dbeaver"; checkCommand "$cmd" '$cmd -nosplash -help';
cmd="usql";    checkCommand "$cmd" '$cmd -c "\drivers"';
cmd="osquery"; checkCommand "$cmd" '${cmd}i "select * from uptime"';
cmd="migra";   checkCommand "$cmd" '$cmd --help';

# GUI only with no commandline args; just check existence of the exe
cmd="postman"; checkCommand "$cmd" 'realpath $(command -v $cmd)';

# newman will test postman too
collectionFile="postman-collection.json";
cat <<'EOF' > $collectionFile
{
	"info": {
		"_postman_id": "afbd8505-8c12-4061-b2af-b949c19d06f6",
		"name": "nix-nice-test",
		"schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
	},
	"item": [
		{
			"name": "nix-nice-test",
			"request": {
				"method": "GET",
				"header": [],
				"url": {
					"raw": "https://jsonplaceholder.typicode.com/users",
					"protocol": "https",
					"host": [
						"jsonplaceholder",
						"typicode",
						"com"
					],
					"path": [
						"users"
					]
				}
			},
			"response": []
		}
	],
	"protocolProfileBehavior": {}
}
EOF
cmd="newman";  checkCommand "$cmd" '$cmd run $collectionFile';

checkCommand "bash-git-prompt" 'git_prompt_list_themes';

cmd="diff-so-fancy"; checkCommand "$cmd" 'echo $cmd | $cmd';

dir="/etc/profile.d/vim_runtime";
checkCommand "vimrc" '[ -d "$dir" ] && [ ! -d "$dir"/zz* ]'

# spot-check files copied in
cmd='nix-nice'; checkCommand "$cmd" 'ls /opt/$cmd/bin/muxmea*';
