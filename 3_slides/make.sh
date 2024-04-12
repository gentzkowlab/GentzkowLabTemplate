#!/bin/bash   
set -e

# Set paths
# (Make sure REPO_ROOT is set to point to the root of the repository!)
MAKE_SCRIPT_DIR=$(dirname "$(realpath "$0")")
REPO_ROOT=$(realpath "$MAKE_SCRIPT_DIR/../")
MODULE=$(basename "$MAKE_SCRIPT_DIR")
LOGFILE="${MAKE_SCRIPT_DIR}/output/make.log"

# Tell user what we're doing
echo -e "\n\nMaking \033[35m${MODULE}\033[0m module with shell: ${SHELL}"

# Check setup; load settings & tools
source "${REPO_ROOT}/lib/shell/check_setup.sh"
source "${REPO_ROOT}/local_env.sh"
source "${REPO_ROOT}/lib/shell/run_latex.sh"

(
    cd "${MAKE_SCRIPT_DIR}"

    # Clear output directory
    rm -rf output
    mkdir -p output

    # Copy and/or symlink inputs to local directory
    # (Make sure this section is updated to pull in all needed input files!)
    rm -rf input
    mkdir -p input
    find "${REPO_ROOT}/2_analysis/output" -type f -exec cp {} input/ \;

    # Run programs in order
    cd source
    run_latex my_project_slides.tex ../output "${LOGFILE}"

) 2>&1 | tee "${LOGFILE}"

# Define the input and output directories
SLIDES_SOURCE=${REPO_ROOT}/extensions/powerpoint

# Uncomment these lines if you want to convert the PowerPoint files in 3_slides/source into PDFs 
echo "Converting .pptx to .pdf"
${SLIDES_SOURCE}/run_pptx.sh