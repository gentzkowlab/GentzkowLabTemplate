#!/bin/bash

# ==============================================================================
# Define your input paths here:
#   - Paths must be relative to the current module.
#   - Quote the string if it contains spaces.
#   - To rename the input symlink, add an arrow "->" followed by a link name.
#   - If no destination name is given, the original name is used.
#
# Examples:
#   - File:
#       ../examples/inputs_for_examples/mpg.csv
#   - Directory:
#       ../examples/inputs_for_examples
#   - Path with custom link name:
#       "../examples/inputs_for_examples -> examples"
# ==============================================================================
INPUT_FILES=(
    # /path/to/your/input/file.csv (replace with your actual input paths)
    # Add more input paths as needed
)

# Path to current module
MAKE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Remove existing input directory and recreate it
rm -rf "${MAKE_SCRIPT_DIR}/input"
mkdir -p "${MAKE_SCRIPT_DIR}/input"

# Variable to track if any links were created
links_created=false

# Loop through each mapping
for entry in "${INPUT_FILES[@]}"; do
  # Split into source and destination around "->"
  if [[ "$entry" == *"->"* ]]; then
    src_path=$(echo "$entry" | awk -F'->' '{print $1}' | xargs)
    dest_name=$(echo "$entry" | awk -F'->' '{print $2}' | xargs)
  else
    src_path=$(echo "$entry" | xargs)
    dest_name=$(basename "${src_path}")
  fi

  # Create link if the source exists
  if [[ -e "${MAKE_SCRIPT_DIR}/${src_path}" ]]; then
    ln -sfn "../${src_path}" "${MAKE_SCRIPT_DIR}/input/${dest_name}"
    echo "Linked: ${src_path} -> input/${dest_name}"
    links_created=true
  else
    echo -e "\033[0;31mWarning\033[0m in \033[0;34mget_inputs.sh\033[0m: '${src_path}' does not exist or is not a valid path." >&2
  fi
done

# Output the result
if [[ "$links_created" == true ]]; then
  echo -e "\nInput links were created!"
else
    echo -e "\n\033[0;34mNote:\033[0m There were no input links to create in \033[0;34mget_inputs.sh\033[0m."
fi
