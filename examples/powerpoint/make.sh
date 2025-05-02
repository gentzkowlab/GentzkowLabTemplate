#!/bin/bash   
set -e

# Set paths
# (Make sure REPO_ROOT is set to point to the root of the repository!)
MAKE_SCRIPT_DIR="$(cd "$(dirname -- "$0")" && pwd -P)"
REPO_ROOT="$(cd "$MAKE_SCRIPT_DIR/../" && pwd -P)"
MODULE="$(basename "$MAKE_SCRIPT_DIR")"

# Tell user what we're doing
echo -e "\n\nMaking \033[35m${MODULE}\033[0m module with shell: ${SHELL}"

# Check setup; load settings & tools
source "${REPO_ROOT}/lib/shell/check_setup.sh"
source "${REPO_ROOT}/local_env.sh"

# Define the input and output directories
SLIDES_SHELL=${REPO_ROOT}/lib/shell

echo "Executing: run_pptx.sh"
${SLIDES_SHELL}/run_pptx.sh
