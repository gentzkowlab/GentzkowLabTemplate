#!/bin/bash

# Define your input file paths here
# Paths may be absolute or relative, depending on what the current working directory is. 
# For example, this is a relative path:
# examples/inputs_for_examples/mpg.csv
# And this is an absolute path:
# /Users/username/GentzkowLabTemplate/examples/inputs_for_examples/mpg.csv
INPUT_FILES=(
    /path/to/your/input/file.csv # replace with your actual input file paths
    # Add more input file paths as needed
)

# Path to current module
MAKE_SCRIPT_DIR=$(dirname "$0")

# Remove existing input directory and recreate it
rm -rf "${MAKE_SCRIPT_DIR}/input"
mkdir -p "${MAKE_SCRIPT_DIR}/input"

# Variable to track if any links were created
links_created=false

# Loop through the input file paths
for file_path in "${INPUT_FILES[@]}"; do
    if [[ -f "$file_path" ]]; then  # check if the file exists
      file_name=$(basename "$file_path")
      abs_path=$(realpath "$file_path")  # get absolute path
      ln -sf "$abs_path" "${MAKE_SCRIPT_DIR}/input/$file_name"  # create symlink
      links_created=true
    else
      echo -e "\033[0;31mError:\033[0m in \033[0;34mget_inputs.sh\033[0m: $file_path does not exist or is not a valid file path." >&2
    fi
done

# Output the result
if [[ "$links_created" == true ]]; then
  echo -e "\nAll input links were created!"
else
    echo -e "\n\033[0;34mNote:\033[0m There were no input links to create in \033[0;34mget_inputs.sh\033[0m."
fi
