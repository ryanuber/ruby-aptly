#!/bin/bash
APTLY_URL="http://dl.bintray.com/smira/aptly/0.5/debian-squeeze-x64/aptly"

# Fetch aptly
(mkdir -p bin && cd bin && curl -OL $APTLY_URL && chmod +x aptly) || exit 1

# Make some phony packages
mkdir -p pkgs
for i in {1..10}; do
    (cd pkgs && fpm -s empty -t deb --version 1.0.$i --iteration $i --name pkg$i)
done
