#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)

ppt_file=${REPO_ROOT}/slides.pptx
output_dir=${REPO_ROOT}

osascript export_pptx_to_pdf.scpt "$ppt_file" "$output_dir/output.pdf"

