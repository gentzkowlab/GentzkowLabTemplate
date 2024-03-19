#!/bin/bash   
set -e

# Set paths
# (Make sure REPO_ROOT is set to point to the root of the repository!)
MAKE_SCRIPT_DIR=$(dirname "$(realpath "$0")")
REPO_ROOT=$(realpath "$MAKE_SCRIPT_DIR/../")
MODULE=$(basename "$MAKE_SCRIPT_DIR")
LOGFILE=${MAKE_SCRIPT_DIR}/output/make.log

# Tell user what we're doing
echo -e "\n\nMaking \033[35m${MODULE}\033[0m module with shell: ${SHELL}"

# Check setup; load settings & tools
source ${REPO_ROOT}/lib/shell/check_setup.sh
source ${REPO_ROOT}/local_env.sh
source ${REPO_ROOT}/lib/shell/run_python.sh
source ${REPO_ROOT}/lib/shell/run_stata.sh
source ${REPO_ROOT}/lib/shell/run_R.sh

(
    cd ${MAKE_SCRIPT_DIR}

    # Clear output directory
    rm -rf output
    mkdir -p output

    # Copy and/or symlink inputs to local directory
	# (Make sure this section is updated to pull in all needed input files!)
    rm -rf input
    mkdir -p input
    cp ${REPO_ROOT}/1_data/output/* input

    # Run programs in order
    cd source
	run_python analyze_data.py ${LOGFILE}
	run_R analyze_data.R ${LOGFILE}
	run_stata analyze_data.do ${LOGFILE}

) 2>&1 | tee ${LOGFILE}


