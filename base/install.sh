#!/bin/sh

# Install and configure the software for this layer.


# Let the Dockerfile do most of the work
sed '1,/SOFTWARE INSTALL START/d;
     /SOFTWARE INSTALL END/,$d;
     /^#/d;' Dockerfile > /tmp/install$$;
/bin/sh /tmp/install$$;
rm /tmp/install$$;

# Now overlay our filesystem
cp -a filesystem/* /;

echo "INSTALLATION COMPLETE." |sed 's/./& /g;';
