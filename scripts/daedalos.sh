#!/bin/bash
set -e
echo "Preparing DeadalOS"

echo "Switching node version to latest alpine"
sed -i '0,/^FROM/{s/^FROM.*/FROM node:22-alpine/}' Dockerfile
