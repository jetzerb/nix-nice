# Base layer
FROM ubuntu:20.04

# Container attributes...
LABEL about="Generic Ubuntu-based Linux environment"
LABEL features="meld, neovim, ripgrep, tmux, trdsql, xsv, bat, fd, fzf, ddgr, tldr, others"
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
echo "Nix-Nice Base Layer Manifest:" |sed 'h; s/./-/g; p; x;' >> $MANIFEST; \
#
# Install the packages we want
DEBIAN_FRONTEND=noninteractive; : so no packages stop to ask us questions; \
apt-get update; \
#
# Other packages mess with some configuration, which causes APT to
# prompt for info regarding tzdata config.  Install this separately
# as a workaround. Also, the libxtst6 package was throwing an
# "Undetermined Error" when installed with the large group below,
# so include that up front as well.
L=""; \
P=""; \
P="$P tzdata";      : so we know what time it is in our time zone; \
P="$P libxtst6";    : required by packages below, but fails with "Undetermined Error" there; \
apt-get -yq install --no-install-recommends $P; \
L="$L $P"; \
#
# Now install the rest of the packages
#
P=""; \
# system level packages
P="$P locales";               : so we speak the right language; \
P="$P openssh-server";        : so we can connect to our container via SSH; \
P="$P xauth";                 : facilitates X11 forwarding in SSH; \
P="$P ca-certificates";       : required to safely download files from the internet; \
P="$P gnupg";                 : for managing cryptographic keys; \
P="$P rsync";                 : so we can sync between Linux and Windows filesystems; \
P="$P dbus-x11";              : so apps like Meld can persist their preferences; \
P="$P at-spi2-core";          : prevent "Error retrieving accessibility bus" warnings in gtk apps; \
P="$P yank";                  : terminal clipboard manager...also installs xsel; \
P="$P xclip";                 : clipboard utility, for those who prefer it to xsel; \
P="$P httping";               : ping for http and https; \
P="$P iputils-ping";          : ping does not work in either busybox or toybox; \
#
# basic operating environment
P="$P busybox";               : lots of utilities in one binary; \
P="$P less";                  : less pkg makes git diff and log colorful -- use this instead of busy/toy box; \
P="$P coreutils";             : because having core utilities is just smart; \
P="$P tree";                  : view indented directory structure; \
P="$P diffutils";             : sdiff is nice; \
P="$P colordiff";             : for colorful diffs; \
P="$P bash";                  : standard-ish shell; \
P="$P bash-completion";       : tab completion for bash, including git branches; \
P="$P perl";                  : when grep, sed, and awk just are not enough; \
P="$P zip";                   : so we can zip in addition to unzipping which toy/busy box can do; \
P="$P neovim";                : vi compatible editor, vim refactored; \
P="$P tmux";                  : terminal multiplexer; \
P="$P ncurses-term";          : to get tmux entries--as of 18.10 rxvt installs ncurses-base instead; \
P="$P sudo";                  : let the users play--this is just a container; \
#
# additional tools
P="$P xsltproc";              : to manipulate XML; \
P="$P jq";                    : to manipulate JSON; \
P="$P wget";                  : download files from the internet; \
P="$P curl";                  : download files from the internet; \
P="$P meld";                  : visual merge/diff tool; \
P="$P parallel";              : run commands simultaneously; \
P="$P ministat";              : statistics tool; \
P="$P imagemagick";           : view and modify images; \
P="$P gnuplot-nox";           : no-X version of gnuplot so we install 3MB instead of 300; \
P="$P poppler-utils";         : pdf utils to extract text and images, concatenate and split, etc; \
#
# productivity
P="$P ddgr";                  : duck duck go from the CLI; \
P="$P nnn";                   : CLI file manager; \
P="$P lynx";                  : terminal-based web browser; \
P="$P sc";                    : text-base spreadsheet; \
#
# graphical apps
P="$P rxvt-unicode";          : for running a terminal on a local X server; \
P="$P fonts-dejavu";          : nice looking unicode terminal font; \
P="$P apvlv";                 : PDF viewer with vi-like key bindings; \
#
# powerline patched dejavu fonts added below
#
BUILDPKGS="lsb-release"; \
apt-get -yq install --no-install-recommends $BUILDPKGS $P; \
#
lsb_release -a >> $MANIFEST 2>&1; \
L="$L $P"; \
dpkg -l $L >> $MANIFEST 2>&1; : capture version info for all packages we just installed; \
#
# **** vvvv ****
# workaround for setrlimit(RLIMIT_CORE): Operation not permitted
# error message when using sudo inside a container, per https://bit.ly/2TbceIY
echo "Set disable_coredump false" >> /etc/sudo.conf; \
# **** ^^^^ ****
#
# cleanup
apt-get remove -yq --purge $BUILDPKGS; \
apt-get -yq autoremove; \
rm -rf /var/lib/apt/lists/*;



#
# Second layer = additional apps to make life better
#

RUN \
#
# Ensure (Toy|Busy)Box links are set up.  Wait until here so that the
# system is in its final configuration (after removing BUILDPKGS). Only now
# do we know for sure which executables to create links for.
# Per http://enkidu.eu/bbtbmergerzip, use TB when you can, and BB for the
# rest.  Note that the linked script says to use BB instead of TB for head,
# tail, gzip.  But those issues have probably been fixed since Feb 2016 when
# that script was written, and those commands are already installed via the
# apt instructions above, so no override is implemented here.
makeToyAndBusyBoxLinks() { \
for LIST in "/opt/toybox/toybox --long" "/bin/busybox --list-full"; \
do \
	EXE=${LIST% *}; \
	echo "Creating links for $EXE:"; \
	for CMD in $($LIST); \
	do \
		[ -f "/$CMD" ] && continue; \
		BASECMD=${CMD##*/}; \
		case "$(type $BASECMD 2>&1)" in \
			*"not found"*) \
				echo "	$CMD"; \
				ln -s $EXE /"$CMD"; \
				;; \
		esac; \
	done; \
done; \
}; \
#
# ToyBox and BusyBox don't overlap completely, so add both.
CMD=toybox; \
DIR=/opt/$CMD; \
mkdir -p $DIR; \
cd $DIR; \
wget -nv -O $CMD http://landley.net/toybox/bin/toybox-x86_64; \
chmod +x $CMD; \
$DIR/$CMD --version >> $MANIFEST 2>&1; \
makeToyAndBusyBoxLinks; \
#
# prep area for additional downloads that don't exist in the Ubuntu package repositories
TMP=/tmp/install; \
GITHUB=https://github.com; \
mkdir -p $TMP; \
L=""; \
P=""; \
BUILDPKGS="build-essential libncurses5-dev libreadline-dev libcunit1-dev git"; \
apt-get update; \
apt-get install -yq --no-install-recommends $BUILDPKGS; \
#
# Bitwise doesn't have a ubuntu package for us yet so build from source
cd $TMP; \
wget $(lynx --dump https://github.com/mellowcandle/bitwise/releases/ |grep 'http.*bitwise-v.*\.tar\.gz' |head -1 |sed 's/.*http/http/;'); \
tar zxf bitwise*.tar.gz; \
rm bitwise*.tar.gz; \
cd bitwise*; \
./configure; \
make; \
./bitwise --version >> $MANIFEST 2>&1; \
DIR="/opt/bitwise"; \
mkdir -p $DIR; \
mv bitwise $DIR; \
#
# Install ripgrep
# rg > ag > ack > grep
cd $TMP; \
CMD=ripgrep; \
URL=$GITHUB/BurntSushi/$CMD/releases; \
wget -nv $(lynx --dump $URL |grep "$URL.*download.*${CMD}.*amd64\.deb$" | sed -n '1{s/.*http/http/;p;}'); \
dpkg -i $CMD*.deb; \
L="$L $CMD"; \
#
# Install xsv (parse delimited files)
cd $TMP; \
CMD=xsv; \
DIR=/opt/$CMD; \
mkdir -p $DIR; \
URL=$GITHUB/BurntSushi/$CMD/releases; \
wget -nv $(lynx --dump $URL |grep "$URL.*download.*${CMD}.*x86.*64.*linux.*gz" | sed -n '1{s/.*http/http/;p;}'); \
tar -xzf $CMD*.gz; \
mv $CMD $DIR; \
echo "$CMD $($DIR/$CMD --version)" >> $MANIFEST 2>&1; \
#
# Install gron (makes JSON greppable)
cd $TMP; \
CMD=gron; \
DIR=/opt/$CMD; \
mkdir -p $DIR; \
URL=$GITHUB/tomnomnom/$CMD/releases; \
wget -nv $(lynx --dump $URL |grep "$URL.*${CMD}-linux-amd64.*tgz" | sed -n '1{s/.*http/http/;p;}'); \
tar -xzf $CMD*tgz; \
mv $CMD $DIR; \
$DIR/$CMD --version >> $MANIFEST 2>&1; \
#
# Install trdsql (parse a variety of file types using SQL)
cd $TMP; \
CMD=trdsql; \
DIR=/opt/$CMD; \
mkdir -p $DIR; \
URL=$GITHUB/noborus/$CMD/releases; \
wget -nv $(lynx --dump $URL | grep "$URL.*${CMD}.*linux.*64.*zip" | sed -n '1{s/.*http/http/;p;}'); \
unzip -q -o $CMD*.zip; \
cd $CMD*linux*; \
mv $CMD $DIR; \
mv README.md $(dirname $DIR); \
mkdir -p /etc/skel/.config/$CMD; \
# copy sample config file, but ensure it uses sqlite by default
sed '/"db":/ {s/"pdb"/"sdb"/;}' config.json.sample > /etc/skel/.config/$CMD/config.json; \
echo "$CMD $($DIR/$CMD --version)" >> $MANIFEST 2>&1; \
#
# Install bat (pager w/syntax highlighting and git integration; can be used as replacement for cat)
# Install fd (file finder)
# Install hexyl (colorized hex dump utility)
cd $TMP; \
for CMD in bat fd hexyl; do \
	URL=$GITHUB/sharkdp/$CMD/releases; \
	wget -nv $(lynx --dump $URL |grep "$URL.*download.*${CMD}.*amd64\.deb$" | grep -v 'musl' | sed -n '1{s/.*http/http/;p;}'); \
	dpkg -i ${CMD}*.deb; \
	L="$L $CMD"; \
done; \
TGT=/etc/skel/.config/bat; \
mkdir -p $TGT; \
TGT=$TGT/config; \
echo "# Options for bat ($GITHUB/sharkdp/bat)" > $TGT; \
echo "\n--pager='/usr/bin/less -iKMQRWX'" >> $TGT; \
#
# One can never have too many hex editors.
cd $TMP; \
CMD=hecate; \
URL=$GITHUB/evanmiller/$CMD/releases; \
wget -nv $(lynx --dump $URL |grep "$URL.*download.*${CMD}.*amd64\.deb$" | sed -n '1{s/.*http/http/;p;}'); \
dpkg -i $CMD*.deb; \
L="$L $CMD"; \
#
# install git temporarily just to assist with installation of other software
apt-get -yq install --no-install-recommends git; \
# Helper function:
# clone a git repo, use latest commit ID as version, and remove ".git" dir
getGitHubAndLogVersion() { \
	git clone --depth 1 https://github.com/$1/${2}.git; \
	cd $2; \
	echo "$2 - $(git log --format='%h - %ai')" >> $MANIFEST 2>&1; \
	rm -rf .git; \
	cd ..; \
}; \
#
# Install "The Ultimate Vim Configuration"
cd $TMP; \
CMD=vimrc; \
getGitHubAndLogVersion amix $CMD; \
mv $CMD /etc/profile.d/vim_runtime; \
mkdir -p /etc/skel/.config/nvim; \
cd /etc/skel/.config/nvim; \
/etc/profile.d/vim_runtime/install_awesome_parameterized.sh /etc/profile.d/vim_runtime root; \
mv ~/.$CMD ./init.vim; \
# point "my_configs" to user's home dir
sed -i 's![^ ]*\(/my_configs\)!~/.config/nvim\1!;' init.vim; \
# until git is installed permanently, move some of the awesomeness out of the way
cd /etc/profile.d/vim_runtime; \
for FILE in $(find . -type f -name '*.vim' -exec grep -il 'git.executable' {} \; | sed 's!^..\([^/]*/[^/]*\)/.*!\1!;' |sort -u); \
do \
	mkdir -p zz${FILE%/*}; \
	mv $FILE zz${FILE%/*}; \
done; \
#
# Install "pretty and versatile" tmux configuration
cd $TMP; \
CMD=.tmux; \
getGitHubAndLogVersion jetzerb $CMD; \
cd $CMD; \
# add weather to the status line, and enable powerline glyphs and OS clipboard integration
sed -i -e '/^#.*navigation/{s/.*/# nix-nice: set terminal to "tmux" so we can have italics\nset -g default-terminal "tmux"\n&/;}' \
       -e '/#tmux_conf_theme_.*_separator_/{s/^#//;}' \
       -e '/tmux_conf_theme_status_right=/{s/ / #{custom}/;}' \
       -e '/tmux_conf_battery_status_charging=.*26A1/{s/^#//;}' \
       -e '/os_clipboard/{s/false/true/;}' \
	${CMD}.conf.local; \
cp ${CMD}.conf /etc/profile.d/tmux.conf; \
ln -s /etc/profile.d/tmux.conf /etc/skel/${CMD}.conf; \
cp ${CMD}.conf.local /etc/skel; \
#
# Overlay powerline fonts
cd $TMP; \
CMD=fonts; \
getGitHubAndLogVersion powerline $CMD; \
DIR=/usr/share/fonts/truetype/dejavu; \
rm $DIR/*Mono*; \
cp $CMD/DejaVuSansMono/*.ttf $DIR; \
#
# tldr bash client with colorful output
CMD=tldr; \
DIR=/opt/$CMD; \
mkdir -p $DIR; \
wget -nv https://4e4.win/$CMD; \
chmod +x $CMD; \
echo 'cachedir=~/.local/share/'$CMD >> /etc/skel/.bashrc; : not using xdg, so this is cache dir; \
echo 'complete -W "$(q=($cachedir/*/*); sed '"'s@\.md @ @g'"' <<<${q[@]##*/})" tldr' >> /etc/skel/.bashrc; : auto complete for tldr; \
mv $CMD $DIR; \
$DIR/$CMD --version | grep version >> $MANIFEST 2>&1; \
#
# fuzzy finder
CMD=fzf; \
cd /opt; \
getGitHubAndLogVersion junegunn $CMD; \
cd $CMD; \
find . -type f -exec dos2unix {} \; ; : just in case; \
echo "n\nn\nn\n" |./install; : answer no to the three questions asked; \
#
# cleanup
apt-get remove -yq --purge $BUILDPKGS; \
apt-get -yq autoremove; \
dpkg -l $L >> $MANIFEST 2>&1; \
cd /tmp; \
rm -rf install; \
#
# Now that BUILDPKGS have been removed, restore the Toybox & Busybox links
# that they overwrote
makeToyAndBusyBoxLinks; \
#
#
# Configure the stuff we just installed
#
# ubuntu auto-generates server keys for SSH;
# just need to turn on X11 forwarding for remote clients and work around
# an issue where X11 forwarding only works if you restrict to ipv4
sed -i -e '/X11Forwarding/  {s/^#//; s/no/yes/;}' \
       -e '/X11UseLocalhost/{s/^#//; s/yes/no/;}' \
       -e '/AddressFamily/  {s/^#//; s/any/inet/;}' \
	/etc/ssh/sshd_config; \
#
# jump to /etc for a few things
cd /etc; \
#
# set up bash completion to be case insensitive
echo set completion-ignore-case on >> inputrc; \
#
#
# set theme back to Adwaita since Yaru is so bloated
sed -i -e '/^gtk-theme/      {s/Yaru/Ambiance/;}' \
       -e '/^gtk-icon-theme/ {s/Yaru/ubuntu-mono-dark/;}' \
       -e '/^gtk-sound/      {s/Yaru/ubuntu/;}' \
	/etc/gtk-3.0/settings.ini; \
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
# Expose the standard SSH port
EXPOSE 22

# entry point creates users inside the container, based on the users
# present in the /hosthome bind mount
ENTRYPOINT ["/opt/nix-nice/sbin/container-startup.sh"]
