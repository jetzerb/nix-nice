# Base layer
FROM ubuntu:19.04

# Container attributes...
LABEL about="Generic Ubuntu-based Linux environment"
LABEL features="meld, neovim, ripgrep, tmux, trdsql, xsv, bat, fd, fzf, ddgr, tldr, others"
LABEL access="SSH, key authentication, X11 forwarding"
LABEL maintainer="jetzerb@sva.com"

#
# First layer = various Ubuntu packages
RUN \
#
# SOFTWARE INSTALL START
#
# make sure our manifest file exists
MANIFEST=/opt/nix-nice/etc/manifest.txt; \
mkdir -p $(dirname $MANIFEST); \
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
P="$P software-properties-common"; : so we can add ppa repositories; \
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
P="$P xpdf";                  : lightest weight pdf viewer around; \
#       powerline patched dejavu fonts added below
apt-get -yq install --no-install-recommends $P; \
L="$L $P"; \
#
# Add repository containing "bitwise" and then install it
add-apt-repository ppa:ramon-fried/bitwise; \
P="bitwise"; \
apt-get -yq install --no-install-recommends $P; \
L="$L $P"; \
dpkg -l $L >> $MANIFEST 2>&1; \
#
# remove package lists to trim > 20MB of cruft
rm -rf /var/lib/apt/lists/*;



#
# Second layer = additional apps to make life better
#

RUN \
#
# New env for each "RUN"; avoid ENV for sake of install script
MANIFEST=/opt/nix-nice/etc/manifest.txt; \
#
# pull most recent date & commit id from a github repo
printVer() { \
	# 1=command, 2=git URL
	echo -n "$1 "; \
	lynx --dump "$2"/commits/master \
	| awk '/Commits on / { \
		sub(/.*Commits on /,""); \
		v = $0; \
		i = 0; \
		while (i < 3) { \
			getline; \
			if ($0 ~ /^  *\[/) { i++; } \
		} \
		sub(/.*\]/,""); \
		printf("%s %s\n",v,$0); \
		exit; \
	}'; \
}; \
logVer() { printVer $1 $2 >> $MANIFEST 2>&1; }; \
L=""; \
#
# ToyBox and BusyBox don't overlap completely, so add both.
CMD=toybox; \
DIR=/opt/$CMD/bin; \
mkdir -p $DIR; \
cd $DIR; \
wget -nv -O $CMD http://landley.net/toybox/bin/toybox-x86_64; \
chmod +x $CMD; \
$DIR/$CMD --version >> $MANIFEST 2>&1; \
#
# Per http://enkidu.eu/bbtbmergerzip, use TB when you can,
# and BB for the rest.  Note that the linked script says
# to use BB instead of TB for head, tail, gzip.  But those
# issues have probably been fixed since Feb 2016 when
# that script was written, and those commands are already
# installed via the apt instructions above, so no override
# is implemented here.
for LIST in "/opt/toybox/bin/toybox --long" "/bin/busybox --list-full"; \
do \
	EXE=${LIST% *}; \
	echo "Creating links for $EXE:"; \
	for CMD in $($LIST); \
	do \
		BASECMD=${CMD##*/}; \
		case "$(type $BASECMD 2>&1)" in \
			*"not found"*) \
				echo "	$CMD"; \
				ln -s $EXE /$CMD; \
				;; \
		esac; \
	done; \
done; \
#
# prep area for additional downloads that don't exist in the Ubuntu package repositories
mkdir -p /tmp/install; \
#
# Install ripgrep
# rg > ag > ack > grep
cd /tmp/install; \
URL=https://github.com/BurntSushi/ripgrep/releases; \
wget -nv $(lynx --dump $URL |grep "$URL.*download.*ripgrep.*amd64\.deb$" | sed -n '1{s/.*http/http/;p;}'); \
dpkg -i ripgrep*.deb; \
L="$L ripgrep"; \
#
# Install xsv (parse delimited files)
cd /tmp/install; \
CMD=xsv; \
DIR=/opt/$CMD/bin; \
mkdir -p $DIR; \
URL=https://github.com/BurntSushi/xsv/releases; \
wget -nv $(lynx --dump $URL |grep "$URL.*download.*xsv.*x86.*64.*linux.*gz" | sed -n '1{s/.*http/http/;p;}'); \
tar -xzf xsv*.gz; \
mv $CMD $DIR; \
echo "$CMD $($DIR/$CMD --version)" >> $MANIFEST 2>&1; \
#
# Install gron (makes JSON greppable)
cd /tmp/install; \
CMD=gron; \
DIR=/opt/$CMD/bin; \
mkdir -p $DIR; \
URL=https://github.com/tomnomnom/gron/releases; \
wget -nv $(lynx --dump $URL |grep "$URL.*gron-linux-amd64.*tgz" | sed -n '1{s/.*http/http/;p;}'); \
tar -xzf gron*tgz; \
mv $CMD $DIR; \
$DIR/$CMD --version >> $MANIFEST 2>&1; \
#
# Install trdsql (parse a variety of file types using SQL)
cd /tmp/install; \
CMD=trdsql; \
DIR=/opt/$CMD/bin; \
mkdir -p $DIR; \
URL=https://github.com/noborus/trdsql/releases; \
wget -nv $(lynx --dump $URL | grep "$URL.*trdsql.*linux.*64.*zip" | sed -n '1{s/.*http/http/;p;}'); \
unzip -q -o trdsql*.zip; \
cd trdsql*linux*; \
mv $CMD $DIR; \
mv README.md $(dirname $DIR); \
mkdir -p /etc/skel/.config/$CMD; \
mv config.json.sample /etc/skel/.config/$CMD/config.json; \
echo "$CMD $($DIR/$CMD --version)" >> $MANIFEST 2>&1; \
#
# Install bat (pager w/syntax highlighting and git integration; can be used as replacement for cat)
# Install fd (file finder)
# Install hexyl (colorized hex dump utility)
cd /tmp/install; \
for CMD in bat fd hexyl; do \
	URL=https://github.com/sharkdp/$CMD/releases; \
	wget -nv $(lynx --dump $URL |grep "$URL.*download.*${CMD}.*amd64\.deb$" | grep -v 'musl' | sed -n '1{s/.*http/http/;p;}'); \
	dpkg -i ${CMD}*.deb; \
	L="$L $CMD"; \
done; \
TGT=/etc/skel/.config/bat; \
mkdir -p $TGT; \
TGT=$TGT/config; \
echo ": Options for bat (https://github.com/sharkdp/bat)" > $TGT; \
echo -e "\n--pager='/usr/bin/less -iKMQRWX'" >> $TGT; \
#
# One can never have too many hex editors.
cd /tmp/install; \
URL=https://github.com/evanmiller/hecate/releases; \
wget -nv $(lynx --dump $URL |grep "$URL.*download.*hecate.*amd64\.deb$" | sed -n '1{s/.*http/http/;p;}'); \
dpkg -i hecate*.deb; \
L="$L hecate"; \
#
# Install perl extension to adjust urxvt font size on the fly
cd /tmp/install; \
CMD=urxvt-font-size; \
URL=https://github.com/majutsushi/$CMD; \
wget -nv $URL/archive/master.zip; \
unzip -q -o master.zip; \
rm master.zip; \
cd urxvt-font-size-master; \
dos2unix font-size; : just in case; \
mkdir -p /etc/skel/.urxvt/ext/; \
mv font-size /etc/skel/.urxvt/ext/; \
logVer "$CMD" "$URL"; \
#
# Install "The Ultimate Vim Configuration"
cd /tmp/install; \
CMD=vimrc; \
URL=https://github.com/amix; \
wget -nv $URL/$CMD/archive/master.zip; \
unzip -q -o master.zip; \
rm master.zip; \
mv vimrc-master /etc/profile.d/vim_runtime; \
mkdir -p /etc/skel/.config/nvim; \
cd /etc/skel/.config/nvim; \
/etc/profile.d/vim_runtime/install_awesome_parameterized.sh /etc/profile.d/vim_runtime root; \
mv ~/.vimrc ./init.vim; \
sed -i 's![^ \]*\(/my_configs\)!~/.config/nvim\1!;' init.vim; \
# until git is installed, move some of the awesomeness out of the way
cd /etc/profile.d/vim_runtime; \
for FILE in $(find . -type f -name '*.vim' -exec grep -il 'git.executable' {} \; | sed 's!^..\([^/]*/[^/]*\)/.*!\1!;' |sort -u); \
do \
	mkdir -p zz${FILE%/*}; \
	mv $FILE zz${FILE%/*}; \
done; \
logVer "$CMD" "$URL"; \
#
# Install "pretty and versatile" tmux configuration
cd /tmp/install; \
CMD=.tmux; \
URL=https://github.com/gpakosz/$CMD; \
wget -nv $URL/$CMD/archive/master.zip; \
unzip -q -o master.zip; \
rm master.zip; \
cd .tmux-master; \
dos2unix .tmux.conf*; : just in case \
# add weather to the status line, and enable powerline glyphs
sed -i -e '/^:.*navigation/{s/.*/# nix-nice# set terminal to "tmux" so we can have italics\nset -g default-terminal "tmux"\n&/;}' \
       -e '/tmux_conf_theme_status_right/{s/synchronized} /&:(curl wttr.in?format=3) /;}' \
       -e '/:tmux_conf_theme_.*_separator_/{s/^#//;}' \
	.tmux.conf.local; \
cp .tmux.conf /etc/profile.d/tmux.conf; \
ln -s /etc/profile.d/tmux.conf /etc/skel/.tmux.conf; \
cp .tmux.conf.local /etc/skel; \
logVer "$CMD" "$URL"; \
#
# Overlay powerline fonts
cd /usr/share/fonts/truetype/dejavu/; \
rm *Mono*; \
CMD=powerline/fonts; \
URL=https://github.com/$CMD; \
wget -nv $(lynx --dump $URL/blob/master/DejaVuSansMono |sed -n '/https.*Mono.*ttf/{s/.*https/https/; s!/blob/!/raw/!; s/ /%20/g; p;}'); \
logVer "$CMD" "$URL"; \
#
# tldr bash client with colorful output
CMD=tldr; \
DIR=/opt/$CMD/bin; \
wget -nv https://4e4.win/tldr; \
chmod +x $CMD; \
echo 'cachedir=~/.local/share/tldr' >> /etc/skel/.bashrc; : not using xdg, so this is cache dir \
echo 'complete -W "q=($cachedir/*/*; sed '"'s@\.md @ @g'"' <<<${q[@]:#*/})" tldr' >> /etc/skel/.bashrc; : auto complete for tldr; \
mv $CMD $DIR; \
$DIR/$CMD --version | grep version >> $MANIFEST 2>&1; \
#
# fuzzy finder
cd /opt; \
[ -d fzf ] && rm -rf fzf; \
wget -nv https://github.com/junegunn/fzf/archive/master.zip; \
unzip -q -o master.zip; \
rm master.zip; \
mv fzf-master fzf; \
cd fzf; \
find . -type f -exec dos2unix {} \; ; : just in case; \
echo -e "n\nn\nn\n" |./install; : answer no to the three questions asked; \
echo "fzf $(bin/fzf --version)" >> $MANIFEST 2>&1; \
#
# cleanup
dpkg -l $L >> $MANIFEST 2>&1; \
cd /tmp; \
rm -rf install; \
#
#
# Configure the stuff we just installed
#
# ubuntu auto-generates server keys for SSH;
# just need to turn on X11 forwarding for remote clients
sed -i -e '/X11Forwarding/  {s/^#//; s/no/yes/;}' \
       -e '/X11UseLocalhost/{s/^#//; s/yes/no/;}' \
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
CMD ["-epus"]
