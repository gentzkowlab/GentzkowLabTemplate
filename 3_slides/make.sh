#!/bin/bash   
set -e

# User-defined constants
REPO_ROOT=$(git rev-parse --show-toplevel)
LIB=${REPO_ROOT}/lib/shell
LOGFILE=output/make.log

# Load local environment and shell commands
source ${REPO_ROOT}/local_env.sh
source ${LIB}/run_latex.sh

# Remove previous output
rm -rf output
rm -f ${LOGFILE}
mkdir -p output

# Copy inputs from data:
rm -rf input
cp -r ${REPO_ROOT}/1_data/output input

# Tell user what we're doing
MODULE=$(basename "$PWD")
echo -e "\n\nMaking \033[35m${MODULE}\033[0m module with shell: ${SHELL}"

# Run LaTeX compilation
(
    cd source 
    run_latex my_project_slides.tex ../$LOGFILE ../output
) 2>&1 | tee ${LOGFILE}

# Define the input and output directories
SLIDES_SOURCE=${REPO_ROOT}/extensions/powerpoint

# Uncomment these lines if you want to convert the PowerPoint files in 3_slides/source into PDFs 
echo "Converting .pptx to .pdf"
${SLIDES_SOURCE}/run_pptx.sh