#!/bin/bash

# Get the root directory of the git repository
REPO_ROOT=$(git rev-parse --show-toplevel)

# Define the input and output directories
SLIDES_SOURCE=${REPO_ROOT}/5_pptx/source
SLIDES_OUTPUT=${REPO_ROOT}/5_pptx/output

# Define the output directory
output_dir=${SLIDES_OUTPUT}

# Iterate over each pptx file in the SLIDES directory
for ppt_file in ${SLIDES_SOURCE}/*.pptx; do
    if [ -e "$ppt_file" ]; then
        # Call the script to convert pptx to pdf
        osascript ${SLIDES_SOURCE}/run_pptx.scpt "$ppt_file" "${output_dir}/$(basename "$ppt_file" .pptx).pdf"
    fi
done
