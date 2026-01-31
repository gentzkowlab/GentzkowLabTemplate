#!/bin/bash   

# Trap to handle shell script errors 
trap 'error_handler' ERR
error_handler() {
    error_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "\n\033[0;31mWarning\033[0m: make.sh failed at ${error_time}. Check above for details." # display warning in terminal
    exit 1 # early exit with error code
}

# Set paths
# (Make sure REPO_ROOT is set to point to the root of the repository!)
MAKE_SCRIPT_DIR="$(cd "$(dirname -- "$0")" && pwd -P)"
REPO_ROOT="$(git rev-parse --show-toplevel)"
MODULE=$(basename "$MAKE_SCRIPT_DIR")
LOGFILE="${MAKE_SCRIPT_DIR}/output/make.log"

# Check setup
source "${REPO_ROOT}/lib/shell/check_setup.sh"

# Tell user what we're doing
echo -e "\n\nMaking module \033[35m${MODULE}\033[0m with shell ${SHELL}"

# Load settings & tools
source "${REPO_ROOT}/local_env.sh"
source "${REPO_ROOT}/lib/shell/run_shell.sh"
source "${REPO_ROOT}/lib/shell/run_python.sh"
source "${REPO_ROOT}/lib/shell/run_R.sh"
source "${REPO_ROOT}/lib/shell/run_julia.sh"
source "${REPO_ROOT}/lib/shell/run_matlab.sh"
source "${REPO_ROOT}/lib/shell/run_stata.sh"
source "${REPO_ROOT}/lib/shell/run_notebook.sh"
source "${REPO_ROOT}/lib/shell/run_rmd.sh"
source "${REPO_ROOT}/lib/shell/run_latex.sh"
source "${REPO_ROOT}/lib/shell/run_lyx.sh"
source "${REPO_ROOT}/lib/shell/run_pptx.sh"

# Clear output directory
# (Guarantees that all output is produced from a clean run of the code)
rm -rf "${MAKE_SCRIPT_DIR}/output"
mkdir -p "${MAKE_SCRIPT_DIR}/output"

# Add symlink input files to local /input/ directory
# (Make sure get_inputs.sh is updated to pull in all needed input files!)
(   cd "${MAKE_SCRIPT_DIR}"
    source "${MAKE_SCRIPT_DIR}/get_inputs.sh"
)

# Run scripts
# (Do this in a subshell so we return to the original working directory
# after scripts are run)
echo -e "\nmake.sh started at $(date '+%Y-%m-%d %H:%M:%S')"

(
cd "${MAKE_SCRIPT_DIR}/source"

echo -e "\n========================================="
echo "Testing Error Handling for run_* scripts"
echo "========================================="

# Test different error scenarios
# Uncomment ONE line below to test a specific run_* script

# Test Python error
echo -e "\n--- Testing Python error (should fail) ---"
run_python error.py "${LOGFILE}" || exit 1

# Test R error
# echo -e "\n--- Testing R error (should fail) ---"
# run_R error.r "${LOGFILE}" || exit 1

# Test Julia error
# echo -e "\n--- Testing Julia error (should fail) ---"
# run_julia error.jl "${LOGFILE}" || exit 1

# Test Shell error
# echo -e "\n--- Testing Shell error (should fail) ---"
# run_shell error.sh "${LOGFILE}" || exit 1

# Test MATLAB error
# echo -e "\n--- Testing MATLAB error (should fail) ---"
# run_matlab error.m "${LOGFILE}" || exit 1

# Test Stata error
# echo -e "\n--- Testing Stata error (should fail) ---"
# run_stata error.do "${LOGFILE}" || exit 1

# Test Jupyter Notebook error
# echo -e "\n--- Testing Notebook error (should fail) ---"
# run_notebook error.ipynb "${LOGFILE}" || exit 1

# Test R Markdown error
# echo -e "\n--- Testing R Markdown error (should fail) ---"
# run_rmd error.Rmd "${LOGFILE}" || exit 1

# Test LaTeX error
# echo -e "\n--- Testing LaTeX error (should fail) ---"
# run_latex error.tex "${LOGFILE}" || exit 1

# Test LyX error
# echo -e "\n--- Testing LyX error (should fail) ---"
# run_lyx error.lyx "${LOGFILE}" || exit 1

) || false

echo -e "\nmake.sh finished at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "${LOGFILE}"
