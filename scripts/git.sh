#!/bin/bash
set -e
echo "Initialize docker"

mkdir -p repo
rm -rf repo

git clone https://github.com/DustinBrett/daedalOS.git repo