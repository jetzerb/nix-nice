# Base layer
FROM jetzerb/nix-nice:dev-latest

# Container attributes...
LABEL about="Ubuntu-Based Linux Environment for Azure DevOps users"
LABEL features="nix-nice dev, plus azure CLI with DevOps extension"
LABEL access="SSH, key authentication, X11 forwarding"
LABEL maintainer="jetzerb@sva.com"

RUN \
#
# SOFTWARE INSTALL START
#
# No prepackaged software.
#
# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash; \
#
# Now the DevOps extension
az extension add --name azure-devops; \
#
#
# remove package lists to trim > 20MB of cruft
rm -rf /var/lib/apt/lists/*; \
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
