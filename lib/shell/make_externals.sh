#!/bin/bash   
set -e

MAKE_EXTERNALS_SCRIPT_DIR=$(dirname "$(realpath "$0")")
REPO_ROOT=$(realpath "$MAKE_EXTERNALS_SCRIPT_DIR/../")

source "${REPO_ROOT}/local_env.sh"

# Create the 'externals' folder in the current directory if it doesn't exist
mkdir -p externals

# Loop through the EXTERNAL_NAMES and EXTERNAL_PATHS arrays and create symlinks
for i in "${!EXTERNAL_NAMES[@]}"; do
    name="${EXTERNAL_NAMES[$i]}"
    target_path="${EXTERNAL_PATHS[$i]}"
    
    if [ -d "$target_path" ]; then
        ln -sfn "$target_path" "externals/$name"
        echo "Symlink created for $name -> $target_path"
    else
        echo "\033[0;31mWarning\033[0m: Target path $target_path does not exist for $name"
    fi
done