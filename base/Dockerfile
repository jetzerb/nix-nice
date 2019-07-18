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
# Install the packages we want
DEBIAN_FRONTEND=noninteractive; $(: so no packages stop to ask us questions) \
apt-get update; \
#
# Other packages mess with some configuration, which causes APT to
# prompt for info regarding tzdata config.  Install this separately
# as a workaround. Also, the libxtst6 package was throwing an
# "Undetermined Error" when installed with the large group below,
# so include that up front as well.
apt-get -yq install --no-install-recommends \
	tzdata                $(: so we know what time it is in our time zone) \
	libxtst6              $(: required by packages below, but fails with "Undetermined Error" there) \
; \
#
# Now install the rest of the packages
apt-get -yq install --no-install-recommends \
#
# system level packages
	software-properties-common $(: so we can add ppa repositories ) \
	locales               $(: so we speak the right language) \
	openssh-server        $(: so we can connect to our container via SSH) \
	xauth                 $(: facilitates X11 forwarding in SSH) \
	ca-certificates       $(: required to safely download files from the internet) \
	gnupg                 $(: for managing cryptographic keys) \
	rsync                 $(: so we can sync between Linux and Windows filesystems) \
	dbus-x11              $(: so apps like Meld can persist their preferences) \
	at-spi2-core          $(: prevent "Error retrieving accessibility bus" warnings in gtk apps) \
	yank                  $(: terminal clipboard manager...also installs xsel) \
	xclip                 $(: clipboard utility, for those who prefer it to xsel) \
#
# basic operating environment
	busybox               $(: lots of utilities in one binary) \
	less                  $(: less pkg makes git diff and log colorful -- use this instead of busy/toy box) \
	coreutils             $(: because having core utilities is just smart) \
	tree                  $(: view indented directory structure) \
	diffutils             $(: sdiff is nice) \
	colordiff             $(: for colorful diffs) \
	bash                  $(: standard-ish shell) \
	bash-completion       $(: tab completion for bash, including git branches) \
	perl                  $(: when grep, sed, and awk just are not enough) \
	zip                   $(: so we can zip in addition to unzipping which toy/busy box can do) \
	neovim                $(: vi compatible editor, vim refactored) \
	tmux                  $(: terminal multiplexer) \
	ncurses-term          $(: to get tmux entries--as of 18.10 rxvt installs ncurses-base instead) \
	sudo                  $(: let the users play--this is just a container) \
#
# additional tools
	xsltproc              $(: to manipulate XML) \
	jq                    $(: to manipulate JSON) \
	wget                  $(: download files from the internet) \
	curl                  $(: download files from the internet) \
	meld                  $(: visual merge/diff tool) \
	ministat              $(: statistics tool) \
#
# productivity
	ddgr                  $(: duck duck go from the CLI) \
	nnn                   $(: CLI file manager) \
	lynx                  $(: terminal-based web browser) \
#
# graphical apps
	rxvt-unicode          $(: for running a terminal on a local X server) \
	fonts-dejavu          $(: nice looking unicode terminal font) \
#       powerline patched dejavu fonts added below
; \
#
# Add repository containing "bitwise" and then install it
add-apt-repository ppa:ramon-fried/bitwise; \
apt-get -yq install --no-install-recommends \
	bitwise; \
#
# remove package lists to trim > 20MB of cruft
rm -rf /var/lib/apt/lists/*;



#
# Second layer = additional apps to make life better
#

RUN \
#
# ToyBox and BusyBox don't overlap completely, so add both.
mkdir -p /opt/toybox/bin; \
cd /opt/toybox/bin; \
wget -O toybox http://landley.net/toybox/bin/toybox-x86_64; \
chmod +x toybox; \
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
wget $(lynx --dump $URL |grep "$URL.*download.*ripgrep.*amd64\.deb$" | sed -n '1{s/.*http/http/;p;}'); \
dpkg -i ripgrep*.deb; \
#
# Install xsv (parse delimited files)
cd /tmp/install; \
mkdir -p /opt/xsv/bin; \
URL=https://github.com/BurntSushi/xsv/releases; \
wget $(lynx --dump $URL |grep "$URL.*download.*xsv.*x86.*64.*linux.*gz" | sed -n '1{s/.*http/http/;p;}'); \
tar -xzf xsv*.gz; \
mv xsv /opt/xsv/bin; \
#
# Install trdsql (parse a variety of file types using SQL)
cd /tmp/install; \
mkdir -p /opt/trdsql/bin; \
URL=https://github.com/noborus/trdsql/releases; \
wget $(lynx --dump $URL | grep "$URL.*trdsql.*linux.*64.*zip" | sed -n '1{s/.*http/http/;p;}'); \
unzip -o trdsql*.zip; \
cd trdsql*linux*; \
mv trdsql /opt/trdsql/bin/; \
mv README.md /opt/trdsql/; \
mkdir -p /etc/skel/.config/trdsql; \
mv config.json.sample /etc/skel/.config/trdsql/config.json; \
#
# Install bat (pager w/syntax highlighting and git integration; can be used as replacement for cat)
# Install fd (file finder)
# Install hexyl (colorized hex dump utility)
cd /tmp/install; \
for CMD in bat fd hexyl; do \
	URL=https://github.com/sharkdp/$CMD/releases; \
	wget $(lynx --dump $URL |grep "$URL.*download.*${CMD}.*amd64\.deb$" | grep -v 'musl' | sed -n '1{s/.*http/http/;p;}'); \
	dpkg -i ${CMD}*.deb; \
done; \
TGT=/etc/skel/.config/bat; \
mkdir -p $TGT; \
TGT=$TGT/config; \
echo "# Options for bat (https://github.com/sharkdp/bat)" > $TGT; \
echo -e "\n--pager='/usr/bin/less -iKMQRWX'"; >> $TGT; \
#
# One can never have too many hex editors.
cd /tmp/install; \
URL=https://github.com/evanmiller/hecate/releases; \
wget $(lynx --dump $URL |grep "$URL.*download.*hecate.*amd64\.deb$" | sed -n '1{s/.*http/http/;p;}'); \
dpkg -i hecate*.deb; \
#
# Install perl extension to adjust urxvt font size on the fly
cd /tmp/install; \
wget https://github.com/majutsushi/urxvt-font-size/archive/master.zip; \
unzip -o master.zip; \
rm master.zip; \
cd urxvt-font-size-master; \
dos2unix font-size; $(: just in case) \
mkdir -p /etc/skel/.urxvt/ext/; \
mv font-size /etc/skel/.urxvt/ext/; \
#
# Install "The Ultimate Vim Configuration"
cd /tmp/install; \
wget https://github.com/amix/vimrc/archive/master.zip; \
unzip -o master.zip; \
rm master.zip; \
mv vimrc-master /etc/profile.d/vim_runtime; \
mkdir -p /etc/skel/.config/nvim; \
cd /etc/skel/.config/nvim; \
/etc/profile.d/vim_runtime/install_awesome_parameterized.sh /etc/profile.d/vim_runtime root; \
mv ~/.vimrc ./init.vim; \
sed -i 's![^ \]*\(/my_configs\)!~/.config/nvim\1!;' init.vim; \
# until git is installed, move some of the awesomeness out of the way
cd /etc/profile.d/vim_runtime; \
for FILE in $(rg -il -g '*.vim' 'git.executable'  |sed 's!\([^/]*/[^/]*\)/.*!\1!;' |sort -u); \
do \
	mkdir -p zz${FILE%/*}; \
	mv $FILE zz${FILE%/*}; \
done; \
#
# Install "pretty and versatile" tmux configuration
cd /tmp/install; \
wget https://github.com/gpakosz/.tmux/archive/master.zip; \
unzip -o master.zip; \
rm master.zip; \
cd .tmux-master; \
dos2unix .tmux.conf*; $(: just in case) \
# add weather to the status line, and enable powerline glyphs
sed -i -e '/^#.*navigation/{s/.*/# nix-nice: set terminal to "tmux" so we can have italics\nset -g default-terminal "tmux"\n&/;}' \
       -e '/tmux_conf_theme_status_right/{s/synchronized} /&#(curl wttr.in?format=3) /;}' \
       -e '/#tmux_conf_theme_.*_separator_/{s/^#//;}' \
	.tmux.conf.local; \
cp .tmux.conf /etc/profile.d/tmux.conf; \
ln -s /etc/profile.d/tmux.conf /etc/skel/.tmux.conf; \
cp .tmux.conf.local /etc/skel; \
#
# Overlay powerline fonts
cd /usr/share/fonts/truetype/dejavu/; \
rm *Mono*; \
URL=https://github.com/powerline/fonts/blob/master/DejaVuSansMono; \
wget $(lynx --dump $URL |sed -n '/https.*Mono.*ttf/{s/.*https/https/; s!/blob/!/raw/!; s/ /%20/g; p;}'); \
#
# tldr bash client with colorful output
cd /opt; \
mkdir -p tldr/bin; \
cd /opt/tldr/bin; \
wget https://4e4.win/tldr; \
chmod +x tldr; \
echo 'cachedir=~/.local/share/tldr' >> /etc/skel/.bashrc; $(: not using xdg, so this is cache dir) \
echo 'complete -W "$(q=($cachedir/*/*); sed '"'s@\.md @ @g'"' <<<${q[@]##*/})" tldr' >> /etc/skel/.bashrc; $(: auto complete for tldr) \
#
# fuzzy finder
cd /opt; \
[ -d fzf ] && rm -rf fzf; \
wget https://github.com/junegunn/fzf/archive/master.zip; \
unzip -o master.zip; \
rm master.zip; \
mv fzf-master fzf; \
cd fzf; \
find . -type f -exec dos2unix {} \; ; $(: just in case) \
echo -e "n\nn\nn\n" |./install; $(: answer no to the three questions asked) \
#
# cleanup
unset URL; \
unset CMD; \
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
