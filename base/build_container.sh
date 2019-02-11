#!/bin/sh

IMG="nix-nice/${PWD##*/}:18.10.0";
echo "Building Image $IMG";

cat <<EOF > filesystem/etc/motd
================================================================================

                         Generic Ubuntu-based Linux Environment
                         Image: $IMG

                Container build date: $(date +"%F %T %z")

================================================================================
EOF

# ensure Linux line endings everywhere before copying into the image
for FILE in $(find filesystem -type f)
do
	dos2unix "$FILE";
	[ "${FILE##*.}" == "sh" ] && chmod 755 "$FILE";
done;

docker build -t nix-nice:$IMG .;

rm filesystem/etc/motd;
