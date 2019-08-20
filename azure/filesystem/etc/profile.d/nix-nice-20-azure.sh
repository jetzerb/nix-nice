#
# additional config/setup to perform at login
#
# Note: Linux's /etc/profile will source all scripts ending in ".sh"
# under /etc/profile.d, so put this script there
#
#


# The Azure CLI does things a little differently.  It has a "bin" directory,
# but apparently we're not supposed to use it.  Upon installation, it creates
# /usr/bin/az, so strip /opt/az/bin out of our PATH so we use the right one.
export PATH=$(echo $PATH |sed 's!/opt/az/bin:!!;');
