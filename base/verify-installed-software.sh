#
# Test Script for Base layer
#


# Test everything installed in the Dockerfile

# packages installed in layer 1
# for some packages without real commands, just verify package is installed
checkInstall "tzdata";
checkInstall "libxtst6";
checkInstall "locales";

mkdir /run/sshd;
checkCommand 'openssh-server' 'sshd -t';

checkInstall "xauth";

checkInstall "ca-certificates";

checkCommand 'gnupg' 'gpg --gen-random 1 2';

cmd="rsync"; checkCommand "$cmd" '$cmd --list-only $csv';

checkCommand 'dbus-x11' 'dbus-launch';

checkInstall 'at-spi2-core';

# not sure how to make yank-cli not require keyboard input during actual usage
checkCommand 'yank' 'yank-cli -v';

checkInstall "xclip";

cmd='httping'; checkCommand "$cmd" '$cmd -c 1 -l https://github.com';

cmd='ping'; checkCommand "$cmd" '$cmd -c 1 github.com';

cmd='busybox'; checkCommand "$cmd" '$cmd echo "foo"';

cmd='less'; checkCommand "$cmd" 'echo "foo" |$cmd -F';

# can't really check an individual command from because if it's
# not installed, they'd probably succeed due to busybox and/or toybox
checkInstall 'coreutils';

cmd='tree'; checkCommand "$cmd" '$cmd .';

# can't really check an individual command from because if it's
# not installed, they'd probably succeed due to busybox and/or toybox
checkInstall 'diffutils';

cmd='colordiff'; checkCommand "$cmd" '$cmd <(echo "foo") <(echo "foo")';

checkInstall 'bash';
checkInstall 'bash-completion';

cmd='perl'; checkCommand "$cmd" '$cmd -e "print;"';

cmd='zip'; checkCommand "$cmd" 'echo "foo" |$cmd -q';

checkInstall 'neovim';

cmd='tmux'; checkCommand "$cmd" '$cmd -c exit';

checkInstall 'ncurses-term';

cmd='sudo'; checkCommand "$cmd" '$cmd echo';

xslt='
<xsl:stylesheet
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     version="1.0">
	<xsl:template match="*">
		<xsl:copy/>
	</xsl:template>
</xsl:stylesheet>';
xml='<a>foo</a>';
cmd='xsltproc'; checkCommand "$cmd" '$cmd <(echo "$xslt") <(echo "<a>foo</a>")';

json='{"a":1}';
cmd='jq'; checkCommand "$cmd" 'echo "$json" | jq "."';

cmd='wget'; checkCommand "$cmd" '$cmd -q --spider https://github.com';

cmd='curl'; checkCommand "$cmd" '$cmd -s https://github.com';

checkInstall 'meld'; # headless system; no GUI

cmd='parallel'; checkCommand "$cmd" '$cmd echo ::: A B C';

cmd='ministat'; checkCommand "$cmd" 'echo -e "1 2\n3 4\n5 6" | $cmd';

checkCommand 'imagemagick' 'convert -size 1x1 canvas:white null:';

cmd='gnuplot'; checkCommand "$cmd" 'echo -e "set term eps\nplot x" | $cmd';

pdf='test.pdf';
# short but valid PDF file, courtesy of https://stackoverflow.com/a/17280876
cat <<'EOF' > "$pdf"
%PDF-1.0
1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj 2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj 3 0 obj<</Type/Page/MediaBox[0 0 3 3]>>endobj
trailer<</Size 4/Root 1 0 R>>
EOF
checkCommand 'poppler-utils' 'pdfinfo $pdf';

cmd='ddgr'; checkCommand "$cmd" '$cmd --noprompt $cmd';

# don't know how to test interactively
cmd='nnn'; checkCommand "$cmd" '$cmd -V';

cmd='lynx'; checkCommand "$cmd" '$cmd --dump https://duckduckgo.com';

cmd='sc'; checkCommand "$cmd" 'echo "let A0 = 1" | $cmd -P %';

checkInstall 'rxvt-unicode'; # headless system; no GUI

# no command, just files
checkInstall 'fonts-dejavu';

checkInstall 'apvlv'; # headless system; no GUI




# software installed in layer 2

cmd='toybox';  checkCommand "$cmd" '$cmd echo';
cmd='bitwise'; checkCommand "$cmd" '$cmd 123';
cmd='ripgrep'; checkCommand "$cmd" 'rg a $csv';
cmd='xsv';     checkCommand "$cmd" '$cmd select b $csv';

json='{"foo": {"bar":"baz"}, "num":123}';
cmd="gron";    checkCommand "$cmd" 'echo $json | $cmd';

cmd="trdsql";  checkCommand "$cmd" '$cmd -driver sqlite3 -icsv -ih -oat "select c,b from $csv" && ls /etc/skel/.config/$cmd/config.json';

cmd="bat";     checkCommand "$cmd" '$cmd $csv';
cmd="fd";      checkCommand "$cmd" '$cmd $csv';
cmd="hexyl";   checkCommand "$cmd" '$cmd $csv';

# not sure how to throw keystrokes at this application
# or how to snag the screen...
cmd="hecate";  checkCommand "$cmd" 'TERM=xterm "$cmd" "$csv" & kill %1;'

cmd="vimrc";   checkCommand "$cmd" 'dir=/etc/profile.d/vim_runtime; ls $dir/*${cmd}* && ls $dir/zz*';
cmd=".tmux";   checkCommand "$cmd" '[ -f "$(realpath /etc/skel/${cmd}.conf)" ] && grep "os_clipboard=true" /etc/skel/${cmd}.conf.local';
cmd="powerline fonts"; checkCommand "$cmd" 'ls /usr/share/fonts/truetype/dejavu/*owerline*';
cmd="tldr";    checkCommand "$cmd" '$cmd $cmd && grep "^complete.*$(q=.*<<<.*##.*$cmd" /etc/skel/.bashrc';

cmd='fzf';     checkCommand "$cmd" '$cmd --version';

# spot-check files copied in
cmd='nix-nice'; checkCommand "$cmd" 'readlink /opt/$cmd/bin/gethost.sh';

# cleanup
rm "$csv" "$pdf";
