FROM ubuntu:18.10

LABEL about="Generic Ubuntu-based Linux environment"
LABEL features="meld, neovim, ripgrep, tmux, trdsql, xsv, bat, fzf"
LABEL access="SSH, key authentication, X11 forwarding"
LABEL maintainer="jetzerb@sva.com"

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
	locales               $(: so we speak the right language) \
	openssh-server        $(: so we can connect to our container via SSH) \
	xauth                 $(: facilitates X11 forwarding in SSH) \
	ca-certificates       $(: required to safely download files from the internet) \
	gnupg                 $(: for managing cryptographic keys) \
	rsync                 $(: so we can sync between Linux and Windows filesystems) \
	dbus-x11              $(: so apps like Meld can persist their preferences) \
	at-spi2-core          $(: prevent "Error retrieving accessibility bus" warnings in gtk apps) \
	xclip                 $(: clipboard manager for X) \
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
	sudo                  $(: let the users play--this is just a container) \
#
# additional tools
	xsltproc              $(: to manipulate XML) \
	jq                    $(: to manipulate JSON) \
	wget                  $(: download files from the internet) \
	curl                  $(: download files from the internet) \
	meld                  $(: visual merge/diff tool) \
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
# For whatever reason, installing busybox on Ubuntu doesn't create symlinks
# so do it here
echo "Creating busybox links:"; \
busybox --list | \
while read CMD; \
do \
	RESULT="$(type $CMD 2>&1)"; \
	if [ "$RESULT" != "${RESULT%*not found*}" ]; \
	then \
		echo "	$CMD"; \
		ln -s /bin/busybox /bin/$CMD; \
	fi; \
done; \
#
# ToyBox and BusyBox don't overlap completely, so add both
mkdir -p /opt/toybox/bin; \
cd /opt/toybox/bin; \
wget -O toybox http://landley.net/toybox/bin/toybox-x86_64; \
chmod +x toybox; \
echo "Creating toybox links:"; \
for CMD in $(./toybox --long); \
do \
	RESULT="$(type ${CMD##*/} 2>&1)"; \
	if [ "$RESULT" != "${RESULT%*not found*}" ]; \
	then \
		echo "	$CMD"; \
		ln -s /opt/toybox/bin/toybox /$CMD; \
	fi; \
done; \
#
# prep area for additional downloads that don't exist in the Ubuntu package repositories
mkdir -p /tmp/install; \
#
# Install ripgrep
# rg > ag > ack > grep
cd /tmp/install; \
URL=https://github.com/BurntSushi/ripgrep/releases; \
wget $(wget -O - "$URL" |sed -n '/href=".*ripgrep.*amd64\.deb"/ {s!.*href="\([^"]*\)".*!https://github.com\1!; p;}' |head -1;); \
dpkg -i ripgrep*.deb; \
#
# Install xsv (parse delimited files)
cd /tmp/install; \
mkdir -p /opt/xsv/bin; \
URL=https://github.com/BurntSushi/xsv/releases; \
wget $(wget -O - "$URL" |sed -n '/href=".*xsv.*x86.*64.*linux.*gz"/ {s!.*href="\([^"]*\)".*!https://github.com\1!; p;}' |head -1;); \
tar -xzf xsv*.gz; \
mv xsv /opt/xsv/bin; \
#
# Install trdsql (parse a variety of file types using SQL)
cd /tmp/install; \
mkdir -p /opt/trdsql/bin; \
URL=https://github.com/noborus/trdsql/releases; \
wget $(wget -O - "$URL" |sed -n '/href=".*trdsql.*linux.*64.*zip"/ {s!.*href="\([^"]*\)".*!https://github.com\1!; p;}' |head -1;); \
unzip -o trdsql*.zip; \
cd trdsql*linux*; \
mv trdsql /opt/trdsql/bin/; \
mv README.md /opt/trdsql/; \
mkdir -p /etc/skel/.config/trdsql; \
mv config.json.sample /etc/skel/.config/trdsql/config.json; \
#
# Install bat (pager w/syntax highlighting and git integration; can be used as replacement for cat)
# Install hexyl (colorized hex dump utility)
cd /tmp/install; \
for CMD in bat hexyl; do \
	URL=https://github.com/sharkdp/$CMD/releases; \
	wget $(wget -O - "$URL" |sed -n '/href=".*'$CMD'.*amd64\.deb"/ {s!.*href="\([^"]*\)".*!https://github.com\1!; p;}' |head -1;); \
	dpkg -i ${CMD}*.deb; \
done; \
#
# One can never have too many hex editors.
cd /tmp/install; \
URL=https://github.com/evanmiller/hecate/releases; \
wget $(wget -O - "$URL" |sed -n '/href=".*hecate.*amd64\.deb"/ {s!.*href="\([^"]*\)".*!https://github.com\1!; p;}' |head -1;); \
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
wget $(wget -O - "$URL" |sed -n '/href=".*Mono.*ttf"/ {s!.*href="\([^"]*\)".*!https://github.com\1!; s!/blob/!/raw/!; p;}'); \
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
ENTRYPOINT ["/usr/local/sbin/container-startup.sh"]
CMD ["-epus"]
