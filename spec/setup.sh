#!/bin/bash
URL="http://dl.bintray.com/smira/aptly/0.5/debian-squeeze-x64/aptly"

# Fetch aptly
(mkdir -p bin && curl -OL $URL -o bin/real_aptly && chmod +x bin/real_aptly)
