#!/bin/sh

echo 'Fetching remote npm packages'
export NODE_OPTIONS="--openssl-legacy-provider"

apt-get update
apt-get install -y git

yarn
