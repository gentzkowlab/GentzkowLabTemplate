#!/bin/bash

SCRIPT_ABSOLUTE_PATH=$(realpath "$0")
REPO_ROOT=$(realpath "$SCRIPT_ABSOLUTE_PATH/../../")

# Check if local_env.sh exists
if [ ! -f "${REPO_ROOT}/local_env.sh" ]; then
    echo "The file local_env.sh was not found at the root of the repository. This is a local settings file that must exist in order for make.sh to run. Please run the script setup.sh at the root of the repository to create local_env.sh and set up the local environment."
    exit 1
fi

# Check if run_all.sh exists and will provie a warning, not error
if [ ! -f "${REPO_ROOT}/run_all.sh" ]; then
    echo "The file run_all.sh does not exist in the directory currently specified as the repository root. This may mean that the variable REPO_ROOT in make.sh is set incorrectly. The variable REPO_ROOT should be a relative path pointing to the top level of the repository."
fi

# Add other checks as needed

