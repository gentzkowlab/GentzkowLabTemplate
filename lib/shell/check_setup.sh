#!/bin/bash

export REPO_ROOT_RELATIVE="../../"
REPO_ROOT=$(realpath "$REPO_ROOT_RELATIVE")
echo $REPO_ROOT

# Check if local_env.sh exists
if [ ! -f "${REPO_ROOT}/local_env.sh" ]; then
    echo "The file local_env.sh was not found at the root of the repository. This is a local settings file that must exist in order for make.sh to run. Please run the script setup.sh at the root of the repository to create local_env.sh and set up the local environment."
    exit 1
fi

# Add other checks as needed

