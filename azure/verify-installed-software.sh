#
# Test Script for Azure layer
#


# Test everything installed in the Dockerfile
checkInstall "libffi-dev";
checkInstall "libxss1";
checkInstall "libgconf-2-4";
checkInstall "libunwind8";

cmd='az';              checkCommand "$cmd" '$cmd extension list';
cmd='azuredatastudio'; checkCommand "$cmd" '$cmd --user-data-dir=/tmp --list-extensions';
