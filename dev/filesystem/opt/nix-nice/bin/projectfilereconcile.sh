#!/bin/bash
set -euo pipefail;

# XSLT to dump out the list of files in a project
read -r -d '' XSLT <<'EOF' || true
<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:prj="http://schemas.microsoft.com/developer/msbuild/2003"
	xmlns:SSIS="www.microsoft.com/SqlServer/SSIS"
>

	<xsl:output method="text" omit-xml-declaration="yes" indent="no" />

	<!-- allow matching on attribute in addition to element -->
	<xsl:template match="/" >
		<xsl:apply-templates select="//@*" />
	</xsl:template>

	<!-- override the default template that prints all text -->
	<xsl:template match="text()|@*" />

	<!-- Output all filenames from selected attributes -->
	<xsl:template match="
		 prj:ItemGroup/prj:Build/@Include
		|prj:ItemGroup/prj:Compile/@Include
		|prj:ItemGroup/prj:Content/@Include
		|prj:ItemGroup/prj:EmbeddedResource/@Include
		|prj:ItemGroup/prj:None/@Include
		|prj:ItemGroup/prj:PreDeploy/@Include
		|prj:ItemGroup/prj:PostDeploy/@Include
		|prj:ItemGroup/prj:RefactorLog/@Include
		|prj:ItemGroup/prj:Report/@Include
		|SSIS:Package/@Name
		|SSIS:ConnectionManager/@Name
	" >
		<xsl:value-of select="translate(.,'\','/')" />
		<xsl:text>
</xsl:text>
		<xsl:apply-templates />
	</xsl:template>

</xsl:stylesheet>
EOF

#echo "$?"; echo "$XSLT"; # debugging...

# Now list all files on the filesystem and compare with the project file

# jump to top of the repo, and find all directories containing a project file
REPODIR=$(git rev-parse --show-toplevel);
cd "$REPODIR";
echo "Checking Project Files Under $REPODIR";
dirname $(find . -iname '*.*proj') 2>/dev/null |
sort -u |
while read -r DIR
do
	cd "$DIR";
	echo ${PWD#$REPODIR/};
	/bin/ls -1 | sed -n '/proj$/{s/^/  /;p;}';
	echo "    Cnt Filesystem                                                                                          Cnt Project File";
	sdiff -s -w 200\
		<(git ls-files | grep -v '\.[a-z]*proj$' |sort -f |uniq -c) \
		<(xsltproc <(echo "$XSLT") *.*proj |sort -f | uniq -c);
done
