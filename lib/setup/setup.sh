#!/bin/bash

SETUP_SCRIPT_DIR=$(dirname "$(realpath "$0")")
REPO_ROOT=$(realpath "$SETUP_SCRIPT_DIR/../../")

# Check if local_env.sh exists
if [ ! -f "${REPO_ROOT}/local_env.sh" ]; then
    echo "The file local_env.sh was not found at the root of the repository."
    echo "I will create it from /lib/setup/local_env_template.sh."
    echo "Please edit this file to reflect your local executables and external file paths."
    cp "${REPO_ROOT}/lib/setup/local_env_template.sh" "${REPO_ROOT}/local_env.sh"
fi

# Find all modules (directory that contains 'make.sh'), skipping the examples directory
find "$REPO_ROOT" -path "$REPO_ROOT/examples" -prune -o -type f -name 'make.sh' -print0 | 
sort -z |
while IFS= read -r -d '' make_file; do

    module_dir=$(dirname "$make_file")
    module_name=$(basename "$module_dir")
    echo -e "\nProcessing module \033[35m${module_name}\033[0m"

    get_inputs_script="$module_dir/get_inputs.sh"

    # Check if 'get_inputs.sh' exists and run it
    if [[ -f "$get_inputs_script" ]]; then
        source "$get_inputs_script"
    else
        echo "Warning: $get_inputs_script not found. Skipping."
    fi
done

# Optional: Create external symlinks
# Uncomment the following line if you need to handle external paths
# source "${REPO_ROOT}/lib/shell/make_externals.sh"

# Setup Completed
echo -e "\nSetup complete."

