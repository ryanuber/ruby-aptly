#!/bin/bash
cat > /dev/stdout <<EOF
List of local repos:
 * [repo1] (packages: 90)
 * [repo2] (packages: 231)

To get more information about local repository, run \`aptly repo show <name>\`.
EOF
exit 0
