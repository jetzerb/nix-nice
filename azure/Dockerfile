# Base layer
FROM jetzerb/nix-nice:dev-latest

# Container attributes...
LABEL about="Ubuntu-Based Linux Environment for Azure DevOps users"
LABEL features="nix-nice dev, plus azure CLI with DevOps extension"
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
# Azure Data Studio pre-requisites
	libxss1 \
	libgconf-2-4 \
	libunwind8 \
; \


#
# Second layer = additional apps
#

RUN \
#
# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash; \
#
# Now the DevOps extension to Azure CLI
az extension add --name azure-devops; \
#
#
# Azure Data Studio (the new SSMS)
# (scrape the download page to make sure we get the latest version)
mkdir -p /tmp/install; \
cd /tmp/install; \
lynx --dump https://docs.microsoft.com/en-us/sql/azure-data-studio/download > download_page; \
wget -O ads.deb $( \
	awk '/\[[0-9]+\]\.deb/ {gsub("[^0-9]",""); LINK="^ +" $0 "\. https";} \
	     /^References$/ {INREFS=1;} \
	     INREFS == 1 && $0 ~ LINK {print $2;}' download_page); \
dpkg -i ads.deb; \
#
#
# remove package lists to trim > 20MB of cruft
rm -rf /var/lib/apt/lists/*; \
#
# clean up the tmp dir
cd /tmp; \
rm -rf install; \
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
