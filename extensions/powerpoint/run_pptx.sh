#!/bin/bash

# Get the root directory of the git repository
REPO_ROOT=$(git rev-parse --show-toplevel)

# Define the input and output directories
SLIDES_SOURCE=${REPO_ROOT}/3_slides/source
SLIDES_OUTPUT=${REPO_ROOT}/3_slides/output
EXTENSION=${REPO_ROOT}/extensions/powerpoint

# Define the output directory
output_dir=${SLIDES_OUTPUT}

# Iterate over each pptx file in the SLIDES directory
for ppt_file in ${SLIDES_SOURCE}/*.pptx; do
    if [ -e "$ppt_file" ]; then
        # Call the script to convert pptx to pdf
        osascript ${EXTENSION}/run_pptx.scpt "$ppt_file" "${output_dir}/$(basename "$ppt_file" .pptx).pdf"
    fi
done
