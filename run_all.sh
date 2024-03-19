#!/bin/bash   
set -e

# Replace with name of your project
PROJECT_NAME="template"

# Tell user what we're doing
echo -e "Making \033[35m${PROJECT_NAME}\033[0m with shell: ${SHELL}"

# Run makefiles of each module
${SHELL} 1_data/make.sh
${SHELL} 2_analysis/make.sh
${SHELL} 3_slides/make.sh
${SHELL} 4_paper/make.sh
