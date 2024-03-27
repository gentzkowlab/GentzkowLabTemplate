#!/bin/bash

ppt_file="/Users/shrishjanarthanan/Desktop/SIEPR/GentzkowLabTemplate/slides.pptx"
output_dir="/Users/shrishjanarthanan/Desktop/SIEPR/GentzkowLabTemplate"

if [ ! -d "$output_dir" ]; then
    echo "Error: Output directory '$output_dir' not found."
    exit 1
fi

osascript export_pptx_to_pdf.scpt "$ppt_file" "$output_dir/slides.pdf"

if [ -f "$output_dir/slides.pdf" ]; then
    echo "PDF saved successfully at $output_dir/slides.pdf"
else
    echo "Error: PDF file was not created."
fi
