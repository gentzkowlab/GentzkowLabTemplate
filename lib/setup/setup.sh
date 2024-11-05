#!/bin/bash
set -e

SETUP_SCRIPT_DIR=$(dirname "$(realpath "$0")")
REPO_ROOT=$(realpath "$SETUP_SCRIPT_DIR/../../")

# Check if local_env.sh exists
if [ ! -f "${REPO_ROOT}/local_env.sh" ]; then
    echo "The file local_env.sh was not found at the root of the repository."
    echo -e "\n\033[0;34mPlease choose:\033[0m Would you like to create local_env.sh from /lib/setup/local_env_template.sh? (y/n): "
    read -r local_env_confirm
    if [[ "$local_env_confirm" != "y" ]]; then
        echo -e "\nOK. Please create local_env.sh and re-run this script."
        exit 1
    fi

    cp "${REPO_ROOT}/lib/setup/local_env_template.sh" "${REPO_ROOT}/local_env.sh"
    echo "local_env.sh has been created from the template."
    echo "Please edit it to reflect your local executables and external file paths."
    echo -e "Press \033[0;34mEnter\033[0m to continue after editing or re-run setup.sh once you've done so."
    read -p " "
    else
        echo -e "\033[0;34mNote:\033[0m: local_env.sh already exists."
fi

# Run get_inputs.sh scripts
echo -e "\n\033[0;34mPlease choose:\033[0m Would you like to run all get_inputs.sh scripts in the repository? (y/n): "
read -r get_inputs_confirm
if [[ "$get_inputs_confirm" == "y" ]]; then
    # Find all get_inputs.sh scripts
    find "$REPO_ROOT" -type f -name 'get_inputs.sh' -print0 |
    sort -z |
    while IFS= read -r -d '' get_inputs_script; do
        module_dir=$(dirname "$get_inputs_script")
        module_name=$(basename "$module_dir")
        echo -e "\nProcessing module \033[35m${module_name}\033[0m"
        source "$get_inputs_script"
    done
    echo -e "\nAll get_inputs.sh scripts have been run."

    else
        echo -e "\nOK. Skipping get_inputs.sh scripts."
fi

# Optional: Create external symlinks
source "${REPO_ROOT}/lib/shell/make_externals.sh"

# Setup Completed
echo -e "\nSetup complete."

