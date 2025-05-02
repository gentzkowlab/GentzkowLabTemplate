#!/bin/bash

# Check if REPO_ROOT is set
if [ -z "${REPO_ROOT}" ]; then
    CHECK_SETUP_SCRIPT_DIR="$(cd "$(dirname -- "$0")" && pwd -P)"
    REPO_ROOT="$(cd "$CHECK_SETUP_SCRIPT_DIR/../../" && pwd -P)"
fi

# Check if local_env.sh exists
if [ ! -f "${REPO_ROOT}/local_env.sh" ]; then
    echo "The file local_env.sh was not found at the root of the repository."
    echo "I will create it from /lib/setup/local_env_template.sh."
    cp "${REPO_ROOT}/lib/setup/local_env_template.sh" "${REPO_ROOT}/local_env.sh"
fi

# Check if run_all.sh exists and will provide a warning, not error
if [ ! -f "${REPO_ROOT}/run_all.sh" ]; then
    echo "The file run_all.sh does not exist in the directory currently specified"
    echo "in the variable REPO_ROOT. This may mean that REPO_ROOT in your make.sh"
    echo "script is set incorrectly. It should be a relative path pointing"
    echo "to the top level of the repository."
fi

# Optional: Check that Git LFS is installed
# Uncomment the lines below if you'd like to activate Git LFS for this project
# if ! which git-lfs > /dev/null; then
#   echo "Warning: It looks like Git Large File Storage (LFS) is not installed."
#   echo "You should install it before using this repository to make sure that"
#   echo "large files are handled correctly. See https://git-lfs.com/ for more"
#   echo "information."
# fi

# Add other checks as needed


# Setup Completed
echo "Setup check complete."

