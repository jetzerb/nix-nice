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
DEBIAN_FRONTEND=noninteractive; $(: so no packages stop to ask us questions) \
apt-get update; \
#
#
# Now install the rest of the packages
apt-get -yq install --no-install-recommends \
#
# developer tools
	git                  $(: source control manager) \
	git-lfs              $(: git add-on for handling BLOBs) \
	sqitch               $(: sane database change management) \
	shellcheck           $(: so you can write proper shell scripts) \
#
# Productivity
	howdoi               $(: ask a coding question, get an answer) \
#
# the go-to db tools
	sqlite3              $(: small, fast, SQL db engine, most-used in the world) \
	postgresql-client    $(: psql and friends) \
#
# VS Code pre-requisites
	libnotify4 \
	libxkbfile1 \
	libsecret-1-0 \
	libxss1 \
	libnss3 \
#
# DBeaver pre-requisites
	default-jre-headless \
#
# OSquery pre-requisites
	libc++1 \
#
# Migra pre-requisites
	python3-pip \
	python3-setuptools \
	python3-wheel \
#
# Newman (Postman automation vi CLI) pre-requisites
	nodejs \
	npm \
; \
#
# remove package lists to trim > 20MB of cruft
rm -rf /var/lib/apt/lists/*;



#
# Second layer = additional apps
#

RUN \
#
# VS Code: Code Editor
mkdir -p /tmp/install; \
cd /tmp/install; \
wget -O code.deb https://go.microsoft.com/fwlink/?LinkID=760868; \
dpkg -i code.deb; \
rm code.deb; \
#
# DBeaver: Free Universal Database Tool
cd /tmp/install; \
wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb; \
dpkg -i dbeaver*.deb; \
rm dbeaver*.deb; \
#
#
# OSQuery: query your system using SQL
ce /tmp/install; \
URL=https://github.com/osquery/osquery/releases; \
wget -O osquery.deb $(lynx --dump $URL | sed -n '/[0-9][0-9]*\. https.*deb/ {s/.*https/https/; p;}'); \
dpkg -i osquery.deb; \
#
# Migra: Schema diff for PostgreSQL
pip3 install migra[pg]; \
#
#
# Postman: API Development Environment
cd /tmp/install; \
wget https://dl.pstmn.io/download/latest/linux64; \
cd /opt; \
tar zxf /tmp/install/linux64; \
cd Postman; \
mkdir bin; \
cd bin; \
ln -s ../app/Postman postman; \
rm /tmp/install/linux64; \
#
npm install -g newman; \
#
#
# feature-rich bash prompt for git
cd /opt; \
git clone --depth=1 https://github.com/magicmonty/bash-git-prompt.git bash-git-prompt; \
# dark blue on black is hard to read, so change blue to cyan
cd bash-git-prompt/themes; \
sed -i '/Blue}/ { s/{Blue}/{Cyan}/g; s/{DimBlue}/{DimCyan}/g; }' Default.bgptheme; \
cd /etc/profile.d; \
ln -s /opt/bash-git-prompt/gitprompt.sh .; \
#
# fancier git diff output
mkdir -p /opt/diff-so-fancy/bin; \
cd /opt/diff-so-fancy/bin; \
wget https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy; \
chmod 755 diff-so-fancy;\
#
#
# clean up after software downloads
rm -rf /tmp/install; \
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
git config --system core.filemode false; $(: so git ignores access mode between windows and linux); \
git config --system credential.helper "cache --timeout=36000"; $(: cache Personal Access Token for full work day); \
git config --system diff.tool meld; \
git config --system difftool.prompt false; $(: prevent the prompt every time you use "git difftool"); \
git config --system difftool.meld.cmd 'meld "$LOCAL" "$REMOTE"'; \
git config --system merge.tool meld; \
git config --system mergetool.prompt false; $(: prevent the prompt every time you use "git mergetool"); \
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
