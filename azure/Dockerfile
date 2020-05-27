# Base layer
FROM jetzerb/nix-nice:dev-latest

# Container attributes...
LABEL about="Ubuntu-Based Linux Environment for Azure DevOps users"
LABEL features="nix-nice dev, plus azure CLI with DevOps extension, and Azure Data Studio"
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
echo "Nix-Nice Azure Manifest:" |sed 'h; s/./-/g; p; x;' >> $MANIFEST; \
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
#
# Azure CLI pre-requisites
P="$P libffi-dev"; \
#
# Azure Data Studio pre-requisites
P="$P libxss1"; \
P="$P libgconf-2-4"; \
P="$P libunwind8"; \
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
mkdir -p $TMP; \
#
# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash; \
#
#
# Azure Data Studio
# (scrape the download page to make sure we get the latest version)
cd $TMP; \
CMD=azuredatastudio; \
lynx --dump https://docs.microsoft.com/en-us/sql/azure-data-studio/download > download_page; \
wget -nv -O ${CMD}.deb $( \
	awk '/\[[0-9]+\]\.deb/ {gsub("[^0-9]",""); LINK="^ +" $0 "\. https";} \
	     /^References$/ {INREFS=1;} \
	     INREFS == 1 && $0 ~ LINK {print $2;}' download_page); \
dpkg -i ${CMD}.deb; \
dpkg -l $CMD >> $MANIFEST; \
#
#
# remove package lists to trim > 20MB of cruft
rm -rf /var/lib/apt/lists/*; \
#
# clean up after software downloads
cd /tmp; \
rm -rf $TMP; \
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
