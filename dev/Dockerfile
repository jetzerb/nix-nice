# Base layer
FROM jetzerb/nix-nice:base-latest

# Container attributes...
LABEL about="Ubuntu-Based Linux Environment for Developers"
LABEL features="nix-nice base, plus git, vs code, dbeaver, postman"
LABEL access="SSH, key authentication, X11 forwarding"
LABEL maintainer="jetzerb@sva.com"

#
# First layer: add pre-packaged software
RUN \
#
# SOFTWARE INSTALL START
#
# make sure our manifest file exists
MANIFEST=/opt/nix-nice/etc/manifest.txt; \
mkdir -p $(dirname $MANIFEST); \
echo -e "\n\n" >> $MANIFEST; \
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
MANIFEST=/opt/nix-nice/etc/manifest.txt; \
TMP=/tmp/install; \
mkdir -p $TMP; \
GITHUB=https://github.com; \
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
DIR=/opt/$CMD/bin; \
mkdir -p $DIR; \
getGitHubAndLogVersion chr15m $CMD; \
cp $CMD/$CMD $DIR; \
chmod +x $DIR/$CMD; \
#
# VS Code: Code Editor
cd $TMP; \
CMD=code; \
wget -O $CMD.deb https://go.microsoft.com/fwlink/?LinkID=760868; \
dpkg -i $CMD.deb; \
rm $CMD.deb; \
L="$L $CMD"; \
#
# DBeaver: Free Universal Database Tool
cd $TMP; \
CMD=dbeaver-cd; \
wget https://$CMD.io/files/$CMD_latest_amd64.deb; \
dpkg -i $CMD*.deb; \
rm $CMD*.deb; \
L="$L $CMD"; \
#
# "universal" SQL access tool
cd $TMP; \
CMD=usql; \
DIR=/opt/$CMD/bin; \
mkdir -p $DIR; \
URL=$GITHUB/xo/$CMD/releases; \
wget $(lynx --dump $URL | sed -n '/https.*linux.*amd64/{s/.*https/https/; p; q;}'); \
tar jxf $CMD*.bz2; \
mv $CMD $DIR; \
#
#
# OSQuery: query your system using SQL
cd $TMP; \
CMD=osquery; \
URL=$GITHUB/$CMD/$CMD/releases; \
wget -O $CMD.deb $(lynx --dump $URL | sed -n '/[0-9][0-9]*\. https.*deb/ {s/.*https/https/; p; q;}'); \
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
wget https://dl.pstmn.io/download/latest/linux64; \
cd /opt; \
tar zxf $TMP/linux64; \
cd $CMD; \
mkdir bin; \
cd bin; \
ln -s ../app/$CMD $(echo $CMD | sed 's/P/p/;'); \
(cat ../app/version && echo) >> $MANIFEST; \
rm $TMP/linux64; \
#
# and the CLI to drive postman
CMD=newman; \
npm install -g $CMD; \
echo "$CMD $($CMD --version)" >> $MANIFEST; \
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
# fancier git diff output
cd $TMP; \
CMD=diff-so-fancy; \
getGitHubAndLogVersion so-fancy $CMD; \
DIR=/opt/$CMD/bin; \
mkdir -p $DIR; \
mv $CMD/$CMD $DIR; \
chmod 755 $DIR/$CMD; \
#
#
# clean up after software downloads
cd /tmp; \
rm -rf $TMP; \
dpkg -l $L >> $MANIFEST; \
#
#
# system-wide settings for git
# Settings for diff-so-fancy:
git config --system core.pager "diff-so-fancy | less"; \
git config --system color.ui true; \
#
git config --system color.diff-highlight.oldNormal    "red bold"; \
git config --system color.diff-highlight.oldHighlight "red bold 52"; \
git config --system color.diff-highlight.newNormal    "green bold"; \
git config --system color.diff-highlight.newHighlight "green bold 22"; \
#
git config --system color.diff.meta       "yellow"; \
git config --system color.diff.frag       "magenta bold"; \
git config --system color.diff.commit     "yellow bold"; \
git config --system color.diff.old        "red bold"; \
git config --system color.diff.new        "green bold"; \
git config --system color.diff.whitespace "red reverse"; \
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
