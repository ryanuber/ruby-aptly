#!/bin/sh
NAME=ruby-aptly
VER=0.1.0

mkdir -p $NAME-$VER
cp -R lib $NAME-$VER
cp -R ext/debian $NAME-$VER
tar czf "${NAME}_${VER}.orig.tar.gz" $NAME-$VER
(cd $NAME-$VER; dpkg-source -b .)
pbuilder --build *.dsc
