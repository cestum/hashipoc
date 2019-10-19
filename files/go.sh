#!/bin/bash

set -e

GO_VERSION=1.13.1
GO_ARCH=linux-amd64
GO_TGZ=go${GO_VERSION}.${GO_ARCH}.tar.gz
GO_TGZ_FLAG=go${GO_VERSION}.${GO_ARCH}.valid

echo "Getting go"
cd /tmp
if test -e "$GO_TGZ_FLAG"
then zflag="-z $GO_TGZ_FLAG"
else zflag=
fi
curl -s $zflag -R -O https://dl.google.com/go/$GO_TGZ 

echo "Installing go to /usr/local/go"
rm -rf /usr/local/go
tar -C /usr/local -xzf /tmp/$GO_TGZ

# Only create the flag file if we've successfully extracted the tarball.
touch -r $GO_TGZ $GO_TGZ_FLAG

perl -i -p -e 'if ( /^PATH=(.+)/ ) { $seen++; chomp; $_ .= ":/usr/local/go/bin\n"; } END{ $seen || print q[PATH=$PATH:/usr/local/go/bin], "\n" } ' /etc/environment


