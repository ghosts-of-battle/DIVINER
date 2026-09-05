#!/usr/bin/env sh
# Builds ghostd_pacdb_x64.so, the Linux server's copy of the extension.
#
#   With Docker (any OS):        sh build-linux.sh
#   On a Linux box, no Docker:   sh build-linux.sh --native
#       needs the .NET 8 SDK, clang and zlib1g-dev (apt-get install clang zlib1g-dev)
#
# The result lands beside this script; copy it into the mod's root next to
# ghostd_pacdb_x64.dll (HEMTT ships both) or into the server's Arma root.
#
# BUILD ON AN OLD GLIBC. The library binds to the glibc it was built against
# and will not load on an older one: the Docker route uses the bullseye
# image (2.31); --native on Ubuntu 20.04 gives 2.29. Either runs on Debian
# 11 and 12 and Ubuntu 20.04 onward. A build on a newer box (Ubuntu 22.04
# binds 2.34) would refuse to load on Debian 11.
set -e
cd "$(dirname "$0")"
if [ "$1" = "--native" ]; then
    dotnet publish -c Release -r linux-x64 -o out-linux
    cp out-linux/ghostd_pacdb.so ./ghostd_pacdb_x64.so
else
    docker build -f Dockerfile.linux -t ghostd-pacdb-linux .
    id=$(docker create ghostd-pacdb-linux)
    docker cp "$id":/out/ghostd_pacdb_x64.so ./ghostd_pacdb_x64.so
    docker rm "$id" > /dev/null
fi
ls -l ghostd_pacdb_x64.so
