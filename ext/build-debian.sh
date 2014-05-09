#!/bin/sh
if ! [ -d ext ]; then
    echo "This script must be run from the repository root"
    exit 1
fi

NAME=ruby-aptly
VER=0.1.0

mkdir -p $NAME-$VER
cp -R lib $NAME-$VER
cp -R ext/debian $NAME-$VER
tar czf "${NAME}_${VER}.orig.tar.gz" $NAME-$VER
(cd $NAME-$VER; dpkg-source -b .)
