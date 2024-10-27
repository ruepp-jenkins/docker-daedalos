#!/bin/bash
set -e
echo "Starting build workflow"

scripts/docker_initialize.sh
scripts/git.sh

# run build
echo "[${BRANCH_NAME}] Building image: ${IMAGE_FULLNAME}"
if [ "$BRANCH_NAME" = "master" ] || [ "$BRANCH_NAME" = "main" ]
then
    docker build \
        -t ${IMAGE_FULLNAME}:latest \
        --push ./repo/
else
    docker build \
        -t ${IMAGE_FULLNAME}-test:${BRANCH_NAME} \
        --push ./repo/
fi

# cleanup
scripts/docker_cleanup.sh
