# Base layer
FROM jetzerb/nix-nice:base-latest

# Container attributes...
LABEL about="Ubuntu-Based Linux Environment for Developers"
LABEL features="nix-nice base, plus git, vs code, dbeaver, postman"
LABEL access="SSH, key authentication, X11 forwarding"
LABEL maintainer="jetzerb@sva.com"


#
# SOFTWARE INSTALL START
#

# Manifest file inside the container
ARG MANIFEST=/opt/nix-nice/etc/manifest.txt

#
# First layer = various Ubuntu packages
RUN \
# make sure our manifest file exists
mkdir -p $(dirname $MANIFEST); \
echo "\n\n" >> $MANIFEST; \
echo "Nix-Nice Developer Manifest:" |sed 'h; s/./-/g; p; x;' >> $MANIFEST; \
#
# Install the packages we want
DEBIAN_FRONTEND=noninteractive; : so no packages stop to ask us questions; \
apt-get update; \
#
L=""; \
P=""; \
#
# Now install the rest of the packages
#
# developer tools
P="$P git";                  : source control manager; \
P="$P git-lfs";              : git add-on for handling BLOBs; \
P="$P sqitch";               : sane database change management; \
P="$P shellcheck";           : so you can write proper shell scripts; \
#
# Productivity
P="$P howdoi";               : ask a coding question, get an answer; \
#
# the go-to db tools
P="$P sqlite3";              : small, fast, SQL db engine, most-used in the world; \
P="$P postgresql-client";    : psql and friends; \
#
# VS Code pre-requisites
P="$P libnotify4"; \
P="$P libxkbfile1"; \
P="$P libsecret-1-0"; \
P="$P libxss1"; \
P="$P libnss3"; \
P="$P libgbm1"; \
P="$P libxcb-dri3-0"; \
#
# DBeaver pre-requisites
P="$P default-jre-headless"; \
#
# OSquery pre-requisites
P="$P libc++1"; \
#
# Migra pre-requisites
P="$P python3-pip"; \
P="$P python3-setuptools"; \
P="$P python3-wheel"; \
#
# Newman (Postman automation vi CLI) pre-requisites
P="$P nodejs"; \
P="$P npm"; \
#
apt-get -yq install --no-install-recommends $P; \
#
L="$L $P"; \
dpkg -l $L >> $MANIFEST 2>&1; : capture version info for all packages we just installed; \
#
# cleanup
rm -rf /var/lib/apt/lists/*;



#
# Second layer = additional apps
#

RUN \
#
# prep work for additional apps
TMP=/tmp/install; \
GITHUB=https://github.com; \
mkdir -p $TMP; \
L=""; \
# Helper function:
# clone a git repo, use latest commit ID as version, and remove ".git" dir
getGitHubAndLogVersion() { \
        git clone --depth 1 $GITHUB/$1/${2}.git; \
	cd $2; \
	echo "$2 - $(git log --format='%h - %ai')" >> $MANIFEST 2>&1; \
	rm -rf .git; \
	cd ..; \
}; \
#
# Fleck: a Clojure-like LISP that runs wherever Bash is
cd $TMP; \
CMD=flk; \
DIR=/opt/$CMD; \
mkdir -p $DIR; \
getGitHubAndLogVersion chr15m $CMD; \
cp $CMD/$CMD $DIR; \
chmod +x $DIR/$CMD; \
#
# VS Code: Code Editor
cd $TMP; \
CMD=code; \
wget -nv -O $CMD.deb https://go.microsoft.com/fwlink/?LinkID=760868; \
dpkg -i $CMD.deb; \
rm $CMD.deb; \
L="$L $CMD"; \
#
# DBeaver: Free Universal Database Tool
cd $TMP; \
CMD=dbeaver; \
wget -nv https://$CMD.io/files/$CMD-ce_latest_amd64.deb; \
dpkg -i $CMD*.deb; \
rm $CMD*.deb; \
L="$L $CMD-ce"; \
#
# "universal" SQL access tool
cd $TMP; \
CMD=usql; \
DIR=/opt/$CMD; \
mkdir -p $DIR; \
URL=$GITHUB/xo/$CMD/releases; \
wget -nv $(lynx --dump $URL | sed -n '/https.*linux.*amd64/{s/.*https/https/; p; q;}'); \
tar jxf $CMD*.bz2; \
mv $CMD $DIR; \
# link multiple versions to shared libraries so usql can run
cd /lib/x86_64-linux-gnu; \
EXE="/opt/nix-nice/sbin/make-lib-links"; \
"$EXE" ./libicuuc; \
"$EXE" ./libicui18n; \
$DIR/$CMD -V >> $MANIFEST 2>&1; \
#
#
# OSQuery: query your system using SQL
cd $TMP; \
CMD=osquery; \
URL=$GITHUB/$CMD/$CMD/releases; \
wget -nv -O $CMD.deb $(lynx --dump $URL | sed -n '/[0-9][0-9]*\. https.*'"$CMD"'.[0-9].*deb/ {s/.*https/https/; p; q;}'); \
dpkg -i $CMD.deb; \
L="$L $CMD"; \
#
# Migra: Schema diff for PostgreSQL
pip3 install migra[pg]; \
# no version flag; pull git repo and log current commit
CMD=migra; \
getGitHubAndLogVersion djrobstep $CMD; \
#
#
# Postman: API Development Environment
CMD=Postman; \
cd $TMP; \
wget -nv https://dl.pstmn.io/download/latest/linux64; \
cd /opt; \
tar zxf $TMP/linux64; \
cd $CMD; \
ln -s $CMD $(echo $CMD | tr 'P' 'p'); \
(cat app/version && echo) >> $MANIFEST; \
rm $TMP/linux64; \
#
# and the CLI to drive postman
CMD=newman; \
npm install -g $CMD; \
echo "$CMD $($CMD --version)" >> $MANIFEST 2>&1; \
#
#
# feature-rich bash prompt for git
cd /opt; \
CMD=bash-git-prompt; \
getGitHubAndLogVersion magicmonty $CMD; \
# dark blue on black is hard to read, so change blue to cyan
cd $CMD/themes; \
sed -i '/Blue}/ { s/{Blue}/{Cyan}/g; s/{DimBlue}/{DimCyan}/g; }' Default.bgptheme; \
cd /etc/profile.d; \
ln -s /opt/$CMD/gitprompt.sh .; \
#
# delta for diff & git diff syntax highlighting
cd $TMP; \
CMD=delta; \
URL=$GITHUB/dandavison/$CMD/releases; \
wget -nv -O $CMD.deb $(lynx --dump $URL | sed -n '/musl/d; /[0-9][0-9]*\. https.*amd64.*deb/ {s/.*https/https/; p; q;}'); \
dpkg -i $CMD.deb; \
L="$L git-$CMD"; \
#
#
# clean up after software downloads
cd /tmp; \
rm -rf $TMP; \
dpkg -l $L >> $MANIFEST 2>&1; \
#
#
# system-wide settings for git
# Settings for delta
git config --system core.pager 'delta --plus-color="#003400" --minus-color="#340000" --theme='"'Monokai Extended'"; \
git config --system interactive.diffFilter 'delta --color-only'; \
#
# other settings
git config --system core.filemode false; : so git ignores access mode between windows and linux; \
git config --system credential.helper "cache --timeout=36000"; : cache Personal Access Token for full work day; \
git config --system diff.tool meld; \
git config --system difftool.prompt false; : prevent the prompt every time you use "git difftool"; \
git config --system difftool.meld.cmd 'meld "$LOCAL" "$REMOTE"'; \
git config --system merge.tool meld; \
git config --system mergetool.prompt false; : prevent the prompt every time you use "git mergetool"; \
git config --system mergetool.meld.cmd 'meld "$LOCAL" "$BASE" "$REMOTE" --output "$MERGED"'; \
git config --system url.MYGITURL.insteadOf work:; \
git config --system alias.hist  "log --format='%C(auto)%h |       %ai | %an | %D | %s' --graph"; \
git config --system alias.histc "log --format='%C(auto)%h | %ci | %ai | %an | %D | %s' --graph"; \
git config --system core.commentChar ';'; : so we can use #nnnnn to reference our work items; \
git config --system commit.template /opt/nix-nice/etc/git/commit.template; \
#
#
# Enable git-specific vimrc features that the base image disabled
cd /etc/profile.d/vim_runtime; \
for DIR in zz*; \
do \
	mv $DIR/* ${DIR#zz}; \
	rmdir $DIR; \
done; \
#
#
#
echo "Done with major installation and configuration";
#
# SOFTWARE INSTALL END
#
#
# Set up customizations and additions to the system
COPY fs/ /

#
# Inherit exposed ports, entry point, and command from base container
