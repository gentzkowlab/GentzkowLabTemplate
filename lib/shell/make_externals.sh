#!/bin/bash   
set -e

MAKE_EXTERNALS_SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
REPO_ROOT=$(realpath "$MAKE_EXTERNALS_SCRIPT_DIR/../../")

source "${REPO_ROOT}/local_env.sh"

# Check if there are valid paths in local_env
create_links=false
for target_path in "${EXTERNAL_PATHS[@]}"; do
    if [ -d "$target_path" ]; then
        create_links=true
        break
    fi
done

# Create the 'externals' folder if there are links to create
if [ "$create_links" = true ]; then
    mkdir -p "${REPO_ROOT}/externals"

    # Loop through the EXTERNAL_NAMES and EXTERNAL_PATHS arrays and create symlinks
    for i in "${!EXTERNAL_NAMES[@]}"; do
        name="${EXTERNAL_NAMES[$i]}"
        target_path="${EXTERNAL_PATHS[$i]}"
        
        if [ -d "$target_path" ]; then
            ln -sfn "$target_path" "${REPO_ROOT}/externals/$name"
            echo -e "\nSymlink created for $name -> $target_path"
        else
            echo -e "\033[0;31mWarning\033[0m: Target path $target_path does not exist for $name"
        fi
    done
else
    echo -e "\n\033[0;34mNote:\033[0m There were no external input links to create in \033[0;34mlocal_env.sh\033[0m."
fi
