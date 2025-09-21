#!/bin/sh

echo 'Fetching remote npm packages'
export NODE_OPTIONS="--openssl-legacy-provider"

apk add --no-cache git

yarn
