::
:: Sample container startup script for launching a nix-nice container
:: on Windows.
::
:: Fill in your own values for the variables
::

::
:: Ensure the existence of a docker volume for users' home directories
:: so that their data persists between container restarts.
docker volume create userdata

:: remember the current directory
set CURDIR=%CD%

:: find base directory for users on this host (to be mounted as /hosthome
:: within the container)
cd /d %USERPROFILE%
cd ..

::
:: Launch the container...
:: Modify the values for Timezone, Locale, & main Git URL as appropriate.
:: Choose whatever port you want to use for ssh.
:: Use whatever host & container name you want.
:: Specify the nix-nice edition (base, dev, etc)
:: And pass in whatever commandline switches you like
::   -e = process environment variables (MYTZ, ...)
::   -u = create users based on hosthome volume mount
::   -s = Start Services (ssh, dbus...)
docker run --detach ^
	-e "MYTZ=America/Chicago" ^
	-e "MYLOCALE=en_US.utf8" ^
	-e "MYGITURL=https://dev.azure.com/SOMEVALUE" ^
	--mount type=bind,source=%CD%,target=/hosthome ^
	--mount type=volume,source=userdata,target=/home ^
	-p 9922:22 ^
	-h nix-nice ^
	--name nix-nice ^
	jetzerb/nix-nice:SOMEVALUE-latest ^
	-eus

cd %CURDIR%
