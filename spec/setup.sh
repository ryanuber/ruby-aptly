#!/bin/bash
URL="http://dl.bintray.com/smira/aptly/0.5/debian-squeeze-x64/aptly"

# Fetch aptly
if [ ! -x bin/real_aptly ]; then
    (mkdir -p bin && curl -L -o bin/real_aptly $URL && chmod +x bin/real_aptly)
fi

# Add Aptly repo GPG keys
gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver keys.gnupg.net \
    --recv-keys 2A194991
