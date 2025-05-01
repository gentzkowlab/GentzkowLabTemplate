#!/bin/bash   
set -e

# Check if REPO_ROOT is set
if [ -z "${REPO_ROOT}" ]; then
    MAKE_EXTERNALS_SCRIPT_DIR="$(cd "$(dirname -- "$0")" && pwd -P)"
    REPO_ROOT="$(cd "$MAKE_EXTERNALS_SCRIPT_DIR/../../" && pwd -P)"
fi

source "${REPO_ROOT}/local_env.sh"

# Determine array starting index
if [ -n "${EXTERNAL_NAMES[0]}" ]; then
    array_start_index=0
else
    array_start_index=1
fi

# Check if there are valid paths in local_env
create_links=false
array_length=${#EXTERNAL_NAMES[@]}
i=$array_start_index
while [ "$i" -lt "$((array_start_index + array_length))" ]; do
    name="${EXTERNAL_NAMES[$i]}"
    target_path="${EXTERNAL_PATHS[$i]}"

    if [ -n "$name" ]; then
        if [ -d "$target_path" ]; then
            create_links=true
            break
        fi
    fi
    i=$((i + 1))
done

# Create the 'external' folder if there are links to create
if [ "$create_links" = true ]; then
    mkdir -p "${REPO_ROOT}/external"
fi

# Loop through the EXTERNAL_NAMES and EXTERNAL_PATHS arrays and create symlinks
i=$array_start_index
while [ "$i" -lt "$((array_start_index + array_length))" ]; do
    name="${EXTERNAL_NAMES[$i]}"
    target_path="${EXTERNAL_PATHS[$i]}"

    if [ -n "$name" ]; then
        if [ -d "$target_path" ]; then
            ln -sfn "$target_path" "${REPO_ROOT}/external/$name"
            printf "\nSymlink created for %s -> %s\n" "$name" "$target_path"
        else
            printf "\033[0;31mWarning\033[0m: Target path '%s' does not exist for %s\n" "$target_path" "$name"
        fi
    fi
    i=$((i + 1))
done


if [ "$create_links" = false ]; then
    printf "\n\033[0;34mNote:\033[0m No external input links were created in \033[0;34mlocal_env.sh\033[0m.\n"
fi
