#!/bin/bash

ppt_file="$1"
output_dir="$2"

osascript export_pptx_to_pdf.scpt "$ppt_file" "$output_dir/slides.pdf"
