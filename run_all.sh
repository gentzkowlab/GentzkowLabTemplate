#!/bin/bash   

# Trap to handle shell script errors 
trap 'error_handler' ERR
error_handler() {
    error_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\n\033[0;31mWarning\033[0m: run_all.sh failed at ${error_time}. Check above for details." # display warning in terminal
    exit 1 # early exit with error code
}

# Replace with name of your project
PROJECT_NAME="template"

# Tell user what we're doing
echo -e "Making \033[35m${PROJECT_NAME}\033[0m with shell: ${SHELL}"

# Run makefiles of each module
${SHELL} 1_data/make.sh
${SHELL} 2_analysis/make.sh
${SHELL} 3_slides/make.sh
${SHELL} 4_paper/make.sh

