#!/bin/bash
URL="http://dl.bintray.com/smira/aptly/0.5/debian-squeeze-x64/aptly"

# Fetch aptly
(mkdir -p bin && curl -L -o bin/real_aptly $URL && chmod +x bin/real_aptly)
